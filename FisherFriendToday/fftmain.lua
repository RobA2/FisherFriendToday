ffta=LibStub("AceAddon-3.0"):NewAddon("FisherFriendToday","AceConsole-3.0","AceEvent-3.0","AceTimer-3.0","AceComm-3.0")local a=LibStub:GetLibrary("LibDataBroker-1.1")local b,c=...local d=c.L;local e={{key='navT',type='toggle',title=d['Use TomTom for directions?'],tooltip=d['If deselected or if TomTom not installed, will use in-game Map Pins'],default=true},{key='announce',type='toggle',title=d['Announcement on startup/reset?'],default=true},{key='anndelay',type='menu',title=d['Startup Announcement Delay?'],default=10,options={{value=0,label='0'},{value=5,label='5 Seconds'},{value=10,label='10 Seconds'},{value=20,label='20 Seconds'},{value=30,label='30 Seconds'},{value=60,label='60 Seconds'}},requires='announce'},{key='alert',type='toggle',title=d['Alert before Reset?'],default=true},{key='alerttime',type='menu',title=d['Minutes before Reset?'],default=5,options={{value=1,label='1 Minute'},{value=2,label='2 Minutes'},{value=5,label='5 Minutes'},{value=10,label='10 Minutes'}},requires='alert'},{key='adjshow',type='toggle',title=d['Cycle correction?'],tooltip=d['Only needed if the wrong Fisherfriend is showing'..'\n\n|cffffaaaa'..d['This should usually be off']..'|r'],default=false},{key='adjn',type='menu',title=d['FFT Calendar Offset?'],tooltip=d['This will offset the cycle if the server/addon are out of sync'..'\n\n|cffffaaaa'..d['This should usually be 0']..'|r'],default=0,options={{value=0,label='0'},{value=1,label='+1'},{value=2,label='+2'},{value=3,label='+3'},{value=4,label='+4'},{value=5,label='+5'}},requires='adjshow'}}c:RegisterSettings('FFTDB',e)c:RegisterSettingsSlash('/ffts','/ffto')local f={"Broken Shore - Impus","Azsuna - Ilyssia of the Waters","Val'sharah - Keeper Raynae","Highmountain - Akule Riverhorn","Stormheim - Corbyn","Suramar - Sha'leth","Dalaran - Conjurer Margoss"}local g={{646,34.00,50.00},{630,43.20,40.60},{641,53.40,72.80},{650,45.14,59.81},{634,90.60,10.60},{680,50.60,49.20},{619,44.68,61.97}}local h=""SLASH_FFT1="/fft"local i=0;local function j(k)if k then k=strlower(k)end;if c:GetOption('adjshow')then i=c:GetOption('adjn')else i=0 end;local l=C_AddOns.IsAddOnLoaded("TomTom")and c:GetOption('navT')local m=tonumber(C_DateAndTime.GetServerTimeLocal())local n=GetQuestResetTime()local o=SecondsToTime(n)local p=(m+n)/86400;local q=floor(1+math.fmod(p+i,6))local r=1+math.fmod(q+6,6)local s=date("%I:00 %p",time()+n+1)ffta.art=s;local t="|cffff99ffFFT: |r"if k=='m'or k=='mar'then q=7 end;if k=='n'or k=='next'or k=='na'or k=='sn'then q=r;t="|cffff99ddNext: |r"end;h=tostring(f[q])local u="#"..g[q][1].." "..g[q][2].." "..g[q][3].." "..t..h;local v="|cffffff00|Hworldmap:"..g[q][1]..":"..g[q][2]*100 ..":"..g[q][3]*100 .."|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a "..h.."]|h|r"local function w()if l then SlashCmdList.TOMTOM_WAY(u)else DEFAULT_CHAT_FRAME:AddMessage(v)end end;local x="|cffff8800**[TomTom] not enabled/detected-FFT will use map pins**|r"if k==''or i>0 then if i>0 then print("|cffffaaffFF Today: [offset="..i.."]|r")else print("|cffddaaffFF Today:|r")end;print("|cffddddff "..h..". Reset ["..s.."] in "..o.."|r")end;if k=='c'then C_Map.ClearUserWaypoint()end;if k=='p'or k=='pin'then DEFAULT_CHAT_FRAME:AddMessage(v)end;if k=='w'or k=='way'or k=='m'or k=='mar'then w()end;if k=='n'or k=='next'then h=t..h;print(h)w()end;if k=='a'then RaidNotice_AddMessage(RaidWarningFrame,"FF Today: "..h..". Reset ["..s.."]",ChatTypeInfo["RAID_WARNING"])end;if k=='na'then RaidNotice_AddMessage(RaidWarningFrame,"FF Next: "..h..". in "..o,ChatTypeInfo["RAID_WARNING"])h="|cffaaddffNext: |r"..h;print("|cffaaddffFF "..h.." in "..o.."|r")end;if k=='?'or k=='help'then print("|cffccffcc   ===FFT===   ver: "..C_AddOns.GetAddOnMetadata("FisherFriendToday","version").."|r")if not l then print(x)end;print("|cffffcccc/FFT|r - prints the current Fisherfriend and reset time|r")print("|cffffcccc/FFT P, W|r - map pin / waypoint for current Fisherfriend|r")print("|cffffcccc/FFT N|r - set waypoint for the Next Fisherfriend|r")print("|cffffcccc/FFT M|r - set waypoint for Margoss|r")print("|cffffcccc/FFT C|r - clear map pin|r")print("|cffaacccc/FFT A / NA - announcment for current/next Fisherfriend|r")print("|cffffcc88/FFTO or /FFTS - Open the options page|r")print("|Cffff88ff/RL - Reload interface|r")end;Gqrt=n;ffta:CancelTimer(ffta.TimerOne)if c:GetOption('alert')then AlertResetTime=c:GetOption('alerttime')*60;if Gqrt<=AlertResetTime then AlertResetTime=0 end;Gqrt=n-AlertResetTime else Gqrt=n;AlertResetTime="Unused"end;ffta.TimerOne=ffta:ScheduleTimer("TimerFeedback",Gqrt+2)if c:GetOption('announce')then ffta.adel=c:GetOption('anndelay')else ffta.adel=0 end;if k=='test'then j("nopt")print("qrt: "..n.." Gqrt: "..Gqrt.." qrts: "..o.." AlertResetTime: "..AlertResetTime)end end;ffta.AlertOnce=nil;function ffta:TimerD1()j("a")end;function ffta:TimerFeedback()if c:GetOption('alert')and not ffta.AlertOnce then print("|cffffcc88Reset Soon|r")j("na")ffta.AlertOnce=true else print("|cffcccc88Reset detected : New FisherFriendToday|r")j("a")j("")ffta.AlertOnce=nil end end;SlashCmdList["FFT"]=j;SLASH_RL1="/rl"SlashCmdList["RL"]=function()ReloadUI()end;local function y()function ffta:OnEnable()j("")if c:GetOption('announce')then ffta.TimerD=ffta:ScheduleTimer("TimerD1",ffta.adel)end end;local z=a:NewDataObject("FisherFriendToday",{type="data source",icon="Interface\\Icons\\Inv_misc_2h_draenorfishingpole_b_01",OnClick=function(A,B)if B=="LeftButton"then if IsShiftKeyDown()then j("m")else if IsControlKeyDown()then else j("w")end end else j("n")end end,label="FFT",text="FisherFriendToday"})local C=CreateFrame("frame")C:SetScript("OnUpdate",function(self,D)z.text=" "..h end)function z:OnTooltipShow()self:AddLine("Left click for current FFT waypoint")self:AddLine("Shift + Left click for Margoss")self:AddLine("Right click for next FFT waypoint")self:AddLine("|cffffcc88 /ffto for options|r")self:AddLine("|cffcccc88 /fft ? for help|r")self:AddLine("|cffcc8888 Reset time: "..ffta.art.."|r")end;function z:OnEnter()GameTooltip:SetOwner(self,"ANCHOR_NONE")GameTooltip:SetPoint("TOPLEFT",self,"BOTTOMLEFT")GameTooltip:ClearLines()z.OnTooltipShow(GameTooltip)GameTooltip:Show()end;function z:OnLeave()GameTooltip:Hide()end end;y()