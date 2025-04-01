--ffta= LibStub("AceAddon-3.0"):NewAddon("FisherFriendToday", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
--0.10.30 major cleanup on ace libs. Line above show what may be added back in when needed,
-- but I'm not sure they were actually getting referenced in the code anyways
--some were intended, but then changed, and just got left in for whatever reason
ffta= LibStub("AceAddon-3.0"):NewAddon("FisherFriendToday", "AceEvent-3.0", "AceTimer-3.0")
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local _, addon = ... --dashi?
local L = addon.L --dashi?
--_G[addonName] = addon

--had Dashi issues, thought it was conflicting libs
--so far it was just my coding
--dashi works fine, but may migrate all to ace3

-----------------------------
-- settings[dashi]
-- moved setting here til I can get files to load in order/fix event checking
-----------------------------

local fftsettings = {
	{
		key = 'navT',
		type = 'toggle',
		title = L['Use TomTom for directions?'],
		tooltip = L['If deselected or if TomTom not installed, will use in-game Map Pins'],
		default = true,
	},
	--maybe someday i'll setup a frame option/toggle... but not today
	{
		key = 'announce',
		type = 'toggle',
		title = L['Announcement on startup/reset?'],
		--tooltip = L['Turn the raid style announcement on/off'],
		default = true,
	},
	{
		key = 'anndelay',
		type = 'menu',
		title = L['Startup Announcement Delay?'],
		--tooltip = L['Seconds to delay the Announcement on startup'],
		default = 10,--save as number
		options = {
			{value = 0, label = '0'},
			{value = 5, label = '5 Seconds'},
			{value = 10, label = '10 Seconds'},
			{value = 20, label = '20 Seconds'},
			{value = 30, label = '30 Seconds'},
			{value = 60, label = '60 Seconds'},
		},

		requires = 'announce', -- (optional) dependency on another setting (must be a "toggle"'myToggle')
	},
	-----reset warning
	{
		key = 'alert',
		type = 'toggle',
		title = L['Alert before Reset?'],
		--tooltip = L['Turn raid style announcement on/off'],
		default = true,
	},
	{
		key = 'alerttime',
		type = 'menu',
		title = L['Minutes before Reset?'],
		--tooltip = L['TimerSeconds to delay the Announcement on startup'],
		default = 5,--save as number
		options = {
			{value = 1, label = '1 Minute'},
			{value = 2, label = '2 Minutes'},
			{value = 5, label = '5 Minutes'},
			{value = 10, label = '10 Minutes'},
		},

		requires = 'alert', -- (optional) dependency on another setting (must be a "toggle"'myToggle')
	},
	-----end reset warning

	{
		key = 'adjshow',
		type = 'toggle',
		title = L['Cycle correction?'],
		tooltip = L['Only needed if the wrong Fisherfriend is showing' .. '\n\n|cffffaaaa' .. L['This should usually be off'] .. '|r'],
		default = false,
	},
	{
		key = 'adjn',
		type = 'menu', -- this works, but shows 'custom' on button if 'value' is string?
		title = L['FFT Calendar Offset?'],
		tooltip = L['This will offset the cycle if the server/addon are out of sync' .. '\n\n|cffffaaaa' .. L['This should usually be 0'] .. '|r'],
		default = 0,--save as number
		options = {
			{value = 0, label = '0'},
			{value = 1, label = '+1'},
			{value = 2, label = '+2'},
			{value = 3, label = '+3'},
			{value = 4, label = '+4'},
			{value = 5, label = '+5'},
		},

		requires = 'adjshow', -- (optional) dependency on another setting (must be a "toggle"'myToggle')
	},
}

addon:RegisterSettings('FFTDB', fftsettings)
addon:RegisterSettingsSlash('/ffts','/ffto')

----------------------------------
-- end setting section
----------------------------------
--local function fftables()
--local fftbl={
--	"Broken Shore - Impus",
--	"Azsuna - Ilyssia of the Waters",
--	"Val'sharah - Keeper Raynae",
--	"Highmountain - Akule Riverhorn",
--	"Stormheim - Corbyn",
--	"Suramar - Sha'leth",
--	"Dalaran - Conjurer Margoss",
--}
--end--old fftable
local fftc={
	{646,34.00,50.00},--2102 impus
	{630,43.20,40.60},--2097 ilyssia
	{641,53.40,72.80},--2098 keeper
	{650,45.14,59.81},--2099 akule
	{634,90.60,10.60},--2100 corbyn
	{680,50.60,49.20},--2101 sha'leth
	{619,44.68,61.97},--1975 margoss
}
-------------
--new fftbl generation to localize npc/rep names
-------------
local ffid={2102,2097,2098,2099,2100,2101,1975}--MUST be in this order for now!!
local fftbl={}
for i=1,7 do--generate fftbl using client locale data
	local genX=C_Reputation.GetFactionDataByID(ffid[i])
	local mapX=C_Map.GetMapInfo(fftc[i][1])
	table.insert(fftbl,i,mapX.name.." - "..genX.name)
	--print(fftb[i])
end
mapX,genX=nil--no need to clutter memory after tbl generated
-----------
--end fftbl generator
-----------
local fftstring=""--define string for other files/functions
SLASH_FFT1 = "/fft"
local adj=0--initialize so addon loads correctly

--ALL FUNCTIONS HERE BEFORE SLASH PROC!!
--note xxx=yyy vs xxx=(yyy) -- save the function vs save the result of the function

	--------
	--core/variables
	--------
local function fftcore(opt)
	if opt then
		opt=strlower(opt)
	end
	if addon:GetOption('adjshow') then --settings check
		adj=(addon:GetOption('adjn'))
	else
		adj=0--leave in place/settings change will need this in core
	end
	local ttcheck=C_AddOns.IsAddOnLoaded("TomTom") and addon:GetOption('navT')
	--Evaluator
	--local ft=#fftbl--table length catcher--if needed in future
	------------------
	--if not ff then --if already defined, then no need to recalc....
	--except.. 'time saving' when i wrote the core, relies on the core recalcing...
	--alot more than is really needed... sigh
	------------------
	local stl=tonumber(C_DateAndTime.GetServerTimeLocal())
	local qrt=GetQuestResetTime() --save result
	local qrts=SecondsToTime(qrt) --readable format
	local rset=(stl+qrt)/86400 --seconds/day-used so fmod won't glitch
	local ff=floor(1+math.fmod(rset+adj,6))
	--save as ffs saved variable[last known]?
	local fn=1+math.fmod(ff+6,6)
	local art=(date("%I:00 %p",time()+qrt+1)) --local time+reset+1
	ffta.art=art--global for ldb
	local wstr=("|cffff99ffFFT: |r")--not needed?
	--end --end ff check
	--------
	--end core
	--------

	--recode new var fp=ff,fn,7 ?? cut down on the repeat calls to the core ??
	-- if so, then would need lcoal refs for the server calcs?
	--thinking on kyboard... core runs on startup... and then only when called by player or timer
	-- if it aint broken dont fix it?
	if opt=='m' or opt=='mar' then ff=7 end -- added for margoss pin
	if opt=='n' or opt=='next' or opt=='na' or opt=='sn' then
		ff=fn
		wstr=("|cffff99ddNext: |r")
	end
	-- added for pin next
	-----tostring
	fftstring=tostring(fftbl [ff])-- when opt=m,n,or adj-shows on ldb
	local usetom=("#"..fftc[ff][1].." "..fftc[ff][2].." "..fftc[ff][3].." "..wstr..fftstring)
	local usepin=("|cffffff00|Hworldmap:"..fftc[ff][1]..":"..(fftc[ff][2]*100)..":"..(fftc[ff][3]*100).."|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a "..fftstring.."]|h|r")
	local function waypin()
		if ttcheck then
			SlashCmdList.TOMTOM_WAY(usetom)
			--print("TomTom"..usetom)
		else
			DEFAULT_CHAT_FRAME:AddMessage(usepin)
			--print("MapPin")
		end
	end
	--local tterk=("")--this was all to see if ldb would display... not so much lol
	--if ttcheck then
	local tterk=("|cffff8800**[TomTom] not enabled/detected-FFT will use map pins**|r")
	--end
	---------------
	--end variable core
	---------------

	--if core is called direct but opt is nil'core()', core still runs, but no chat print
	if opt=='' or adj>0 then -- default print/also force print adjustment if set
		if adj>0 then print("|cffffaaffFF Today: [offset="..adj.."]|r")
		else print("|cffddaaffFF Today:|r") end
		print("|cffddddff "..fftstring..". Reset ["..art.."] in "..qrts.."|r");
		--print("|cffddddff ",addon.fftshow,". Reset ["..art.."] in "..qrts.."|r");
	end
	if opt=='c' then--clear map pin
		C_Map.ClearUserWaypoint()
	end
	-----------
	--share opt
	-----------
	--if opt=='s' then --disable on release for now
	--	DEFAULT_CHAT_FRAME:AddMessage(usepin)--MUST set pin for share link to work
	--	ffts=C_Map.GetUserWaypointHyperlink()
	--	if ffts then
	--		SendChatMessage("FFT: "..fftstring..ffts)
	--	else
	--		print("Please click pin to share")
	--	end
	--end

	-----------
	--share opt notes
	-----------
	-- share testing!! DO NOT SPAM!!
	--pin share works! AceCom throttle?
	--the only point is the chat text plus the selected hyperlink
	--otherwise.. shift-clicking pin is already a thing
	--in other words-- is it really worth it to include this option?
	--this works, but if user does not click the link/has an existing pin/will share the wrong pin :/
	--can't force clear since it would rerun,clear repeat & never share :(
	--C_Map.ClearUserWaypoint()--clear to force user to 'click' the correct pin for sharing
	--else it will share whatever is already pinned--dat is bad :)
	--except...map pins are not autoselecting, so just keeps clearing & never shares
	--local mapPoint = UiMapPoint.CreateFromVector2D(fftc[ff][1], fftc[ff][2]/100, fftc[ff][3]/100)
	--ffts=C_Map.SetUserWaypoint(mapPoint)--does NOT like the formatting above
	
	---------
	--misc notes
	---------
	--need to extract the 'name' from the ingame reputation		
	--for factionID=2099,9 do-- idk for do loops lol
	--friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = C_GossipInfo.GetFriendshipReputation(factionID)
	-- DEFAULT_CHAT_FRAME:AddMessage("Name: "..friendName.." Rank: "..friendTextLevel.." ID: "..factionID)
	--end
	------------

	if opt=='p' or opt=='pin' then
		DEFAULT_CHAT_FRAME:AddMessage(usepin)
	end
	if opt=='w' or opt=='way' or opt=='m' or opt=='mar' then
		waypin();
	end
	if opt=='n' or opt=='next' then
		--fftstring=("|cffaaddffNext: |r"..fftstring)--to show on ldb as well
		--print("|cffaaddffFF "..fftstring.."|r")
		fftstring=(wstr..fftstring)--to show on ldb as well
		print(fftstring)
		--print("|cffaaddffFF Next: "..fftstring.."|r")
		waypin();
	end
	if opt=='a' then
		--ignores menu setting in case they want to run this in a macro
		RaidNotice_AddMessage(RaidWarningFrame,"FF Today: "..fftstring..". Reset ["..art.."]",ChatTypeInfo["RAID_WARNING"]);
	end
	if opt=='na' then
		RaidNotice_AddMessage(RaidWarningFrame,"FF Next: "..fftstring..". in "..qrts,ChatTypeInfo["RAID_WARNING"]);
		fftstring=("|cffaaddffNext: |r"..fftstring)--to show on ldb as well
		print("|cffaaddffFF "..fftstring.." in "..qrts.."|r");
		
	end
	if opt=='?' or opt=='help' then
		print("|cffccffcc   ===FFT===   ver: "..C_AddOns.GetAddOnMetadata("FisherFriendToday","version").."|r")
		if not ttcheck then
			print(tterk)
		end
		print("|cffffcccc/FFT|r - prints the current Fisherfriend and reset time|r")
		print("|cffffcccc/FFT P, W|r - map pin / waypoint for current Fisherfriend|r")
		--print("|cffffcccc/FFT P / pin|r -map pin link for current Fisherfriend|r")
		--print("|cffffcccc/FFT W / way|r -set waypoint for current Fisherfriend|r")
		print("|cffffcccc/FFT N|r - set waypoint for the Next Fisherfriend|r")
		print("|cffffcccc/FFT M|r - set waypoint for Margoss|r")
		print("|cffffcccc/FFT C|r - clear map pin|r")
		print("|cffaacccc/FFT A / NA - announcment for current/next Fisherfriend|r")
		print("|cffffcc88/FFTO or /FFTS - Open the options page|r")
		print("|Cffff88ff/RL - Reload interface|r")
	end

	----------------------
	--setup/reset timer section
	----------------------
	Gqrt=qrt--save as global for ace timer
	ffta:CancelTimer(ffta.TimerOne)--reset on next line
	--'alert' 'alerttime'

	--on trial run, when timer cycles past the alert time...
	--omg!!! Keeps running til reset...Huge spam glitch!
	--oops
	if addon:GetOption('alert') then --settings check
		AlertResetTime=(addon:GetOption('alerttime')*60)
		if Gqrt<=AlertResetTime then--no negative timers please
			AlertResetTime=0 end--FAILSAFE!!
		Gqrt=qrt-AlertResetTime
	else
		Gqrt=qrt--if 'alert' option changes, might need this here
		AlertResetTime=("Unused")
	end
	ffta.TimerOne=ffta:ScheduleTimer("TimerFeedback", (Gqrt+2))--Always +2 seconds
	--main timer gets really weird between 0-1 seconds remaining
	--math.floor might fix, but, if timer ends before servertime cycles
	-- it could still loop for that last second.. 2 sec offset just works
	if addon:GetOption('announce') then --settings check
		ffta.adel=(addon:GetOption('anndelay'))--startup ann check
	else
		ffta.adel=0--if announce is nil, still need this for error prevention?
	end
	-----------
	--test/info last to catch vars after ALL calcs :)
	-----------
	if opt=='test' then
		fftcore("nopt")--run core but no print
		print("qrt: "..qrt.." Gqrt: "..Gqrt.." qrts: "..qrts.." AlertResetTime: "..AlertResetTime)
	end
	--if opt=='info' then end---moved ALL down to NOOOOTES
