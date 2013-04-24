#region Information
// Behavior originally contributed by AknA.
// Custom behavior created for Liquid Zebra.
// 
// Examples :
// This would load the profile mysite.com/blahblah.xml if all partymembers are above level 90 and within interact range of you.
// <CustomBehavior File="Misc\RemoteLoader" MinLevel="90" CheckRange="1" ProfileName="blahblah.xml" RemotePath="http://mysite.com/" />
// This would load the profile blahblah.xml (from the same directory as you last localy loaded) if everyone in your party is above level 5.
// <CustomBehavior File="Misc\RemoteLoader" MinLevel="5" ProfileName="blahblah.xml" />
// This would make the profile pause until all party members are within interactrange (and then continue the profile).
// <CustomBehavior File="Misc\RemoteLoader" CheckRange="1" />
//
// MinLevel    : (OPTIONAL) If not everyone in your party (including yourself) is above level then QB will exit doing nothing.
// CheckRange  : (OPTIONAL, default = 0) If set to 1 QB will pause the profile until every party member is within your interact range.
// ProfileName : (OPTIONAL) Name of the profile to load (If RemotePath isn't included then the profile to load must be in the same directory as previous profile).
// RemotePath  : (OPTIONAL) URL to where you have your remote profile stored.
//
// Special thanks to Natfoth for helping me understand and improving my Behavior Tree programming.
#endregion

#region using
using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Windows.Media;

using Styx.Common;
using Styx.CommonBot;
using Styx.CommonBot.Profiles;
using Styx.TreeSharp;
using Styx.WoWInternals;
using Styx.WoWInternals.WoWObjects;

using CommonBehaviors.Actions;
using Action = Styx.TreeSharp.Action;
#endregion

namespace Styx.Bot.Quest_Behaviors {
    [CustomBehaviorFileName(@"Misc\RemoteLoader")]
    public class RemoteLoader : CustomForcedBehavior {
        public RemoteLoader(Dictionary<string, string> args)
            : base(args) {
            try {
                MinLevel = GetAttributeAsNullable("MinLevel", false, ConstrainAs.Milliseconds, null) ?? 0;
                CheckRange = GetAttributeAsNullable("CheckRange", false, ConstrainAs.Milliseconds, null) ?? 0;
                ProfileName = GetAttributeAs("ProfileName", false, ConstrainAs.StringNonEmpty, null) ?? "";
                RemotePath = GetAttributeAs(@"RemotePath", false, ConstrainAs.StringNonEmpty, null) ?? "";
            }

            catch (Exception except) {
                LogMessage("error", "BEHAVIOR MAINTENANCE PROBLEM: " + except.Message
                                    + "\nFROM HERE:\n"
                                    + except.StackTrace + "\n");
                IsAttributeProblem = true;
            }
        }

        #region Variables
        // Attributes provided by caller
        public int MinLevel { get; private set; }
        public int CheckRange { get; private set; }
        public string ProfileName { get; private set; }
        public string RemotePath { get; private set; }

        // Private variables for internal state
        private static bool _isBehaviorDone;
        private bool _IsDisposed;
        private Composite _Root;
        public static LocalPlayer Me { get { return StyxWoW.Me; } }
        private String CurrentProfile { get { return (ProfileManager.XmlLocation); } }
        private String NewLocalProfilePath {
            get { return (Path.Combine(Path.GetDirectoryName(CurrentProfile), ProfileName)); }
        }
        private String NewRemoteProfilePath {
            get { return (Path.Combine(RemotePath, ProfileName)); }
        }
        #endregion

        #region Dispose
        ~RemoteLoader() { Dispose(false); }

        public void Dispose(bool isExplicitlyInitiatedDispose) {
            if (!_IsDisposed) {
                // NOTE: we should call any Dispose() method for any managed or unmanaged
                // resource, if that resource provides a Dispose() method.

                // Clean up managed resources, if explicit disposal...
                if (isExplicitlyInitiatedDispose) { }  // empty, for now

                // Clean up unmanaged resources (if any) here...
                BotEvents.OnBotStop -= BotEvents_OnBotStop;
                _isBehaviorDone = false;

                // Call parent Dispose() (if it exists) here ...
                base.Dispose();
            }
            _IsDisposed = true;
        }

        public void BotEvents_OnBotStop(EventArgs args) { Dispose(); }
        #endregion

        #region Methods
        private bool CheckLevel() {
            foreach (var groupMember in StyxWoW.Me.GroupInfo.RaidMembers) {
                var player = groupMember.ToPlayer();
                var level = player != null ? player.Level : groupMember.Level;
                if (level < MinLevel) { return false; }
            }
            if (Me.Level < MinLevel) { return false; }
            return true;
        }

        private bool CheckPartyRange() {
            foreach (var groupMember in StyxWoW.Me.GroupInfo.RaidMembers) {
                var player = groupMember.ToPlayer();
                if (player != null) {
                    var loc = WoWMovement.CalculatePointFrom(player.Location, player.InteractRange);
                    if (loc.Distance(Me.Location) > player.InteractRange) { return false; }
                }
            }
            return true;
        }

        static private bool UrlExists(string url) {
            var a = true;
            var fileExists = WebRequest.Create(new Uri(url));
            fileExists.Method = "HEAD";
            fileExists.Timeout = 30000;
            try {
                using (fileExists.GetResponse()) { }
            }
            catch (WebException request) {
                Logging.WriteDiagnostic(Colors.Red, request.Message);
                a = false;
            }
            return a;
        }
        #endregion

