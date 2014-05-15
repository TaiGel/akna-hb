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
 * 
 * Ver 2.00
 * Complete recode of the plugin, was such horrible code as it was ages ago I made this and wasn't very experienced.
 */
#endregion

using System;
using System.Collections.Generic;
using System.Linq;
using System.Diagnostics;
using IronpawTokens.Gui;
using IronpawTokens.Helpers;
using Styx;
using Styx.CommonBot.Frames;
using Styx.Pathing;
using Styx.Plugins;
using Styx.WoWInternals;
using Styx.WoWInternals.WoWObjects;

namespace IronpawTokens {
    public class IronpawTokens : HBPlugin {
        // ===========================================================
        // Constants
        // ===========================================================

        // ===========================================================
        // Fields
        // ===========================================================

        public static uint[] ItemList;

        private static readonly Stopwatch ShopTimer = new Stopwatch();
        private static WoWItem _itemToUse;
        private static bool _initialized;
        private static bool _buying;
        private static int _shoppingStep;

        private static readonly uint[] FilterMisc = {
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

            87658, // Empty Raw Tiger Steak Container
            87659, // Empty Mushan Ribs Container
            87660, // Empty Raw Turtle Meat Container
            87661, // Empty Raw Crab Meat Container
            87662, // Empty Wildfowl Breast Container
            87687, // Empty Crocolisk Belly Container

            87663, // Empty Green Cabbage Container
            87664, // Empty Juicycrunch Carrot Container
            87665, // Empty Mogu Pumpkin Container
            87666, // Empty Scallions Container
            87667, // Empty Red Blossom Leek Container
            87669, // Empty Witchberries Container
            87670, // Empty Jade Squash Container
            87671, // Empty Striped Melon Container
            87672, // Empty Pink Turnip Container
            87673  // Empty White Turnip Container
        };

        private static readonly Tuple<int, int, int>[] Combinables = {
            // Ingridient, Container, MinQuantity
            Tuple.Create(74856, 87678, 20),
            Tuple.Create(74857, 87679, 20),
            Tuple.Create(74859, 87680, 20),
            Tuple.Create(74860, 87681, 20),
            Tuple.Create(74861, 87682, 20),
            Tuple.Create(74863, 87683, 20),
            Tuple.Create(74864, 87684, 20),
            Tuple.Create(74865, 87685, 20),
            Tuple.Create(74866, 87686, 60),
            Tuple.Create(74833, 87658, 20),
            Tuple.Create(74834, 87659, 20),
            Tuple.Create(74837, 87660, 20),
            Tuple.Create(74838, 87661, 20),
            Tuple.Create(74839, 87662, 20),
            Tuple.Create(75014, 87687, 20),
            Tuple.Create(74840, 87663, 100),
            Tuple.Create(74841, 87664, 100),
            Tuple.Create(74842, 87665, 100),
            Tuple.Create(74843, 87666, 100),
            Tuple.Create(74844, 87667, 100),
            Tuple.Create(74846, 87669, 100), 
            Tuple.Create(74847, 87670, 100),
            Tuple.Create(74848, 87671, 100),
            Tuple.Create(74849, 87672, 100),
            Tuple.Create(74850, 87673, 100)
        };

        // ===========================================================
        // Constructors
        // ===========================================================

        // ===========================================================
        // Getter & Setter
        // ===========================================================

        // ===========================================================
        // Methods for/from SuperClass/Interfaces
        // ===========================================================
        
        public override string Name { get { return "IronpawTokens"; } }
        
        public override string Author { get { return "AknA"; } }

        public override Version Version { get { return new Version(2, 0, 0); } }

        public override void OnEnable() {
            if(_initialized) return;
            ItemList = UpdateItemList();
            CustomLog.Normal("Version {0} Loaded.", Version);
            _initialized = true;
        }

        public override void OnDisable() { }

        public override bool WantButton { get { return true; } }

        public override void OnButtonPress() {
            using(var gui = new IronpawTokensGui()) {
                gui.ShowDialog();
            }
        }