end
-----------------------
-- end of core function
--timer feedback begin
-----------------------------
ffta.AlertOnce=nil
function ffta:TimerD1()--used if startup announce enabled
	fftcore("a")
end
function ffta:TimerFeedback()--used when reset timer cycles	
	if addon:GetOption('alert') and not ffta.AlertOnce then --settings check
		print("|cffffcc88Reset Soon|r")
		fftcore("na")--print&announce
		ffta.AlertOnce=true--one alert only please
	else
		print("|cffcccc88Reset detected : New FisherFriendToday|r")
		fftcore("a")--announce
		fftcore("")--print
		ffta.AlertOnce=nil
	end
	
end
---------------------
--timer feedback end 
---------------------

	SlashCmdList["FFT"] = fftcore
	SLASH_RL1 = "/rl"
	SlashCmdList["RL"] = function() ReloadUI() end
------------
--readycheck
------------

	local function rdychk()
		function ffta:OnEnable()--prevents startup from glitching
			fftcore("")
			if addon:GetOption('announce') then--run once if option
				ffta.TimerD=ffta:ScheduleTimer("TimerD1", (ffta.adel))
			end
		end
		-----------
		--end timer set #1
		--ldb start
		----------
		local dataobj = ldb:NewDataObject("FisherFriendToday",
			{type = "data source",
				icon = "Interface\\Icons\\Inv_misc_2h_draenorfishingpole_b_01",
				OnClick = function(clickedframe, button)
					if (button == "LeftButton") then
						if (IsShiftKeyDown()) then
							fftcore("m")--margoss
						else
							if (IsControlKeyDown())  then
								--time to learn ace menus
								--Settings.OpenToCategory(categoryID)--dashi
								--[opens settings, but not to addon]
							else
								fftcore("w")
							end	
						end
					else-- if any other 'click'
						fftcore("n")-- right click for now
						--fftOpenSet() --not working
					end
				end,
				-- autoturnin reference for correct onclick operation
				--OnClick = function(clickedframe, button)
				--	if (button == "LeftButton") then
				--		AutoTurnIn:ShowOptions("")
				--	else
				--		AutoTurnIn:SetEnabled(not db.enabled)
				--	end
				--end,
				-- autoturnin end referecne
				label = "FFT",
				text = "FisherFriendToday"})
		local f = CreateFrame("frame")

		f:SetScript("OnUpdate", function(self, elap)
			dataobj.text = (" "..fftstring)--prepend with opt,m,n,etc
			--change onclick to update on click,use alt,ctrl,shift for opt-n/m/somthin--right click for navigation
		end)


		function dataobj:OnTooltipShow()
			--self:AddLine("|cffffcc88Right click for options|r") -- click section fine, but 'open settings' is not
			self:AddLine("Left click for current FFT waypoint")
			self:AddLine("Shift + Left click for Margoss")
			self:AddLine("Right click for next FFT waypoint")
			self:AddLine("|cffffcc88 /ffto for options|r")
			self:AddLine("|cffcccc88 /fft ? for help|r")
			self:AddLine("|cffcc8888 Reset time: "..ffta.art.."|r")
			--self:AddLine(tterk)--it didnt like this lol
		end

		function dataobj:OnEnter()
			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
			GameTooltip:ClearLines()
			dataobj.OnTooltipShow(GameTooltip)
			GameTooltip:Show()
		end
		function dataobj:OnLeave()
			GameTooltip:Hide()
		end
	end

