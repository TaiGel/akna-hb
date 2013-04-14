#region Information
// Behavior originally contributed by AknA.
// CODMail is a Quest Behavior developed after a PB question by Sowsix
// This project ended up being harder than I first expected.
// First I really had to learn how to do proper Behavior Tree programming.
// Then it was to code all the methods to stack/split/mail.
// Special thanks to HighVoltz for the stacking method, it was more clean than the one I made.
// Special thanks to chinajade for all the help with Behavior Tree programming questions.
// 
// Examples :
// This would send 1 stack of Windwool Cloth with COD 1 gold, 2 silver, 3 copper to AknA
// <CustomBehavior File="Misc\CODMail" Name="AknA" ItemID="72988" Amount="20" CodGold="1" CodSilver="2" CodCopper="3" />
// This would send 1 Windwool Cloth (not 1 stack but 1 cloth) without COD to AknA
// <CustomBehavior File="Misc\CODMail" Name="AknA" ItemID="72988" />
//
// This behavior will only attach ONE item / mail, so NEVER set the Amount bigger than the biggest stacksize.
//
// Name = Name of the one you want to send the mail to (REQUIRED)
// ItemID = The itemID of the item you want to send (REQUIRED)
// Amount = Stacksize of the item you want to send (OPTIONAL, default = 1)
// CodGold = Gold for the COD (OPTIONAL, default = 0)
// CodSilver = Silver for the COD (OPTIONAL, default = 0)
// CodCopper = Copper for the COD (OPTIONAL, default = 0)
//
// This behavior will stack all your stackable items.
// This behavior will split a stack if needed if you have more in a stack than you want to send.
//
#endregion

#region Using
using System;
using System.Linq;
using System.Collections.Generic;
using System.Diagnostics;
using System.Windows.Media;

using Styx.Common;
using Styx.CommonBot;
using Styx.CommonBot.Frames;
using Styx.Pathing;
using Styx.WoWInternals;
using Styx.WoWInternals.WoWObjects;
using Styx.CommonBot.Profiles;
using Styx.TreeSharp;

using CommonBehaviors.Actions;
using Action = Styx.TreeSharp.Action;
#endregion

namespace Styx.Bot.Quest_Behaviors {
    [CustomBehaviorFileName(@"Misc\CODMail")]
    public class CODMail : CustomForcedBehavior {
        public CODMail(Dictionary<string, string> args)
		: base(args) {
            try {
                Name = GetAttributeAs("Name", true, ConstrainAs.StringNonEmpty, null);
                ItemID = GetAttributeAsNullable("ItemID", true, ConstrainAs.ItemId, null) ?? 0;
                Amount = GetAttributeAsNullable("Amount", false, ConstrainAs.Milliseconds, null) ?? 1;
                CodGold = GetAttributeAsNullable("CodGold", false, ConstrainAs.Milliseconds, null) ?? 0;
                CodSilver = GetAttributeAsNullable("CodSilver", false, ConstrainAs.Milliseconds, null) ?? 0;
                CodCopper = GetAttributeAsNullable("CodCopper", false, ConstrainAs.Milliseconds, null) ?? 0;
            }

            catch (Exception except) {
                // Maintenance problems occur for a number of reasons.  The primary two are...
                // * Changes were made to the behavior, and boundary conditions weren't properly tested.
                // * The Honorbuddy core was changed, and the behavior wasn't adjusted for the new changes.
                // In any case, we pinpoint the source of the problem area here, and hopefully it
                // can be quickly resolved.
                LogMessage("error", "BEHAVIOR MAINTENANCE PROBLEM: " + except.Message
                                    + "\nFROM HERE:\n"
                                    + except.StackTrace + "\n");
                IsAttributeProblem = true;
            }
        }
        #region Variables
        // Attributes provided by caller
        public string Name { get; private set; }
        public int ItemID { get; private set; }
        public int Amount { get; private set; }
        public int CodGold { get; private set; }
        public int CodSilver { get; private set; }
        public int CodCopper { get; private set; }

        // Private variables for internal state
        private static bool _mailSent;
        private bool _IsDisposed;
        private bool _DoneStacking;
        private bool _DoneSplitting;
        private Composite _Root;
        private static WoWGameObject _mailbox;
        private readonly Stopwatch _StackerTimer = new Stopwatch();
        private static void CODLog(string message, params object[] args) { Logging.Write(Colors.DeepSkyBlue, "[CODMail]: " + message, args); }
        #endregion

