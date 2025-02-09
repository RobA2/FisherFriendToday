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

SLASH_FFT1 = "/fft"
--ALL FUNCTIONS HERE BEFORE SLASH PROC!!
--note xxx=yyy vs xxx=(yyy) -- save the function vs save the result of the function
local function fftmain(opt)
	local adj=0
	if strmatch(opt,"%d") then
		adj=tonumber(opt)
	end	
	--local ft=#fftbl--table length catcher--if needed in future
	local stl=tonumber(C_DateAndTime.GetServerTimeLocal())
	local qrt=GetQuestResetTime() --save result
	local qrts=SecondsToTime(qrt) --readable format
	local rset=(stl+qrt)/86400 --seconds/day-used so fmod won't glitch
	local ff=floor(1+math.fmod(rset+adj,6))
	--save as ffs saved variable[last known]?
	local fn=1+math.fmod(ff+6,6)
	local art=(date("%I:00 %p",time()+qrt+1)) --local time+reset+1
	local ttcheck=C_AddOns.IsAddOnLoaded("TomTom")--later option to be saved var for toggle/select
	if opt=='m' or opt=='mar' then ff=7 end -- added for margoss pin
	if opt=='n' or opt=='next' then ff=fn end -- added for pin next
	local usetom=("#"..fftc[ff][1].." "..fftc[ff][2].." "..fftc[ff][3].." "..fftbl[ff])
	local usepin=("|cffffff00|Hworldmap:"..fftc[ff][1]..":"..(fftc[ff][2]*100)..":"..(fftc[ff][3]*100).."|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a "..fftbl[ff].."]|h|r")
	local function waypin()
		if ttcheck then
			SlashCmdList.TOMTOM_WAY(usetom);
		else
			DEFAULT_CHAT_FRAME:AddMessage(usepin);
		end
	end
	--start slash command processing
	--was looking up ways to combine argument evaluation...
	-- but again... making an interface would solve these things :)
	if opt=='' or adj>0 then
		if adj>0 then print("|cffddaaffFF Today: [adjustment="..adj.."]|r")
		else print("|cffddaaffFF Today:|r") end
		print("|cffddddff "..fftbl[ff]..". Reset ["..art.."] in "..qrts.."|r");
	end
	if opt=='c' then -- was for testing/may remove for public release
		print("|cffddddff "..fftbl[ff]..". Reset ["..art.."] in "..qrts.."|r");
		print("C-Test: #"..fftc[ff][1]..":"..(fftc[ff][2]*100)..":"..(fftc[ff][3]*100))
		SlashCmdList.TOMTOM_WAY(usetom);
		DEFAULT_CHAT_FRAME:AddMessage(usepin);
	end
	if opt=='p' or opt=='pin' then
		DEFAULT_CHAT_FRAME:AddMessage(usepin);
	end
	if opt=='w' or opt=='way' or opt=='m' or opt=='mar' then
		waypin();
	end
	if opt=='n' or opt=='next' then
		print("|cffaaddffFF Next: "..fftbl[ff].."|r")
		waypin();
	end
	if opt=='?' or opt=='help' then
		if not ttcheck then
			print("|cffff8800**[TomTom] not detected-FFT will use map pins**|r")
		else
			print("|cffccffcc                 ---FFT---|r")
		end
		print("|cffffcccc/fft|r -prints the current Fisherfriend and reset time|r")
		print("|cffffcccc/fft p / pin|r -map pin link for current Fisherfriend|r")
		print("|cffffcccc/fft w / way|r -set waypoint for current Fisherfriend|r")
		print("|cffffcccc/fft n / next|r -set waypoint for the next Fisherfriend|r")
		print("|cffffcccc/fft m / mar|r -set waypoint for Margoss|r")
		print("|cffffcc88/fft 1-5  -adjustment value if cycle is out of sync|r")
		print("|Cffff88ff/rl       -Reload interface|r")
	end
	if opt== 'info' then -- this can go away in public builds? or retain for diags/saved var
		print("|cffff8855Version: "..C_AddOns.GetAddOnMetadata("FisherFriend_Today","version").."|r")
		local r1=GetCurrentRegionName() 
		local r2=GetRealmName()
		print(" Region/Realm: "..r1.."/"..r2)
		v, b, d, t = GetBuildInfo()
		print(string.format("version = %s, build = %s, date = '%s', tocversion = %s.", v, b, d, t))
		local d = C_DateAndTime.GetCurrentCalendarTime()
		local weekDay = CALENDAR_WEEKDAY_NAMES[d.weekday]
		local month = CALENDAR_FULLDATE_MONTH_NAMES[d.month]
		print(format("Realm time is %02d:%02d, %s, %d %s %d", d.hour, d.minute, weekDay, d.monthDay, month, d.year))
	end
	if opt=='a' then
		RaidNotice_AddMessage(RaidWarningFrame,"FF Today: "..fftbl[ff]..". Reset ["..art.."]",ChatTypeInfo["RAID_WARNING"]);
	end
end
	SlashCmdList["FFT"] = fftmain
	SLASH_RL1 = "/rl"
	SlashCmdList["RL"] = function() ReloadUI() end
--run once for announcement
C_Timer.After(0, function() -- leave at 0
	C_Timer.After(6, function() -- default is 3 - 6 for my slow gears (add to option menu)
		fftmain("a")
	end)
end)

	
--end--if you missed a close function, this will at least help format to track down the oops