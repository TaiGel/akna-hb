#region Information
/* 
 * Ironpaw Tokens by AknA
 * 
 * Made this plugin after a request by Kuat on HB forums.
 * 
 * Scan what area you are in - if you're not in the Halfhill Market then plugin will do nothing.
 * If you are in the Halfhill Market it will scan your bags for ingredients.
 * If you have enough ingredients (and you have selected it in the GUI), it will move to the vendor.
 * It will buy "Empty 'ingredients type' Container" acording to how much you have of each ingredient.
 * It will turn the Empty Containers with ingredients into Bundle of Groceries.
 * It will move to the quest npc.
 * It will turn in all Bundle of Groceries into Ironpaw Tokens.
 * 
 * Ver 1.00
 * First official release
 * Only Fishes working.
 * 
 * Ver 1.10
 * Fixed a error I made when I fixed a other error :P
 * 
 * Ver 1.12
 * Had the wrong itemID for Jade Lungfish
 * 
 * Ver 1.50
 * Fishes, Meats and Vegetables should all now be working.
 */
#endregion

#region Styx Namespace

using System.Globalization;
using Styx;
using Styx.Common;
using Styx.CommonBot.Frames;
using Styx.Pathing;
using Styx.Plugins;
using Styx.WoWInternals;
using Styx.WoWInternals.WoWObjects;
#endregion

#region System Namespace
using System;
using System.Collections.Generic;
using System.Linq;
using System.Diagnostics;
using System.Windows.Media;
#endregion System Namespace

namespace IronpawTokens {
    public class IronpawTokens : HBPlugin {
        #region Variables
        public override string Name { get { return "IronpawTokens"; } }
        public override string Author { get { return "AknA"; } }
        public override Version Version { get { return new Version(1, 5, 0); } }
        public static void IpTlog(string message, params object[] args) { Logging.Write(Colors.DeepSkyBlue, "[IronpawTokens]: " + message, args); }
        public static LocalPlayer Me { get { return StyxWoW.Me; } }
        public static uint[] ItemList;
        private static readonly Stopwatch ShopTimer = new Stopwatch();
        private static WoWItem _itemToUse;
        private static bool _initialized;
        private static bool _buying;
        private static int _shoppingStep;
        #endregion

        #region Initialize
        public override void Initialize() {
            if (_initialized) return;
            ItemList = UpdateItemList();
            IpTlog("Version " + Version + " Loaded.");
            _initialized = true;
        }
        #endregion

        #region Dispose
        public override void Dispose() { }
        #endregion

        #region Load GUI
        public override bool WantButton { get { return true; } }
        public override void OnButtonPress() { var GUI = new IronpawTokensGui(); GUI.ShowDialog(); }
        #endregion

        #region Pulse
        public override void Pulse() {
            if ((!_initialized) || (!ExtensiveCheck())) { return; }
            if (!CheckForLocation()) { return; }
            Logging.WriteDiagnostic("Step : " + _shoppingStep.ToString(CultureInfo.InvariantCulture));

            switch (_shoppingStep) {
                case 0:
                    GoShopping();
                    break;

                case 1:
                    CreateGroceries();
                    break;

                case 2:
                    MoveToTurnIn();
                    break;
            }
        }
        #endregion

        #region CheckForLocation
        private static bool CheckForLocation() {
            return ((ObjectManager.GetObjectsOfType<WoWUnit>().FirstOrDefault(npc => npc.Entry == 64395) != null) && 
                   (ObjectManager.GetObjectsOfType<WoWUnit>().FirstOrDefault(npc => npc.Entry == 64940) != null));
        }
        #endregion

        #region MerchantBuy
        private static void MerchantBuy(string a, int b) {
            if (b > 20) { b = 20; }
            Lua.DoString("for i=1, GetMerchantNumItems() do local l=GetMerchantItemLink(i) if l then if l:find(\"" + a + "\") then BuyMerchantItem(i, " + b + ")end end end");
            ShopTimer.Restart();
        }
        #endregion

