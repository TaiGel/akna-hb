#region Information
/* 
 * ObjectGatherer by AknA
 * 
 * Original idea by LiquidAtoR but I decided to recode what he had done and make
 * a whole new plugin.
 * 
 * Special thanks to chinajade and Inrego for your endless help with my silly questions.
 * And to BarryDurex for the avoid logics.
 * 
 * Ver 0.53 Beta
 * First official Beta testing stage.
 * 
 * Ver 0.57 Beta
 * Fixed a spamming issues with Logging.Write if you're exalted with a faction.
 * Fixed the interact timer.
 * 
 * Ver 0.58 Beta
 * Tweaked the timer logic abit more.
 * 
 * Ver 0.60 Beta
 * Just found out that HB had a Stopwatch() function (yes, I'm a retard).
 * Added the NPC id's for Lost And Found achievement (not working yet tho)
 * 
 * Ver 0.63 Beta
 * Reworked the Interact behavior after some testing, it should work now (I hope).
 * Fixed some Logging.Write spamming issues.
 * 
 * Ver 0.69 Beta
 * Implemented the blacklist again with a new logic, hopefully it should work.
 * Removed some Logging.Write spam as that part of the plugin is working.
 * Removed alot of not needed code to optimate plugin some more :)
 * 
 * Ver 1.00
 * No more Beta :)
 * Figued out a way to check if the object we found can be looted (no need for faction check).
 * So don't need to wait for HonorBuddy to be updated before taking this out of Beta.
 * Everything should work now after my own testing. (Still report if it doesn't.)
 * So now I can concentrate on adding new features instead.
 * 
 * Ver 1.10
 * Added logic for WoWUnit as well.
 * Should be able to interact with the npc's for the Lost and Found achievement now.
 * Added all 5 npc id's for the Lost and Found achievement.
 * Allso improved the interact logic to not clear the waypoint until we're sure we have looted/interacted.
 * 
 * Ver 1.20
 * Fixed the issues that I broke the plugin with last update (thanks chinajade)
 * Improved the code alot.
 * Now everything should work (I hope), npc interact is still untested.
 * Added Gold Coins by request.
 * 
 * Ver 1.21
 * Finaly found a NPC, it interacted but didn't select gossip option correctly, testing a new method.
 * Select Gossip option (1) is still untested, please report if it works or not for you.
 * Allso recoded the interact logic abit.
 * 
 * Ver 1.25
 * NPC interact is now working, had to do a lua script for it to work correct but atleast it's working now.
 * Updated MoveTo to include both Navigator and Flightor to improve the logic abit more.
 * Added aditional checks to clear the waypoint if we are dead, ghost or in combat, hopefully it works now.
 * 
 * Ver 1.30
 * GUI has been added. (However the settings doesn't change anything yet :P)
 * Added a new cathegory for Quests and added a few items (if it's any quest items you want me to add please comment)
 * Tweaks in the move to logic and more checks to clear waypoint if it takes too long etc.
 * 
 * Ver 1.31
 * All the settings in the GUI is finaly working, now you can choose if you want the plugin to not search for a itemgroup.
 * 
 * Ver 1.35
 * Added the option to Skin / Herb / Mine corpses if you have the ability to do so (BETA!!!) as requested.
 * 
 * Ver 1.40
 * Now the option to Skin / Herb / Mine corpses if you have the profession should work.
 * 
 * Ver 1.41
 * Tweaked the moveto logic (forgot to add the check for SpecialToFind).
 */
#endregion

#region Styx Namespace
using Styx;
using Styx.Common;
using Styx.CommonBot;
using Styx.Pathing;
using Styx.Plugins;
using Styx.WoWInternals;
using Styx.WoWInternals.WoWObjects;
#endregion Styx Namespace

#region System Namespace
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Windows.Media;
#endregion System Namespace

