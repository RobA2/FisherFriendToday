FisherFriendToday= LibStub("AceAddon-3.0"):NewAddon("FisherFriendToday", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
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
		title = L['Announcement on startup?'],
		tooltip = L['Turn the raid style announcement on/off'],
		default = true,
	},
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
			{value = 1, label = '1'},
			{value = 2, label = '2'},
			{value = 3, label = '3'},
			{value = 4, label = '4'},
			{value = 5, label = '5'},
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
local fftbl={
	"Broken Shore - Impus",
	"Azsuna - Ilyssia of the Waters",
	"Val'sharah - Keeper Raynae",
	"Highmountain - Akule Riverhorn",
	"Stormheim - Corbyn",
	"Suramar - Sha'leth",
	"Dalaran - Conjurer Margoss",
}

local fftc={
	{646,34.00,50.00},--impus
	{630,43.20,40.60},--ilyssia
	{641,53.40,72.80},--keeper
	{650,45.14,59.81},--akule
	{634,90.60,10.60},--corbyn
	{680,50.60,49.20},--sha'leth
	{619,44.68,61.97},--margoss
}
--end--fftable

local fftstring=""--define string for other files/functions
SLASH_FFT1 = "/fft"
local adj=0--initialize so addon loads correctly
--ALL FUNCTIONS HERE BEFORE SLASH PROC!!
--note xxx=yyy vs xxx=(yyy) -- save the function vs save the result of the function

local function fftcore(opt)
	--fftables()--load tables
	--------
	--core/variables
	--------
	if addon:GetOption('adjshow') then --settings check
		adj=(addon:GetOption('adjn'))
	else
		adj=0
	end
	local ttcheck=C_AddOns.IsAddOnLoaded("TomTom") and addon:GetOption('navT')
	--Evaluator
	--local ft=#fftbl--table length catcher--if needed in future
	local stl=tonumber(C_DateAndTime.GetServerTimeLocal())
	local qrt=GetQuestResetTime() --save result
	local qrts=SecondsToTime(qrt) --readable format
	local rset=(stl+qrt)/86400 --seconds/day-used so fmod won't glitch
	local ff=floor(1+math.fmod(rset+adj,6))
	--save as ffs saved variable[last known]?
	local fn=1+math.fmod(ff+6,6)
	local art=(date("%I:00 %p",time()+qrt+1)) --local time+reset+1
	--------
	--end core
	--------
	if opt=='m' or opt=='mar' then ff=7 end -- added for margoss pin
	if opt=='n' or opt=='next' then ff=fn end -- added for pin next
	-----tostring
	fftstring=tostring(fftbl [ff])-- when opt=m,n,or adj-shows on ldb
	--that it shows on the ldb is fine, but need to prepend with the alternate info
	local usetom=("#"..fftc[ff][1].." "..fftc[ff][2].." "..fftc[ff][3].." "..fftstring)
	local usepin=("|cffffff00|Hworldmap:"..fftc[ff][1]..":"..(fftc[ff][2]*100)..":"..(fftc[ff][3]*100).."|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a "..fftstring.."]|h|r")
	local function waypin()
		if ttcheck then
			SlashCmdList.TOMTOM_WAY(usetom);
			--print("TomTom"..usetom)
		else
			DEFAULT_CHAT_FRAME:AddMessage(usepin);
			--print("MapPin")
		end
	end
	local tterk=("|cffff8800**[TomTom] not enabled/detected-FFT will use map pins**|r")
	---------------
	--end variable core
	--start timer setup
	---------------
	--self.fftimer()--runc in rdychk section
	---------------------------------
	--end timer setup
	--start slash command processing
	---------------------------------
	if opt=='' or adj>0 then -- default print/also force print adjustment if set
		if adj>0 then print("|cffddaaffFF Today: [offset="..adj.."]|r")
		else print("|cffddaaffFF Today:|r") end
		print("|cffddddff "..fftstring..". Reset ["..art.."] in "..qrts.."|r");
		--print("|cffddddff ",addon.fftshow,". Reset ["..art.."] in "..qrts.."|r");
	end
	--if opt=='c' then -- was for testing/may remove for public release
	--	xx=self:TimeLeft(self.fftimer)--bad reference... issue viewing timer
	--	print(xx)
	--end
	--	print("|cffddddff "..fftstring..". Reset ["..art.."] in "..qrts.."|r");
	--	print("C-Test: #"..fftc[ff][1]..":"..(fftc[ff][2]*100)..":"..(fftc[ff][3]*100))
	--	print("ttcheck= ["..(ttcheck and 'true' or 'false').."] arrow only shows if you're in Legion!!")
	--	if not ttcheck then
	--		print(tterk)
	--	else
	--		SlashCmdList.TOMTOM_WAY(usetom);--this line will error if used on its own w/out tt
	--	end
	--	DEFAULT_CHAT_FRAME:AddMessage(usepin);
	--end
	if opt=='p' or opt=='pin' then
		DEFAULT_CHAT_FRAME:AddMessage(usepin);
	end
	if opt=='w' or opt=='way' or opt=='m' or opt=='mar' then
		waypin();
	end
	if opt=='n' or opt=='next' then
		fftstring=("|cffaaddffNext: |r"..fftstring)--to show on ldb as well
		print("|cffaaddffFF "..fftstring.."|r")
		--print("|cffaaddffFF Next: "..fftstring.."|r")
		waypin();
	end
	if opt=='?' or opt=='help' then
		print("|cffccffcc                 ===FFT===|r")
		if not ttcheck then
			print(tterk)
		end
		print("|cffffcccc/fft|r -prints the current Fisherfriend and reset time|r")
		print("|cffffcccc/fft p / pin|r -map pin link for current Fisherfriend|r")
		print("|cffffcccc/fft w / way|r -set waypoint for current Fisherfriend|r")
		print("|cffffcccc/fft n / next|r -set waypoint for the next Fisherfriend|r")
		print("|cffffcccc/fft m / mar|r -set waypoint for Margoss|r")
		print("|cffffcc88/ffto or /ffts -Open the setting page|r")
		--print("|cffffcc88/fft 1-5  -adjustment value if cycle is out of sync|r")
		-- 1-5 disabled on line 28 in favor of option menu
		print("|cffaacccc/fft a       -announcment for current Fisherfriend|r")
		--print("|cffaacccc/fft c, info -testing info n stuffs|r")
		print("|Cffff88ff/rl          -Reload interface|r")
		--print("Timer left: "..AceTimer:TimeLeft(FisherFriendToday))--no??
	end
	--if opt== 'info' then -- this can go away in public builds? or retain for diags/saved var
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
	--end
	if opt=='a' then
		RaidNotice_AddMessage(RaidWarningFrame,"FF Today: "..fftstring..". Reset ["..art.."]",ChatTypeInfo["RAID_WARNING"]);
	end
	globqrt=qrt--save as global for ace timer