        public override void Pulse() {
            if(!_initialized || !ExtensiveCheck() || !AreNPCsNear()) {
                return;
            }

            CustomLog.Diagnostic("Step : {0}", _shoppingStep);

            switch(_shoppingStep) {
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

        // ===========================================================
        // Methods
        // ===========================================================
        
        public static uint[] UpdateItemList() {
            var itemList = new List<uint>();
            if(Settings.IronpawTokensSettings.Instance.EmperorSalmon) { itemList.Add(74859); }
            if(Settings.IronpawTokensSettings.Instance.JadeLungfish) { itemList.Add(74856); }
            if(Settings.IronpawTokensSettings.Instance.GiantMantisShrimp) { itemList.Add(74857); }
            if(Settings.IronpawTokensSettings.Instance.ReefOctopus) { itemList.Add(74864); }
            if(Settings.IronpawTokensSettings.Instance.RedbellyMandarin) { itemList.Add(74860); }
            if(Settings.IronpawTokensSettings.Instance.TigerGourami) { itemList.Add(74861); }
            if(Settings.IronpawTokensSettings.Instance.JewelDanio) { itemList.Add(74863); }
            if(Settings.IronpawTokensSettings.Instance.KrasarangPaddlefish) { itemList.Add(74865); }
            if(Settings.IronpawTokensSettings.Instance.GoldenCarp) { itemList.Add(74866); }

            if(Settings.IronpawTokensSettings.Instance.RawCrocoliskBelly) { itemList.Add(75014); }
            if(Settings.IronpawTokensSettings.Instance.RawTigerSteak) { itemList.Add(74833); }
            if(Settings.IronpawTokensSettings.Instance.MushanRibs) { itemList.Add(74834); }
            if(Settings.IronpawTokensSettings.Instance.RawTurtleMeat) { itemList.Add(74837); }
            if(Settings.IronpawTokensSettings.Instance.RawCrabMeat) { itemList.Add(74838); }
            if(Settings.IronpawTokensSettings.Instance.WildfowlBreast) { itemList.Add(74839); }

            if(Settings.IronpawTokensSettings.Instance.GreenCabbage) { itemList.Add(74840); }
            if(Settings.IronpawTokensSettings.Instance.JuicycrunchCarrot) { itemList.Add(74841); }
            if(Settings.IronpawTokensSettings.Instance.MoguPumpkin) { itemList.Add(74842); }
            if(Settings.IronpawTokensSettings.Instance.Scallions) { itemList.Add(74843); }
            if(Settings.IronpawTokensSettings.Instance.RedBlossomLeek) { itemList.Add(74844); }
            if(Settings.IronpawTokensSettings.Instance.Witchberries) { itemList.Add(74846); }
            if(Settings.IronpawTokensSettings.Instance.JadeSquash) { itemList.Add(74847); }
            if(Settings.IronpawTokensSettings.Instance.StripedMelon) { itemList.Add(74848); }
            if(Settings.IronpawTokensSettings.Instance.PinkTurnip) { itemList.Add(74849); }
            if(Settings.IronpawTokensSettings.Instance.WhiteTurnip) { itemList.Add(74850); }

            itemList.AddRange(FilterMisc);
            return (itemList.ToArray());
        }

        public bool ExtensiveCheck() {
            if(StyxWoW.Me.Combat || StyxWoW.Me.IsActuallyInCombat) { return false; }
            if(ObjectManager.GetObjectsOfType<WoWUnit>().Any(unit => unit.Aggro || unit.PetAggro)) { return false; }
            return !StyxWoW.Me.IsOnTransport && !StyxWoW.Me.IsGhost && !StyxWoW.Me.IsDead;
        }

        // ===========================================================
        // Inner and Anonymous Classes
        // ===========================================================

        private static int UpdateShoppingList(int id) {
            CustomLog.Diagnostic("ItemID : {0} : {1}", id, ItemList.Any(u => u == id) ? Lua.GetReturnVal<int>(string.Format("return GetItemCount({0})", id), 0) : 0);
            return ItemList.Any(u => u == id) ? Lua.GetReturnVal<int>(string.Format("return GetItemCount({0})", id), 0) : 0;
        }

        private static bool HaveItem(int id) {
            _itemToUse = StyxWoW.Me.CarriedItems.FirstOrDefault(i => i.Entry == id);
            return (StyxWoW.Me.BagItems.FirstOrDefault(i => i.Entry == id) != null);
        }

        private static int BagCount(int itemIdQuantity, int containerIdQuantity, int minQuantity) {
            double aa = ((itemIdQuantity / minQuantity) - containerIdQuantity);
            int bb = Convert.ToInt16(Math.Floor(aa));
            return bb;
        }

        private static bool AreNPCsNear() {
            return ((ObjectManager.GetObjectsOfType<WoWUnit>().FirstOrDefault(npc => npc.Entry == 64395) != null) &&
                   (ObjectManager.GetObjectsOfType<WoWUnit>().FirstOrDefault(npc => npc.Entry == 64940) != null));
        }

        private static void MerchantBuy(int containerId, int quantity) {
            if(quantity > 20) {
                quantity = 20;
            }

            var getItemInfo = Lua.GetReturnValues(string.Format("return GetItemInfo({0});", containerId));
            var itemName = getItemInfo[0];
            if(string.IsNullOrEmpty(itemName)) {
                CustomLog.Normal("Can't find vendor item.");
                return;
            }

            Lua.DoString(string.Format("for i=1, GetMerchantNumItems() do local l=GetMerchantItemLink(i) if l then if l:find('{0}') then BuyMerchantItem(i, {1})end end end", itemName, quantity));
            ShopTimer.Restart();
        }

        private static void CountAndBuyFromMerchant(int itemId, int containerId, int minQuantity) {
            if(_buying) {
                return;
            }

            var quantity = BagCount(UpdateShoppingList(itemId), UpdateShoppingList(containerId), minQuantity);

            if(quantity <= 0) {
                return;
            }

            _buying = true;
            MerchantBuy(containerId, quantity);
        }

        private static void GoShopping() {
            if(Combinables.All(t => BagCount(UpdateShoppingList(t.Item1), UpdateShoppingList(t.Item2), t.Item3) <= 0)) {
                _shoppingStep = 1;
                return;
            }

            if(ShopTimer.ElapsedMilliseconds >= 2000) {
                _buying = false;
            }

            var shopNPC = ObjectManager.GetObjectsOfType<WoWUnit>().FirstOrDefault(npc => npc.Entry == 64940);
            if(shopNPC == null) {
                return;
            }

            if(shopNPC.WithinInteractRange) {
                if(StyxWoW.Me.IsMoving) { WoWMovement.MoveStop(); }
                if(!MerchantFrame.Instance.IsVisible) { shopNPC.Interact(); }
                foreach(var u in Combinables.Where(u => UpdateShoppingList(u.Item1) >= u.Item3)) {
                    CountAndBuyFromMerchant(u.Item1, u.Item2, u.Item3);
                }
            } else {
                Navigator.MoveTo(shopNPC.Location);
            }
        }

        private static void CreateGroceries() {
            if(MerchantFrame.Instance.IsVisible) { MerchantFrame.Instance.Close(); }
            if(Combinables.All(t => UpdateShoppingList(t.Item1) < t.Item3)) {
                _shoppingStep = 2;
                return;
            }

            if(!StyxWoW.Me.IsCasting && !StyxWoW.Me.IsChanneling && Combinables.Any(t => HaveItem(t.Item2) && UpdateShoppingList(t.Item1) >= t.Item3)) {
                _itemToUse.Use();
            }
        }

        private static void MoveToTurnIn() {
            if(!HaveItem(87557)) {
                _shoppingStep = 0;
                return;
            }

            var questNPC = ObjectManager.GetObjectsOfType<WoWUnit>().FirstOrDefault(npc => npc.Entry == 64395);
            if(questNPC == null) return;
            if(questNPC.WithinInteractRange) {
                if(StyxWoW.Me.IsMoving) { WoWMovement.MoveStop(); }
                if(!QuestFrame.Instance.IsVisible || GossipFrame.Instance.IsVisible) { questNPC.Interact(); }
                Lua.DoString("SelectGossipAvailableQuest(1)");
                QuestFrame.Instance.CompleteQuest();
                QuestFrame.Instance.SelectQuestReward(1);
            } else { Navigator.MoveTo(questNPC.Location); }
        }
    }
}