        #region Overrides of CustomForcedBehavior
        protected override Composite CreateBehavior() {
            return _Root ?? (_Root =
                new PrioritySelector(context => !_isBehaviorDone,
                    // Should we check for partymember minumum level ?
                    new Decorator(context => (MinLevel > 0),
                        new Sequence(
                            // Someone is below MinLevel.
                            new DecoratorContinue(context => !CheckLevel(),
                                new Sequence(
                                    new Action(context => Logging.Write(Colors.DeepSkyBlue, string.Format("[RemoteLoader]: Someone in your party is below level {0}.", MinLevel))),
                                    new Action(context => _isBehaviorDone = true)
                                )
                            ),
                            // Everyone is equal or above MinLevel.
                            new DecoratorContinue(context => CheckLevel(),
                                new Action(context => MinLevel = 0)
                            )
                        )
                    ),

                    // Should we wait for party members to be in range ?
                    new Decorator(context => (CheckRange != 0),
                        new Sequence(
                            // Everyone isn't within interact range, lets wait abit before checking again.
                            new DecoratorContinue(context => !CheckPartyRange(),
                                new WaitContinue(TimeSpan.FromMilliseconds(300), context => false, new ActionAlwaysSucceed())
                            ),
                            // Everyone is within interact range.
                            new DecoratorContinue(context => CheckPartyRange(),
                                new Sequence(
                                    new Action(context => Logging.Write(Colors.DeepSkyBlue, "[RemoteLoader]: Everyone is within range.")),
                                    new Action(context => CheckRange = 0)
                                )
                            )
                        )
                    ),

                    // Load the remote profile...
                    new Decorator(context => RemotePath != "",
                        new Sequence(
                            // You have included a RemotePath but not a ProfileName.
                            new DecoratorContinue(context => ProfileName == "",
                                new Sequence(
                                    new Action(context => Logging.Write(Colors.Red, "[RemoteLoader]: You need to include a ProfileName.")),
                                    new Action(context => _isBehaviorDone = true)
                                )
                            ),
                            // Remote Profile doesn't exist.
                            new DecoratorContinue(context => (ProfileName != "" && !UrlExists(NewRemoteProfilePath)),
                                new Sequence(
                                    new Action(context => Logging.Write(Colors.Red, "[RemoteLoader]: Profile '{0}' does not exist.", ProfileName)),
                                    new Action(context => _isBehaviorDone = true)
                                )
                            ),
                            // Everything is ok, Load the remote Profile
                            new DecoratorContinue(context => (ProfileName != "" && UrlExists(NewRemoteProfilePath)),
                                new Sequence(
                                    new Action(context => TreeRoot.StatusText = "Loading profile '" + ProfileName + "'"),
                                    new Action(context => Logging.Write(Colors.DeepSkyBlue, "[RemoteLoader]: Loading profile '{0}'", ProfileName)),
                                    new Action(context => ProfileManager.LoadNew(new MemoryStream(new WebClient().DownloadData(NewRemoteProfilePath)))),
                                    new WaitContinue(TimeSpan.FromMilliseconds(300), context => false, new ActionAlwaysSucceed()),
                                    new Action(context => _isBehaviorDone = true)
                                )
                            )
                        )
                    ),

                    // Load the local profile...
                    new Decorator(context => (ProfileName != "" && RemotePath == ""),
                        new Sequence(
                            // Local Profile doesn't exist.
                            new DecoratorContinue(context => !File.Exists(NewLocalProfilePath),
                                new Sequence(
                                    new Action(context => Logging.Write(Colors.Red, "[RemoteLoader]: Profile '{0}' does not exist.", ProfileName)),
                                    new Action(context => _isBehaviorDone = true)
                                )
                            ),
                            // Everything is ok, Load the local Profile.
                            new DecoratorContinue(context => File.Exists(NewLocalProfilePath),
                                new Sequence(
                                    new Action(context => TreeRoot.StatusText = "Loading profile '" + ProfileName + "'"),
                                    new Action(context => Logging.Write(Colors.DeepSkyBlue, "[RemoteLoader]: Loading profile '{0}'", ProfileName)),
                                    new Action(context => ProfileManager.LoadNew(NewLocalProfilePath, false)),
                                    new WaitContinue(TimeSpan.FromMilliseconds(300), context => false, new ActionAlwaysSucceed()),
                                    new Action(context => _isBehaviorDone = true)
                                )
                            )
                        )
                    ),

                    // Everyone is within interact range and we shouldn't load a profile, then end the Quest Behavior.
                    new Decorator(context => !_isBehaviorDone,
                        new Action(context => _isBehaviorDone = true)
                    )
                )
            );
        }

        public override void Dispose() {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        public override bool IsDone { get { return _isBehaviorDone; } }

        public override void OnStart() {
            // This reports problems, and stops BT processing if there was a problem with attributes...
            // We had to defer this action, as the 'profile line number' is not available during the element's
            // constructor call.
            OnStart_HandleAttributeProblem();

            if (!IsDone) {
                BotEvents.OnBotStop += BotEvents_OnBotStop;
            }
        }
        #endregion
    }
}