namespace ObjectGatherer {
    public class ObjectGatherer : HBPlugin {
        #region Variables
        public override string Name { get { return "ObjectGatherer"; } }
        public override string Author { get { return "AknA"; } }
        public override Version Version { get { return new Version(1, 4, 1); } }
        public static void OGlog(string message, params object[] args) { Logging.Write(Colors.DeepSkyBlue, "[ObjectGatherer]: " + message, args); }
        public static LocalPlayer Me { get { return StyxWoW.Me; } }
        public static WoWPoint LocationId = WoWPoint.Empty;
        public static WoWGameObject ObjectToFind;
        public static WoWUnit NPCToFind;
        public static WoWUnit SpecialToFind;
        public static List<WoWGameObject> ObjList;
        public static List<WoWUnit> NPCList;
        public static List<WoWUnit> SpecialList;
        public static uint[] Filterlist;
        private static bool _miner;
        private static bool _skinner;
        private static bool _herber;
        private static int _interactway;
        private static readonly Stopwatch MyTimer = new Stopwatch();
        private static readonly Stopwatch CheckPointTimer = new Stopwatch();
        private static bool _initialized;
        private static bool _checkTimer;
        private static bool _checkInteract;
        #endregion

        #region Initialize
        public override void Initialize() {
            if (_initialized) return;
            _initialized = true;
            OGlog("Version " + Version + " Loaded.");
            Filterlist = UpdateFilterList();
            BotEvents.OnBotStarted += BotEvent_OnBotStarted;
            BotEvents.OnBotStopped += BotEvent_OnBotStopped;
            if (Me.GetSkill(SkillLine.Mining).CurrentValue != 0) {
                _miner = true;
            }
            if (Me.GetSkill(SkillLine.Skinning).CurrentValue != 0) {
                _skinner = true;
            }
            if (Me.GetSkill(SkillLine.Herbalism).CurrentValue != 0) {
                _herber = true;
            }


        }
        #endregion

        #region Load GUI
        public override bool WantButton { get { return true; } }
        public override void OnButtonPress() { var GUI = new ObjectGatherer_Gui(); GUI.ShowDialog(); }
        #endregion

        #region Pulse
        public override void Pulse() {
            if (!_initialized) return;
            if (CheckPointTimer.ElapsedMilliseconds > 30000) { LocationId = WoWPoint.Empty; }
            if ((Me.IsActuallyInCombat) || (Me.IsDead) || (Me.IsGhost)) { LocationId = WoWPoint.Empty; }
            if (LocationId == WoWPoint.Empty) { 
                UpdateObjectList();
                return;
            }
            if (LocationId.Distance(Me.Location) > 3) { MoveToObject(); }
            if (LocationId.Distance(Me.Location) <= 3) { InteractWithObject(); }
        }
        #endregion

        #region Ancient Guo-Lai Cache Key
        private static bool AncientGuoLaiCacheKey() { return Me.BagItems.FirstOrDefault(i => i.Entry == 87779) != null; }
        #endregion

        #region BotEvent_OnBotStart
        private void BotEvent_OnBotStarted(EventArgs args) {
            LocationId = WoWPoint.Empty;
        }
        #endregion

        #region BotEvent_OnBotStop
        private void BotEvent_OnBotStopped(EventArgs args) {
            LocationId = WoWPoint.Empty;
        }
        #endregion
        
        #region FilterList

        #region Ancient Guo-Lai Cache
        private static readonly uint[] Filter_AGLC = {
            214388, // Ancient Guo-Lai Cache
        };
        #endregion

        #region Dark Soil
        private static readonly uint[] Filter_DS = {
            210565, // Dark Soil
        };
        #endregion

        #region Gold Coins
        private static readonly uint[] Filter_GC = {
            186633, // Gold Coins
            186634, // Gold Coins
            210894, // Gold Coins
            214458, // Gold Coins
            214985, // Gold Coins
        };
        #endregion

