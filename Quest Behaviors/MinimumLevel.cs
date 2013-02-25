// Behavior originally contributed by AknA.
// This is a variation of LoadProfile QB.
// Custom behavior created for Liquid Zebra.
// MinimumLevel is a Quest Behavior developed to change profile if the levels of your partymembers are high enough.
// 
// To use the QB : 
// <CustomBehavior File="Misc\MinimumLevel" MinLevel="1" NextProfile="blahblah.xml" />
//
using System;
using System.Collections.Generic;
using System.IO;
using System.Windows.Media;

using Styx.Common;
using Styx.CommonBot;
using Styx.CommonBot.Profiles;
using Styx.TreeSharp;
using Styx.WoWInternals.WoWObjects;

using CommonBehaviors.Actions;
using Action = Styx.TreeSharp.Action;


namespace Styx.Bot.Quest_Behaviors {
    /// <summary>
    /// MinimumLevel by AknA
    /// ##Syntax##
    /// MinLevel: int (minimum level of your party members)
    /// NextProfile: filename.xml (path and name of the profile to load)
    /// </summary>
    public class MinimumLevel : CustomForcedBehavior {
        public MinimumLevel(Dictionary<string, string> args)
		: base(args) {
            try {
                MinLevel = GetAttributeAsNullable("MinLevel", true, ConstrainAs.Milliseconds, null) ?? 1;
                NextProfile = GetAttributeAs("NextProfile", true, ConstrainAs.StringNonEmpty, null) ?? "";
            }

            catch (Exception except) {
                // Maintenance problems occur for a number of reasons.  The primary two are...
                // * Changes were made to the behavior, and boundary conditions weren't properly tested.
                // * The Honorbuddy core was changed, and the behavior wasn't adjusted for the new changes.
                // In any case, we pinpoint the source of the problem area here, and hopefully it
                // can be quickly resolved.
                LogMessage("error", "BEHAVIOR MAINTENANCE PROBLEM: " + except.Message
                                    + "\nFROM HERE:\n"
                                    + except.StackTrace + "\n");
                IsAttributeProblem = true;
            }
        }

        // Attributes provided by caller
        public int MinLevel { get; private set; }
        public string NextProfile { get; private set; }

        // Private variables for internal state
        private bool _isBehaviorDone;
        private bool _isDisposed;
        public static LocalPlayer Me { get { return StyxWoW.Me; } }
        private String CurrentProfile { get { return (ProfileManager.XmlLocation); } }
        private String NewProfilePath { get {
            string directory = Path.GetDirectoryName(CurrentProfile);
            return (Path.Combine(directory, NextProfile));
        } }


        ~MinimumLevel() {
            Dispose(false);
        }

        public void Dispose(bool isExplicitlyInitiatedDispose) {
            if (!_isDisposed) {
                // NOTE: we should call any Dispose() method for any managed or unmanaged
                // resource, if that resource provides a Dispose() method.

                // Clean up managed resources, if explicit disposal...
                if (isExplicitlyInitiatedDispose) { }  // empty, for now

                // Clean up unmanaged resources (if any) here...

                // Call parent Dispose() (if it exists) here ...
                base.Dispose();
            }

            _isDisposed = true;
        }

        public bool CheckLevel() {
            foreach (var groupMember in StyxWoW.Me.GroupInfo.RaidMembers) {
                WoWPlayer player = groupMember.ToPlayer();
                var level = player != null ? player.Level : groupMember.Level;
                if (level < MinLevel) { return false; }
            }
            if (Me.Level < MinLevel) { return false; }
            return true;
        }


        #region Overrides of CustomForcedBehavior

        protected override Composite CreateBehavior() {
            return (
                new PrioritySelector(
                    // Behavior is done.
                    new Decorator(ret => _isBehaviorDone,
                        new Action(delegate {
                            Logging.Write(Colors.DeepSkyBlue, "[MinimumLevel]: Behavior done.");
                    })),

                    // If not all partymembers is above level.
                    new Decorator(ret => !CheckLevel(),
                        new Action(delegate { _isBehaviorDone = true; })
                    ),

                    // If file does not exist, notify of problem...
                    new Decorator(ret => !File.Exists(NewProfilePath),
                        new Action(delegate {
                            Logging.Write(Colors.Red, "[MinimumLevel]: Profile '{0}' does not exist.", NewProfilePath);
                            _isBehaviorDone = true;
                    })),

                    // Load the specified profile...
                    new Sequence(
                        new Action(delegate {
                            TreeRoot.StatusText = "Loading profile '" + NewProfilePath + "'";
                            Logging.Write(Colors.DeepSkyBlue, "[MinimumLevel]: Loading profile '{0}'", NextProfile);
                            ProfileManager.LoadNew(NewProfilePath, false);
                        }),
                        new WaitContinue(TimeSpan.FromMilliseconds(300), ret => false, new ActionAlwaysSucceed()),
                        new Action(delegate { _isBehaviorDone = true; })
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

            if (!IsDone) { }
        }
        #endregion
    }
}