        #region Lua Stack Method
        private const string StackLua = @"
            local items={}  
            local done = 1  
            for bag = 0,4 do  
                for slot=1,GetContainerNumSlots(bag) do  
                    local id = GetContainerItemID(bag,slot)  
                    local _,c,l = GetContainerItemInfo(bag, slot)  
                    if id ~= nil then  
                        local n,_,_,_,_,_,_, maxStack = GetItemInfo(id)  
                        if c < maxStack then  
                            if items[id] == nil then  
                                items[id] = {left=maxStack-c,bag=bag,slot=slot,locked = l or 0}  
                            else  
                                if items[id].locked == 0 then  
                                    PickupContainerItem(bag, slot)  
                                    PickupContainerItem(items[id].bag, items[id].slot)  
                                    items[id] = nil  
                                else  
                                    items[id] = {left=maxStack-c,bag=bag,slot=slot,locked = l or 0}  
                                end  
                                done = 0  
                            end  
                        end  
                    end  
                end  
            end  
            return done 
        ";
        #endregion

        #region Dispose
        ~CODMail() {
            Dispose(false);
        }

        public void Dispose(bool isExplicitlyInitiatedDispose) {
            if (!_IsDisposed) {
                // NOTE: we should call any Dispose() method for any managed or unmanaged
                // resource, if that resource provides a Dispose() method.

                // Clean up managed resources, if explicit disposal...
                if (isExplicitlyInitiatedDispose) { }  // empty, for now

                // Clean up unmanaged resources (if any) here...
                BotEvents.OnBotStop -= BotEvents_OnBotStop;
                _mailSent = false;
                _mailbox = null;

                // Call parent Dispose() (if it exists) here ...
                base.Dispose();
            }
            _IsDisposed = true;
        }

        public void BotEvents_OnBotStop(EventArgs args) { Dispose(); }
        #endregion

        #region Lua Methods
        private void SplitItemStack() {
            Lua.DoString(
                string.Format(
                "local amount = {0}; ", Amount) +
                string.Format(
                "local item = {0}; ", ItemID) +
                "local ItemBagNr = 0; " +
                "local ItemSlotNr = 1; " +
                "local EmptyBagNr = 0; " +
                "local EmptySlotNr = 1; " +
                "SplitDone = 0; " +
                "for b=0,4 do " +
                    "for s=1,GetContainerNumSlots(b) do " +
                        "if GetContainerItemID(b,s) == item then " +
                            "ItemBagNr = b; " +
                            "ItemSlotNr = s; " +
                        "end; " +
                    "end; " +
                "end; " +
                "for b=0,4 do " +
                    "for s=1,GetContainerNumSlots(b) do " +
                        "if GetContainerItemID(b,s) == nil then " +
                            "EmptyBagNr = b; " +
                            "EmptySlotNr = s; " +
                        "end; " +
                    "end; " +
                "end; " +
                "ClearCursor(); " +
                "SplitContainerItem(ItemBagNr,ItemSlotNr,amount); " +
                "if CursorHasItem() then " +
                    "PickupContainerItem(EmptyBagNr,EmptySlotNr); " +
                    "ClearCursor(); " +
                    "SplitDone = 1; " +
                "end;"
            );
        }
        
        private void AttachItem() {
            Lua.DoString(
                string.Format(
                "local item = {0} ", ItemID) +
                string.Format(
                "local amount = {0} ", Amount) +
                "attachDone = 0 " +
                "for b=0,4 do " +
                    "for s=1,GetContainerNumSlots(b) do " +
                        "if ((GetContainerItemID(b,s) == item) and (select(2, GetContainerItemInfo(b,s)) == amount)) then " +
                            "UseContainerItem(b,s) " +
                            "attachDone = 1 " +
                        "end " +
                    "end " +
                "end"
            );
        }

        private int GetStackInfo() {
            return Lua.GetReturnVal<int>(
                string.Format(
                "local item = {0} ", ItemID) +
                "for b=0,4 do " +
                    "for s=1,GetContainerNumSlots(b) do " +
                        "if GetContainerItemID(b,s) == item then " +
                            "return( (select(2, GetContainerItemInfo(b,s))) ) " +
                        "end " +
                    "end " +
                "end ", 0
            );
        }
        #endregion