-----------------------------
-- end ldb section
-----------------------------
--xpcall(rdychk,'')-- keep note if needed later
rdychk()

--run once to initalize everything

--end --if you missed a close function, this can at least help format to track down the oops

----------------------------------------------------------
--NOOOOOOOOOTES!!!!
----------------------------------
--if opt=='info' then -- this can go away in public builds? or retain for diags/saved var
	--	print("|cffff8855Version: "..C_AddOns.GetAddOnMetadata("FisherFriendToday","version").."|r")
	--	local r1=GetCurrentRegionName() 
	--	local r2=GetRealmName()
	--	print(" Region/Realm: "..r1.."/"..r2)
	--	v, b, d, t = GetBuildInfo()
	--	print(string.format("version = %s, build = %s, date = '%s', tocversion = %s.", v, b, d, t))
	--	local d = C_DateAndTime.GetCurrentCalendarTime()
	--	local weekDay = CALENDAR_WEEKDAY_NAMES[d.weekday]
	--	local month = CALENDAR_FULLDATE_MONTH_NAMES[d.month]
	--	print(format("Realm time is %02d:%02d, %s, %d %s %d", d.hour, d.minute, weekDay, d.monthDay, month, d.year))
	--local Timer1 = SecondsToTime(ffta:TimeLeft(ffta.TimerOne))-- was used to verify timer functions
	--local Timer2 = SecondsToTime(ffta:TimeLeft(ffta.TimerD))
	--print("Timer reset: "..Timer1)
	--print("Ann timer left: "..Timer2)
	--print("Announce Delay: "..ffta.adel)
	--end

