--[[
			%%%%%%				%%%%%%%%%%			%%%%%%%%%%%%
		%%%%%%%%%%%%%   	%%%%%%%%%%%%%%%%%%%		   %%%%%%	
	   %%%        %%%%    %%%%%            %%%%%        %%%%
	  %%%%		   %%%    %%%%			    %%%%        %%%%
      %%%%%				  %%%%               %%%		%%%%
	   %%%%%%   		  %%%%							%%%%
		  %%%%%%          %%%%							%%%%
              %%%%%       %%%%         %%%%%%			%%%%
			     %%%%     %%%%%         %%%%%%% 		%%%%
			     %%%%%     %%%%%           %%%%			%%%%
			    %%%%%       %%%%%		  %%%%			%%%%
	 %%%%     %%%%%           %%%%%%%%%%%%%%%          %%%%%%
	  %%%%%%%%%%			   %%%%%%%%%%%%%        %%%%%%%%%%%%

	  SuperGuildInvite 
	  
											Written by
											
			Janniie - Stormreaver EU


]]

-- File global variables --
local DATA_INDEX
local LOGO = "|cffffff00<|r|cff16ABB5SGI|r|cffffff00>|r "
SLASH_SUPERGUILDINVITE1 = '/sgi'
SLASH_SUPERGUILDINVITE2 = '/superguildinvite'
local VERSION_MAJOR = "6.2"
local VERSION_MINOR = ""

local SuperScanInterval = 9
local SuperScanLast = 0
local SuperScanProgress = 1
local whoQueryList 
local whoSent
local ScanInProgress = false
local SGI_QUEUE = {}
local SGI_ANTI_SPAM = {}
local SGI_TEMP_BAN = {}
local SGI_InviteFrames = {}
local whisperWaiting = {}
local WhisperQueue = {}

local sessionTotal = 0
local amountScanned = 0
local amountGuildless = 0
local amountQueued = 0

local ID_REQUEST = "SGI_REQ"
local ID_MASSLOCK = "SGI_MASS"
local ID_LOCK = "SGI_LOCK"
local ID_SHIELD = "I_HAVE_SHIELD"
local ID_VERSION = "SGI_VERSION"
local ID_LIVE_SYNC = "SGI_LIVE_SYNC"
RegisterAddonMessagePrefix(ID_REQUEST)
RegisterAddonMessagePrefix(ID_LOCK)
RegisterAddonMessagePrefix(ID_SHIELD)
RegisterAddonMessagePrefix(ID_MASSLOCK)
RegisterAddonMessagePrefix(ID_VERSION)
RegisterAddonMessagePrefix(ID_LIVE_SYNC)

local MinimapLoad

local L

local GetTime = GetTime
local strfind = strfind
local strsub = strsub
local tonumber = tonumber
----------------------------

-- This functioncauses the who window not to be displayed --
--WhoList_Update()
local function DontShowWho()
	local numWhos, totalCount = GetNumWhoResults();
	local name, guild, level, race, class, zone;
	local button, buttonText, classTextColor, classFileName;
	local columnTable;
	local whoOffset = FauxScrollFrame_GetOffset(WhoListScrollFrame);
	local whoIndex;
	local showScrollBar = nil;
	if ( numWhos > WHOS_TO_DISPLAY ) then
		showScrollBar = 1;
	end
	local displayedText = "";
	if ( totalCount > MAX_WHOS_FROM_SERVER ) then
		displayedText = format(WHO_FRAME_SHOWN_TEMPLATE, MAX_WHOS_FROM_SERVER);
	end
	WhoFrameTotals:SetText(format(WHO_FRAME_TOTAL_TEMPLATE, totalCount).."  "..displayedText);
	for i=1, WHOS_TO_DISPLAY, 1 do
		whoIndex = whoOffset + i;
		button = _G["WhoFrameButton"..i];
		button.whoIndex = whoIndex;
		name, guild, level, race, class, zone, classFileName = GetWhoInfo(whoIndex);
		columnTable = { zone, guild, race };

		if ( classFileName ) then
			classTextColor = RAID_CLASS_COLORS[classFileName];
		else
			classTextColor = HIGHLIGHT_FONT_COLOR;
		end
		buttonText = _G["WhoFrameButton"..i.."Name"];
		buttonText:SetText(name);
		buttonText = _G["WhoFrameButton"..i.."Level"];
		buttonText:SetText(level);
		buttonText = _G["WhoFrameButton"..i.."Class"];
		buttonText:SetText(class);
		buttonText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);
		local variableText = _G["WhoFrameButton"..i.."Variable"];
		variableText:SetText(columnTable[UIDropDownMenu_GetSelectedID(WhoFrameDropDown)]);
		
		-- If need scrollbar resize columns
		if ( showScrollBar ) then
			variableText:SetWidth(95);
		else
			variableText:SetWidth(110);
		end

		-- Highlight the correct who
		if ( WhoFrame.selectedWho == whoIndex ) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
		
		if ( whoIndex > numWhos ) then
			button:Hide();
		else
			button:Show();
		end
	end

	if ( not WhoFrame.selectedWho ) then
		WhoFrameGroupInviteButton:Disable();
		WhoFrameAddFriendButton:Disable();
	else
		WhoFrameGroupInviteButton:Enable();
		WhoFrameAddFriendButton:Enable();
		WhoFrame.selectedName = GetWhoInfo(WhoFrame.selectedWho); 
	end

	-- If need scrollbar resize columns
	if ( showScrollBar ) then
		WhoFrameColumn_SetWidth(WhoFrameColumnHeader2, 105);
		UIDropDownMenu_SetWidth(WhoFrameDropDown, 80);
	else
		WhoFrameColumn_SetWidth(WhoFrameColumnHeader2, 120);
		UIDropDownMenu_SetWidth(WhoFrameDropDown, 95);
	end

	-- ScrollFrame update
	FauxScrollFrame_Update(WhoListScrollFrame, numWhos, WHOS_TO_DISPLAY, FRIENDS_FRAME_WHO_HEIGHT );

	PanelTemplates_SetTab(FriendsFrame, 2);
end
local function ShowWhoFrame()
	DontShowWho()
	ShowUIPanel(FriendsFrame)
end

local old = print
local function print(...)
	if not SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_MUTE"] then
		old("|cffffff00<|r|cff16ABB5SGI|r|cffffff00>|r|cffffff00",...,"|r")
	end
end

-- && Format seconds to:    && --
-- && X hours Y mins Z secs && --
	
local function FormatTime(T)
	local R,S,M,H = ""
	T = floor(T)
	H = floor(T/3600)
	M = floor((T-3600*H)/60)
	S = T-(3600*H + 60*M)
		
	if T <= 0 then
		return L["less than 1 second"]
	end
		
	if H ~= 0 then
		R =  R..H..L[" hours "]
	end
	if M ~= 0 then
		R = R..M..L[" minutes "]
	end
	if S ~= 0 then
		R = R..S..L[" seconds"]
	end
	
	return R
end

local function CountTable(T)
	local i = 0
	if type(T) ~= "table" then
		return i
	end
	for k,_ in pairs(T) do
		i = i + 1
	end
	return i
end

local function LoadLocale()
	local Locale = GetLocale()
		
	if SGI_Locale[Locale] then 
		L = SGI_Locale[Locale]
		print(L["English Locale loaded"]..L["Author"])
		return true
	else
		L = SGI_Locale["enGB"]
		print("|cffffff00Locale missing! Loaded English.|r")
		return false
	end

end

local function FormatWhisper(msg,name)
	local whisper = msg
	if not name then name = "ExampleName" end
	local guildName,guildLevel = GetGuildInfo(UnitName("Player")),GetGuildLevel()
	if not guildName then guildName = "<InvalidName>" end
	if not guildLevel then guildLevel = "<InvalidLevel>" end
	if strfind(msg,"PLAYER") then
		whisper = strsub(msg,1,strfind(msg,"PLAYER")-1)..name..strsub(msg,strfind(msg,"PLAYER")+6)
	end
	if strfind(whisper,"NAME") then
		whisper = strsub(whisper,1,strfind(whisper,"NAME")-1)..guildName..strsub(whisper,strfind(whisper,"NAME")+4)
	end
	if strfind(whisper,"LEVEL") then
		whisper = strsub(whisper,1,strfind(whisper,"LEVEL")-1)..guildLevel..strsub(whisper,strfind(whisper,"LEVEL")+5)
	end
	return whisper
end