        #region Overrides of CustomForcedBehavior
        protected override Composite CreateBehavior() {
            return _Root ?? (_Root =
                new PrioritySelector(context => !_mailSent,
                    // If we haven't located nearest mailbox, find it...
                    new Decorator(context => _mailbox == null,
                        new Action(context => {
                            _mailbox =
                                ObjectManager.GetObjectsOfType<WoWGameObject>().Where(
                                o => o.SubType == WoWGameObjectType.Mailbox)
                                .OrderBy(o => o.Distance).FirstOrDefault();
                            if (_mailbox == null) {
                                CODLog("Unable to locate a nearby mailbox");
                                _mailSent = true;
                            }
                        })
                    ),
                    // If we're to far from the mailbox, move withing interaction distance...
                    new Decorator(context => (_mailbox != null && _mailbox.Distance > _mailbox.InteractRange),
                        new Action(context => {
                            CODLog("Moving to {0}", _mailbox.Name);
                            Navigator.MoveTo(_mailbox.Location);
                        })
                    ),
                    // Stack Items if needed...
                    new Decorator(context => (!_DoneStacking),
                        new Action(context => {
                            if (!_StackerTimer.IsRunning) {
                                _StackerTimer.Start();
                                CODLog("Stacking items, please wait.");
                                Lua.DoString(StackLua);
                            }
                            if (_StackerTimer.ElapsedMilliseconds > 500) {
                                _StackerTimer.Reset();
                                _DoneStacking = Lua.GetReturnVal<int>(StackLua, 0) == 1;
                            }
                        })
                    ),
                    // Split Items if needed...
                    new Decorator(context => ((GetStackInfo() != Amount) && !_DoneSplitting),
                        new Action(context => {
                            CODLog("Spliting item, please wait.");
                            SplitItemStack();
                            _DoneSplitting = Lua.GetReturnVal<int>("return SplitDone", 0) == 1;
                        })
                    ),
                    // Open Mailbox...
                    new Decorator(context => (_mailbox != null && !MailFrame.Instance.IsVisible),
                        new Action(context => { _mailbox.Interact(); } )
                    ),
                    // Mail our stuff...
                    new Decorator(context => (_mailbox != null && MailFrame.Instance.IsVisible),
                        new Sequence(
                            // Fixing all settings in the mail...
                            new WaitContinue(TimeSpan.FromMilliseconds(300), context => false, new ActionAlwaysSucceed()),
                            new Action(context => {
                                Lua.DoString(
                                    "MailFrameTab2:Click(); " +
                                    string.Format(
                                    "SendMailNameEditBox:SetText(\"{0}\"); ", Name),
                                    string.Format(
                                    "SendMailSubjectEditBox:SetText(\"{0}\"); ", Lua.GetReturnVal<string>(string.Format("return GetItemInfo({0})", ItemID), 0))
                                );
                                // Attach the item
                                AttachItem();
                                // Set COD if we should
                                if ((CodGold > 0) || (CodSilver > 0) || (CodCopper > 0)) {
                                    Lua.DoString(
                                        string.Format(
                                        "SendMailMoneyGold:SetText(\"{0}\"); ", CodGold) +
                                        string.Format(
                                        "SendMailMoneySilver:SetText(\"{0}\"); ", CodSilver) +
                                        string.Format(
                                        "SendMailMoneyCopper:SetText(\"{0}\"); ", CodCopper) +
                                        "SendMailCODButton:Click();"
                                    );
                                }
                            }),
                            new WaitContinue(TimeSpan.FromMilliseconds(300), context => false, new ActionAlwaysSucceed()),
                            new Action(context => {
                                // Send the mail...
                                if (Lua.GetReturnVal<int>("return attachDone", 0) == 1) {
                                    Lua.DoString("SendMailMailButton:Click();");
                                    MailFrame.Instance.Close();
                                    _mailSent = true;
                                }
                                // If we can't attach the item to the mail then abort...
                                else {
                                    CODLog(string.Format("You don't have {0} of {1}, or you have selected a too big stack amount.", 
                                        Amount, Lua.GetReturnVal<string>(string.Format("return GetItemInfo({0})", ItemID), 0)));
                                    MailFrame.Instance.Close();
                                    _mailSent = true;
                                }
                            })
                        )
                    )
                )
            );
        }

        public override void Dispose() {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        public override bool IsDone { get { return (_mailSent); } }

        public override void OnStart() {
            // This reports problems, and stops BT processing if there was a problem with attributes...
            // We had to defer this action, as the 'profile line number' is not available during the element's
            // constructor call.
            OnStart_HandleAttributeProblem();

            if (!IsDone) {
                BotEvents.OnBotStop += BotEvents_OnBotStop;
            }
        }
        #endregion
    }
}