--fftcore only needs to be run on startup
--further calls maybe causing garbage
--new func just needs to ref existing data
--timer calls just need to advance ff since it was already synced on startup


--------
-- c-timer was here-- all timer notes are outdated & replaced with working code
-- but there's been a few 'how did i try that before' reasons to keep these notes :)
--------

------------------
--event check was not working--moved all below to ace enable check
----------------------
--local function OnEvent(self, event, ...)
--	if addon:GetOption('announce') then --MUST follow timer or it tries to run b4 vars rdy
--			fftcore("a");--raid announce
--			fftcore("");-- standard print
--			--addon.fftcore=fftcore()--- possible issue? wrong place? wrong what??
--		end
--end

----------------
--event check?!?!? --almost certain this is NOT the source of dashi glitching
---------------
-- moved to encompase ldb section
--	local function rdychk()
--		--repeat   --event nvr triggerd?
--		C_Timer.After(0, function()
--		--C_Timer.After(10, rdychk)---just recycles on itself
--			C_Timer.After(3, function()
--		--until(addon.event == "ADDON_LOADED" and arg1 == addon)--pretty sure im stuck in a loop
--		--event never loads, then repeats and halts everything, bleh
--		--if GetOption('announce') then 
--		if announce then
--			fftcore("a");--raid announce
--		end
--		fftcore("");-- standard print
--			end)
--		end)
--	end
--	--xpcall(rdychk,'')--run separate till section below is sorted?
--rdychk()
---------
--event checker?-ace/dashi conflict?
----------
	
	--local frame = CreateFrame("Frame");
	--frame:RegisterEvent("ADDON_LOADED",...);