        #region Is Another Man's Treasure
        private static readonly uint[] Filter_IAMT = {
            213363, // Wodin's Mantid Shanker
            213364, // Ancient Pandaren Mining Pick
            213366, // Ancient Pandaren Tea Pot (Grey trash worth 100G)
            213368, // Lucky Pandaren Coin (Grey trash worth 95G)
            213649, // Cache of Pilfered Goods
            213653, // Pandaren Fishing Spear
            213741, // Ancient Jinyu Staff
            213742, // Hammer of Ten Thunders
            213748, // Pandaren Ritual Stone (Grey trash worth 105G)
            213749, // Staff of the Hidden Master
            213750, // Saurok Stone Tablet (Grey trash worth 100G)
            213751, // Sprite's Cloth Chest
            213765, // Tablet of Ren Yun (Cooking Recipy)
            213768, // Hozen Warrior Spear
            213771, // Statue of Xuen (Grey trash worth 100G)
            213782, // Terracotta Head (Grey trash worth 100G)
            213793, // Riktik's Tiny Chest (Grey trash worth 105G)
            213842, // Stash of Yaungol Weapons
            213844, // Amber Encased Moth (Grey trash worth 105G)
            213845, // The Hammer of Folly (Grey trash worth 100G)
            213956, // Fragment of Dread (Grey trash worth 90G)
            213959, // Hardened Sap of Kri'vess (Grey trash worth 110G)
            213960, // Yaungol Fire Carrier
            213962, // Wind-Reaver's Dagger of Quick Strikes
            213964, // Malik's Stalwart Spear
            213966, // Amber Encased Necklace
            213967, // Blade of the Prime
            213968, // Swarming Cleaver of Ka'roz
            213969, // Dissector's Staff of Mutilation
            213970, // Bloodsoaked Chitin Fragment
            213972, // Blade of the Poisoned Mind
            214340, // Boat-Building Instructions (Grey trash worth 10G)
            214438, // Ancient Mogu Tablet (Grey trash worth 95G)
            214439, // Barrel of Banana Infused Rum (Cooking Recipy and Rum)
        };
        #endregion

        #region Is Another Man's Treasure NPC
        private static readonly uint[] Filter_IAMTN = {
            65552, // Glinting Rapana Whelk
            64272, // Jade Warrior Statue
            64004, // Ghostly Pandaren Fisherman
            64191, // Ghostly Pandaren Craftsman
            64227, // Frozen Trail Packer
        };
        #endregion

        #region Netherwing Egg
        private static readonly uint[] Filter_NE = {
            185915, // Netherwing Egg
        };
        #endregion

        #region Onyx Egg
        private static readonly uint[] Filter_OE = {
            214945, // Onyx Egg
        };
        #endregion

