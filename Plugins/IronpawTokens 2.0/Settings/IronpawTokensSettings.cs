using System.IO;
using Styx;
using Styx.Common;
using Styx.Helpers;

namespace IronpawTokens.Settings {
    public class IronpawTokensSettings : Styx.Helpers.Settings {
        public static readonly IronpawTokensSettings Instance = new IronpawTokensSettings();

        public IronpawTokensSettings() : base( Path.Combine(Path.Combine(Utilities.AssemblyDirectory, "Settings"), string.Format("IronpawTokens-Settings-{0}.xml", StyxWoW.Me.Name))) { }

        [Setting, DefaultValue(false)]
        public bool EmperorSalmon { get; set; }

        [Setting, DefaultValue(false)]
        public bool JadeLungfish { get; set; }

        [Setting, DefaultValue(false)]
        public bool GiantMantisShrimp { get; set; }
        
        [Setting, DefaultValue(false)]
        public bool ReefOctopus { get; set; }

        [Setting, DefaultValue(false)]
        public bool RedbellyMandarin { get; set; }

        [Setting, DefaultValue(false)]
        public bool TigerGourami { get; set; }

        [Setting, DefaultValue(false)]
        public bool JewelDanio { get; set; }

        [Setting, DefaultValue(false)]
        public bool KrasarangPaddlefish { get; set; }

        [Setting, DefaultValue(false)]
        public bool GoldenCarp { get; set; }

        [Setting, DefaultValue(false)]
        public bool WildfowlBreast { get; set; }

        [Setting, DefaultValue(false)]
        public bool RawTigerSteak { get; set; }

        [Setting, DefaultValue(false)]
        public bool RawTurtleMeat { get; set; }

        [Setting, DefaultValue(false)]
        public bool RawCrabMeat { get; set; }

        [Setting, DefaultValue(false)]
        public bool MushanRibs { get; set; }

        [Setting, DefaultValue(false)]
        public bool RawCrocoliskBelly { get; set; }

        [Setting, DefaultValue(false)]
        public bool JuicycrunchCarrot { get; set; }

        [Setting, DefaultValue(false)]
        public bool Scallions { get; set; }

        [Setting, DefaultValue(false)]
        public bool GreenCabbage { get; set; }

        [Setting, DefaultValue(false)]
        public bool MoguPumpkin { get; set; }

        [Setting, DefaultValue(false)]
        public bool RedBlossomLeek { get; set; }

        [Setting, DefaultValue(false)]
        public bool Witchberries { get; set; }

        [Setting, DefaultValue(false)]
        public bool StripedMelon { get; set; }

        [Setting, DefaultValue(false)]
        public bool WhiteTurnip { get; set; }

        [Setting, DefaultValue(false)]
        public bool JadeSquash { get; set; }

        [Setting, DefaultValue(false)]
        public bool PinkTurnip { get; set; }
    }
}