local function PickRandomWhisper()
	local i = 0
	local tbl = {}
	for k,_ in pairs(SGI_DATA[DATA_INDEX].settings.whispers) do
		i = i + 1
		tbl[i] = SGI_DATA[DATA_INDEX].settings.whispers[k]
	end
	if #tbl == 0 then
		return SGI_DATA[DATA_INDEX].settings.whisper
	end
	return tbl[random(#tbl)]
end

local function GetClassColor(classFileName)
	if classFileName == "DEATHKNIGHT" then
		return "C41F3B" 
	elseif classFileName == "DRUID" then
		return "FF7D0A"
	elseif classFileName == "HUNTER" then
		return "ABD473"
	elseif classFileName == "MAGE" then
		return "69CCF0"
	elseif classFileName == "MONK" then
		return "558A84"
	elseif classFileName == "PALADIN" then
		return "F58CBA"
	elseif classFileName == "PRIEST" then
		return "FFFFFF"
	elseif classFileName == "ROGUE" then
		return "FFF569"
	elseif classFileName == "SHAMAN" then
		return "0070DE"
	elseif classFileName == "WARLOCK" then
		return "9482C9"
	elseif classFileName == "WARRIOR" then
		return "C79C6E"
	else
		return "857C7C"
	end
end

local function shouldWhisper(name)
	for k,_ in pairs(whisperWaiting) do
		if k == name then
			return true
		end
	end
end

function SetFramePos(frame)
	if not frame then return end
	local name = frame:GetName()
	if type(SGI_DATA[DATA_INDEX].settings.frames[name]) ~= "table" then
		SGI_DATA[DATA_INDEX].settings.frames[name] = {}
	end
	if name == "SGI_MiniMapButton" then
		SGI_DATA[DATA_INDEX].settings.frames[name][3] = SGI_DATA[DATA_INDEX].settings.frames[name][3] or -58.32
		SGI_DATA[DATA_INDEX].settings.frames[name][4] = SGI_DATA[DATA_INDEX].settings.frames[name][4] or -51.79
	end
	SGI_DATA[DATA_INDEX].settings.frames[name][1] = SGI_DATA[DATA_INDEX].settings.frames[name][1] or "CENTER"
	SGI_DATA[DATA_INDEX].settings.frames[name][2] = SGI_DATA[DATA_INDEX].settings.frames[name][2] or "CENTER"
	SGI_DATA[DATA_INDEX].settings.frames[name][3] = SGI_DATA[DATA_INDEX].settings.frames[name][3] or 0
	SGI_DATA[DATA_INDEX].settings.frames[name][4] = SGI_DATA[DATA_INDEX].settings.frames[name][4] or 0

	if name == "SGI_MiniMapButton" then
		frame:SetPoint(
			SGI_DATA[DATA_INDEX].settings.frames[name][1],
			Minimap,
			SGI_DATA[DATA_INDEX].settings.frames[name][2],
			SGI_DATA[DATA_INDEX].settings.frames[name][3],
			SGI_DATA[DATA_INDEX].settings.frames[name][4]
		)
	else
		frame:SetPoint(
			SGI_DATA[DATA_INDEX].settings.frames[name][1],
			UIParent,
			SGI_DATA[DATA_INDEX].settings.frames[name][2],
			SGI_DATA[DATA_INDEX].settings.frames[name][3],
			SGI_DATA[DATA_INDEX].settings.frames[name][4]
		)
	end
end

local function GetFramePos(frame)
	if not frame then return end
	local name = frame:GetName()
	if type(SGI_DATA[DATA_INDEX].settings.frames[name]) ~= "table" then
		SGI_DATA[DATA_INDEX].settings.frames[name] = {}
	end
	local point,relativeTo,relativePoint,xOfs,yOfs = frame:GetPoint()
	
	SGI_DATA[DATA_INDEX].settings.frames[name][1] = point
	SGI_DATA[DATA_INDEX].settings.frames[name][2] = relativePoint
	SGI_DATA[DATA_INDEX].settings.frames[name][3] = xOfs
	SGI_DATA[DATA_INDEX].settings.frames[name][4] = yOfs
end

local function SendLocks(target)
	local parts = {}
	local piece = "SGI_V"
	local i = 0
	for k,_ in pairs(SGI_DATA.lock) do
		piece = piece..":"..k
		if strlen(piece) > 200 then
			i = i + 1
			parts[i] = piece
			piece = "SGI_V"
		end
	end
	local f = CreateFrame("Frame")
	local t,j = 0,0
	f:SetScript("OnUpdate",function()
		if GetTime() > t then
			for h = 1,5 do
				j = j + 1
				if not parts[j] then
					f:SetScript("OnUpdate",nil)
					return
				end
				SendAddonMessage(ID_MASSLOCK,parts[j],"WHISPER",target)
			end
			t = GetTime() + 2
		end
	end)
end

local function divide(str,div)
	local out = {}
	local i = 0
	while strfind(str,div) do
		i = i + 1
		out[i] = strsub(str,1,strfind(str,div)-1)
		str = strsub(str,strfind(str,div)+1)
	end
	out[i+1] = str
	return out
end

local function RecievedLocks(msg)
	local locks = divide(msg,":")
	local new = 0
	for k,_ in pairs(locks) do
		if not SGI_DATA.lock[locks[k]] then
			SGI_DATA.lock[locks[k]] = "MASSSHARED"
			new = new + 1
		end
	end
	return new
end

local function RequestSync()
	SendAddonMessage(ID_REQUEST,"","GUILD")
end
	
	
local function LiveSync(name)
	SendAddonMessage(ID_LIVE_SYNC,name,"GUILD")
end

local function BackUp()
	local failed,c1
	if type(SGI_BACKUP) ~= "table" then
		SGI_BACKUP = {}
		c1 = true
	end
	if type(SGI_DATA.lock) == "table" then
		for k,_ in pairs(SGI_DATA.lock) do
			SGI_BACKUP[k] = SGI_DATA.lock[k]
		end
	elseif c1 then
		failed = true
	end
	for k,_ in pairs(SGI_BACKUP) do
		if not SGI_DATA.lock[k] then
			SGI_DATA.lock[k] = SGI_BACKUP[k]
		end
	end
	return failed
end

-- SuperScan related--

local function QueueInvite(name,level,classFile,race,class,found)
	SGI_QUEUE[name] = {
		level = level,
		class = class,
		classFile = classFile,
		race = race,
		found = found,
	}
--	GuildShield:IsShielded(name)
end

local function isException(name)
	if type(SGI_DATA[DATA_INDEX].settings.exceptions) ~= "table" then
		SGI_DATA[DATA_INDEX].settings.exceptions = {}
	end
	for k,_ in pairs(SGI_DATA[DATA_INDEX].settings.exceptions) do
		if strfind(name,k) then
			print(format(L["%s not put in queue because of exception %s"],name,k))
			return true
		end
	end
end

local function PutOnHold(name,level,classFile,race,class,found)
	if isException(name) then return end
	SGI_ANTI_SPAM[name] = {
		level = level,
		class = class,
		classFile = classFile,
		race = race,
		found = found,
	}
--	GuildShield:IsShielded(name)
end

local function SendWhisper(msg,target,delay)
	WhisperQueue[target] = { msg=msg, t=GetTime() + delay }
end

local WhisperDelay = CreateFrame("Frame")
WhisperDelay.update = 0
WhisperDelay:SetScript("OnUpdate",function()
	if GetTime() > WhisperDelay.update then
		local Now = GetTime()
		for k,_ in pairs(WhisperQueue) do
			if WhisperQueue[k].t < Now then
				SendChatMessage(WhisperQueue[k].msg,"WHISPER",nil,k)
				WhisperQueue[k] = nil
			end
		end
		WhisperDelay.update = GetTime() + 0.5
	end
end)

local function RemoveShielded(player)
	SGI_ANTI_SPAM[player] = nil
	print("|cffffff00Removed |r|cff00A2FF"..player.."|r|cffffff00 because they are shielded.|r")
end

local HoldTimer = CreateFrame("Frame")
local HoldUpdate = 0
HoldTimer:SetScript("OnUpdate",function()
	if HoldUpdate < GetTime() then
		for k,_ in pairs(SGI_ANTI_SPAM) do
			if SGI_ANTI_SPAM[k].found + 4 < GetTime() then
				SGI_QUEUE[k] = SGI_ANTI_SPAM[k]
				SGI_ANTI_SPAM[k] = nil
			end
		end
		HoldUpdate = GetTime() + 0.5
	end
end)

local function SendGuildInvite(self,button)
	local name = self.player
	if not name then name = next(SGI_QUEUE) button = "LeftButton" end
	if not name then return end
	if not SGI_DATA.lock[name] then
		SGI_DATA.lock[name] = "INVITED"
	end
	if button == "LeftButton" then
		if SGI_DATA[DATA_INDEX].settings.dropdown["SGI_WHISPER_MODE"] == 1 then
		
			--Just invite
			GuildInvite(name)
			
		elseif SGI_DATA[DATA_INDEX].settings.dropdown["SGI_WHISPER_MODE"] == 2 and SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_WHISPER"] then
			
			--Invite and register for a whisper
			GuildInvite(name)
			whisperWaiting[name] = 1
			
		elseif SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_WHISPER"] then
			
			--Just whisper
			SendChatMessage(FormatWhisper(PickRandomWhisper(),name),"WHISPER",nil,name)
			
		else
			print(L["You need to specify the mode in which you wish to invite"])
			print(L["Go to Options and slelect you Invite Mode"])
			print(L["You might also need to check enable whisper"])
		end
		SGI_QUEUE[name] = nil
		LiveSync(name)
		SendAddonMessage(ID_LOCK,name,"GUILD")
	else
		SGI_QUEUE[name] = nil
	end
end
local checker = CreateFrame("Frame")
checker.font = checker:CreateFontString(nil,"OVERLAY")
checker.font:SetFont("Fonts\\ARIALN.TTF",14)
local function DisplayLocks()
	print(L["Locked players are: "])
	for k,_ in pairs(SGI_DATA.lock) do
		local name = k
		checker.font:SetText(name)
		while checker.font:GetWidth() < 70 do
			name = name.." "
			checker.font:SetText(name)
		end
		print("|cffff8800"..name.."|r|cffffff00 locked by |r|cff00ffff"..SGI_DATA.lock[k].."|r")
	end
end

local function CreateScanQuery(low,high,int,race,class)
	local RuLoc = GetLocale()
	local Levels,i = {},low
	local Classes = {
			L["Death Knight"],
			L["Druid"],
			L["Hunter"],
			L["Mage"],
			L["Monk"],
			L["Paladin"],
			L["Priest"],
			L["Rogue"],
			L["Shaman"],
			L["Warlock"],
			L["Warrior"],
	}
	local Races = {}
	if UnitFactionGroup("player") == "Horde" then
		Races = {
			L["Orc"],
			L["Blood Elf"],
			L["Undead"],
			L["Troll"],
			L["Goblin"],
			L["Tauren"],
			L["Pandaren"],
		}
	else
		Races = {
			L["Human"],
			L["Dwarf"],
			L["Worgen"],
			L["Draenei"],
			L["Night Elf"],
			L["Gnome"],
			L["Pandaren"],
		}
	end
	while i + int < 85 and i + int < high do
		if i + int >= race and i + int >= class then
			for k,_ in pairs(Races) do
				for j,_ in pairs(Classes) do
					if RuLoc == "ruRU" then
						tinsert(Levels,i.."- -"..(i+int-1).." р-"..Races[k].. " к-"..Classes[j])
					else
						tinsert(Levels,i.."- -"..(i+int-1).." r-"..Races[k].. " c-"..Classes[j])
					end
				end
			end
		elseif i + int >= race then
			for k,_ in pairs(Races) do
				if RuLoc == "ruRU" then
					tinsert(Levels,i.."- -"..(i+int-1).." р-"..Races[k])
				else
					tinsert(Levels,i.."- -"..(i+int-1).." r-"..Races[k])
				end
			end
		elseif i + int >= class then
			for k,_ in pairs(Classes) do
				if RuLoc == "ruRU" then
					tinsert(Levels,i.."- -"..(i+int-1).." к-"..Classes[k])
				else
					tinsert(Levels,i.."- -"..(i+int-1).." c-"..Classes[k])
				end
			end
		else
			tinsert(Levels,i.."- -"..(i+int-1))
		end
		i = i + int 
	end
	local top = 85 > high and high or 85
	if top >= race and top >= class then
		for k,_ in pairs(Races) do
			for j,_ in pairs(Classes) do
				if RuLoc == "ruRU" then
					tinsert(Levels,i.."- -"..top.." р-"..Races[k].. " к-"..Classes[j])
				else
					tinsert(Levels,i.."- -"..top.." r-"..Races[k].. " c-"..Classes[j])
				end
			end
		end
	elseif top >= race then
		for k,_ in pairs(Races) do
			if RuLoc == "ruRU" then
				tinsert(Levels,i.."- -"..top.." р-"..Races[k])
			else
				tinsert(Levels,i.."- -"..top.." r-"..Races[k])
			end
		end
	elseif top >= class then
		for k,_ in pairs(Classes) do
			if RuLoc == "ruRU" then
				tinsert(Levels,i.."- -"..top.." к-"..Classes[k])
			else
				tinsert(Levels,i.."- -"..top.." c-"..Classes[k])
			end
		end
	else
		tinsert(Levels,i.."- -"..top)
	end
	
	if top == 85 then
		for p = top+1,high do
			if p >= race and p >= class then
				for k,_ in pairs(Races) do
					for j,_ in pairs(Classes) do
						if RuLoc == "ruRU" then
							tinsert(Levels,p.." р-"..Races[k].. " к-"..Classes[j])
						else
							tinsert(Levels,p.." r-"..Races[k].. " c-"..Classes[j])
						end
					end
				end
			elseif p >= race then
				for k,_ in pairs(Races) do
					if RuLoc == "ruRU" then
						tinsert(Levels,p.." р-"..Races[k])
					else
						tinsert(Levels,p.." r-"..Races[k])
					end
				end
			elseif p >= class then
				for k,_ in pairs(Classes) do
					if RuLoc == "ruRU" then
						tinsert(Levels,p.." к-"..Classes[k])
					else
						tinsert(Levels,p.." c-"..Classes[k])
					end
				end
			else
				tinsert(Levels,p)
			end
		end
	end
	if SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_DK_INV"] then
		if RuLoc == "ruRU" then
			tinsert(Levels,"55- -58 к-"..L["Death Knight"])
		else
			tinsert(Levels,"55- -58 c-"..L["Death Knight"])
		end
	end
	whoQueryList = Levels
end

local function SuperScan()
	if GetTime() > SuperScanLast + SuperScanInterval then
		if SuperScanProgress == #whoQueryList + 1 then
			SuperScanProgress = 1
			SuperScanLast = GetTime()
			SuperScanFrame.timeT = GetTime()
			
			sessionTotal = sessionTotal + amountScanned
			
			print("|cff16ABB5",L["Scan Completed"],"|r")
			print("|cff16ABB5"..format(L["PlayersScanned"],amountScanned,sessionTotal).."|r")
			print("|cff16ABB5"..format(L["PlayersGuildLess"],amountGuildless,(floor(1000*amountGuildless/amountScanned)/10)).."|r")
			print("|cff16ABB5"..format(L["InvitesQueued"],amountQueued).."|r")
			
			amountScanned = 0
			amountGuildless = 0
			amountQueued = 0
		else
			SetWhoToUI(1)
			WhoList_Update = DontShowWho
			FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")
			SendWho(whoQueryList[SuperScanProgress])
			whoSent = true
			SuperScanLast = GetTime()
			print("|cff16ABB5"..L["Who sent: "].."|r|cff44FF44"..whoQueryList[SuperScanProgress].."|r")
		end
	end		
end
CreateFrame("Frame","SuperScanFrameTimer")

local function BroadcastVersion()
	SendAddonMessage(ID_VERSION,VERSION_MAJOR,"GUILD")
end


local function ProcessSystemMsg(msg)
	local place = strfind(ERR_GUILD_INVITE_S,"%s",1,true)
	local n = strsub(msg,place)
	local name = strsub(n,1,(strfind(n,"%s") or 2)-1)
	if format(ERR_GUILD_INVITE_S,name) == msg then
		return "invite",name
	end
	
	place = strfind(ERR_GUILD_DECLINE_S,"%s",1,true)
	n = strsub(msg,place)
	name = strsub(n,1,(strfind(n,"%s") or 2)-1)
	if format(ERR_GUILD_DECLINE_S,name) == msg then
		return "decline",name
	end
	
	place = strfind(ERR_ALREADY_IN_GUILD_S,"%s",1,true)
	n = strsub(msg,place)
	name = strsub(n,1,(strfind(n,"%s") or 2)-1)
	if format(ERR_ALREADY_IN_GUILD_S,name) == msg then
		return "guilded",name
	end
	
	place = strfind(ERR_ALREADY_INVITED_TO_GUILD_S,"%s",1,true)
	n = strsub(msg,place)
	name = strsub(n,1,(strfind(n,"%s") or 2)-1)
	if format(ERR_ALREADY_INVITED_TO_GUILD_S,name) == msg then
		return "already",name
	end
	
	place = strfind(ERR_GUILD_DECLINE_AUTO_S,"%s",1,true)
	n = strsub(msg,place)
	name = strsub(n,1,(strfind(n,"%s") or 2)-1)
	if format(ERR_GUILD_DECLINE_AUTO_S,name) == msg then
		return "auto",name
	end
	
	place = strfind(ERR_GUILD_JOIN_S,"%s",1,true)
	n = strsub(msg,place)
	name = strsub(n,1,(strfind(n,"%s") or 2)-1)
	if format(ERR_GUILD_JOIN_S,name) == msg then
		return "join",name
	end
	
	place = strfind(ERR_GUILD_PLAYER_NOT_FOUND_S,"%s",1,true)
	n = strsub(msg,place)
	name = strsub(n,1,(strfind(n,"%s") or 2)-2)
	if format(ERR_GUILD_PLAYER_NOT_FOUND_S,name) == msg then
		return "miss",name
	end
end

local function HandleSystemMsg(msg)
	local p,name = ProcessSystemMsg(msg)
	if not L then return end
	
	if p == "invite" then
		if shouldWhisper(name) then
			SendWhisper(FormatWhisper(PickRandomWhisper(),name),name,1)
		end
		whisperWaiting[name] = nil
	elseif p == "decline" then
		WhisperQueue[name] = nil
	elseif p == "auto" then
		if not SGI_DATA.lock[name] then
			SGI_DATA.lock[name] = "DECLINING"
		end
		WhisperQueue[name] = nil
	elseif p == "guilded" then
		-- old("|cffffff00<|r|cff16ABB5SGI|r|cffffff00>|r|cffffff00",(format(L["Unable to invite %s. They are already in a guild."],name)),"|r")
		SGI_DATA.lock[name] = nil
		SGI_BACKUP[name] = nil
		WhisperQueue[name] = nil
	elseif p == "already" then
		-- old("|cffffff00<|r|cff16ABB5SGI|r|cffffff00>|r|cffffff00",(format(L["Unable to invite %s. They will not be blacklisted."],name)),"|r")
		SGI_DATA.lock[name] = nil
		SGI_BACKUP[name] = nil
		WhisperQueue[name] = nil
	elseif p == "join" then
		PMGPlayerJoinedGuild(name)
	elseif p == "miss" then
		-- old("|cffffff00<|r|cff16ABB5SGI|r|cffffff00>|r|cffffff00",(format(L["Unable to invite %s. They will not be blacklisted."],name)),"|r")
		SGI_DATA.lock[name] = nil
		SGI_BACKUP[name] = nil
		WhisperQueue[name] = nil
	end
end

--[[
local function SetUpChatInterception()
	if SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_HIDE"] then
		ChatIntercept:State(nil)
	else
		ChatIntercept:State(nil)
	end
end
]]

-- Event handlers --
local SGI_EVENTS = {}

function SGI_EVENTS:PLAYER_LOGIN()
	if not DATA_INDEX then
		DATA_INDEX = UnitName("player").." - "..GetRealmName()
	end
	if type(SGI_DATA) ~= "table" then
		SGI_DATA = {}
	end
	if type(SGI_DATA.lock) ~= "table" then
		SGI_DATA.lock = {}
	end
	if type(SGI_DATA[DATA_INDEX]) ~= "table" then
		SGI_DATA[DATA_INDEX] = {}
	end
	if type(SGI_DATA[DATA_INDEX].settings) ~= "table" then
		SGI_DATA[DATA_INDEX].settings = {
			inviteMode = 1,
			frames = {},
			checkboxes = {},
			dropdown = {["SGI_WHISPER_MODE"] = 2},
			lowLimit = 1,
			highLimit = 90,
			raceStart = 90,
			classStart = 90,
			interval = 5,
			exceptions = {},
			whisper = "Dear PLAYER. Would you like to join <NAME> (Lvl LEVEL)? You would make great recruit, so please accept! :)",
		}
	end
	if type(SGI_DATA[DATA_INDEX].settings.whispers) ~= "table" then
		SGI_DATA[DATA_INDEX].settings.whispers = {}
	end
	if type(SGI_BACKUP) ~= "table" then
		SGI_BACKUP = SGI_DATA.lock
	end
	if MinimapLoad and not SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_MINI"] then
		MinimapLoad()
	end
--	GuildShield:Initiate(RemoveShielded)
--	SetUpChatInterception()
--	SetUpChatInterception()
	BroadcastVersion()
	RequestSync()
	BackUp()
	LoadLocale()
	print("|cffffff00Successfully loaded|r")
end

function SGI_EVENTS:WHO_LIST_UPDATE()
	if whoSent then
		whoSent = false
		SuperScanProgress = SuperScanProgress + 1
		local ETR = (#whoQueryList - SuperScanProgress + 1) * SuperScanInterval
		if SuperScanFrame then
			SuperScanFrame.timeV = ETR
			SuperScanFrame.timeS = GetTime()
		end
		for i = 1, GetNumWhoResults() do
			amountScanned = amountScanned + 1
			local name, guild, level, race, class, zone, classFileName = GetWhoInfo(i)
			if guild == "" then
				if SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_DK"] and classFileName == "DEATHKNIGHT" and level >= 55 and level <= 58 then
					print("Dk stopped:",name,level)
				end
				amountGuildless = amountGuildless + 1
				if not SGI_DATA.lock[name] then
					if SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_DK"] and classFileName == "DEATHKNIGHT" and level >= 55 and level <= 58 then
						print("|cffffff00Guildless DK filtered.|r")
					else
						PutOnHold(name,level,classFileName,race,class,GetTime())
						amountQueued = amountQueued + 1
					end
				end
			end
		end
		WhoList_Update = ShowWhoFrame		
	end
end

function SGI_EVENTS:CHAT_MSG_ADDON(event,...)
	local ID,msg,channel,sender = select(1,...)
	if sender == UnitName("player") then return end
	if ID == ID_SHIELD then
		SGI_DATA.lock[sender] = "SHIELD"
		SGI_QUEUE[sender] = nil
		SGI_ANTI_SPAM[sender] = nil
		print("|cffffff00The player: |r|cff22ff11"..sender.."|r|cffffff00 is protected by |r|cffff8800Guild|r|cff00A2FFShield|r")
	elseif ID == ID_LOCK then
		if not SGI_DATA.lock[sender] then
			SGI_DATA.lock[sender] = "SHARED"
		end
		SGI_QUEUE[sender] = nil
		print("|cffffff00Recieved shared lock on |r|cff22ff11"..msg.."|r|cffffff00 from |r|cff0044ee"..sender.."|r|cffffff00 ("..strlower(channel)..")|r")
	elseif ID == ID_REQUEST then
		BroadcastVersion()
		print("|cffffff00Recieved request of locksharing from |r|cff0033ff"..sender.."|r")
		SendLocks(sender)
	elseif ID == ID_MASSLOCK then
		print("|cffffff00 Recieved: "..RecievedLocks(msg).." new locks from |r|cff0033ff"..sender.."|r")
	elseif ID == ID_LIVE_SYNC then
		SGI_QUEUE[msg] = nil
		SGI_ANTI_SPAM[msg] = nil
		print("|cffffff00The player: |r|cff22ff11"..msg.."|r|cffffff00 was invited by someone in your guild. Removed from queue|r")
	end
end

function SGI_EVENTS:CHAT_MSG_SYSTEM(event,...)
	local msg = select(1,...)
	HandleSystemMsg(msg)
end

CreateFrame("Frame","SGI_EventHandler")
for k,_ in pairs(SGI_EVENTS) do	
	SGI_EventHandler:RegisterEvent(k)
end
SGI_EventHandler:SetScript("OnEvent",function(self,event,...)
	SGI_EVENTS[event](self,event,...)
end)

-- User Interface --

local function CreateNewButton(name,parent,width,height,label,anchor,OnClick)
	local f = CreateFrame("Button",name,parent,"UIPanelButtonTemplate")
	f:SetWidth(width)
	f:SetHeight(height)
	local Label = f:CreateFontString(name.."Font","OVERLAY","GameFontNormalSmall")
	Label:SetText(label)
	Label:SetPoint("CENTER")
	Label:SetWidth(width-10)
	
	if type(anchor) == "table" then
		f:SetPoint(anchor.point,parent,anchor.relativePoint,anchor.xOfs,anchor.yOfs)
	end
	f:SetScript("OnClick",OnClick)
	return f
end

local function CreateNewCheckbox(name,parent,label,anchor)
	local f = CreateFrame("CheckButton",name,parent,"OptionsBaseCheckButtonTemplate")
	local l = f:CreateFontString(name.."Font","OVERLAY","GameFontNormal")
	l:SetText(label)
	l:SetPoint("LEFT",f,"RIGHT",5,1)
	if type(anchor) == "table" then
		f:SetPoint(anchor.point,parent,anchor.relativePoint,anchor.xOfs,anchor.yOfs)
	end
	f:HookScript("OnClick",function(self)
		SGI_DATA[DATA_INDEX].settings.checkboxes[name] = self:GetChecked()
	end)
	if SGI_DATA[DATA_INDEX].settings.checkboxes[name] then
		f:SetChecked()
	end
	return f
end

local function CreateDropDown(Parent,NAME,anchor,ITEMS,name,label)
	local Drop = CreateFrame("Button", NAME, Parent, "UIDropDownMenuTemplate")

	Drop:ClearAllPoints()
	Drop:SetPoint(anchor.point,Parent,anchor.relativePoint,anchor.xOfs,anchor.yOfs)
	Drop:Show()
	
	local Label = Drop:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Label:SetPoint("BOTTOMLEFT",Drop,"TOPLEFT",20,5)
	Label:SetText(label or "")

	local items = {
	"All",
	"Deathknight",
	"Druid",
	"Hunter",
	"Paladin",
	"Mage",
	"Priest",
	"Rogue",
	"Shaman",
	"Warlock",
	"Warrior",
	}
	items = ITEMS or items
	name = name or "Class"
	local function OnClick(self)
		UIDropDownMenu_SetSelectedID(Drop, self:GetID())
		SGI_DATA[DATA_INDEX].settings.dropdown[name] = self:GetID()
	end
	local function initialize(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for k,v in pairs(items) do
			info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.value = v
			info.func = OnClick
			UIDropDownMenu_AddButton(info, level)
		end
	end

	UIDropDownMenu_Initialize(Drop, initialize)
	UIDropDownMenu_SetWidth(Drop, 100);
	UIDropDownMenu_SetButtonWidth(Drop, 124)
	SGI_DATA[DATA_INDEX].settings.dropdown[name] = SGI_DATA[DATA_INDEX].settings.dropdown[name] or 1
	UIDropDownMenu_SetSelectedID(Drop, SGI_DATA[DATA_INDEX].settings.dropdown[name] or 1)
	UIDropDownMenu_JustifyText(Drop, "LEFT")
	return Drop
end



local function CreateInviteListFrame()
	CreateFrame("Frame","SGI_Invites")
	SGI_Invites:SetWidth(300)
	SGI_Invites:SetHeight(20*CountTable(SGI_QUEUE) + 40)
	SGI_Invites:SetMovable()
	SetFramePos(SGI_Invites)
	SGI_Invites:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	SGI_Invites:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		GetFramePos(SGI_Invites)
	end)
	local backdrop = 
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background", 
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", 
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	SGI_Invites:SetBackdrop(backdrop)
	
	SGI_Invites.text = SGI_Invites:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SGI_Invites.text:SetPoint("TOP",SGI_Invites,"TOP",-15,-15)
	SGI_Invites.text:SetText(L["Click on the players you wish to invite"])
	SGI_Invites.tooltip = CreateFrame("Frame","InviteTime",SGI_Invites,"GameTooltipTemplate")
	SGI_Invites.tooltip.text = SGI_Invites.tooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SGI_Invites.tooltip:SetPoint("TOP",SGI_Invites,"BOTTOM",0,-2)
	SGI_Invites.tooltip.text:SetText("Unknown")
	SGI_Invites.tooltip.text:SetPoint("CENTER")
	
	local close = CreateFrame("Button",nil,SGI_Invites,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",SGI_Invites,"TOPRIGHT",-4,-4)
	
	SGI_Invites:SetScript("OnShow",StartSuperScan)
	SGI_Invites:SetScript("OnHide",StopSuperScan)
	SGI_Invites.items = {}
	local update = 0
	local toolUpdate = 0
	SGI_Invites:SetScript("OnUpdate",function()
		if GetTime() < update then return end
		for k,_ in pairs(SGI_Invites.items) do
			SGI_Invites.items[k]:Hide()
		end
		local i = 0
		local x,y = 10,-30
		for i = 1,30 do
			if not SGI_Invites.items[i] then
				SGI_Invites.items[i] = CreateFrame("Button","InviteBar"..i,SGI_Invites)
				SGI_Invites.items[i]:SetWidth(280)
				SGI_Invites.items[i]:SetHeight(20)
				SGI_Invites.items[i]:EnableMouse(true)
				SGI_Invites.items[i]:SetPoint("TOP",SGI_Invites,"TOP",0,y)
				SGI_Invites.items[i].text = SGI_Invites.items[i]:CreateFontString(nil,"OVERLAY","GameFontNormal")
				SGI_Invites.items[i].text:SetPoint("LEFT",SGI_Invites.items[i],"LEFT",3,0)
				SGI_Invites.items[i].text:SetJustifyH("LEFT")
				SGI_Invites.items[i].player = "unknown"
				SGI_Invites.items[i]:RegisterForClicks("LeftButtonDown","RightButtonDown")
				SGI_Invites.items[i]:SetScript("OnClick",SendGuildInvite)
				
				SGI_Invites.items[i].highlight = SGI_Invites.items[i]:CreateTexture()
				SGI_Invites.items[i].highlight:SetAllPoints()
				SGI_Invites.items[i].highlight:SetTexture(1,1,0,0.2)
				SGI_Invites.items[i].highlight:Hide()
				
				SGI_Invites.items[i]:SetScript("OnEnter",function()
					SGI_Invites.items[i].highlight:Show()
					SGI_Invites.tooltip:Show()
					SGI_Invites.items[i]:SetScript("OnUpdate",function()
						if GetTime() > toolUpdate and SGI_QUEUE[SGI_Invites.items[i].player] then
							SGI_Invites.tooltip.text:SetText("Found |cff"..GetClassColor(SGI_QUEUE[SGI_Invites.items[i].player].classFile)..SGI_Invites.items[i].player.."|r "..FormatTime(floor(GetTime()-SGI_QUEUE[SGI_Invites.items[i].player].found)).." ago")
							local h,w = SGI_Invites.tooltip.text:GetHeight(),SGI_Invites.tooltip.text:GetWidth()
							SGI_Invites.tooltip:SetWidth(w+20)
							SGI_Invites.tooltip:SetHeight(h+20)
							toolUpdate = GetTime() + 0.1
						end
					end)
				end)
				SGI_Invites.items[i]:SetScript("OnLeave",function() 
					SGI_Invites.items[i].highlight:Hide()
					SGI_Invites.tooltip:Hide()
					SGI_Invites.items[i]:SetScript("OnUpdate",nil)
				end)
			end
			y = y - 20
		end
		i = 0
		for k,_ in pairs(SGI_QUEUE) do
			i = i + 1
			local level,classFile,race,class,found = SGI_QUEUE[k].level, SGI_QUEUE[k].classFile, SGI_QUEUE[k].race, SGI_QUEUE[k].class, SGI_QUEUE[k].found
			local Text = i..". |cff"..GetClassColor(classFile)..k.."|r Lvl "..level.." "..race.." |cff"..GetClassColor(classFile)..class.."|r"
			SGI_Invites.items[i].text:SetText(Text)
			SGI_Invites.items[i].player = k
			SGI_Invites.items[i]:Show()
			if i >= 30 then break end
		end
		SGI_Invites:SetHeight(i * 20 + 40)
		update = GetTime() + 0.5
	end)
end

local function ShowSGI_Inv()
	if SGI_Invites then
		SGI_Invites:Show()
	else
		CreateInviteListFrame()
		SGI_Invites:Show()
	end
end

local function HideSGI_Inv()
	if SGI_Invites then
		SGI_Invites:Hide()
	end
end


local function StopSuperScan2()
	SuperScanFrameTimer:SetScript("OnUpdate",nil)
	ScanInProgress = false
	if SuperScanFrame then
		SuperScanFrame:Hide()
	end
	if SGI_Options then
		SGI_Options:Show()
	end
	BackUp()
	print(L["SuperScan was stopped"])
end

local function CreateSuperscanFrame()
	CreateFrame("Frame","SuperScanFrame")
	SuperScanFrame:SetWidth(270)
	SuperScanFrame:SetHeight(75)
	local backdrop = 
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background", 
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", 
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	SetFramePos(SuperScanFrame)
	SuperScanFrame:SetMovable()
	SuperScanFrame:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	SuperScanFrame:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		GetFramePos(self)
	end)
	SuperScanFrame:SetBackdrop(backdrop)
	
	SuperScanFrame.time = SuperScanFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SuperScanFrame.time:SetPoint("CENTER",0,15)
	SuperScanFrame.time:SetText("HH:MM:SS")
	
	local anchor = {
		point = "BOTTOMLEFT",
		relativePoint = "BOTTOMLEFT",
		xOfs = 7,
		yOfs = 10,
	}
	
	SuperScanFrame.progress = CreateFrame("Button","SGI_Progress",SuperScanFrame)
	SuperScanFrame.progress:SetWidth(270)
	SuperScanFrame.progress:SetHeight(30)
	SuperScanFrame.progress:SetBackdrop(backdrop)
	SuperScanFrame.progress:SetPoint("TOP",SuperScanFrame,"BOTTOM",0,0)
	
	SuperScanFrame.progress.percent = SuperScanFrame.progress:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SuperScanFrame.progress.percent:SetPoint("CENTER")
	SuperScanFrame.progress.percent:SetText("N/A")
	SuperScanFrame.progress.percent:SetTextColor(0,1,0)
	
	SuperScanFrame.progress.texture = SuperScanFrame.progress:CreateTexture()
	SuperScanFrame.progress.texture:SetPoint("LEFT",5,0)
	SuperScanFrame.progress.texture:SetHeight(19)
	SuperScanFrame.progress.texture:SetWidth(1)
	SuperScanFrame.progress.texture:SetTexture(1,0.5,0,0.4)
	
	SuperScanFrame.progress.tooltip = CreateFrame("Frame","progressTooltip",SuperScanFrame.progress,"GameTooltipTemplate")
	SuperScanFrame.progress.tooltip:SetWidth(120)
	SuperScanFrame.progress.tooltip:SetHeight(40)
	SuperScanFrame.progress.tooltip:SetPoint("TOP",SuperScanFrame.progress,"BOTTOM")
	SuperScanFrame.progress.tooltip.text = SuperScanFrame.progress.tooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SuperScanFrame.progress.tooltip.text:SetPoint("LEFT",SuperScanFrame.progress.tooltip,"LEFT",10,0)
	SuperScanFrame.progress.tooltip.text:SetJustifyH("LEFT")
	SuperScanFrame.progress.tooltip.text:SetText(L["Click to toggle SuperScan"])
	SuperScanFrame.progress.tooltip.text:SetWidth(110)
	SuperScanFrame.progress:SetScript("OnEnter",function()
		SuperScanFrame.progress.tooltip:Show()
	end)
	SuperScanFrame.progress:SetScript("OnLeave",function()
		SuperScanFrame.progress.tooltip:Hide()
	end)
	SuperScanFrame.progress:SetScript("OnClick",function()
		if ScanInProgress then
			StopSuperScan2()
		else
			StartSuperScan()
		end
	end)
	local update = 0
	SuperScanFrame.progress:SetScript("OnUpdate",function(self)
		if GetTime() > update then
			local num
			if whoQueryList then
				num = #whoQueryList
			else
				num = 10000
			end
			local percent = (SuperScanProgress-1)/num
			if percent < 0.01 then percent = 1/260 end
			if SuperScanFrame.timeV and SuperScanFrame.timeS and SuperScanFrame.timeT then
				local diff = GetTime() - SuperScanFrame.timeS
				
				SuperScanFrame.time:SetText(FormatTime(SuperScanFrame.timeV-diff)..L[" remaining"])
				local total,diff2 = (#whoQueryList -1) * SuperScanInterval,GetTime() - SuperScanFrame.timeT
				local cent = diff2/total
				if cent > 1 then cent = 1 end
				self.texture:SetWidth(ceil(cent*260))
				self.percent:SetText(floor(100 * cent).."%")
			end
			SGI_InviteButtonFont:SetText(format(L["Invite: %d"],CountTable(SGI_QUEUE)))
			update = GetTime() + 0.5
		end
	end)
	
	SuperScanFrame.button1 = CreateNewButton("SGI_PurgeQueue",SuperScanFrame,85,30,L["Purge Queue"],anchor,function() SGI_QUEUE = {} end)
	anchor.xOfs = 92
	SuperScanFrame.button2 = CreateNewButton("SGI_InviteButton",SuperScanFrame,85,30,format(L["Invite: %d"],CountTable(SGI_QUEUE)),anchor,SendGuildInvite)
	anchor.xOfs = 177
	SuperScanFrame.button3 = CreateNewButton("SGI_ChooseInviteButton",SuperScanFrame,85,30,L["Choose Invites"],anchor,ShowSGI_Inv)
	
end

local function ShowSuperScan()
	if SuperScanFrame then
		SuperScanFrame:Show()
	else
		CreateSuperscanFrame()
		SuperScanFrame:Show()
	end
end

local function HideSuperScan()
	if SuperScanFrame then
		SuperScanFrame:Hide()
	end
end



function StartSuperScan()
--	SetUpChatInterception()
	CreateScanQuery(SGI_DATA[DATA_INDEX].settings.lowLimit,SGI_DATA[DATA_INDEX].settings.highLimit,SGI_DATA[DATA_INDEX].settings.interval,SGI_DATA[DATA_INDEX].settings.raceStart,SGI_DATA[DATA_INDEX].settings.classStart)
	SuperScanFrameTimer:SetScript("OnUpdate",SuperScan)
	ScanInProgress = true
	SuperScanProgress = 1
	if SuperScanFrame then
		SuperScanFrame:Show()
		SuperScanFrame.timeT = GetTime()
	else
		CreateSuperscanFrame()
		SuperScanFrame:Show()
		SuperScanFrame.timeT = GetTime()
	end
	print(L["SuperScan was started"])
end
local function StopSuperScan()
	SuperScanFrameTimer:SetScript("OnUpdate",nil)
	ScanInProgress = false
	if SuperScanFrame then
		SuperScanFrame:Hide()
	end
	if SGI_Options then
		SGI_Options:Show()
	end
	print(L["SuperScan was stopped"])
end

local function CreateWhisperDefineFrame()
	CreateFrame("Frame","SGI_Whisper")
	local backdrop = 
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background", 
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", 
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	SGI_Whisper:SetWidth(500)
	SGI_Whisper:SetHeight(365)
	SGI_Whisper:SetBackdrop(backdrop)
	SetFramePos(SGI_Whisper)
	SGI_Whisper:SetMovable()
	SGI_Whisper:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	SGI_Whisper:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		GetFramePos(SGI_Whisper)
	end)
	
	local close = CreateFrame("Button",nil,SGI_Whisper,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",SGI_Whisper,"TOPRIGHT",-4,-4)
	
	SGI_Whisper.title = SGI_Whisper:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SGI_Whisper.title:SetText(L["SuperGuildInvite Custom Whisper"])
	SGI_Whisper.title:SetPoint("TOP",SGI_Whisper,"TOP",0,-20)
	
	SGI_Whisper.info = SGI_Whisper:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SGI_Whisper.info:SetPoint("TOPLEFT",SGI_Whisper,"TOPLEFT",33,-55)
	SGI_Whisper.info:SetText(L["WhisperInstructions"])
	SGI_Whisper.info:SetWidth(450)
	SGI_Whisper.info:SetJustifyH("LEFT")
	
	SGI_Whisper.edit = CreateFrame("EditBox",nil,SGI_Whisper)
	SGI_Whisper.edit:SetWidth(450)
	SGI_Whisper.edit:SetHeight(65)
	SGI_Whisper.edit:SetMultiLine(true)
	SGI_Whisper.edit:SetPoint("TOPLEFT",SGI_Whisper,"TOPLEFT",35,-110)
	SGI_Whisper.edit:SetFontObject("GameFontNormal")
	SGI_Whisper.edit:SetTextInsets(10,10,10,10)
	SGI_Whisper.edit:SetMaxLetters(256)
	SGI_Whisper.edit:SetBackdrop(backdrop)
	SGI_Whisper.edit:SetText(SGI_DATA[DATA_INDEX].settings.whispers[SGI_DATA[DATA_INDEX].settings.dropdown["SGI_WHISPER_DROP"] or 1] or "")
	SGI_Whisper.edit:SetScript("OnHide",function()
		SGI_Whisper.edit:SetText(SGI_DATA[DATA_INDEX].settings.whispers[SGI_DATA[DATA_INDEX].settings.dropdown["SGI_WHISPER_DROP"] or 1] or "")
	end)
	SGI_Whisper.edit.text = SGI_Whisper.edit:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SGI_Whisper.edit.text:SetPoint("TOPLEFT",SGI_Whisper.edit,"TOPLEFT",10,13)
	SGI_Whisper.edit.text:SetText(L["Enter your whisper"])
	
	local yOfs = -20
	SGI_Whisper.status = {}
	for i = 1,6 do
		SGI_Whisper.status[i] = {}
		SGI_Whisper.status[i].box = CreateFrame("Frame",nil,SGI_Whisper)
		SGI_Whisper.status[i].box:SetWidth(170)
		SGI_Whisper.status[i].box:SetHeight(18)
		SGI_Whisper.status[i].box:SetFrameStrata("HIGH")
		SGI_Whisper.status[i].box.index = i
		SGI_Whisper.status[i].box:SetPoint("LEFT",SGI_Whisper,"CENTER",50,yOfs)
		SGI_Whisper.status[i].box:SetScript("OnEnter",function(self)
			if SGI_DATA[DATA_INDEX].settings.whispers[self.index] then
				GameTooltip:SetOwner(self,"ANCHOR_CURSOR")
				GameTooltip:SetText(FormatWhisper(SGI_DATA[DATA_INDEX].settings.whispers[self.index],UnitName("Player")))
			end
		end)
		SGI_Whisper.status[i].box:SetScript("OnLeave",function(self)
			GameTooltip:Hide()
		end)
		SGI_Whisper.status[i].text = SGI_Whisper:CreateFontString(nil,nil,"GameFontNormal")
		SGI_Whisper.status[i].text:SetText("Whisper #"..i.." status: ")
		SGI_Whisper.status[i].text:SetWidth(200)
		SGI_Whisper.status[i].text:SetJustifyH("LEFT")
		SGI_Whisper.status[i].text:SetPoint("LEFT",SGI_Whisper,"CENTER",50,yOfs)
		yOfs = yOfs - 18
	end
	local whispers = {
		"Whisper #1",
		"Whisper #2",
		"Whisper #3",
		"Whisper #4",
		"Whisper #5",
		"Whisper #6",
	}
	
	anchor = {}
		anchor.point = "BOTTOMLEFT"
		anchor.relativePoint = "BOTTOMLEFT"
		anchor.xOfs = 50
		anchor.yOfs = 120
		
	SGI_Whisper.drop = CreateDropDown(SGI_Whisper,"SGI_WHISPER_DROP",anchor,whispers,"SGI_WHISPER_DROP",L["Select whisper"])

		anchor.xOfs = 100
		anchor.yOfs = 20
	
	CreateNewButton("SGI_SAVEWHISPER",SGI_Whisper,120,30,L["Save"],anchor,function()
		local text = SGI_Whisper.edit:GetText()
		local ID = SGI_DATA[DATA_INDEX].settings.dropdown["SGI_WHISPER_DROP"]
		SGI_DATA[DATA_INDEX].settings.whispers[ID] = text
		SGI_Whisper.edit:SetText("")
	end)
	anchor.xOfs = 280
	CreateNewButton("SGI_CANCELWHISPER",SGI_Whisper,120,30,L["Cancel"],anchor,function()
		SGI_Whisper:Hide()
	end)
	
	SGI_Whisper.update = 0
	SGI_Whisper.changed = false
	SGI_Whisper:SetScript("OnUpdate",function()
		if GetTime() > SGI_Whisper.update then
			for i = 1,6 do
				if type(SGI_DATA[DATA_INDEX].settings.whispers[i]) == "string" then
					SGI_Whisper.status[i].text:SetText("Whisper #"..i.." status: |cff00ff00Good|r")
				else
					SGI_Whisper.status[i].text:SetText("Whisper #"..i.." status: |cffff0000Undefined|r")
				end
			end
			local ID = SGI_DATA[DATA_INDEX].settings.dropdown["SGI_WHISPER_DROP"]
			SGI_Whisper.status[ID].text:SetText("Whisper #"..ID.." status: |cffff8800Editing...|r")
			
			if ID ~= SGI_Whisper.changed then
				SGI_Whisper.changed = ID
				SGI_Whisper.edit:SetText(SGI_DATA[DATA_INDEX].settings.whispers[SGI_DATA[DATA_INDEX].settings.dropdown["SGI_WHISPER_DROP"] or 1] or "")
			end
			
			SGI_Whisper.update = GetTime() + 0.5
		end
	end)
end

local function ShowWhisperFrame()
	if SGI_Whisper then
		SGI_Whisper:Show()
	else
		CreateWhisperDefineFrame()
		SGI_Whisper:Show()
	end
end

local function HideWhisperFrame()
	if SGI_Whisper then
		SGI_Whisper:Hide()
	end
end

local function GetPossibleCauses()
	local out = {}
	if not SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_WHISPER"] then
		out["whisperBox"] = true
	end
	if not SGI_DATA[DATA_INDEX].settings.dropdown["SGI_WHISPER_MODE"] then
		out["dropdown"] = 0
	elseif SGI_DATA[DATA_INDEX].settings.dropdown["SGI_WHISPER_MODE"] == 1 then
		out["dropdown"] = 1
	elseif SGI_DATA[DATA_INDEX].settings.dropdown["SGI_WHISPER_MODE"] == 2 then
		out["dropdown"] = 2
	elseif SGI_DATA[DATA_INDEX].settings.dropdown["SGI_WHISPER_MODE"] == 3 then
		out["dropdown"] = 3
	end
	if SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_MUTE"] then
		out["mute"] = true
	end
	local L = GetLocale()
	if L ~= "enGB" and L ~= "enUS" then
		out["locale"] = true
	end
	
	return out
end
	
local function ProcessCause(cause)
	local out = {}
	if cause["whisperBox"] then
		out["whisperBox"] = {msg=L["not sending"],Type="whisperBox"}
	end
	if cause["dropdown"] == 0 then
		out["dropdown"] = {msg=L["to specify"],Type="dropdown0"}
	elseif cause["dropdown"] == 1 then
		out["dropdown"] = {msg=L["I checked the box"],Type="dropdown1"}
	elseif cause["dropdown"] == 2 then
		out["dropdown"] = {msg=L["whisper to everyone"],Type="dropdown2"}
	elseif cause["dropdown"] == 3 then
		out["dropdown"] = {msg=L["can't get SGI to invite"],Type="dropdown3"}
	end
	if cause["mute"] then
		out["mute"] = {msg=L["can't see any messages"],Type="mute"}
	end
	if cause["locale"] then
		out["locale"] = {msg=L["None of the above"],Type="locale"}
	end
	return out
end

local function CreateTroubleshoter()
	CreateFrame("Frame","SGI_Help")
	local helpItems = {}
	local backdrop = 
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background", 
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", 
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	SGI_Help:SetWidth(300)
	SGI_Help:SetHeight(100)
	SGI_Help:SetBackdrop(backdrop)
	SGI_Help:SetMovable()
	SetFramePos(SGI_Help)
	SGI_Help.title = SGI_Help:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SGI_Help.title:SetPoint("TOP",SGI_Help,"TOP",0,-10)
	SGI_Help.title:SetText("Common issues")
	SGI_Help:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	SGI_Help:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		GetFramePos(self)
	end)
	local close = CreateFrame("Button",nil,SGI_Help,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",SGI_Help,"TOPRIGHT",-4,-4)
	
	local lastUpdate = 0
	SGI_Help:SetScript("OnUpdate",function()
		if lastUpdate > GetTime() then return end
		local i = 0
		local problems = ProcessCause(GetPossibleCauses())
		for k,_ in pairs(helpItems) do
			helpItems[k]:Hide()
		end
		for k,_ in pairs(problems) do
			i = i + 1
			if not helpItems[i] then
				helpItems[i] = CreateFrame("Button","helpItem"..i,SGI_Help)
				helpItems[i]:SetWidth(285)
				helpItems[i]:SetHeight(50)
				if helpItems[i-1] then
					helpItems[i]:SetPoint("TOP",helpItems[i-1],"BOTTOM",0,-1)
				else
					helpItems[i]:SetPoint("TOP",SGI_Help,"TOP",0,-30)
				end
				helpItems[i]:EnableMouse(true)
				helpItems[i]:RegisterForClicks("LeftButtonDown","RightButtonDown")
				helpItems[i].text = helpItems[i]:CreateFontString(nil,"OVERLAY","GameFontNormal")
				helpItems[i].text:SetPoint("CENTER")
				helpItems[i].text:SetWidth(280)
				helpItems[i].text:SetJustifyH("LEFT")
				helpItems[i].highlight = helpItems[i]:CreateTexture()
				helpItems[i].highlight:SetAllPoints(helpItems[i])
				helpItems[i].highlight:SetTexture(1,1,0,0.2)
				helpItems[i].highlight:Hide()
			end
		end
		i = 0
		local totalH = 0
		for k,_ in pairs(problems) do
			i = i + 1
			helpItems[i].text:SetText(problems[k].msg)
			helpItems[i]:SetHeight(helpItems[i].text:GetHeight() + 10)
			totalH = totalH + helpItems[i].text:GetHeight() + 10
			helpItems[i]:Show()
			helpItems[i]:SetScript("OnEnter",function(self)
				self.highlight:Show()
			end)
			helpItems[i]:SetScript("OnLeave",function(self)
				self.highlight:Hide()
			end)
			helpItems[i]:SetScript("OnClick",function()
				if problems[k].Type == "whisperBox" then
					SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_WHISPER"] = 1
					print(L["Enabled whispers"])
				elseif problems[k].Type == "dropdown0" then
					SGI_DATA[DATA_INDEX].settings.dropdown["SGI_WHISPER_MODE"] = 2
					print(L['Changed invite mode to "Invite and Whisper"'])
				elseif problems[k].Type == "dropdown1" then
					SGI_DATA[DATA_INDEX].settings.dropdown["SGI_WHISPER_MODE"] = 2
					print(L['Changed invite mode to "Invite and Whisper"'])
				elseif problems[k].Type == "dropdown2" then
					SGI_DATA[DATA_INDEX].settings.dropdown["SGI_WHISPER_MODE"] = 1
					print(L['Changed invite mode to "Only Invite". If you wanted "Only Whisper" go to Options and change.'])
				elseif problems[k].Type == "dropdown3" then
					SGI_DATA[DATA_INDEX].settings.dropdown["SGI_WHISPER_MODE"] = 2
					print(L['Changed invite mode to "Invite and Whisper"'])
				elseif problems[k].Type == "mute" then
					SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_MUTE"] = nil
					print(L["Mute has been turned off"])
				end
				
			end)
		end
		SGI_Help:SetHeight(totalH+35)
		lastUpdate = GetTime() + 0.3
	end)
end

local function ShowHelp()
	if SGI_Help then
		SGI_Help:Show()
	else
		CreateTroubleshoter()
		SGI_Help:Show()
	end
end

local function HideHelp()
end

local function CreateExceptionFrame()
	CreateFrame("Frame","SGI_Exceptions")
	local backdrop = 
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background", 
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", 
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	SGI_Exceptions:SetWidth(500)
	SGI_Exceptions:SetHeight(365)
	SGI_Exceptions:SetBackdrop(backdrop)
	SetFramePos(SGI_Exceptions)
	SGI_Exceptions:SetMovable()
	SGI_Exceptions:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	SGI_Exceptions:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		GetFramePos(SGI_Exceptions)
	end)
	
	local close = CreateFrame("Button",nil,SGI_Exceptions,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",SGI_Exceptions,"TOPRIGHT",-4,-4)
	
	SGI_Exceptions.title = SGI_Exceptions:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SGI_Exceptions.title:SetText(L["SGI Exceptions"])
	SGI_Exceptions.title:SetPoint("TOP",SGI_Exceptions,"TOP",0,-20)
	
	SGI_Exceptions.info = SGI_Exceptions:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SGI_Exceptions.info:SetPoint("TOPLEFT",SGI_Exceptions,"TOPLEFT",33,-55)
	SGI_Exceptions.info:SetText(L["ExceptionsInstructions"])
	SGI_Exceptions.info:SetWidth(450)
	SGI_Exceptions.info:SetJustifyH("LEFT")
	
	SGI_Exceptions.edit = CreateFrame("EditBox",nil,SGI_Exceptions)
	SGI_Exceptions.edit:SetWidth(450)
	SGI_Exceptions.edit:SetHeight(65)
	SGI_Exceptions.edit:SetMultiLine(true)
	SGI_Exceptions.edit:SetPoint("TOPLEFT",SGI_Exceptions,"TOPLEFT",35,-140)
	SGI_Exceptions.edit:SetFontObject("GameFontNormal")
	SGI_Exceptions.edit:SetTextInsets(10,10,10,10)
	SGI_Exceptions.edit:SetMaxLetters(256)
	SGI_Exceptions.edit:SetBackdrop(backdrop)
	SGI_Exceptions.edit:SetText("")
	SGI_Exceptions.edit:SetScript("OnHide",function()
		SGI_Exceptions.edit:SetText("")
	end)
	SGI_Exceptions.edit.text = SGI_Exceptions.edit:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SGI_Exceptions.edit.text:SetPoint("TOPLEFT",SGI_Exceptions.edit,"TOPLEFT",10,13)
	SGI_Exceptions.edit.text:SetText(L["Enter exceptions"])
	local Anchor = {}
		Anchor.point = "BOTTOM"
		Anchor.relativePoint = "BOTTOM"
		Anchor.xOfs = -150
		Anchor.yOfs = 20
	CreateNewButton("SGI_CUSTOM_EXC",SGI_Exceptions,120,30,L["Save"],Anchor,function()
			local text = SGI_Exceptions.edit:GetText()
			text = divide(text,",")
			SGI_Exceptions.update = GetTime() + 1
			SGI_DATA[DATA_INDEX].settings.exceptions = SGI_DATA[DATA_INDEX].settings.exceptions or {}
			for k,_ in pairs(text) do
				SGI_DATA[DATA_INDEX].settings.exceptions[text[k]] = 1
				print(format(L["Added exception %s"],text[k]))
			end
			SGI_Exceptions.edit:SetText("")
		end)
		Anchor.xOfs = 150
	CreateNewButton("SGI_CUSTOM_EXC",SGI_Exceptions,120,30,L["Cancel"],Anchor,function(self)
		self:GetParent():Hide()
		SGI_Exceptions = nil
	end)
	
	SGI_Exceptions.bottom = SGI_Exceptions:CreateFontString(nil,nil,"GameFontNormal")
	SGI_Exceptions.bottom:SetPoint("BOTTOM",SGI_Exceptions,"BOTTOM",0,30)
	SGI_Exceptions.bottom:SetText("Click on exceptions to remove")
	
	SGI_Exceptions.items = {}
	SGI_Exceptions.update = 0
	SGI_Exceptions:SetScript("OnUpdate",function()
		if GetTime() > SGI_Exceptions.update then
			local i = -1
			if type(SGI_DATA[DATA_INDEX].settings.exceptions) ~= "table" then
				SGI_DATA[DATA_INDEX].settings.exceptions = {}
			end
			local anchor = {}
				anchor.xOfs = -135
				anchor.yOfs = -25
			for k,_ in pairs(SGI_Exceptions.items) do
				SGI_Exceptions.items[k]:Hide()
				SGI_Exceptions.items[k].text:SetText("")
				SGI_Exceptions.items[k].exc = nil
			end
				
			for k,_ in pairs(SGI_DATA[DATA_INDEX].settings.exceptions) do
				i = i + 1
				if not SGI_Exceptions.items[i] then
					SGI_Exceptions.items[i] = CreateFrame("Button","SGI_exc"..i,SGI_Exceptions)
					SGI_Exceptions.items[i]:SetWidth(80)
					SGI_Exceptions.items[i]:SetHeight(25)
					SGI_Exceptions.items[i]:EnableMouse(true)
					SGI_Exceptions.items[i]:SetPoint("CENTER",SGI_Exceptions,"CENTER",anchor.xOfs,anchor.yOfs)
					if mod(i,4) == 3 then
						anchor.xOfs = -135
						anchor.yOfs = anchor.yOfs - 30
					else
						anchor.xOfs = anchor.xOfs + 102
					end
					SGI_Exceptions.items[i].text = SGI_Exceptions.items[i]:CreateFontString(nil,nil,"GameFontNormalLarge")
					SGI_Exceptions.items[i].text:SetPoint("LEFT",SGI_Exceptions.items[i],"LEFT",3,0)
					SGI_Exceptions.items[i].text:SetJustifyH("LEFT")
					SGI_Exceptions.items[i]:RegisterForClicks("LeftButtonDown","RightButtonDown")
					SGI_Exceptions.items[i].Highlight = SGI_Exceptions.items[i]:CreateTexture(nil,"HIGHLIGHT")
					SGI_Exceptions.items[i].Highlight:SetAllPoints()
					SGI_Exceptions.items[i].Highlight:SetTexture(1,1,0,0.2)
					SGI_Exceptions.items[i]:SetScript("OnEnter",function(self)
						self.Highlight:Show()
					end)
					SGI_Exceptions.items[i]:SetScript("OnLeave",function(self)
						self.Highlight:Hide()
					end)
				end
				SGI_Exceptions.items[i]:SetScript("OnClick",function(self)
					if self.exc and SGI_DATA[DATA_INDEX].settings.exceptions then
						SGI_DATA[DATA_INDEX].settings.exceptions[k] = nil
						print(format(L["Removed exception %s"],k))
					end
				end)
				SGI_Exceptions.items[i].text:SetText(k)
				SGI_Exceptions.items[i].exc = k
				SGI_Exceptions.items[i]:Show()
				if i == 15 then break end
			end
			SGI_Exceptions.update = GetTime() + 0.5
		end
	end)
end

local function ShowExc()
	if SGI_Exceptions then
		SGI_Exceptions:Show()
	else
		CreateExceptionFrame()
		SGI_Exceptions:Show()
	end
end

function CreateOptions()
	CreateFrame("Frame","SGI_Options")
	SGI_Options:SetWidth(550)
	SGI_Options:SetHeight(420)
	SetFramePos(SGI_Options)
	SGI_Options:SetMovable()
	SGI_Options:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	SGI_Options:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		GetFramePos(SGI_Options)
	end)
	local backdrop = 
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background", 
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", 
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	SGI_Options:SetBackdrop(backdrop)
	local close = CreateFrame("Button",nil,SGI_Options,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",SGI_Options,"TOPRIGHT",-4,-4)
	
	SGI_Options.title = SGI_Options:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SGI_Options.title:SetText("SuperGuildInvite "..VERSION_MAJOR..VERSION_MINOR.." Options")
	SGI_Options.title:SetPoint("TOP",SGI_Options,"TOP",0,-15)
	SGI_Options.bottom = SGI_Options:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SGI_Options.bottom:SetText("Written by Janniie - Stormreaver EU")
	SGI_Options.bottom:SetPoint("BOTTOM",SGI_Options,"BOTTOM",0,20)
	
	local anchor = {}
			anchor.point = "TOPLEFT"
			anchor.relativePoint = "TOPLEFT"
			anchor.xOfs = 20
			anchor.yOfs = -50
	
	local WhisperMode = {
		L["Invite only"],
		L["Invite and whisper"],
		L["Whisper only"],
	}
	SGI_Options.checkbox1 = CreateNewCheckbox("SGI_WHISPER",SGI_Options,L["Enable Addon"],anchor)
		anchor.yOfs = anchor.yOfs - 50
		anchor.xOfs = anchor.xOfs - 13
	SGI_Options.dropdown1 = CreateDropDown(SGI_Options,"SGI_WHISPER_MODE",anchor,WhisperMode,"SGI_WHISPER_MODE",L["Invite Mode"])
		anchor.yOfs = anchor.yOfs - 30
		anchor.xOfs = anchor.xOfs + 13
	SGI_Options.checkbox2 = CreateNewCheckbox("SGI_MUTE",SGI_Options,L["Mute SGI"],anchor)
		anchor.yOfs = anchor.yOfs - 30
	SGI_Options.checkbox3 = CreateNewCheckbox("SGI_DK_INV",SGI_Options,L["Always scan for 55-58 Death Knights"],anchor)
		anchor.yOfs = anchor.yOfs - 30
	SGI_Options.checkbox4 = CreateNewCheckbox("SGI_DK",SGI_Options,L["Filter 55-58 Death Knights"],anchor)
		anchor.yOfs = anchor.yOfs - 30
	SGI_Options.checkbox5 = CreateNewCheckbox("SGI_LONG",SGI_Options,L["Do a more thorough search"],anchor)
		anchor.yOfs = anchor.yOfs - 30
	SGI_Options.checkbox6 = CreateNewCheckbox("SGI_HIDE",SGI_Options,L["Hide system messages"],anchor)
		anchor.yOfs = anchor.yOfs - 30
	SGI_Options.checkbox7 = CreateNewCheckbox("SGI_HIDEWHISPER",SGI_Options,L["Hide outgoing whisper"],anchor)
		anchor.xOfs = anchor.xOfs + 250
		anchor.yOfs = anchor.yOfs + 60
	SGI_Options.checkbox8 = CreateNewCheckbox("SGI_MINI",SGI_Options,L["Hide minimap button"],anchor)
	SGI_Options.checkbox8:HookScript("PostClick",function()
		if SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_MINI"] and SGI_MiniMapButton then
			SGI_MiniMapButton:Hide()
		elseif SGI_MiniMapButton then
			SGI_MiniMapButton:Show()
		end
	end)
		anchor.yOfs = anchor.yOfs - 30
	SGI_Options.checkbox9 = CreateNewCheckbox("SGI_GREET",SGI_Options,L["Greet joined players"],anchor)
		anchor.yOfs = anchor.yOfs - 30
	SGI_Options.checkbox9 = CreateNewCheckbox("SGI_OFFICER_NOTE",SGI_Options,L["Set join date in officer note"],anchor)
		anchor.point = "BOTTOMLEFT"
		anchor.relativePoint = "BOTTOMLEFT"
		anchor.xOfs = 20
		anchor.yOfs = 45
		
	SGI_Options.button1 = CreateNewButton("SGI_CUSTOM_WHISPER",SGI_Options,120,30,L["Customize whisper"],anchor,ShowWhisperFrame)
		anchor.xOfs = anchor.xOfs + 125
	SGI_Options.button2 = CreateNewButton("SGI_SUPERSCAN",SGI_Options,120,30,L["SuperScan"],anchor,function()
		if ScanInProgress then
			StopSuperScan()
		else
			StartSuperScan()
			SGI_Options:Hide()
		end
	end)
		anchor.xOfs = anchor.xOfs + 125
	SGI_Options.button3 = CreateNewButton("SGI_INVITE",SGI_Options,120,30,format(L["Invite: %d"],CountTable(SGI_QUEUE)),anchor,SendGuildInvite)
		anchor.xOfs = anchor.xOfs + 125
	SGI_Options.button4 = CreateNewButton("SGI_CHOOSE",SGI_Options,120,30,L["Choose Invites"],anchor,ShowSGI_Inv)
		anchor.yOfs = 80
	SGI_Options.button5 = CreateNewButton("SGI_ADV_FIL",SGI_Options,120,30,L["Exceptions"],anchor,ShowExc)
		anchor.xOfs = anchor.xOfs - 125
	SGI_Options.button6 = CreateNewButton("SGI_HELP",SGI_Options,120,30,L["Help"],anchor,ShowHelp)
		anchor.xOfs = anchor.xOfs - 250
	SGI_Options.button6 = CreateNewButton("SGI_CUSTOM_GREET",SGI_Options,120,30,L["Customize Greet Message"],anchor,ShowGreetFrame)
	
	
	SGI_Options.limitLow = CreateFrame("Frame","SGI_LowLimit",SGI_Options)
	SGI_Options.limitLow:SetWidth(40)
	SGI_Options.limitLow:SetHeight(40)
	SGI_Options.limitLow:SetPoint("CENTER",SGI_Options,"CENTER",20,80)
	SGI_Options.limitLow.text = SGI_Options.limitLow:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SGI_Options.limitLow.text:SetPoint("CENTER")
	SGI_Options.limitLow.texture = SGI_Options.limitLow:CreateTexture()
	SGI_Options.limitLow.texture:SetAllPoints()
	SGI_Options.limitLow.texture:SetTexture(1,1,0,0.2)
	SGI_Options.limitLow.texture:Hide()
	SGI_Options.limitTooltip = CreateFrame("Frame","LimitTool",SGI_Options.limitLow,"GameTooltipTemplate")
	SGI_Options.limitTooltip:SetWidth(130)
	SGI_Options.limitTooltip:SetHeight(70)
	SGI_Options.limitTooltip:SetPoint("TOP",SGI_Options.limitLow,"BOTTOM")
	SGI_Options.limitTooltip.text = SGI_Options.limitTooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SGI_Options.limitTooltip.text:SetPoint("LEFT",SGI_Options.limitTooltip,"LEFT",10,0)
	SGI_Options.limitTooltip.text:SetJustifyH("LEFT")
	SGI_Options.limitTooltip.text:SetText(L["Highest and lowest level to search for"])
	SGI_Options.limitTooltip.text:SetWidth(115)
	
	SGI_Options.limitLow:SetScript("OnEnter",function()
		SGI_Options.limitLow.texture:Show()
		SGI_Options.limitTooltip:Show()
	end)
	SGI_Options.limitLow:SetScript("OnLeave",function()
		SGI_Options.limitLow.texture:Hide()
		SGI_Options.limitTooltip:Hide()
	end)
	
	
	SGI_Options.limitHigh = CreateFrame("Frame","SGI_HighLimit",SGI_Options)
	SGI_Options.limitHigh:SetWidth(40)
	SGI_Options.limitHigh:SetHeight(40)
	SGI_Options.limitHigh:SetPoint("CENTER",SGI_Options,"CENTER",60,80)
	SGI_Options.limitHigh.text = SGI_Options.limitHigh:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SGI_Options.limitHigh.text:SetPoint("CENTER")
	SGI_Options.limitHigh.texture = SGI_Options.limitHigh:CreateTexture()
	SGI_Options.limitHigh.texture:SetAllPoints()
	SGI_Options.limitHigh.texture:SetTexture(1,1,0,0.2)
	SGI_Options.limitHigh.texture:Hide()
	
	SGI_Options.limitHigh:SetScript("OnEnter",function()
		SGI_Options.limitHigh.texture:Show()
		SGI_Options.limitTooltip:Show()
	end)
	SGI_Options.limitHigh:SetScript("OnLeave",function()
		SGI_Options.limitHigh.texture:Hide()
		SGI_Options.limitTooltip:Hide()
	end)
	
	SGI_Options.limitLow.text:SetText(SGI_DATA[DATA_INDEX].settings.lowLimit.."  - ")
	SGI_Options.limitLow:SetScript("OnMouseWheel",function(self,delta)
		if delta == 1 and SGI_DATA[DATA_INDEX].settings.lowLimit + 1 <= SGI_DATA[DATA_INDEX].settings.highLimit then
			SGI_DATA[DATA_INDEX].settings.lowLimit = SGI_DATA[DATA_INDEX].settings.lowLimit + 1
			SGI_Options.limitLow.text:SetText(SGI_DATA[DATA_INDEX].settings.lowLimit.." - ")
		elseif delta == -1 and SGI_DATA[DATA_INDEX].settings.lowLimit - 1 > 0 then
			SGI_DATA[DATA_INDEX].settings.lowLimit = SGI_DATA[DATA_INDEX].settings.lowLimit - 1
			SGI_Options.limitLow.text:SetText(SGI_DATA[DATA_INDEX].settings.lowLimit.." - ")
		end
	end)
	
	SGI_Options.limitHigh.text:SetText(SGI_DATA[DATA_INDEX].settings.highLimit)
	SGI_Options.limitHigh:SetScript("OnMouseWheel",function(self,delta)
		if delta == 1 and SGI_DATA[DATA_INDEX].settings.highLimit + 1 <= 90 then
			SGI_DATA[DATA_INDEX].settings.highLimit = SGI_DATA[DATA_INDEX].settings.highLimit + 1
			SGI_Options.limitHigh.text:SetText(SGI_DATA[DATA_INDEX].settings.highLimit)
		elseif delta == -1 and SGI_DATA[DATA_INDEX].settings.highLimit > SGI_DATA[DATA_INDEX].settings.lowLimit then
			SGI_DATA[DATA_INDEX].settings.highLimit = SGI_DATA[DATA_INDEX].settings.highLimit - 1
			SGI_Options.limitHigh.text:SetText(SGI_DATA[DATA_INDEX].settings.highLimit)
		end
	end)
	
	SGI_Options.limitText = SGI_Options.limitLow:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SGI_Options.limitText:SetPoint("BOTTOM",SGI_Options.limitLow,"TOP",16,3)
	SGI_Options.limitText:SetText(L["Level limits"])
	
	
	SGI_Options.raceLimitHigh = CreateFrame("Frame","SGI_RaceLimitHigh",SGI_Options)
	SGI_Options.raceLimitHigh:SetWidth(40)
	SGI_Options.raceLimitHigh:SetHeight(40)
	SGI_Options.raceLimitHigh:SetPoint("CENTER",SGI_Options,"CENTER",150,80)
	SGI_Options.raceLimitHigh.text = SGI_Options.raceLimitHigh:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SGI_Options.raceLimitHigh.text:SetPoint("CENTER")
	SGI_Options.raceLimitHigh.texture = SGI_Options.raceLimitHigh:CreateTexture()
	SGI_Options.raceLimitHigh.texture:SetAllPoints()
	SGI_Options.raceLimitHigh.texture:SetTexture(1,1,0,0.2)
	SGI_Options.raceLimitHigh.texture:Hide()
	SGI_Options.raceTooltip = CreateFrame("Frame","LimitTool",SGI_Options.raceLimitHigh,"GameTooltipTemplate")
	SGI_Options.raceTooltip:SetWidth(125)
	SGI_Options.raceTooltip:SetHeight(60)
	SGI_Options.raceTooltip:SetPoint("TOP",SGI_Options.raceLimitHigh,"BOTTOM")
	SGI_Options.raceTooltip.text = SGI_Options.raceTooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SGI_Options.raceTooltip.text:SetPoint("LEFT",SGI_Options.raceTooltip,"LEFT",10,0)
	SGI_Options.raceTooltip.text:SetJustifyH("LEFT")
	SGI_Options.raceTooltip.text:SetText(L["The level you wish to start dividing the search by race"])
	SGI_Options.raceTooltip.text:SetWidth(110)
	
	
	SGI_Options.raceLimitText = SGI_Options.raceLimitHigh:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SGI_Options.raceLimitText:SetPoint("BOTTOM",SGI_Options.raceLimitHigh,"TOP",0,3)
	SGI_Options.raceLimitText:SetText(L["Racefilter Start:"])
	
	SGI_Options.raceLimitHigh.text:SetText(SGI_DATA[DATA_INDEX].settings.raceStart)
	SGI_Options.raceLimitHigh:SetScript("OnMouseWheel",function(self,delta)
		if delta == -1 and SGI_DATA[DATA_INDEX].settings.raceStart > 1 then
			SGI_DATA[DATA_INDEX].settings.raceStart = SGI_DATA[DATA_INDEX].settings.raceStart - 1
			SGI_Options.raceLimitHigh.text:SetText(SGI_DATA[DATA_INDEX].settings.raceStart)
		elseif delta == 1 and SGI_DATA[DATA_INDEX].settings.raceStart < 90 then
			SGI_DATA[DATA_INDEX].settings.raceStart = SGI_DATA[DATA_INDEX].settings.raceStart + 1
			SGI_Options.raceLimitHigh.text:SetText(SGI_DATA[DATA_INDEX].settings.raceStart)
		end
	end)
	
	SGI_Options.raceLimitHigh:SetScript("OnEnter",function()
		SGI_Options.raceLimitHigh.texture:Show()
		SGI_Options.raceTooltip:Show()
	end)
	SGI_Options.raceLimitHigh:SetScript("OnLeave",function()
		SGI_Options.raceLimitHigh.texture:Hide()
		SGI_Options.raceTooltip:Hide()
	end)
	
	SGI_Options.classLimitHigh = CreateFrame("Frame","SGI_ClassLimitHigh",SGI_Options)
	SGI_Options.classLimitHigh:SetWidth(40)
	SGI_Options.classLimitHigh:SetHeight(40)
	SGI_Options.classLimitHigh:SetPoint("CENTER",SGI_Options,"CENTER",150,10)
	SGI_Options.classLimitHigh.text = SGI_Options.classLimitHigh:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SGI_Options.classLimitHigh.text:SetPoint("CENTER")
	SGI_Options.classLimitHigh.texture = SGI_Options.classLimitHigh:CreateTexture()
	SGI_Options.classLimitHigh.texture:SetAllPoints()
	SGI_Options.classLimitHigh.texture:SetTexture(1,1,0,0.2)
	SGI_Options.classLimitHigh.texture:Hide()
	SGI_Options.classTooltip = CreateFrame("Frame","LimitTool",SGI_Options.classLimitHigh,"GameTooltipTemplate")
	SGI_Options.classTooltip:SetWidth(120)
	SGI_Options.classTooltip:SetHeight(60)
	SGI_Options.classTooltip:SetPoint("TOP",SGI_Options.classLimitHigh,"BOTTOM")
	SGI_Options.classTooltip.text = SGI_Options.classTooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SGI_Options.classTooltip.text:SetPoint("LEFT",SGI_Options.classTooltip,"LEFT",10,0)
	SGI_Options.classTooltip.text:SetJustifyH("LEFT")
	SGI_Options.classTooltip.text:SetText(L["The level you wish to divide the search by class"])
	SGI_Options.classTooltip.text:SetWidth(110)
	
	SGI_Options.classLimitText = SGI_Options.classLimitHigh:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SGI_Options.classLimitText:SetPoint("BOTTOM",SGI_Options.classLimitHigh,"TOP",0,3)
	SGI_Options.classLimitText:SetText(L["Classfilter Start:"])
	
	SGI_Options.classLimitHigh.text:SetText(SGI_DATA[DATA_INDEX].settings.classStart)
	SGI_Options.classLimitHigh:SetScript("OnMouseWheel",function(self,delta)
		if delta == -1 and SGI_DATA[DATA_INDEX].settings.classStart > 1 then
			SGI_DATA[DATA_INDEX].settings.classStart = SGI_DATA[DATA_INDEX].settings.classStart - 1
			SGI_Options.classLimitHigh.text:SetText(SGI_DATA[DATA_INDEX].settings.classStart)
		elseif delta == 1 and SGI_DATA[DATA_INDEX].settings.classStart < 90 then
			SGI_DATA[DATA_INDEX].settings.classStart = SGI_DATA[DATA_INDEX].settings.classStart + 1
			SGI_Options.classLimitHigh.text:SetText(SGI_DATA[DATA_INDEX].settings.classStart)
		end
	end)
	
	SGI_Options.classLimitHigh:SetScript("OnEnter",function()
		SGI_Options.classLimitHigh.texture:Show()
		SGI_Options.classTooltip:Show()
	end)
	SGI_Options.classLimitHigh:SetScript("OnLeave",function()
		SGI_Options.classLimitHigh.texture:Hide()
		SGI_Options.classTooltip:Hide()
	end)
	
	SGI_Options.Interval = CreateFrame("Frame","SGI_Interval",SGI_Options)
	SGI_Options.Interval:SetWidth(40)
	SGI_Options.Interval:SetHeight(40)
	SGI_Options.Interval:SetPoint("CENTER",SGI_Options,"CENTER",40,10)
	SGI_Options.Interval.text = SGI_Options.Interval:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SGI_Options.Interval.text:SetPoint("CENTER")
	SGI_Options.Interval.texture = SGI_Options.Interval:CreateTexture()
	SGI_Options.Interval.texture:SetAllPoints()
	SGI_Options.Interval.texture:SetTexture(1,1,0,0.2)
	SGI_Options.Interval.texture:Hide()
	SGI_Options.intervalTooltip = CreateFrame("Frame","LimitTool",SGI_Options.Interval,"GameTooltipTemplate")
	SGI_Options.intervalTooltip:SetWidth(125)
	SGI_Options.intervalTooltip:SetHeight(40)
	SGI_Options.intervalTooltip:SetPoint("TOP",SGI_Options.Interval,"BOTTOM")
	SGI_Options.intervalTooltip.text = SGI_Options.intervalTooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SGI_Options.intervalTooltip.text:SetPoint("LEFT",SGI_Options.intervalTooltip,"LEFT",10,0)
	SGI_Options.intervalTooltip.text:SetJustifyH("LEFT")
	SGI_Options.intervalTooltip.text:SetText(L["Amount of levels to search every ~7 seconds (higher numbers increase the risk of capping the search results)"])
	SGI_Options.intervalTooltip.text:SetWidth(110)
	SGI_Options.intervalTooltip:SetHeight(120)
	
	SGI_Options.intervalText = SGI_Options.Interval:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SGI_Options.intervalText:SetPoint("BOTTOM",SGI_Options.Interval,"TOP",0,3)
	SGI_Options.intervalText:SetText(L["Interval:"])
	
	SGI_Options.Interval.text:SetText(SGI_DATA[DATA_INDEX].settings.interval)
	SGI_Options.Interval:SetScript("OnMouseWheel",function(self,delta)
		if delta == -1 and SGI_DATA[DATA_INDEX].settings.interval > 1 then
			SGI_DATA[DATA_INDEX].settings.interval = SGI_DATA[DATA_INDEX].settings.interval - 1
			SGI_Options.Interval.text:SetText(SGI_DATA[DATA_INDEX].settings.interval)
		elseif delta == 1 and SGI_DATA[DATA_INDEX].settings.interval < 30 then
			SGI_DATA[DATA_INDEX].settings.interval = SGI_DATA[DATA_INDEX].settings.interval + 1
			SGI_Options.Interval.text:SetText(SGI_DATA[DATA_INDEX].settings.interval)
		end
	end)
	
	SGI_Options.Interval:SetScript("OnEnter",function()
		SGI_Options.Interval.texture:Show()
		SGI_Options.intervalTooltip:Show()
	end)
	SGI_Options.Interval:SetScript("OnLeave",function()
		SGI_Options.Interval.texture:Hide()
		SGI_Options.intervalTooltip:Hide()
	end)
	
	local SGI_OptionsUpdate = 0
	SGI_Options:SetScript("OnUpdate",function()
		if SGI_OptionsUpdate < GetTime() then
			
			if SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_LONG"] and not SGI_ClassLimitHigh:IsShown() then
				SGI_ClassLimitHigh:Show()
				SGI_DATA[DATA_INDEX].settings.classStart = 90
				SGI_Options.classLimitHigh.text:SetText(SGI_DATA[DATA_INDEX].settings.classStart)
				
				SGI_RaceLimitHigh:Show()
				SGI_DATA[DATA_INDEX].settings.raceStart = 90
				SGI_Options.raceLimitHigh.text:SetText(SGI_DATA[DATA_INDEX].settings.raceStart)
				
				SGI_Options.Interval:Show()
				SGI_DATA[DATA_INDEX].settings.interval = SGI_DATA[DATA_INDEX].settings.interval or 5
				SGI_Options.Interval.text:SetText(SGI_DATA[DATA_INDEX].settings.interval)
			elseif not SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_LONG"] then
				SGI_ClassLimitHigh:Hide()
				SGI_DATA[DATA_INDEX].settings.classStart = 91
				SGI_RaceLimitHigh:Hide()
				SGI_DATA[DATA_INDEX].settings.raceStart = 91
				SGI_Options.Interval:Hide()
				SGI_DATA[DATA_INDEX].settings.interval = 5
			end
			
			SGI_INVITEFont:SetText(format(L["Invite: %d"],CountTable(SGI_QUEUE)))
			SGI_Options.Interval.text:SetText(SGI_DATA[DATA_INDEX].settings.interval)
			SGI_Options.classLimitHigh.text:SetText(SGI_DATA[DATA_INDEX].settings.classStart)
			SGI_Options.raceLimitHigh.text:SetText(SGI_DATA[DATA_INDEX].settings.raceStart)
			
			SGI_Options.limitLow.text:SetText(SGI_DATA[DATA_INDEX].settings.lowLimit.." - ")
			SGI_Options.limitHigh.text:SetText(SGI_DATA[DATA_INDEX].settings.highLimit)
			
			SGI_OptionsUpdate = GetTime() + 0.5
			
		end
	end)
	if not SGI_DATA[DATA_INDEX].settings.greet then
		SGI_DATA[DATA_INDEX].settings.greet = "Welcome PLAYER to NAME!"
	end

end

local function ShowOptions()
	if SGI_Options then
		SGI_Options:Show()
	else
		CreateOptions()
		SGI_Options:Show()
	end
end

local function HideOptions()
	if SGI_Options then
		SGI_Options:Hide()
	end
end

local function CreateMinimapbutton()
	local f = CreateFrame("Button","SGI_MiniMapButton",Minimap)
	f:SetWidth(32)
	f:SetHeight(32)
	f:SetFrameStrata("MEDIUM")
	f:SetMovable(true)
	SetFramePos(f)
	
	f:SetNormalTexture("Interface\\AddOns\\SuperGuildInvite\\SGI_MiniMapButton")
	f:SetPushedTexture("Interface\\AddOns\\SuperGuildInvite\\SGI_MiniMapButtonPushed")
	f:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	
	local tooltip = CreateFrame("Frame","SGI_TooltTipMini",f,"GameTooltipTemplate")
	tooltip:SetPoint("BOTTOMRIGHT",f,"TOPLEFT",0,-3)
	local toolstring = tooltip:CreateFontString(nil,"OVERLAY","GameFontNormal")
	toolstring:SetPoint("CENTER")
	toolstring:SetText(LOGO.."|cff88aaffSuperGuildInvite|r")
	tooltip:SetWidth(toolstring:GetWidth()+ 20)
	tooltip:SetHeight(30)
	tooltip:Hide()
	f:SetScript("OnEnter",function()
		tooltip:Show()
	end)
	f:SetScript("OnLeave",function()
		tooltip:Hide()
	end)
	
	local function moveButton(self)
		local centerX, centerY = Minimap:GetCenter()
		local x, y = GetCursorPosition()
		x, y = x / self:GetEffectiveScale() - centerX, y / self:GetEffectiveScale() - centerY
		centerX, centerY = math.abs(x), math.abs(y)
		centerX, centerY = (centerX / math.sqrt(centerX^2 + centerY^2)) * 78, (centerY / sqrt(centerX^2 + centerY^2)) * 78
		centerX = x < 0 and -centerX or centerX
		centerY = y < 0 and -centerY or centerY
		self:ClearAllPoints()
		self:SetPoint("CENTER", centerX, centerY)
	end
	
	f:SetScript("OnMouseDown",function(self,button)
		if button == "RightButton" then
			self:SetScript("OnUpdate",moveButton)
		end
	end)
	f:SetScript("OnMouseUp",function(self,button)
		self:SetScript("OnUpdate",nil)
		GetFramePos(self)
	end)
	f:SetScript("OnClick",function(self,button)
		if SGI_Options and SGI_Options:IsShown() then
			HideOptions()
		else
			ShowOptions()
		end
	end)
end

MinimapLoad = function() if not SGI_MiniMapButton then CreateMinimapbutton() end end

function SlashCmdList.SUPERGUILDINVITE(msg)
	if msg == "reset" then
		local lock = SGI_DATA.lock
		SGI_DATA = nil
		SGI_EVENTS["PLAYER_LOGIN"]()
		SGI_DATA.lock = lock
	elseif msg == "test" then
		print(PickRandomWhisper())
	elseif msg == "locks" then
		DisplayLocks()
	elseif strfind(msg,"unlock") then
		local name = strsub(msg,8)
		if SGI_DATA.lock[name] == "MANUAL" then
			SGI_DATA.lock[name] = nil
			SGI_BACKUP[name] = nil
			print("|cffffff00Manual lock removed on |r|cff00A2FF"..name.."|r")
		elseif SGI_DATA.lock[name] then
			print("|cffffff00The lock on |r|cff00A2FF"..name.."|r|cffffff00 is not manual and can't be removed.|r")
		else
			print("|cffffff00There is no lock on |r|cff00A2FF"..name.."|r")
		end
	elseif strfind(msg,"lock") then
		local name = strsub(msg,6)
		if name then
			SGI_DATA.lock[name] = "MANUAL"
		end
		print("|cffffff00Manual lock on: |r|cff00A2FF"..name.."|r")
	elseif strfind(msg,"limit") then
		local low,high = strsplit(":",strsub(msg,6))
		high = tonumber(high)
		low = tonumber(low)
		if high > 90 then high = 90 end
		if high < low then print("|cffffff00Format: /sgi limit low:high|r") return end
		if low < 1 then low = 1 end
		if low > 90 then low = high-1 end
		SGI_DATA[DATA_INDEX].settings.lowLimit = low
		SGI_DATA[DATA_INDEX].settings.highLimit = high
		print("|cffffff00New low: "..low.." New High: "..high.."|r")
	elseif strfind(msg,"class") then
		local class = tonumber(strsub(msg,7))
		if class then
			if class < 1 then
				class = 1
			elseif class > 90 then
				class = 90
			end
		end
		SGI_DATA[DATA_INDEX].settings.classStart = class
		print("|cffffff00Class searching now starts on level |r|cff00A2FF"..class)
	elseif strfind(msg,"race") then
		local race = tonumber(strsub(msg,6))
		if class then
			if class < 1 then
				class = 1
			elseif class > 90 then
				class = 90
			end
		end
		SGI_DATA[DATA_INDEX].settings.raceStart = race
		print("|cffffff00Race searching now starts on level |r|cff00A2FF"..race)
	elseif strfind(msg,"interval") then
		local interval = tonumber(strsub(msg,10))
		if interval then
			if interval < 1 then
				interval = 1
			elseif interval > 85 then
				interval = 85
			end
		end
		SGI_DATA[DATA_INDEX].settings.interval = interval
		print("|cffffff00Search interval changed to |r|cff00A2FF"..interval)
	elseif msg == "options" then
		ShowOptions()
	elseif msg == "show" then
		for k,_ in pairs(whoQueryList) do
			print(whoQueryList[k])
		end
	elseif strfind(msg,"locale:") then
		local ID = strsub(msg,8)
		if SGI_Locale[ID] then
			L = SGI_Locale[ID]
			print(L["English Locale loaded"]..L["Author"])
		else
			print("Unknown locale ("..ID..")")
		end
	elseif msg == "purge" then
		local i = 0
		for k,_ in pairs(SGI_DATA.lock) do
			SGI_DATA.lock[k]=nil
			SGI_BACKUP[k]=nil
			i = i + 1
		end
		old("|cffffff00<|r|cff16ABB5PMG|r|cffffff00>|r|cffffff00Purging done, "..i.." players have been purged from lockout, enjoy.|r")
	else
		print("|cffffff00Commands: |r|cff00A2FF/sgi or /superguildinvite|r")
		print("|cff00A2FFreset |r|cffffff00to reset all data except locks|r")
		print("|cff00A2FFlocks |r|cffffff00to display currently locked players|r")
		print("|cff00A2FFlock <player>|r|cffffff00 will lock the specified player|r")
		print("|cff00A2FFunlock <player>|r|cffffff00 will unlock the specified player IF they were added manually|r")
		print("|cff00A2FFlimit low:high|r|cffffff00 changes the search limits to low and high|r")
		print("|cff00A2FFclass level|r|cffffff00 changes the level at which class searching will start|r")
		print("|cff00A2FFrace level|r|cffffff00 changes the level at which race searching will start|r")
		print("|cff00A2FFinterval number|r|cffffff00 changes the range each search will have (5 means 1-5,6-10 and so on)|r")
		print("|cff00A2FFoptions|r|cffffff00 shows the options. Same effect as clicking the minimap button|r")
		
	end
end

-- Start of PMG Stuff
local NoteQueue = {}

function PMGCount()
	local i = 0
	if type(SGI_QUEUE) ~= "table" then
		return i
	end
	for k,_ in pairs(SGI_QUEUE) do
		i = i + 1
	end
	return i
end

function PMGGetNameInvite()
	for k,_ in pairs(SGI_QUEUE) do
		return k
	end
end

function PMGGuildInvite(name)
	if not SGI_DATA.lock[name] then
		SGI_DATA.lock[name] = "INVITED"
	end
	if SGI_DATA[DATA_INDEX].settings.dropdown["SGI_WHISPER_MODE"] == 2 and SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_WHISPER"] then
		whisperWaiting[name] = 1
	end
	SGI_QUEUE[name] = nil
	SendAddonMessage(ID_LOCK,name,"GUILD")
end

function PMGPlayerJoinedGuild(name)
	if SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_GREET"] then
		local name = name
		local guildName,guildLevel = GetGuildInfo(UnitName("Player")),GetGuildLevel()
		local PMGgreet = SGI_DATA[DATA_INDEX].settings.greet
		if type(PMGgreet) == "string" then
			if strfind(PMGgreet,"PLAYER") then
				PMGgreet = strsub(PMGgreet,1,strfind(PMGgreet,"PLAYER")-1)..name..strsub(PMGgreet,strfind(PMGgreet,"PLAYER")+6)
			end
			if strfind(PMGgreet,"NAME") then
				PMGgreet = strsub(PMGgreet,1,strfind(PMGgreet,"NAME")-1)..guildName..strsub(PMGgreet,strfind(PMGgreet,"NAME")+4)
			end
			if strfind(PMGgreet,"LEVEL") then
				PMGgreet = strsub(PMGgreet,1,strfind(PMGgreet,"LEVEL")-1)..guildLevel..strsub(PMGgreet,strfind(PMGgreet,"LEVEL")+5)
			end
		end
		SendChatMessage(PMGgreet, "GUILD", nil, index)
	end
	if SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_OFFICER_NOTE"] then
		if CanEditOfficerNote() == 1 then
			PMGSetNote(name, 1)
		end
	end
end

function PMGSetNote(name,delay)
	NoteQueue[name] = { t=GetTime() + delay }
end

local NoteDelay = CreateFrame("Frame")
NoteDelay.update = 0
NoteDelay:SetScript("OnUpdate",function()
	if GetTime() > NoteDelay.update then
		local Now = GetTime()
		for k,_ in pairs(NoteQueue) do
			if NoteQueue[k].t < Now then
				local a, b = GetNumGuildMembers()
				for i = 1, a do
					if GetGuildRosterInfo(i) == k then
						GuildRosterSetOfficerNote(i, date("%d/%m-%Y"))
						NoteQueue[k] = nil
					end
				end
			end
		end
		NoteDelay.update = GetTime() + 0.5
	end
end)

function PMGStartSuperScan()
	if (not ScanInProgress) then
	    CreateOptions()
		SGI_Options:Show()
		if SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_WHISPER"] then
			StartSuperScan()
			SGI_Options:Hide()
		end
	end
end

function ShowGreetFrame()
	if SGI_Greet then
		SGI_Options:Hide()
		SGI_Greet:Show()
	else
		CreateGreetDefineFrame()
		SGI_Options:Hide()
		SGI_Greet:Show()
	end
end

local function PMGmyChatFilter(self, event, msg, _, _, _, toWhom, ...)
	if event == "CHAT_MSG_WHISPER_INFORM" and SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_HIDEWHISPER"] then
		local name = toWhom
		local guildName,guildLevel = GetGuildInfo(UnitName("Player")),GetGuildLevel()
		local i = 0
		local PMGtext = ""
		for i = 1,6 do
			if type(SGI_DATA[DATA_INDEX].settings.whispers[i]) == "string" then
				PMGtext = SGI_DATA[DATA_INDEX].settings.whispers[i]
			else 
				PMGtext = SGI_DATA[DATA_INDEX].settings.whisper
			end
			if type(PMGtext) == "string" then
				if strfind(PMGtext,"PLAYER") then
					PMGtext = strsub(PMGtext,1,strfind(PMGtext,"PLAYER")-1)..name..strsub(PMGtext,strfind(PMGtext,"PLAYER")+6)
				end
				if strfind(PMGtext,"NAME") then
					PMGtext = strsub(PMGtext,1,strfind(PMGtext,"NAME")-1)..guildName..strsub(PMGtext,strfind(PMGtext,"NAME")+4)
				end
				if strfind(PMGtext,"LEVEL") then
					PMGtext = strsub(PMGtext,1,strfind(PMGtext,"LEVEL")-1)..guildLevel..strsub(PMGtext,strfind(PMGtext,"LEVEL")+5)
				end
				if strfind(PMGtext,"%(") then
					PMGtext = strsub(PMGtext,1,strfind(PMGtext,"%(")-1).."."..strsub(PMGtext,strfind(PMGtext,"%(")+1)
				end
				if strfind(PMGtext,"%)") then
					PMGtext = strsub(PMGtext,1,strfind(PMGtext,"%)")-1).."."..strsub(PMGtext,strfind(PMGtext,"%)")+1)
				end
				if strfind(PMGtext,"+") then
					PMGtext = strsub(PMGtext,1,strfind(PMGtext,"+")-1).."."..strsub(PMGtext,strfind(PMGtext,"+")+1)
				end
				if strfind(PMGtext,"-") then
					PMGtext = strsub(PMGtext,1,strfind(PMGtext,"-")-1).."."..strsub(PMGtext,strfind(PMGtext,"-")+1)
				end
				if string.len(PMGtext) > 10 then
					if msg:find(PMGtext) then
						return true
					end
				end
			end
		end
	end
	if event == "CHAT_MSG_SYSTEM" then
		local messagesToHide = {
			ERR_GUILD_INVITE_S,
			ERR_GUILD_DECLINE_S,
			ERR_ALREADY_IN_GUILD_S,
			ERR_ALREADY_INVITED_TO_GUILD_S,
			ERR_GUILD_DECLINE_AUTO_S,
			ERR_GUILD_PLAYER_NOT_FOUND_S,
		}
		local place
		local n
		local name
		for k,_ in pairs(messagesToHide) do
			place = strfind(messagesToHide[k],"%s",1,true)
			if place then
				name = strfind(msg," ",place,true)
				if name then
					n = strsub(msg,place,name-1)
					if format(messagesToHide[k],n) == msg and SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_HIDE"] then
						return true
					else
						n = strsub(msg,place,name-2)
						if format(messagesToHide[k],n) == msg and SGI_DATA[DATA_INDEX].settings.checkboxes["SGI_HIDE"] then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

local function PMGmyChatEventHandler(self,event,arg1,...)
	local filterFuncList = ChatFrame_GetMessageEventFilters(event)
	if filterFuncList then
		for _, filterFunc in pairs(filterFuncList) do
			local filter, newarg1 = filterFunc(self,event,arg1,...)
			if filter then 
				return
			end
			if newarg1 then
				arg1 = newarg
			end
		end
	end
end

function CreateGreetDefineFrame()
	CreateFrame("Frame","SGI_Greet")
	local backdrop = 
	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background", 
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", 
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}
	SGI_Greet:SetWidth(500)
	SGI_Greet:SetHeight(240)
	SGI_Greet:SetBackdrop(backdrop)
	SetFramePos(SGI_Greet)
	SGI_Greet:SetMovable()
	SGI_Greet:SetScript("OnMouseDown",function(self)
		self:StartMoving()
	end)
	SGI_Greet:SetScript("OnMouseUp",function(self)
		self:StopMovingOrSizing()
		GetFramePos(SGI_Greet)
	end)
	
	local close = CreateFrame("Button",nil,SGI_Greet,"UIPanelCloseButton")
	close:SetPoint("TOPRIGHT",SGI_Greet,"TOPRIGHT",-4,-4)
	
	SGI_Greet.title = SGI_Greet:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
	SGI_Greet.title:SetText("Custom Greet Message")
	SGI_Greet.title:SetPoint("TOP",SGI_Greet,"TOP",0,-20)
	
	SGI_Greet.info = SGI_Greet:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SGI_Greet.info:SetPoint("TOPLEFT",SGI_Greet,"TOPLEFT",33,-55)
	SGI_Greet.info:SetText("Create a customized greet message to send people that joins! If you enter the words (must be caps) |cff00ff00NAME|r or |cffff0000PLAYER|r these will be replaced by your Guildname and the players name")
	SGI_Greet.info:SetWidth(450)
	SGI_Greet.info:SetJustifyH("LEFT")
	
	SGI_Greet.edit = CreateFrame("EditBox",nil,SGI_Greet)
	SGI_Greet.edit:SetWidth(450)
	SGI_Greet.edit:SetHeight(65)
	SGI_Greet.edit:SetMultiLine(true)
	SGI_Greet.edit:SetPoint("TOPLEFT",SGI_Greet,"TOPLEFT",35,-120)
	SGI_Greet.edit:SetFontObject("GameFontNormal")
	SGI_Greet.edit:SetTextInsets(10,10,10,10)
	SGI_Greet.edit:SetMaxLetters(256)
	SGI_Greet.edit:SetBackdrop(backdrop)
	SGI_Greet.edit:SetText(SGI_DATA[DATA_INDEX].settings.greet)
	SGI_Greet.edit:SetScript("OnHide",function()
		SGI_Greet.edit:SetText(SGI_DATA[DATA_INDEX].settings.greet)
	end)
	SGI_Greet.edit.text = SGI_Greet.edit:CreateFontString(nil,"OVERLAY","GameFontNormal")
	SGI_Greet.edit.text:SetPoint("TOPLEFT",SGI_Greet.edit,"TOPLEFT",10,13)
	SGI_Greet.edit.text:SetText(L["Enter your greet message"])
	
	anchor = {}
		anchor.point = "BOTTOMLEFT"
		anchor.relativePoint = "BOTTOMLEFT"
		anchor.xOfs = 100
		anchor.yOfs = 20
	
	CreateNewButton("SGI_SAVEGREET",SGI_Greet,120,30,L["Save"],anchor,function()
		local text = SGI_Greet.edit:GetText()
		SGI_DATA[DATA_INDEX].settings.greet = text
		SGI_Greet:Hide()
		SGI_Options:Show()
	end)
	anchor.xOfs = 280
	CreateNewButton("SGI_CANCELGREET",SGI_Greet,120,30,L["Cancel"],anchor,function()
		SGI_Greet:Hide()
		SGI_Options:Show()
	end)
end	

ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", PMGmyChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", PMGmyChatFilter)
-- End PMG Stuff