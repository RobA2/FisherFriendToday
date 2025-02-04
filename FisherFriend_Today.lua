local fftbl={
	"Broken Shore - Impus",
	"Azsuna - Ilyssia of the Waters",
	"Val'sharah - Keeper Raynae",
	"Highmountain - Akule Riverhorn",
	"Stormheim - Corbyn",
	"Suramar - Sha'leth",
	"Dalaran - Conjurer Margoss",
}
local fftway={
	"#646 33.70 49.80 ",-- Impus
	"#630 43.21 40.55 ",-- Ilyssia
	"#641 53.41 72.86 ",-- Keeper
	"#650 45.14 59.81 ",-- Akule
	"#634 90.69 10.87 ",-- Corbyn
	"#680 50.71 49.34 ",-- Sha'leth
	"#619 44.68 61.97 ",-- Margoss
}
--format for pin v={650, .4515, .5981}
local fftpin={
	"646:3400:5000",--impus
	"630:4320:4060",--ilyssia
	"641:5340:7280",--keeper
	"650:4514:5981",--akule
	"634:9060:1060",--corbyn
	"680:5060:4920",--sha'leth
	"619:4468:6197",--margoss
}
--todo list: combine way & pin but use each npc as separate tables?
SLASH_FFT1 = "/fft"
--note xxx=yyy vs xxx=(yyy) -- save the function vs save the result of the function
local function fftmain(opt)--add 1-6 adj--can use multi opt? /fft xxx xxx
	local adj=0--set as a dropdown list for any possible timing issues
	--local ft=#fftbl--table length catcher--if needed in future
	local t=tonumber(C_DateAndTime.GetServerTimeLocal())
	local qrt=GetQuestResetTime() --must be a variable
	local qrts=SecondsToTime(qrt) --show readable format
	local rset=(t+qrt)/86400 --seconds/day-used so fmod won't glitch
	local ff=floor(1+math.fmod(rset+adj,6))
	--save as ffs saved variable[last known]?
	local fn=1+math.fmod(ff+6,6)
	local art=(date("%I:00 %p",time()+qrt+1)) --local time+reset+1
	local ttcheck=C_AddOns.IsAddOnLoaded("TomTom")--Works!! if tt is loaded,ttcheck saves, if not then nil
	if opt == 'm' or opt=='mar' then ff=7 end -- added for margoss pin
	if opt == 'n' or opt=='next' then ff=fn end -- added for pin next
	local usepin=("|cffffff00|Hworldmap:"..fftpin[ff].."|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a "..fftbl[ff].."]|h|r")
	--start slash command processing
	if opt=='' then
		print(" ")
		print("FF Today: "..fftbl[ff]..". Reset ["..art.."] in "..qrts);
	end
	if opt=='p' or opt=='pin' then
		--save next note for table redo list
		--C_Map.SetUserWaypoint(UiMapPoint.CreateFromVector2D(fftpin[1],CreateVector2D(fftpin[2],fftpin[3])))
		DEFAULT_CHAT_FRAME:AddMessage(usepin);
	end
	if opt == 'w' or opt=='way'  then
		if ttcheck then
			SlashCmdList.TOMTOM_WAY(fftway[ff]..fftbl[ff])
		else
			DEFAULT_CHAT_FRAME:AddMessage(usepin);
		end
	end
	if opt=='n' or opt=='next' then
		if ttcheck then
			SlashCmdList.TOMTOM_WAY(fftway[fn]..fftbl[fn])
		else
			DEFAULT_CHAT_FRAME:AddMessage(usepin);--ff=fn
		end
	end
	if opt == 'm' or opt == 'mar' then
		if ttcheck then
			SlashCmdList.TOMTOM_WAY(fftway[7]..fftbl[7])
		else
			DEFAULT_CHAT_FRAME:AddMessage(usepin);--added opt7 check to show margoss usepin
		end
	end
	if opt == '?' or opt=='help' then
		print(" ")
		if not ttcheck then
			print("|cffff8800**[TomTom] not detected-Using map pins**|r")
		end
		print("|cffffcccc/fft|r -prints the current Fisherfriend and reset time")
		print("|cffffcccc/fft p / pin|r -map pin link for current Fisherfriend")
		print("|cffffcccc/fft w / way|r -set waypoint for current Fisherfriend")
		print("|cffffcccc/fft n / next|r -set waypoint for the next Fisherfriend")
		print("|cffffcccc/fft m / mar|r -set waypoint for Margoss")
		--print("   [though he is not a FisherFriend, is related enough :)")
		print("|cffffcccc/fft ? or /fft help|r -this help list :)")
		print("|Cffff88ff/rl       -Reload interface|r")
	end
	if opt== 'info' then
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
end
	SlashCmdList["FFT"] = fftmain
	SLASH_RL1 = "/rl"
	SlashCmdList["RL"] = function() ReloadUI() end
--end--if you missed a close function, this will at least help format to track down the oops