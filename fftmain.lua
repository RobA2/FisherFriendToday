FisherFriend_Today= LibStub("AceAddon-3.0"):NewAddon("FisherFriend_Today", "AceConsole-3.0", "AceEvent-3.0")
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local _, addon = ...
local L = addon.L
local fftsettings = {
{
key = 'navT',
type = 'toggle',
title = L['Use TomTom for directions?'],
tooltip = L['If deselected or if TomTom not installed, will use in-game Map Pins'],
default = true,
},
{
key = 'announce',
type = 'toggle',
title = L['Announcement on startup?'],
tooltip = L['Turn the startup raid style announcement on/off'],
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
type = 'menu',
title = L['FFT Calendar Offset?'],
tooltip = L['This will offset the cycle if the server/addon are out of sync' .. '\n\n|cffffaaaa' .. L['This should usually be 0'] .. '|r'],
default = 0,
options = {
{value = 0, label = '0'},
{value = 1, label = '1'},
{value = 2, label = '2'},
{value = 3, label = '3'},
{value = 4, label = '4'},
{value = 5, label = '5'},
},
requires = 'adjshow',
},
}
addon:RegisterSettings('FFTDB', fftsettings)
addon:RegisterSettingsSlash('/ffts','/ffto')
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
{646,34.00,50.00},
{630,43.20,40.60},
{641,53.40,72.80},
{650,45.14,59.81},
{634,90.60,10.60},
{680,50.60,49.20},
{619,44.68,61.97},
}
local fftstring=""
SLASH_FFT1 = "/fft"
local adj=0
local function fftcore(opt)
if addon:GetOption('adjshow') then
adj=(addon:GetOption('adjn'))
else
adj=0
end
local ttcheck=C_AddOns.IsAddOnLoaded("TomTom") and addon:GetOption('navT')
local stl=tonumber(C_DateAndTime.GetServerTimeLocal())
local qrt=GetQuestResetTime()
local qrts=SecondsToTime(qrt)
local rset=(stl+qrt)/86400
local ff=floor(1+math.fmod(rset+adj,6))
local fn=1+math.fmod(ff+6,6)
local art=(date("%I:00 %p",time()+qrt+1))
if opt=='m' or opt=='mar' then ff=7 end
if opt=='n' or opt=='next' then ff=fn end
fftstring=tostring(fftbl [ff])
local usetom=("#"..fftc[ff][1].." "..fftc[ff][2].." "..fftc[ff][3].." "..fftstring)
local usepin=("|cffffff00|Hworldmap:"..fftc[ff][1]..":"..(fftc[ff][2]*100)..":"..(fftc[ff][3]*100).."|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a "..fftstring.."]|h|r")
local function waypin()
if ttcheck then
SlashCmdList.TOMTOM_WAY(usetom);
else
DEFAULT_CHAT_FRAME:AddMessage(usepin);
end
end
local tterk=("|cffff8800**[TomTom] not enabled/detected-FFT will use map pins**|r")
if opt=='' or adj>0 then
if adj>0 then print("|cffddaaffFF Today: [offset="..adj.."]|r")
else print("|cffddaaffFF Today:|r") end
print("|cffddddff "..fftstring..". Reset ["..art.."] in "..qrts.."|r");
end
if opt=='c' then
print("|cffddddff "..fftstring..". Reset ["..art.."] in "..qrts.."|r");
print("C-Test: #"..fftc[ff][1]..":"..(fftc[ff][2]*100)..":"..(fftc[ff][3]*100))
print("ttcheck= ["..(ttcheck and 'true' or 'false').."] arrow only shows if you're in Legion!!")
if not ttcheck then
print(tterk)
else
SlashCmdList.TOMTOM_WAY(usetom);
end
DEFAULT_CHAT_FRAME:AddMessage(usepin);
end
if opt=='p' or opt=='pin' then
DEFAULT_CHAT_FRAME:AddMessage(usepin);
end
if opt=='w' or opt=='way' or opt=='m' or opt=='mar' then
waypin();
end
if opt=='n' or opt=='next' then
fftstring=("|cffaaddffNext: |r"..fftstring)
print("|cffaaddffFF "..fftstring.."|r")
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
print("|cffaacccc/fft a       -announcment for current Fisherfriend|r")
print("|Cffff88ff/rl          -Reload interface|r")
end
if opt== 'info' then
print("|cffff8855Version: "..C_AddOns.GetAddOnMetadata("FisherFriendToday","version").."|r")
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
RaidNotice_AddMessage(RaidWarningFrame,"FF Today: "..fftstring..". Reset ["..art.."]",ChatTypeInfo["RAID_WARNING"]);
end
end
SlashCmdList["FFT"] = fftcore
SLASH_RL1 = "/rl"
SlashCmdList["RL"] = function() ReloadUI() end
local function fftOpenSet()
if Settings and SettingsPanel and Settings.OpenToCategory then
if SettingsPanel:IsShown() then
HideUIPanel(SettingsPanel);
else
Settings.OpenToCategory("(FFT) FisherFriendToday");
end
elseif InterfaceOptionsFrame then
if not InterfaceOptionsFrame:IsShown() then
InterfaceOptionsFrame_OpenToCategory([[(FFT) FisherFriendToday]]);
else
InterfaceOptionsFrame:Hide();
end
end
end
local function rdychk()
C_Timer.After(0, function()
C_Timer.After(3, function()
if announce then
fftcore("a");
end
fftcore("");
end)
end)
local dataobj = ldb:NewDataObject("FisherFriendToday",
{type = "data source",
icon = "Interface\\Icons\\Inv_misc_2h_draenorfishingpole_b_01",
OnClick = function(clickedframe, button)
if (button == "LeftButton") then
if (IsShiftKeyDown()) then
else
fftcore("w")
end
else
fftcore("n")
end
end,
label = "FFT",
text = "FisherFriendToday"})
local f = CreateFrame("frame")
f:SetScript("OnUpdate", function(self, elap)
dataobj.text = (" "..fftstring)
end)
function dataobj:OnTooltipShow()
self:AddLine("Left click for current FFT waypoint")
self:AddLine("Right click for next FFT waypoint")
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
rdychk()
