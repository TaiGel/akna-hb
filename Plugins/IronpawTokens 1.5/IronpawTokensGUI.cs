using System;
using System.Windows.Forms;

namespace IronpawTokens {
    public partial class IronpawTokensGui : Form {

        public IronpawTokensGui() {
            InitializeComponent();
        }

        #region Load Stored Settings
        private void IronpawTokensGuiLoad(object sender, EventArgs e) {
            IronpawTokensSettings.Instance.Load();
            Fish_ES.Checked  = IronpawTokensSettings.Instance.Fish_ES;
            Fish_JL.Checked  = IronpawTokensSettings.Instance.Fish_JL;
            Fish_GMS.Checked = IronpawTokensSettings.Instance.Fish_GMS;
            Fish_RO.Checked  = IronpawTokensSettings.Instance.Fish_RO;
            Fish_RM.Checked  = IronpawTokensSettings.Instance.Fish_RM;
            Fish_TG.Checked  = IronpawTokensSettings.Instance.Fish_TG;
            Fish_JD.Checked  = IronpawTokensSettings.Instance.Fish_JD;
            Fish_KP.Checked  = IronpawTokensSettings.Instance.Fish_KP;
            Fish_GC.Checked  = IronpawTokensSettings.Instance.Fish_GC;
            Meat_WB.Checked  = IronpawTokensSettings.Instance.Meat_WB;
            Meat_RTS.Checked = IronpawTokensSettings.Instance.Meat_RTS;
            Meat_RTM.Checked = IronpawTokensSettings.Instance.Meat_RTM;
            Meat_RCM.Checked = IronpawTokensSettings.Instance.Meat_RCM;
            Meat_MR.Checked  = IronpawTokensSettings.Instance.Meat_MR;
            Meat_RCB.Checked  = IronpawTokensSettings.Instance.Meat_RCB;
            Vege_JC.Checked  = IronpawTokensSettings.Instance.Vege_JC;
            Vege_SC.Checked  = IronpawTokensSettings.Instance.Vege_SC;
            Vege_GC.Checked  = IronpawTokensSettings.Instance.Vege_GC;
            Vege_MP.Checked  = IronpawTokensSettings.Instance.Vege_MP;
            Vege_RBL.Checked = IronpawTokensSettings.Instance.Vege_RBL;
            Vege_WB.Checked  = IronpawTokensSettings.Instance.Vege_WB;
            Vege_SM.Checked  = IronpawTokensSettings.Instance.Vege_SM;
            Vege_WT.Checked  = IronpawTokensSettings.Instance.Vege_WT;
            Vege_JS.Checked  = IronpawTokensSettings.Instance.Vege_JS;
            Vege_PT.Checked  = IronpawTokensSettings.Instance.Vege_PT;
        }
        #endregion

        #region SaveButton
        private void Save_Click(object sender, EventArgs e) {
            MessageBox.Show("Ironpaw Tokens Settings have been saved.", "Save");
            IronpawTokensSettings.Instance.Save();
            IronpawTokens.IpTlog("Settings Saved");
            IronpawTokens.ItemList = IronpawTokens.UpdateItemList();
            Close();
        }
        #endregion

        #region Fishes
        private void Fish_ES_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Fish_ES = Fish_ES.Checked; }
        private void Fish_JL_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Fish_JL = Fish_JL.Checked; }
        private void Fish_GMS_CheckedChanged(object sender, EventArgs e) { IronpawTokensSettings.Instance.Fish_GMS = Fish_GMS.Checked; }
        private void Fish_RO_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Fish_RO = Fish_RO.Checked; }
        private void Fish_RM_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Fish_RM = Fish_RM.Checked; }
        private void Fish_TG_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Fish_TG = Fish_TG.Checked; }
        private void Fish_JD_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Fish_JD = Fish_JD.Checked; }
        private void Fish_KP_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Fish_KP = Fish_KP.Checked; }
        private void Fish_GC_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Fish_GC = Fish_GC.Checked; }
        #endregion

        #region Meats
        private void Meat_WB_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Meat_WB = Meat_WB.Checked; }
        private void Meat_RTS_CheckedChanged(object sender, EventArgs e) { IronpawTokensSettings.Instance.Meat_RTS = Meat_RTS.Checked; }
        private void Meat_RTM_CheckedChanged(object sender, EventArgs e) { IronpawTokensSettings.Instance.Meat_RTM = Meat_RTM.Checked; }
        private void Meat_RCM_CheckedChanged(object sender, EventArgs e) { IronpawTokensSettings.Instance.Meat_RCM = Meat_RCM.Checked; }
        private void Meat_MR_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Meat_MR = Meat_MR.Checked; }
        private void Meat_CB_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Meat_RCB = Meat_RCB.Checked; }
        #endregion

        #region Vegetables
        private void Vege_JC_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Vege_JC = Vege_JC.Checked; }
        private void Vege_SC_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Vege_SC = Vege_SC.Checked; }
        private void Vege_GC_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Vege_GC = Vege_GC.Checked; }
        private void Vege_MP_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Vege_MP = Vege_MP.Checked; }
        private void Vege_RBL_CheckedChanged(object sender, EventArgs e) { IronpawTokensSettings.Instance.Vege_RBL = Vege_RBL.Checked; }
        private void Vege_WB_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Vege_WB = Vege_WB.Checked; }
        private void Vege_SM_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Vege_SM = Vege_SM.Checked; }
        private void Vege_WT_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Vege_WT = Vege_WT.Checked; }
        private void Vege_JS_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Vege_JS = Vege_JS.Checked; }
        private void Vege_PT_CheckedChanged(object sender, EventArgs e)  { IronpawTokensSettings.Instance.Vege_PT = Vege_PT.Checked; }
        #endregion
    }
}