        #region GoShopping
        private static void GoShopping() {
            if ((BagCount(UpdateShoppingList(74856), UpdateShoppingList(87678), 20)  <= 0) && (BagCount(UpdateShoppingList(74857), UpdateShoppingList(87679), 20)  <= 0) &&
                (BagCount(UpdateShoppingList(74859), UpdateShoppingList(87680), 20)  <= 0) && (BagCount(UpdateShoppingList(74860), UpdateShoppingList(87681), 20)  <= 0) &&
                (BagCount(UpdateShoppingList(74861), UpdateShoppingList(87682), 20)  <= 0) && (BagCount(UpdateShoppingList(74863), UpdateShoppingList(87683), 20)  <= 0) &&
                (BagCount(UpdateShoppingList(74864), UpdateShoppingList(87684), 20)  <= 0) && (BagCount(UpdateShoppingList(74865), UpdateShoppingList(87685), 20)  <= 0) &&
                (BagCount(UpdateShoppingList(74866), UpdateShoppingList(87686), 60)  <= 0) && 
                (BagCount(UpdateShoppingList(74833), UpdateShoppingList(87658), 20)  <= 0) && (BagCount(UpdateShoppingList(74834), UpdateShoppingList(87659), 20)  <= 0) && 
                (BagCount(UpdateShoppingList(74837), UpdateShoppingList(87660), 20)  <= 0) && (BagCount(UpdateShoppingList(74838), UpdateShoppingList(87661), 20)  <= 0) && 
                (BagCount(UpdateShoppingList(74839), UpdateShoppingList(87662), 20)  <= 0) && (BagCount(UpdateShoppingList(75014), UpdateShoppingList(87687), 20)  <= 0) && 
                (BagCount(UpdateShoppingList(74840), UpdateShoppingList(87663), 100) <= 0) && (BagCount(UpdateShoppingList(74841), UpdateShoppingList(87664), 100) <= 0) && 
                (BagCount(UpdateShoppingList(74842), UpdateShoppingList(87665), 100) <= 0) && (BagCount(UpdateShoppingList(74843), UpdateShoppingList(87666), 100) <= 0) && 
                (BagCount(UpdateShoppingList(74844), UpdateShoppingList(87667), 100) <= 0) && (BagCount(UpdateShoppingList(74846), UpdateShoppingList(87669), 100) <= 0) && 
                (BagCount(UpdateShoppingList(74847), UpdateShoppingList(87670), 100) <= 0) && (BagCount(UpdateShoppingList(74848), UpdateShoppingList(87671), 100) <= 0) && 
                (BagCount(UpdateShoppingList(74849), UpdateShoppingList(87672), 100) <= 0) && (BagCount(UpdateShoppingList(74850), UpdateShoppingList(87673), 100) <= 0)) {
                _shoppingStep = 1;
                return;
            }
            if (ShopTimer.ElapsedMilliseconds >= 2000) { _buying = false; }
            var shopNPC = ObjectManager.GetObjectsOfType<WoWUnit>().FirstOrDefault(npc => npc.Entry == 64940);
            if (shopNPC == null) return;
            if (shopNPC.WithinInteractRange) {
                if (Me.IsMoving) { WoWMovement.MoveStop(); }
                if (!MerchantFrame.Instance.IsVisible) { shopNPC.Interact(); }

                #region Fishes
                if (UpdateShoppingList(74856) >= 20) { // Jade Lungfish
                    var a = BagCount(UpdateShoppingList(74856), UpdateShoppingList(87678), 20);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Jade Lungfish Container", a);
                    }
                }
                if (UpdateShoppingList(74857) >= 20) { // Giant Mantis Shrimp
                    var a = BagCount(UpdateShoppingList(74857), UpdateShoppingList(87679), 20);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Giant Mantis Shrimp Container", a);
                    }
                }
                if (UpdateShoppingList(74859) >= 20) { // Emperor Salmon
                    var a = BagCount(UpdateShoppingList(74859), UpdateShoppingList(87680), 20);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Emperor Salmon Container", a);
                    }
                }
                if (UpdateShoppingList(74860) >= 20) { // Redbelly Mandarin
                    var a = BagCount(UpdateShoppingList(74860), UpdateShoppingList(87681), 20);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Redbelly Mandarin Container", a);
                    }
                }
                if (UpdateShoppingList(74861) >= 20) { // Tiger Gourami
                    var a = BagCount(UpdateShoppingList(74861), UpdateShoppingList(87682), 20);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Tiger Gourami Container", a);
                    }
                }
                if (UpdateShoppingList(74863) >= 20) { // Jewel Danio
                    var a = BagCount(UpdateShoppingList(74863), UpdateShoppingList(87683), 20);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Jewel Danio Container", a);
                    }
                }
                if (UpdateShoppingList(74864) >= 20) { // Reef Octopus
                    var a = BagCount(UpdateShoppingList(74864), UpdateShoppingList(87684), 20);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Reef Octopus Container", a);
                    }
                }
                if (UpdateShoppingList(74865) >= 20) { // Krasarang Paddlefish
                    var a = BagCount(UpdateShoppingList(74865), UpdateShoppingList(87685), 20);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Krasarang Paddlefish Container", a);
                    }
                }
                if (UpdateShoppingList(74866) >= 60) { // Golden Carp
                    var a = BagCount(UpdateShoppingList(74866), UpdateShoppingList(87686), 60);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Golden Carp Container", a);
                    }
                }
                #endregion

                #region Meats
                if (UpdateShoppingList(74833) >= 20) { // Raw Tiger Steak
                    var a = BagCount(UpdateShoppingList(74833), UpdateShoppingList(87658), 20);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Raw Tiger Steak Container", a);
                    }
                }
                if (UpdateShoppingList(74834) >= 20) { // Mushan Ribs
                    var a = BagCount(UpdateShoppingList(74834), UpdateShoppingList(87659), 20);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Mushan Ribs Container", a);
                    }
                }
                if (UpdateShoppingList(74837) >= 20) { // Raw Turtle Meat
                    var a = BagCount(UpdateShoppingList(74837), UpdateShoppingList(87660), 20);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Raw Turtle Meat Container", a);
                    }
                }
                if (UpdateShoppingList(74838) >= 20) { // Raw Crab Meat
                    var a = BagCount(UpdateShoppingList(74838), UpdateShoppingList(87661), 20);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Raw Crab Meat Container", a);
                    }
                }
                if (UpdateShoppingList(74839) >= 20) { // Wildfowl Breast
                    var a = BagCount(UpdateShoppingList(74839), UpdateShoppingList(87662), 20);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Wildfowl Breast Container", a);
                    }
                }
                if (UpdateShoppingList(75014) >= 20) { // Raw Crocolisk Belly
                    var a = BagCount(UpdateShoppingList(75014), UpdateShoppingList(87687), 20);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Crocolisk Belly Container", a);
                    }
                }
                #endregion

                #region Vegetables
                if (UpdateShoppingList(74840) >= 100) { // Green Cabbage
                    var a = BagCount(UpdateShoppingList(74840), UpdateShoppingList(87663), 100);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Green Cabbage Container", a);
                    }
                }
                if (UpdateShoppingList(74841) >= 100) { // Juicycrunch Carrot
                    var a = BagCount(UpdateShoppingList(74841), UpdateShoppingList(87664), 100);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Juicycrunch Carrot Container", a);
                    }
                }
                if (UpdateShoppingList(74842) >= 100) { // Mogu Pumpkin
                    var a = BagCount(UpdateShoppingList(74842), UpdateShoppingList(87665), 100);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Mogu Pumpkin Container", a);
                    }
                }
                if (UpdateShoppingList(74843) >= 100) { // Scallions
                    var a = BagCount(UpdateShoppingList(74843), UpdateShoppingList(87666), 100);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Scallions Container", a);
                    }
                }
                if (UpdateShoppingList(74844) >= 100) { // Red Blossom Leek
                    var a = BagCount(UpdateShoppingList(74844), UpdateShoppingList(87667), 100);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Red Blossom Leek Container", a);
                    }
                }
                if (UpdateShoppingList(74846) >= 100) { // Witchberries
                    var a = BagCount(UpdateShoppingList(74846), UpdateShoppingList(87669), 100);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Witchberries Container", a);
                    }
                }
                if (UpdateShoppingList(74847) >= 100) { // Jade Squash
                    var a = BagCount(UpdateShoppingList(74847), UpdateShoppingList(87670), 100);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Jade Squash Container", a);
                    }
                }
                if (UpdateShoppingList(74848) >= 100) { // Striped Melon
                    var a = BagCount(UpdateShoppingList(74848), UpdateShoppingList(87671), 100);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Striped Melon Container", a);
                    }
                }
                if (UpdateShoppingList(74849) >= 100) { // Pink Turnip
                    var a = BagCount(UpdateShoppingList(74849), UpdateShoppingList(87672), 100);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty Pink Turnip Container", a);
                    }
                }
                if (UpdateShoppingList(74850) >= 100) { // White Turnip
                    var a = BagCount(UpdateShoppingList(74850), UpdateShoppingList(87673), 100);
                    if (!_buying && (a > 0)) {
                        _buying = true;
                        MerchantBuy("Empty White Turnip Container", a);
                    }
                }
                #endregion
            }
            else { Navigator.MoveTo(shopNPC.Location); }
        }
        #endregion

        #region BagCount
        private static int BagCount(int a, int b, int c) {
            double aa = ((a/c) - b);
            int bb = Convert.ToInt16(Math.Floor(aa));
            return bb;
        }
        #endregion

        #region CreateGroceries
        private static void CreateGroceries() {
            if (MerchantFrame.Instance.IsVisible) { MerchantFrame.Instance.Close(); }
            if ((UpdateShoppingList(74856) < 20) && (UpdateShoppingList(74857) < 20) && (UpdateShoppingList(74859) < 20) && (UpdateShoppingList(74860) < 20) &&
                (UpdateShoppingList(74861) < 20) && (UpdateShoppingList(74863) < 20) && (UpdateShoppingList(74864) < 20) && (UpdateShoppingList(74865) < 20) &&
                (UpdateShoppingList(74866) < 60) &&
                (UpdateShoppingList(74833) < 20) && (UpdateShoppingList(74834) < 20) && (UpdateShoppingList(74837) < 20) && (UpdateShoppingList(74838) < 20) &&
                (UpdateShoppingList(74839) < 20) && (UpdateShoppingList(75014) < 20) &&
                (UpdateShoppingList(74840) < 100) && (UpdateShoppingList(74841) < 100) && (UpdateShoppingList(74842) < 100) && (UpdateShoppingList(74843) < 100) &&
                (UpdateShoppingList(74844) < 100) && (UpdateShoppingList(74846) < 100) && (UpdateShoppingList(74847) < 100) && (UpdateShoppingList(74848) < 100) &&
                (UpdateShoppingList(74849) < 100) && (UpdateShoppingList(74850) < 100)) {
                _shoppingStep = 2;
                return;
                }
            #region Fishes
            if ((HaveItem(87678)) && (!Me.IsCasting) && (UpdateShoppingList(74856) >= 20)) { _itemToUse.Use(); } // Empty Jade Lungfish Container
            if ((HaveItem(87679)) && (!Me.IsCasting) && (UpdateShoppingList(74857) >= 20)) { _itemToUse.Use(); } // Empty Giant Mantis Shrimp Container
            if ((HaveItem(87680)) && (!Me.IsCasting) && (UpdateShoppingList(74859) >= 20)) { _itemToUse.Use(); } // Empty Emperor Salmon Container
            if ((HaveItem(87681)) && (!Me.IsCasting) && (UpdateShoppingList(74860) >= 20)) { _itemToUse.Use(); } // Empty Redbelly Mandarin Container
            if ((HaveItem(87682)) && (!Me.IsCasting) && (UpdateShoppingList(74861) >= 20)) { _itemToUse.Use(); } // Empty Tiger Gourami Container
            if ((HaveItem(87683)) && (!Me.IsCasting) && (UpdateShoppingList(74863) >= 20)) { _itemToUse.Use(); } // Empty Jewel Danio Container
            if ((HaveItem(87684)) && (!Me.IsCasting) && (UpdateShoppingList(74864) >= 20)) { _itemToUse.Use(); } // Empty Reef Octopus Container
            if ((HaveItem(87685)) && (!Me.IsCasting) && (UpdateShoppingList(74865) >= 20)) { _itemToUse.Use(); } // Empty Krasarang Paddlefish Container
            if ((HaveItem(87686)) && (!Me.IsCasting) && (UpdateShoppingList(74866) >= 60)) { _itemToUse.Use(); } // Empty Golden Carp Container
            #endregion

            #region Meats
            if ((HaveItem(87658)) && (!Me.IsCasting) && (UpdateShoppingList(74833) >= 20)) { _itemToUse.Use(); } // Empty Raw Tiger Steak Container
            if ((HaveItem(87659)) && (!Me.IsCasting) && (UpdateShoppingList(74834) >= 20)) { _itemToUse.Use(); } // Empty Mushan Ribs Container
            if ((HaveItem(87660)) && (!Me.IsCasting) && (UpdateShoppingList(74837) >= 20)) { _itemToUse.Use(); } // Empty Raw Turtle Meat Container
            if ((HaveItem(87661)) && (!Me.IsCasting) && (UpdateShoppingList(74838) >= 20)) { _itemToUse.Use(); } // Empty Raw Crab Meat Container
            if ((HaveItem(87662)) && (!Me.IsCasting) && (UpdateShoppingList(74839) >= 20)) { _itemToUse.Use(); } // Empty Wildfowl Breast Container
            if ((HaveItem(87687)) && (!Me.IsCasting) && (UpdateShoppingList(75014) >= 20)) { _itemToUse.Use(); } // Empty Crocolisk Belly Container
            #endregion

            #region Vegetables
            if ((HaveItem(87663)) && (!Me.IsCasting) && (UpdateShoppingList(74840) >= 100)) { _itemToUse.Use(); } // Empty Green Cabbage Container
            if ((HaveItem(87664)) && (!Me.IsCasting) && (UpdateShoppingList(74841) >= 100)) { _itemToUse.Use(); } // Empty Juicycrunch Carrot Container
            if ((HaveItem(87665)) && (!Me.IsCasting) && (UpdateShoppingList(74842) >= 100)) { _itemToUse.Use(); } // Empty Mogu Pumpkin Container
            if ((HaveItem(87666)) && (!Me.IsCasting) && (UpdateShoppingList(74843) >= 100)) { _itemToUse.Use(); } // Empty Scallions Container
            if ((HaveItem(87667)) && (!Me.IsCasting) && (UpdateShoppingList(74844) >= 100)) { _itemToUse.Use(); } // Empty Red Blossom Leek Container
            if ((HaveItem(87669)) && (!Me.IsCasting) && (UpdateShoppingList(74846) >= 100)) { _itemToUse.Use(); } // Empty Witchberries Container
            if ((HaveItem(87670)) && (!Me.IsCasting) && (UpdateShoppingList(74847) >= 100)) { _itemToUse.Use(); } // Empty Jade Squash Container
            if ((HaveItem(87671)) && (!Me.IsCasting) && (UpdateShoppingList(74848) >= 100)) { _itemToUse.Use(); } // Empty Striped Melon Container
            if ((HaveItem(87672)) && (!Me.IsCasting) && (UpdateShoppingList(74849) >= 100)) { _itemToUse.Use(); } // Empty Pink Turnip Container
            if ((HaveItem(87673)) && (!Me.IsCasting) && (UpdateShoppingList(74850) >= 100)) { _itemToUse.Use(); } // Empty White Turnip Container
            #endregion
        }
        #endregion

        #region ItemList
        #region Fishes
        private static readonly uint[] Filter_Fish_ES = {
            74859, // Emperor Salmon
        };
        private static readonly uint[] Filter_Fish_JL = {
            74856, // Jade Lungfish
        };
        private static readonly uint[] Filter_Fish_GMS = {
            74857, // Giant Mantis Shrimp
        };
        private static readonly uint[] Filter_Fish_RO = {
            74864, // Reef Octopus
        };
        private static readonly uint[] Filter_Fish_RM = {
            74860, // Redbelly Mandarin
        };
        private static readonly uint[] Filter_Fish_TG = {
            74861, // Tiger Gourami
        };
        private static readonly uint[] Filter_Fish_JD = {
            74863, // Jewel Danio
        };
        private static readonly uint[] Filter_Fish_KP = {
            74865, // Krasarang Paddlefish
        };
        private static readonly uint[] Filter_Fish_GC = {
            74866, // Golden Carp
        };
        #endregion

        #region Meats
        private static readonly uint[] Filter_Meat_RCB = {
            75014, // Raw Crocolisk Belly
        };
        private static readonly uint[] Filter_Meat_RTS = {
            74833, // Raw Tiger Steak
        };
        private static readonly uint[] Filter_Meat_MR = {
            74834, // Mushan Ribs
        };
        private static readonly uint[] Filter_Meat_RTM = {
            74837, // Raw Turle Meat
        };
        private static readonly uint[] Filter_Meat_RCM = {
            74838, // Raw Crab Meat
        };
        private static readonly uint[] Filter_Meat_WB = {
            74839, // Wildfowl Breast
        };
        #endregion

        #region Vegetables
        private static readonly uint[] Filter_Vege_GC = {
            74840, // Green Cabbage
        };
        private static readonly uint[] Filter_Vege_JC = {
            74841, // Juicycrunch Carrot
        };
        private static readonly uint[] Filter_Vege_MP = {
            74842, // Mogu Pumpkin
        };
        private static readonly uint[] Filter_Vege_SC = {
            74843, // Scallions
        };
        private static readonly uint[] Filter_Vege_RBL = {
            74844, // Red Blossom Leek
        };
        private static readonly uint[] Filter_Vege_WB = {
            74846, // Witchberries
        };
        private static readonly uint[] Filter_Vege_JS = {
            74847, // Jade Squash
        };
        private static readonly uint[] Filter_Vege_SM = {
            74848, // Striped Melon
        };
        private static readonly uint[] Filter_Vege_PT = {
            74849, // Pink Turnip
        };
        private static readonly uint[] Filter_Vege_WT = {
            74850, // White Turnip
        };
        #endregion

        #region Bundle of Groceries
        private static readonly uint[] Filter_Misc = {
            #region Fishes
            87557, // Bundle of Groceries
            87678, // Empty Jade Lungfish Container
            87679, // Empty Giant Mantis Shrimp Container
            87680, // Empty Emperor Salmon Container
            87681, // Empty Redbelly Mandarin Container
            87682, // Empty Tiger Gourami Container
            87683, // Empty Jewel Danio Container
            87684, // Empty Reef Octopus Container
            87685, // Empty Krasarang Paddlefish Container
            87686, // Empty Golden Carp Container
            #endregion
            #region Meats
            87658, // Empty Raw Tiger Steak Container
            87659, // Empty Mushan Ribs Container
            87660, // Empty Raw Turtle Meat Container
            87661, // Empty Raw Crab Meat Container
            87662, // Empty Wildfowl Breast Container
            87687, // Empty Crocolisk Belly Container
            #endregion
            #region Vegetables
            87663, // Empty Green Cabbage Container
            87664, // Empty Juicycrunch Carrot Container
            87665, // Empty Mogu Pumpkin Container
            87666, // Empty Scallions Container
            87667, // Empty Red Blossom Leek Container
            87669, // Empty Witchberries Container
            87670, // Empty Jade Squash Container
            87671, // Empty Striped Melon Container
            87672, // Empty Pink Turnip Container
            87673, // Empty White Turnip Container
            #endregion
        };
        #endregion

        #region UpdateItemList()
        public static uint[] UpdateItemList() {
            var itemList = new List<uint>();
            #region Fishes
            if (IronpawTokensSettings.Instance.Fish_ES)  { itemList.AddRange(Filter_Fish_ES); }
            if (IronpawTokensSettings.Instance.Fish_JL)  { itemList.AddRange(Filter_Fish_JL); }
            if (IronpawTokensSettings.Instance.Fish_GMS) { itemList.AddRange(Filter_Fish_GMS); }
            if (IronpawTokensSettings.Instance.Fish_RO)  { itemList.AddRange(Filter_Fish_RO); }
            if (IronpawTokensSettings.Instance.Fish_RM)  { itemList.AddRange(Filter_Fish_RM); }
            if (IronpawTokensSettings.Instance.Fish_TG)  { itemList.AddRange(Filter_Fish_TG); }
            if (IronpawTokensSettings.Instance.Fish_JD)  { itemList.AddRange(Filter_Fish_JD); }
            if (IronpawTokensSettings.Instance.Fish_KP)  { itemList.AddRange(Filter_Fish_KP); }
            if (IronpawTokensSettings.Instance.Fish_GC)  { itemList.AddRange(Filter_Fish_GC); }
            #endregion

            #region Meats
            if (IronpawTokensSettings.Instance.Meat_RCB) { itemList.AddRange(Filter_Meat_RCB); }
            if (IronpawTokensSettings.Instance.Meat_RTS) { itemList.AddRange(Filter_Meat_RTS); }
            if (IronpawTokensSettings.Instance.Meat_MR)  { itemList.AddRange(Filter_Meat_MR); }
            if (IronpawTokensSettings.Instance.Meat_RTM) { itemList.AddRange(Filter_Meat_RTM); }
            if (IronpawTokensSettings.Instance.Meat_RCM) { itemList.AddRange(Filter_Meat_RCM); }
            if (IronpawTokensSettings.Instance.Meat_WB)  { itemList.AddRange(Filter_Meat_WB); }
            #endregion

            #region Vegetables
            if (IronpawTokensSettings.Instance.Vege_GC)  { itemList.AddRange(Filter_Vege_GC); }
            if (IronpawTokensSettings.Instance.Vege_JC)  { itemList.AddRange(Filter_Vege_JC); }
            if (IronpawTokensSettings.Instance.Vege_MP)  { itemList.AddRange(Filter_Vege_MP); }
            if (IronpawTokensSettings.Instance.Vege_SC)  { itemList.AddRange(Filter_Vege_SC); }
            if (IronpawTokensSettings.Instance.Vege_RBL) { itemList.AddRange(Filter_Vege_RBL); }
            if (IronpawTokensSettings.Instance.Vege_WB)  { itemList.AddRange(Filter_Vege_WB); }
            if (IronpawTokensSettings.Instance.Vege_JS)  { itemList.AddRange(Filter_Vege_JS); }
            if (IronpawTokensSettings.Instance.Vege_SM)  { itemList.AddRange(Filter_Vege_SM); }
            if (IronpawTokensSettings.Instance.Vege_PT)  { itemList.AddRange(Filter_Vege_PT); }
            if (IronpawTokensSettings.Instance.Vege_WT)  { itemList.AddRange(Filter_Vege_WT); }
            #endregion

            #region Misc
            itemList.AddRange(Filter_Misc);
            #endregion
            return (itemList.ToArray());
        }
        #endregion
        #endregion

        #region HaveItem
        private static bool HaveItem(uint a) {
            _itemToUse = StyxWoW.Me.CarriedItems.FirstOrDefault(i => i.Entry == a);
            return (Me.BagItems.FirstOrDefault(i => i.Entry == a) != null);
        }
        #endregion

        #region MoveToTurnIn
        private static void MoveToTurnIn() {
            if (!HaveItem(87557)) {
                _shoppingStep = 0;
                return;
            }
            var questNPC = ObjectManager.GetObjectsOfType<WoWUnit>().FirstOrDefault(npc => npc.Entry == 64395);
            if (questNPC == null) return;
            if (questNPC.WithinInteractRange) {
                if (Me.IsMoving) { WoWMovement.MoveStop(); }
                if (!QuestFrame.Instance.IsVisible || GossipFrame.Instance.IsVisible) { questNPC.Interact(); }
                Lua.DoString("SelectGossipAvailableQuest(1)");
                QuestFrame.Instance.CompleteQuest();
                QuestFrame.Instance.SelectQuestReward(1);
            }
            else { Navigator.MoveTo(questNPC.Location); }
        }
        #endregion

        #region ExtensiveCheck
        public bool ExtensiveCheck() {
            if (Me.Combat || Me.IsActuallyInCombat) { return false; }
            if (ObjectManager.GetObjectsOfType<WoWUnit>().Any(unit => unit.Aggro || unit.PetAggro)) { return false; }
            if (Me.IsOnTransport || Me.IsGhost || Me.IsDead) { return false; }
            return true;
        }
        #endregion

        #region UpdateShoppingList
        private static int UpdateShoppingList(uint id) {
            var a = ItemList.Any(u => u == id) ? Lua.GetReturnVal<int>("return GetItemCount(" + id + ")", 0) : 0;
            Logging.WriteDiagnostic("ItemID : " + id + " : " + a.ToString(CultureInfo.InvariantCulture));
            return ItemList.Any(u => u == id) ? Lua.GetReturnVal<int>("return GetItemCount(" + id + ")", 0) : 0;
        }
        #endregion
    }
}
