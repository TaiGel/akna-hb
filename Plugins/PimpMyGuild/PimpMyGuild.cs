using System;
using Styx.CommonBot;
using Styx.Plugins;
using Styx.WoWInternals;

namespace PimpMyGuild {
    public class PimpMyGuild : HBPlugin {
        public override string Name { get { return "PimpMyGuild"; } }
        public override string Author { get { return "Sidalol and AknA"; } }
        public override Version Version { get { return _version; } }
        private readonly Version _version = new Version(4, 0, 0, 1);
        private static string _lastInvite = "";
        private static string _nextInvite = "";
        private static bool _initialized;

        public override void OnEnable() {
            if(_initialized) {
                return;
            }

            _initialized = true;
            BotEvents.OnBotStarted += BotEvent_OnBotStarted;
        }

        public void BotEvent_OnBotStarted(EventArgs args) {
            Lua.DoString("PMGStartSuperScan()");
        }

        public override void Pulse() {
            var countInvites = Lua.GetReturnVal<int>(string.Format("return PMGCount()"), 0);
            if(countInvites <= 0) {
                return;
            }

            _nextInvite = Lua.GetReturnVal<string>(string.Format("return PMGGetNameInvite()"), 0);
            if(_nextInvite == _lastInvite) {
                return;
            }

            Lua.DoString("GuildInvite(\"" + _nextInvite + "\")");
            Lua.DoString(string.Format("PMGGuildInvite(\"{0}\")", _nextInvite), 0);
            _lastInvite = _nextInvite;
        }
    }
}