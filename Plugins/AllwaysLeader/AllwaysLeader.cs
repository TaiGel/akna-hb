#region Using
using System;
using System.Linq;

using Styx;
using Styx.Common;
using Styx.Plugins;
using Styx.WoWInternals;
using Styx.WoWInternals.WoWObjects;
#endregion

namespace AllwaysLeader {
    public class AllwaysLeader : HBPlugin {
        #region Variables
        public override string Name { get { return "AllwaysLeader"; } }
        public override string Author { get { return "AknA"; } }
        public override Version Version { get { return new Version(1, 0, 0); } }
        public static LocalPlayer Me { get { return StyxWoW.Me; } }
        private static bool _initialized;
        private string _BoosterName = Me.Name;
        #endregion

        #region Initialize
        public override void Initialize() {
            if (!_initialized) {
                _initialized = true;
                Logging.Write("[Allways Leader]: Ver {0} loaded.", Version);
            }
        }
        #endregion

        #region GetBoosterName
        private void GetBoosterName() {
            var nummember = StyxWoW.Me.GroupInfo.RaidMembers.Count();
            for (var i = 1; i <= nummember; i++) {
                if (Lua.GetReturnVal<int>(string.Format("return (select(4, GetRaidRosterInfo({0})))", i), 0) == 90) {
                    _BoosterName = Lua.GetReturnVal<string>(string.Format("return (select(1, GetRaidRosterInfo({0})))", i), 0);
                }
            }
        }
        #endregion

        #region Pulse
        public override void Pulse() {
            if ((Me.IsGroupLeader) && (StyxWoW.Me.GroupInfo.RaidMembers.Count() > 1) && (Me.Level != 90)) {
                GetBoosterName();
                Lua.DoString(string.Format("PromoteToLeader('{0}');", _BoosterName));
            }
        }
        #endregion
    }
}