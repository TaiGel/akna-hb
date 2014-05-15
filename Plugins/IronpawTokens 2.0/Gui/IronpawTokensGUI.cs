using System;
using System.Windows.Forms;

namespace IronpawTokens.Gui {
    public partial class IronpawTokensGui : Form
    {

        public IronpawTokensGui()
        {
            InitializeComponent();
        }

        private void IronpawTokensGuiLoad(object sender, EventArgs e)
        {
            Settings.IronpawTokensSettings.Instance.Load();
            EmperorSalmonCheckBox.Checked = Settings.IronpawTokensSettings.Instance.EmperorSalmon;
            JadeLungfishCheckBox.Checked = Settings.IronpawTokensSettings.Instance.JadeLungfish;
            GiantMantisShrimpCheckBox.Checked = Settings.IronpawTokensSettings.Instance.GiantMantisShrimp;
            ReefOctopusCheckBox.Checked = Settings.IronpawTokensSettings.Instance.ReefOctopus;
            RedbellyMandarinCheckBox.Checked = Settings.IronpawTokensSettings.Instance.RedbellyMandarin;
            TigerGouramiCheckBox.Checked = Settings.IronpawTokensSettings.Instance.TigerGourami;
            JewelDanioCheckBox.Checked = Settings.IronpawTokensSettings.Instance.JewelDanio;
            KrasarangPaddlefishCheckBox.Checked = Settings.IronpawTokensSettings.Instance.KrasarangPaddlefish;
            GoldenCarpCheckBox.Checked = Settings.IronpawTokensSettings.Instance.GoldenCarp;
            WildfowlBreastCheckBox.Checked = Settings.IronpawTokensSettings.Instance.WildfowlBreast;
            RawTigerSteakCheckBox.Checked = Settings.IronpawTokensSettings.Instance.RawTigerSteak;
            RawTurtleMeatCheckBox.Checked = Settings.IronpawTokensSettings.Instance.RawTurtleMeat;
            RawCrabMeatCheckBox.Checked = Settings.IronpawTokensSettings.Instance.RawCrabMeat;
            MushanRibsCheckBox.Checked = Settings.IronpawTokensSettings.Instance.MushanRibs;
            RawCrocoliskBellyCheckBox.Checked = Settings.IronpawTokensSettings.Instance.RawCrocoliskBelly;
            JuicycrunchCarrotCheckBox.Checked = Settings.IronpawTokensSettings.Instance.JuicycrunchCarrot;
            ScallionsCheckBox.Checked = Settings.IronpawTokensSettings.Instance.Scallions;
            GreenCabbageCheckBox.Checked = Settings.IronpawTokensSettings.Instance.GreenCabbage;
            MoguPumpkinCheckBox.Checked = Settings.IronpawTokensSettings.Instance.MoguPumpkin;
            RedBlossomLeekCheckBox.Checked = Settings.IronpawTokensSettings.Instance.RedBlossomLeek;
            WitchberriesCheckBox.Checked = Settings.IronpawTokensSettings.Instance.Witchberries;
            StripedMelonCheckBox.Checked = Settings.IronpawTokensSettings.Instance.StripedMelon;
            WhiteTurnipCheckBox.Checked = Settings.IronpawTokensSettings.Instance.WhiteTurnip;
            JadeSquashCheckBox.Checked = Settings.IronpawTokensSettings.Instance.JadeSquash;
            PinkTurnipCheckBox.Checked = Settings.IronpawTokensSettings.Instance.PinkTurnip;
        }

        private void EmperorSalmonCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.EmperorSalmon = EmperorSalmonCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void JadeLungfishCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.JadeLungfish = JadeLungfishCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void GiantMantisShrimpCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.GiantMantisShrimp = GiantMantisShrimpCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void ReefOctopusCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.ReefOctopus = ReefOctopusCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void RedbellyMandarinCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.RedbellyMandarin = RedbellyMandarinCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void TigerGouramiCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.TigerGourami = TigerGouramiCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void JewelDanioCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.JewelDanio = JewelDanioCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void KrasarangPaddlefishCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.KrasarangPaddlefish = KrasarangPaddlefishCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void GoldenCarpCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.GoldenCarp = GoldenCarpCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void WildfowlBreastCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.WildfowlBreast = WildfowlBreastCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void RawTigerSteakCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.RawTigerSteak = RawTigerSteakCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void RawTurtleMeatCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.RawTurtleMeat = RawTurtleMeatCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void RawCrabMeatCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.RawCrabMeat = RawCrabMeatCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void MushanRibsCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.MushanRibs = MushanRibsCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void RawCrocoliskBellyCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.RawCrocoliskBelly = RawCrocoliskBellyCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void JuicycrunchCarrotCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.JuicycrunchCarrot = JuicycrunchCarrotCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void ScallionsCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.Scallions = ScallionsCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void GreenCabbageCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.GreenCabbage = GreenCabbageCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void MoguPumpkinCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.MoguPumpkin = MoguPumpkinCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void RedBlossomLeekCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.RedBlossomLeek = RedBlossomLeekCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void WitchberriesCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.Witchberries = WitchberriesCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void StripedMelonCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.StripedMelon = StripedMelonCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void WhiteTurnipCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.WhiteTurnip = WhiteTurnipCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void JadeSquashCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.JadeSquash = JadeSquashCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }

        private void PinkTurnipCheckBox_CheckedChanged(object sender, EventArgs e) {
            Settings.IronpawTokensSettings.Instance.PinkTurnip = PinkTurnipCheckBox.Checked;
            Settings.IronpawTokensSettings.Instance.Save();
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
        }
    }
}
