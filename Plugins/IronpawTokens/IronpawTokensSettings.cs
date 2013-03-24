#region System Namespace
using System.IO;
#endregion

#region Styx Namespace
using Styx;
using Styx.Common;
using Styx.Helpers;
#endregion

namespace IronpawTokens {
    public class IronpawTokensSettings : Settings {
        public static readonly IronpawTokensSettings Instance = new IronpawTokensSettings();

        public IronpawTokensSettings() : base( Path.Combine(Path.Combine(Utilities.AssemblyDirectory, "Settings"), string.Format("IronpawTokens-Settings-{0}.xml", StyxWoW.Me.Name))) { }

        #region Fishes Settings
        [Setting, DefaultValue(false)]
        public bool Fish_ES { get; set; }

        [Setting, DefaultValue(false)]
        public bool Fish_JL { get; set; }

        [Setting, DefaultValue(false)]
        public bool Fish_GMS { get; set; }
        
        [Setting, DefaultValue(false)]
        public bool Fish_RO { get; set; }

        [Setting, DefaultValue(false)]
        public bool Fish_RM { get; set; }

        [Setting, DefaultValue(false)]
        public bool Fish_TG { get; set; }

        [Setting, DefaultValue(false)]
        public bool Fish_JD { get; set; }

        [Setting, DefaultValue(false)]
        public bool Fish_KP { get; set; }

        [Setting, DefaultValue(false)]
        public bool Fish_GC { get; set; }
        #endregion

        #region Meats Settings
        [Setting, DefaultValue(false)]
        public bool Meat_WB { get; set; }

        [Setting, DefaultValue(false)]
        public bool Meat_RTS { get; set; }

        [Setting, DefaultValue(false)]
        public bool Meat_RTM { get; set; }

        [Setting, DefaultValue(false)]
        public bool Meat_RCM { get; set; }

        [Setting, DefaultValue(false)]
        public bool Meat_MR { get; set; }

        [Setting, DefaultValue(false)]
        public bool Meat_RCB { get; set; }
        #endregion

        #region Vegetables Settings
        [Setting, DefaultValue(false)]
        public bool Vege_JC { get; set; }

        [Setting, DefaultValue(false)]
        public bool Vege_SC { get; set; }

        [Setting, DefaultValue(false)]
        public bool Vege_GC { get; set; }

        [Setting, DefaultValue(false)]
        public bool Vege_MP { get; set; }

        [Setting, DefaultValue(false)]
        public bool Vege_RBL { get; set; }

        [Setting, DefaultValue(false)]
        public bool Vege_WB { get; set; }

        [Setting, DefaultValue(false)]
        public bool Vege_SM { get; set; }

        [Setting, DefaultValue(false)]
        public bool Vege_WT { get; set; }

        [Setting, DefaultValue(false)]
        public bool Vege_JS { get; set; }

        [Setting, DefaultValue(false)]
        public bool Vege_PT { get; set; }
        #endregion
    }
}