        #region Treasure Chests
        private static readonly uint[] Filter_TC = {
            176944, // Old Treasure Chest (Scholomance Instance)
            179697, // Arena Treasure Chest (STV Arena)
            203090, // Sunken Treaure Chest
            207472, // Silverbound Treasure Chest (Zone 1)
            207473, // Silverbound Treasure Chest (Zone 2)
            207474, // Silverbound Treasure Chest (Zone 3)
            207475, // Silverbound Treasure Chest (Zone 4)
            207476, // Silverbound Treasure Chest (Zone 5)
            207477, // Silverbound Treasure Chest (Zone 6)
            207478, // Silverbound Treasure Chest (Zone 7)
            207479, // Silverbound Treasure Chest (Zone 8)
            207480, // Silverbound Treasure Chest (Zone 9)
            207484, // Sturdy Treasure Chest (Zone 1)
            207485, // Sturdy Treasure Chest (Zone 2)
            207486, // Sturdy Treasure Chest (Zone 3)
            207487, // Sturdy Treasure Chest (Zone 4)
            207488, // Sturdy Treasure Chest (Zone 5)
            207489, // Sturdy Treasure Chest (Zone 6)
            207492, // Sturdy Treasure Chest (Zone 7)
            207493, // Sturdy Treasure Chest (Zone 8)
            207494, // Sturdy Treasure Chest (Zone 9)
            207495, // Sturdy Treasure Chest (Zone 10)
            207496, // Dark Iron Treasure Chest (Zone 1)
            207497, // Dark Iron Treasure Chest (Zone 2)
            207498, // Dark Iron Treasure Chest (Zone 3)
            207500, // Dark Iron Treasure Chest (Zone 4)
            207507, // Dark Iron Treasure Chest (Zone 5)
            207512, // Silken Treasure Chest (Zone 1)
            207513, // Silken Treasure Chest (Zone 2)
            207517, // Silken Treasure Chest (Zone 3)
            207518, // Silken Treasure Chest (Zone 4)
            207519, // Silken Treasure Chest (Zone 5)
            207520, // Maplewood Treasure Chest (Zone 1)
            207521, // Maplewood Treasure Chest (Zone 2)
            207522, // Maplewood Treasure Chest (Zone 3)
            207523, // Maplewood Treasure Chest (Zone 4)
            207524, // Maplewood Treasure Chest (Zone 5)
            207528, // Maplewood Treasure Chest (Zone 6)
            207529, // Maplewood Treasure Chest (Zone 7)
            207533, // Runestone Treasure Chest (Zone 1)
            207534, // Runestone Treasure Chest (Zone 2)
            207535, // Runestone Treasure Chest (Zone 3)
            207540, // Runestone Treasure Chest (Zone 4)
            207542, // Runestone Treasure Chest (Zone 5)
            213362, // Ship's Locker (Contains ~ 96G)
            213650, // Virmen Treasure Cache (Contains ~ 100G)
            213769, // Hozen Treasure Cache (Contains ~ 100G)
            213770, // Stolen Sprite Treasure (Contains ~ 105G)
            213774, // Lost Adventurer's Belongings (Contains ~ 100G)
            213961, // Abandoned Crate of Goods (Contains ~ 100G)
            214325, // Forgotten Lockbox (Contains ~ 10G)
            214407, // Mo-Mo's Treasure Chest (Contains ~ 9G)
            214337, // Stash of Gems (few green uncut MoP gems and ~ 7G)
            214337, // Offering of Rememberance (Contains ~ 30G and debuff turns you grey)
        };
        #endregion

        #region Quests
        private static readonly uint[] Filter_Q = {
            #region Paying Tribute (Niuzao Food Supply)
            212131, // Niuzao Food Supply
            212132, // Niuzao Food Supply
            212133, // Niuzao Food Supply
            #endregion
        };
        #endregion

        #region UpdateFilterList()
        public static uint[] UpdateFilterList() {
            var tmpList = new List<uint>();
            if (ObjectGatherer_Settings.Instance.AGLC_CB) { tmpList.AddRange(Filter_AGLC); }
            if (ObjectGatherer_Settings.Instance.DS_CB) { tmpList.AddRange(Filter_DS); }
            if (ObjectGatherer_Settings.Instance.GC_CB) { tmpList.AddRange(Filter_GC); }
            if (ObjectGatherer_Settings.Instance.IAMT_CB) { tmpList.AddRange(Filter_IAMT); }
            if (ObjectGatherer_Settings.Instance.IAMTN_CB) { tmpList.AddRange(Filter_IAMTN); }
            if (ObjectGatherer_Settings.Instance.NE_CB) { tmpList.AddRange(Filter_NE); }
            if (ObjectGatherer_Settings.Instance.OE_CB) { tmpList.AddRange(Filter_OE); }
            if (ObjectGatherer_Settings.Instance.TC_CB) { tmpList.AddRange(Filter_TC); }
            if (ObjectGatherer_Settings.Instance.Q_CB) { tmpList.AddRange(Filter_Q); }
            return (tmpList.ToArray());
        }
        #endregion

        #endregion

