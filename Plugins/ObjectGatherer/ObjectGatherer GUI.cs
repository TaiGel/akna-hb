#region System Namespace
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
#endregion

namespace ObjectGatherer
{
    public partial class ObjectGatherer_Gui : Form {
        public ObjectGatherer_Gui() {
            InitializeComponent();
        }

        private void ObjectGatherer_Gui_Load(object sender, EventArgs e) {
            ObjectGatherer_Settings.Instance.Load();

            AGLC_CB.Checked = ObjectGatherer_Settings.Instance.AGLC_CB;
            DS_CB.Checked = ObjectGatherer_Settings.Instance.DS_CB;
            GC_CB.Checked = ObjectGatherer_Settings.Instance.GC_CB;
            IAMT_CB.Checked = ObjectGatherer_Settings.Instance.IAMT_CB;
            IAMTN_CB.Checked = ObjectGatherer_Settings.Instance.IAMTN_CB;
            NE_CB.Checked = ObjectGatherer_Settings.Instance.NE_CB;
            OE_CB.Checked = ObjectGatherer_Settings.Instance.OE_CB;
            TC_CB.Checked = ObjectGatherer_Settings.Instance.TC_CB;
            Q_CB.Checked = ObjectGatherer_Settings.Instance.Q_CB;
        }

        #region Button Settings
        private void button1_Click(object sender, EventArgs e)
        {
            MessageBox.Show("ObjectGatherer Settings have been saved.", "Save");
            ObjectGatherer_Settings.Instance.Save();
            ObjectGatherer.OGlog("Settings Saved");
            Close();
        }
        #endregion

        #region Links Settings
        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start("http://www.thebuddyforum.com/honorbuddy-forum/plugins/uncataloged/99699-plugin-objectgatherer.html");
            linkLabel1.LinkVisited = true;
        }
        private void linkLabel2_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7ZGWJEKMM7M9W");
            linkLabel2.LinkVisited = true;
        }
        #endregion

        #region Ancient Guo-Lai Cashe Settings
        private void AGLC_CB_CheckedChanged(object sender, EventArgs e) {
            ObjectGatherer_Settings.Instance.AGLC_CB = AGLC_CB.Checked;
        }
        #endregion

        #region Dark Soil Settings
        private void DS_CB_CheckedChanged(object sender, EventArgs e) {
            ObjectGatherer_Settings.Instance.DS_CB = DS_CB.Checked;
        }
        #endregion

        #region Gold Coins Settings
        private void GC_CB_CheckedChanged(object sender, EventArgs e) {
            ObjectGatherer_Settings.Instance.GC_CB = GC_CB.Checked;
        }
        #endregion

        #region Is Another Man's Treasure Settings
        private void IAMT_CB_CheckedChanged(object sender, EventArgs e)
        {
            ObjectGatherer_Settings.Instance.IAMT_CB = IAMT_CB.Checked;
        }
        #endregion

        #region Is Another Man's Treasure NPC's Settings
        private void IAMTN_CB_CheckedChanged(object sender, EventArgs e)
        {
            ObjectGatherer_Settings.Instance.IAMTN_CB = IAMTN_CB.Checked;
        }
        #endregion

        #region Netherwing Egg Settings
        private void NE_CB_CheckedChanged(object sender, EventArgs e)
        {
            ObjectGatherer_Settings.Instance.NE_CB = NE_CB.Checked;
        }
        #endregion

        #region Onyx Egg Settings
        private void OE_CB_CheckedChanged(object sender, EventArgs e)
        {
            ObjectGatherer_Settings.Instance.OE_CB = OE_CB.Checked;
        }
        #endregion

        #region Treasure Chests Settings
        private void TC_CB_CheckedChanged(object sender, EventArgs e)
        {
            ObjectGatherer_Settings.Instance.TC_CB = TC_CB.Checked;
        }
        #endregion

        #region Quests Settings
        private void Q_CB_CheckedChanged(object sender, EventArgs e)
        {
            ObjectGatherer_Settings.Instance.Q_CB = Q_CB.Checked;
        }
        #endregion
    }
}