end
-----------------------
-- end of core function
-----------------------

	SlashCmdList["FFT"] = fftcore
	SLASH_RL1 = "/rl"
	SlashCmdList["RL"] = function() ReloadUI() end
------------
--readycheck
------------

	local function rdychk()
		-----------
		--setup timer
		-----------
		function FisherFriendToday:OnEnable()
			if addon:GetOption('announce') then
				fftcore("a")
			end
				fftcore("")			
			--end
			local fftimer=self:ScheduleTimer(fftcore, globqrt)
			----maybe the timer is set... maybe it isn't...TimeLeft has known issues :/
			--xx=tonumber(self.Timeleft(fftimer))--maybe the timer is set... maybe it isn't
			--print("globqrt: "..globqrt)
			--print("timer: "..xx)
			--print(self.TimeLeft(fftimer))
		end
		-----------
		--end timer
		--ldb start
		----------
		local dataobj = ldb:NewDataObject("FisherFriendToday",
			{type = "data source",
				icon = "Interface\\Icons\\Inv_misc_2h_draenorfishingpole_b_01",
				OnClick = function(clickedframe, button)
					if (button == "LeftButton") then --add "middle" for margos?
						if (IsShiftKeyDown()) then
							--fftcore("n") disabled for now

						else
							fftcore("w")
						end
					else-- if any other 'click'
						fftcore("n")-- right click for now/disabled for now
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
			--self:AddLine("Shift + Left click for FFT next waypoint")
			self:AddLine("Right click for next FFT waypoint")--disabled for now
			self:AddLine("|cffffcc88 /ffto for options|r")
			self:AddLine("|cffcccc88 /fft ? for help|r")
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
--NOOOOOOOOOTES
----------------------------------
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
--open setting by left click ldb -- is not working
-------------------
----local function fftOpenSet()
----	--function wlMiniMapOnClick(self, button, down)
----    if Settings and SettingsPanel and Settings.OpenToCategory then
----        if SettingsPanel:IsShown() then
----            HideUIPanel(SettingsPanel);
----        else
----            Settings.OpenToCategory("(FFT) FisherFriendToday");
----			--Settings.OpenToCategory("FisherFriendToday");
----        end
----    elseif InterfaceOptionsFrame then
----        if not InterfaceOptionsFrame:IsShown() then
----            InterfaceOptionsFrame_OpenToCategory([[(FFT) FisherFriendToday]]);
----			--InterfaceOptionsFrame_OpenToCategory([[FisherFriendToday]]);
----        else
----            InterfaceOptionsFrame:Hide();
----        end
----    end
----end