        #region InteractWithObject
        private static void InteractWithObject() {
            if (Me.IsActuallyInCombat) { return; }
            if (LocationId.Distance(Me.Location) > 3) { return; }

            if (!_checkTimer) { MyTimer.Restart(); }
            while ((MyTimer.ElapsedMilliseconds < 5000) && (!Me.IsActuallyInCombat) && (!Me.IsDead) && (!Me.IsGhost) && (LocationId != WoWPoint.Empty)) {
                WoWMovement.MoveStop();
                if (!_checkTimer) { 
                    if (!Me.HasAura(40120) && !Me.HasAura(33943)) {
                        Flightor.MountHelper.Dismount(); // If we're not in flightform we need to Dismount.
                        _checkTimer = true;
                    }
                }
                if ((!_checkInteract) && (MyTimer.ElapsedMilliseconds > 2000)) {
                    if ((_interactway == 1) && (LocationId.Distance(Me.Location) <= NPCToFind.InteractRange)) {
                        NPCToFind.Target();
                        NPCToFind.Interact();
                    }
                    if ((_interactway == 2) && (ObjectToFind.CanUseNow())) {
                        ObjectToFind.Interact();
                    }
                    if (_interactway == 3) {
                        SpecialToFind.Interact();
                    }
                    _checkInteract = true;
                }
            }
            if (_checkInteract) {
                if (_interactway == 1) { Lua.DoString("SelectGossipOption(1)"); }
                if (_interactway == 2) { Lua.DoString("StaticPopup1Button1:Click()"); }
            }
            _checkTimer = false;
            _checkInteract = false;
            _interactway = 0;
            LocationId = WoWPoint.Empty;
        }
        #endregion

        #region MoveToObject
        private static void MoveToObject() {
            while ((LocationId.Distance(Me.Location) > 3) && (!Me.IsActuallyInCombat) && (!Me.IsDead) && (!Me.IsGhost) && (LocationId != WoWPoint.Empty)) {
                if ((!Me.IsMoving) && (Flightor.MountHelper.Mounted) && 
                    ((ObjectToFind.InLineOfSight) || (NPCToFind.InLineOfSight) || (SpecialToFind.InLineOfSight))) { Flightor.MoveTo(LocationId); }
                if ((!Me.IsMoving) && (Navigator.CanNavigateFully(Me.Location, LocationId))) { Navigator.MoveTo(LocationId); }
                if ((!Me.IsMoving) && (!Flightor.MountHelper.Mounted)) { Flightor.MountHelper.MountUp(); }
            }
        }
        #endregion