--frame:SetScript("OnEvent", function(__, event, arg1)
	--if (event == "ADDON_LOADED" and arg1 == addon) then
		--xpcall(rdychk,'')
	--end
--end)
-------------
--end event check
-----------
--addon:RegisterEvent('ADDON_LOADED') --?????

	--local frame = CreateFrame("Frame");
	--frame:SetScript("OnEvent", function(__, event, arg1)
	--    if (event == "ADDON_LOADED" and arg1 == addon) then
	--        xpcall(rdychk,'')
	--    end
	--end);
	--frame:RegisterEvent("ADDON_LOADED");
	----C_Timer.After(0, function() -- leave at 0
	--	--C_Timer.After(3, function() -- default is 3 may add to option menu
	--	--if addon:GetOption('announce') then --MUST follow timer or it tries to run b4 vars rdy?
	--	if GetOption('announce') then --MUST follow timer or it tries to run b4 vars rdy?
	--		fftcore("a");--raid announce
	--		fftcore("");-- standard print
	--		--addon.fftcore=fftcore()--- possible issue? wrong place? wrong what??
	--	end
	--end)
	--end)
	--end
-----------------------
--end event check
--------------------

--local f = CreateFrame("Frame")-- tried
----f:RegisterEvent("CHAT_MSG_CHANNEL")
----f:RegisterEvent("PLAYER_STARTED_MOVING")
----f:RegisterEvent("PLAYER_STOPPED_MOVING")
--f:SetScript("OnEvent", OnEvent)-- tried
-------------------------------------------
-- shoving ldb section here til I get global mess sorted
-------------------------------------------
-------------------