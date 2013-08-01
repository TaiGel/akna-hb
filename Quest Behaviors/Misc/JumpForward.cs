#region Information
// Behavior originally contributed by AknA.
// A simple Jump Forward QB.
#endregion

#region Using
using System;
using System.Collections.Generic;

using Styx.Common;
using Styx.CommonBot.Profiles;
using Styx.Helpers;
using Styx.TreeSharp;

using CommonBehaviors.Actions;
using Action = Styx.TreeSharp.Action;
#endregion

namespace Styx.Bot.Quest_Behaviors {
    [CustomBehaviorFileName(@"Misc\JumpForward")]
    public class JumpForward : CustomForcedBehavior {
        public JumpForward(Dictionary<string, string> args)
            : base(args) { }

        #region Variables
        // Attributes provided by caller

        // Private variables for internal state
        private static bool _isBehaviorDone;
        private bool _IsDisposed;
        private Composite _Root;
        public WoWPoint MyHotSpot = WoWPoint.Empty;
        #endregion

        #region Dispose
        ~JumpForward() { Dispose(false); }

        public void Dispose(bool isExplicitlyInitiatedDispose) {
            if (!_IsDisposed) {
                // NOTE: we should call any Dispose() method for any managed or unmanaged
                // resource, if that resource provides a Dispose() method.

                // Clean up managed resources, if explicit disposal...
                if (isExplicitlyInitiatedDispose) { }  // empty, for now

                // Clean up unmanaged resources (if any) here...
                _isBehaviorDone = false;

                // Call parent Dispose() (if it exists) here ...
                base.Dispose();
            }
            _IsDisposed = true;
        }

        public override void Dispose() {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
        
        public void BotEvents_OnBotStop(EventArgs args) { Dispose(); }
        #endregion

        #region Overrides of CustomForcedBehavior
        protected override Composite CreateBehavior() {
            return _Root ?? (_Root =
                new PrioritySelector(
                    new Decorator(context => !StyxWoW.Me.IsMoving,
                        new Sequence(
                            new Action(context => Logging.Write("Moving Forward.")),
                            new Action(context => KeyboardManager.PressKey((char)KeyboardManager.eVirtualKeyMessages.VK_UP)),
                            new WaitContinue(TimeSpan.FromMilliseconds(50), context => false, new ActionAlwaysSucceed()),
                            new Action(context => Logging.Write("Jumping.")),
                            new Action(context => KeyboardManager.PressKey((char)KeyboardManager.eVirtualKeyMessages.VK_SPACE)),
                            new WaitContinue(TimeSpan.FromMilliseconds(200), context => false, new ActionAlwaysSucceed()),
                            new Action(context => KeyboardManager.ReleaseKey((char)KeyboardManager.eVirtualKeyMessages.VK_SPACE)),
                            new WaitContinue(TimeSpan.FromMilliseconds(50), context => false, new ActionAlwaysSucceed()),
                            new Action(context => KeyboardManager.ReleaseKey((char)KeyboardManager.eVirtualKeyMessages.VK_UP)),
                            new WaitContinue(TimeSpan.FromMilliseconds(50), context => false, new ActionAlwaysSucceed()),
                            new Action(context => _isBehaviorDone = true)
                        )
                    )
                )
            );
        }

        public override bool IsDone { get { return _isBehaviorDone; } }

        public override void OnStart()
        {
            // This reports problems, and stops BT processing if there was a problem with attributes...
            // We had to defer this action, as the 'profile line number' is not available during the element's
            // constructor call.
            OnStart_HandleAttributeProblem();

            if (!IsDone) { }
        }
        #endregion
    }
}
