#region System Namespace
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
#endregion

#region Styx Namespace
using Styx;
using Styx.Common;
using Styx.Helpers;
#endregion

namespace ObjectGatherer
{
    public class ObjectGatherer_Settings : Settings
    {
        public static readonly ObjectGatherer_Settings Instance = new ObjectGatherer_Settings();
        public ObjectGatherer_Settings()
            : base(Path.Combine(Path.Combine(Utilities.AssemblyDirectory, "Settings"), string.Format("ObjectGatherer-Settings-{0}.xml", StyxWoW.Me.Name)))
        {
        }

        #region Ancient Guo-Lai Cashe Settings
        [Setting, DefaultValue(true)]
        public bool AGLC_CB { get; set; }
        #endregion

        #region Dark Soil Settings
        [Setting, DefaultValue(true)]
        public bool DS_CB { get; set; }
        #endregion

        #region Gold Coins Settings
        [Setting, DefaultValue(true)]
        public bool GC_CB { get; set; }
        #endregion

        #region Is Another Man's Treasure Settings
        [Setting, DefaultValue(true)]
        public bool IAMT_CB { get; set; }
        #endregion

        #region Is Another Man's Treasure NPC's Settings
        [Setting, DefaultValue(true)]
        public bool IAMTN_CB { get; set; }
        #endregion

        #region Netherwing Egg Settings
        [Setting, DefaultValue(true)]
        public bool NE_CB { get; set; }
        #endregion

        #region Onyx Egg Settings
        [Setting, DefaultValue(true)]
        public bool OE_CB { get; set; }
        #endregion

        #region Treasure Chests Settings
        [Setting, DefaultValue(true)]
        public bool TC_CB { get; set; }
        #endregion

        #region Quests Settings
        [Setting, DefaultValue(true)]
        public bool Q_CB { get; set; }
        #endregion
        
        #region Skin/Herb/Mine Corpses Settings
        [Setting, DefaultValue(true)]
        public bool SHMC_CB { get; set; }
        #endregion
    }
}