        #region UpdateObjectList
        private static void UpdateObjectList() {
            ObjectManager.Update();
            NPCList = ObjectManager.GetObjectsOfType<WoWUnit>().Where(u => Filterlist.Contains(u.Entry))
                      .OrderBy(u => u.Distance)
                      .ToList();
            ObjList = ObjectManager.GetObjectsOfType<WoWGameObject>()
                      .Where(o => (o.Distance2D <= LootTargeting.LootRadius) && Filterlist.Contains(o.Entry))
                      .OrderBy(o => o.Distance)
                      .ToList();
            SpecialList = ObjectManager.GetObjectsOfType<WoWUnit>().Where(s => !s.IsAlive)
                      .OrderBy(s => s.Distance)
                      .ToList();

            #region Search for Skinn-/Herb-/Minable NPC's
            foreach (var s in SpecialList) {
                if (Me.IsOnTransport) {
                    LocationId = WoWPoint.Empty;
                    return;
                }
                #region Mineing
                if ((ObjectGatherer_Settings.Instance.SHMC_CB) && (s.Skinnable) && (s.SkinType == WoWCreatureSkinType.Rock) && (!s.Lootable) && 
                    (!Me.Looting) && (_miner) && (LocationId == WoWPoint.Empty)) {
                    if ((!Flightor.MountHelper.Mounted) && (!Me.IsActuallyInCombat) && (!Me.IsDead) && (!Me.IsGhost) && (s.Distance < 20)) {
                        if (SpecialToFind != s) {
                            OGlog("Moveing to Mine {0}", s.Name);
                            SpecialToFind = s;
                        }
                        while (s.Distance > 3) {
                            Navigator.MoveTo(s.Location);
                        }
                    }
                    if (SpecialToFind != s) {
                        OGlog("Moveing to Mine {0}", s.Name);
                        SpecialToFind = s;
                    }
                    LocationId = WoWMovement.CalculatePointFrom(s.Location, 3);
                    _interactway = 3;
                    }
                #endregion

                #region Herbing
                if ((ObjectGatherer_Settings.Instance.SHMC_CB) && (s.Skinnable) && (s.SkinType == WoWCreatureSkinType.Herb) && (!s.Lootable) && 
                    (!Me.Looting) && (_herber) && (LocationId == WoWPoint.Empty)) {
                    if ((!Flightor.MountHelper.Mounted) && (!Me.IsActuallyInCombat) && (!Me.IsDead) && (!Me.IsGhost) && (s.Distance < 20)) {
                        if (SpecialToFind != s) {
                            OGlog("Moveing to Herb {0}", s.Name);
                            SpecialToFind = s;
                        }
                        while (s.Distance > 3) {
                            Navigator.MoveTo(s.Location);
                        }
                    }
                    if (SpecialToFind != s) {
                        OGlog("Moveing to Herb {0}", s.Name);
                        SpecialToFind = s;
                    }
                    LocationId = WoWMovement.CalculatePointFrom(s.Location, 3);
                    _interactway = 3;
                    }
                #endregion

                #region Skinning
                if ((ObjectGatherer_Settings.Instance.SHMC_CB) && (s.Skinnable) && (s.SkinType == WoWCreatureSkinType.Leather) && (!s.Lootable) && 
                    (!Me.Looting) && (_skinner) && (LocationId == WoWPoint.Empty)) {
                    if ((!Flightor.MountHelper.Mounted) && (!Me.IsActuallyInCombat) && (!Me.IsDead) && (!Me.IsGhost) && (s.Distance < 20)) {
                        if (SpecialToFind != s) {
                            OGlog("Moveing to Skin {0}", s.Name);
                            SpecialToFind = s;
                        }
                        while (s.Distance > 3) {
                            Navigator.MoveTo(s.Location);
                        }
                    }
                    if (SpecialToFind != s) {
                        OGlog("Moveing to Skin {0}", s.Name);
                        SpecialToFind = s;
                    }
                    LocationId = WoWMovement.CalculatePointFrom(s.Location, 3);
                    _interactway = 3;
                    }
                #endregion

                CheckPointTimer.Restart();
            }
            #endregion

            if (LocationId != WoWPoint.Empty) { return; }

            #region Search for NPC
            foreach (var u in NPCList) {
                if (Me.IsOnTransport) {
                    LocationId = WoWPoint.Empty; 
                    return;
                }
                if (!u.CanSelect) {
                    LocationId = WoWPoint.Empty; 
                    return;
                }
                if ((!Navigator.CanNavigateFully(Me.Location, u.Location)) && (!u.InLineOfSight)) {
                    if (NPCToFind != u) {
                        OGlog("Found {0} at {1}, but can't get to it.", u.Name, u.Location);
                        NPCToFind = u;
                    }
                    LocationId = WoWPoint.Empty;
                    return;
                }
                LocationId = WoWMovement.CalculatePointFrom(u.Location, 3);
                _interactway = 1;
                if (NPCToFind != u) {
                    OGlog("Moving to {0}, to interact with {1}.", u.Location, u.Name);
                    NPCToFind = u;
                }
                CheckPointTimer.Restart();
            }
            #endregion

            if (LocationId != WoWPoint.Empty) { return; }

            #region Search for Object
            foreach (var o in ObjList) {
                if ((o.Entry == 214388) && (!AncientGuoLaiCacheKey())) {
                    LocationId = WoWPoint.Empty;
                    return;
                }
                if (Me.IsOnTransport) {
                    LocationId = WoWPoint.Empty;
                    return;
                }
                if (!o.CanUse()) {
                    LocationId = WoWPoint.Empty;
                    return;
                }
                if ((!Navigator.CanNavigateFully(Me.Location, o.Location)) && (!o.InLineOfSight)) {
                    if (ObjectToFind != o) {
                        OGlog("Found {0} at {1}, but can't get to it.", o.Name, o.Location);
                        ObjectToFind = o;
                    }
                    return;
                }
                LocationId = WoWMovement.CalculatePointFrom(o.Location, 3);
                _interactway = 2;
                if (ObjectToFind != o) {
                    OGlog("Moving to {0}, to pickup {1}.", o.Location, o.Name);
                    ObjectToFind = o;
                }
                CheckPointTimer.Restart();
            }
            #endregion
        }
        #endregion

    }
}