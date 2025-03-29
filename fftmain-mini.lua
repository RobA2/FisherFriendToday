ffta=LibStub("AceAddon-3.0"):NewAddon("FisherFriendToday","AceConsole-3.0","AceEvent-3.0","AceTimer-3.0","AceComm-3.0")local a=LibStub:GetLibrary("LibDataBroker-1.1")local b,c=...local d=c.L;local e={{key='navT',type='toggle',title=d['Use TomTom for directions?'],tooltip=d['If deselected or if TomTom not installed, will use in-game Map Pins'],default=true},{key='announce',type='toggle',title=d['Announcement on startup/reset?'],default=true},{key='anndelay',type='menu',title=d['Startup Announcement Delay?'],default=10,options={{value=0,label='0'},{value=5,label='5 Seconds'},{value=10,label='10 Seconds'},{value=20,label='20 Seconds'},{value=30,label='30 Seconds'},{value=60,label='60 Seconds'}},requires='announce'},{key='alert',type='toggle',title=d['Alert before Reset?'],default=true},{key='alerttime',type='menu',title=d['Minutes before Reset?'],default=5,options={{value=1,label='1 Minute'},{value=2,label='2 Minutes'},{value=5,label='5 Minutes'},{value=10,label='10 Minutes'}},requires='alert'},{key='adjshow',type='toggle',title=d['Cycle correction?'],tooltip=d['Only needed if the wrong Fisherfriend is showing'..'\n\n|cffffaaaa'..d['This should usually be off']..'|r'],default=false},{key='adjn',type='menu',title=d['FFT Calendar Offset?'],tooltip=d['This will offset the cycle if the server/addon are out of sync'..'\n\n|cffffaaaa'..d['This should usually be 0']..'|r'],default=0,options={{value=0,label='0'},{value=1,label='+1'},{value=2,label='+2'},{value=3,label='+3'},{value=4,label='+4'},{value=5,label='+5'}},requires='adjshow'}}c:RegisterSettings('FFTDB',e)c:RegisterSettingsSlash('/ffts','/ffto')local f={{646,34.00,50.00},{630,43.20,40.60},{641,53.40,72.80},{650,45.14,59.81},{634,90.60,10.60},{680,50.60,49.20},{619,44.68,61.97}}local g={2102,2097,2098,2099,2100,2101,1975}local h={}for i=1,7 do local genX=C_Reputation.GetFactionDataByID(g[i])local mapX=C_Map.GetMapInfo(f[i][1])table.insert(h,i,mapX.name.." - "..genX.name)end;mapX,genX=nil;local j=""SLASH_FFT1="/fft"local k=0;local function l(m)if m then m=strlower(m)end;if c:GetOption('adjshow')then k=c:GetOption('adjn')else k=0 end;local n=C_AddOns.IsAddOnLoaded("TomTom")and c:GetOption('navT')local o=tonumber(C_DateAndTime.GetServerTimeLocal())local p=GetQuestResetTime()local q=SecondsToTime(p)local r=(o+p)/86400;local s=floor(1+math.fmod(r+k,6))local t=1+math.fmod(s+6,6)local u=date("%I:00 %p",time()+p+1)ffta.art=u;local v="|cffff99ffFFT: |r"if m=='m'or m=='mar'then s=7 end;if m=='n'or m=='next'or m=='na'or m=='sn'then s=t;v="|cffff99ddNext: |r"end;j=tostring(h[s])local w="#"..f[s][1].." "..f[s][2].." "..f[s][3].." "..v..j;local x="|cffffff00|Hworldmap:"..f[s][1]..":"..f[s][2]*100 ..":"..f[s][3]*100 .."|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a "..j.."]|h|r"local function y()if n then SlashCmdList.TOMTOM_WAY(w)else DEFAULT_CHAT_FRAME:AddMessage(x)end end;local z="|cffff8800**[TomTom] not enabled/detected-FFT will use map pins**|r"if m==''or k>0 then if k>0 then print("|cffffaaffFF Today: [offset="..k.."]|r")else print("|cffddaaffFF Today:|r")end;print("|cffddddff "..j..". Reset ["..u.."] in "..q.."|r")end;if m=='c'then C_Map.ClearUserWaypoint()end;if m=='p'or m=='pin'then DEFAULT_CHAT_FRAME:AddMessage(x)end;if m=='w'or m=='way'or m=='m'or m=='mar'then y()end;if m=='n'or m=='next'then j=v..j;print(j)y()end;if m=='a'then RaidNotice_AddMessage(RaidWarningFrame,"FF Today: "..j..". Reset ["..u.."]",ChatTypeInfo["RAID_WARNING"])end;if m=='na'then RaidNotice_AddMessage(RaidWarningFrame,"FF Next: "..j..". in "..q,ChatTypeInfo["RAID_WARNING"])j="|cffaaddffNext: |r"..j;print("|cffaaddffFF "..j.." in "..q.."|r")end;if m=='?'or m=='help'then print("|cffccffcc   ===FFT===   ver: "..C_AddOns.GetAddOnMetadata("FisherFriendToday","version").."|r")if not n then print(z)end;print("|cffffcccc/FFT|r - prints the current Fisherfriend and reset time|r")print("|cffffcccc/FFT P, W|r - map pin / waypoint for current Fisherfriend|r")print("|cffffcccc/FFT N|r - set waypoint for the Next Fisherfriend|r")print("|cffffcccc/FFT M|r - set waypoint for Margoss|r")print("|cffffcccc/FFT C|r - clear map pin|r")print("|cffaacccc/FFT A / NA - announcment for current/next Fisherfriend|r")print("|cffffcc88/FFTO or /FFTS - Open the options page|r")print("|Cffff88ff/RL - Reload interface|r")end;Gqrt=p;ffta:CancelTimer(ffta.TimerOne)if c:GetOption('alert')then AlertResetTime=c:GetOption('alerttime')*60;if Gqrt<=AlertResetTime then AlertResetTime=0 end;Gqrt=p-AlertResetTime else Gqrt=p;AlertResetTime="Unused"end;ffta.TimerOne=ffta:ScheduleTimer("TimerFeedback",Gqrt+2)if c:GetOption('announce')then ffta.adel=c:GetOption('anndelay')else ffta.adel=0 end;if m=='test'then l("nopt")print("qrt: "..p.." Gqrt: "..Gqrt.." qrts: "..q.." AlertResetTime: "..AlertResetTime)end end;ffta.AlertOnce=nil;function ffta:TimerD1()l("a")end;function ffta:TimerFeedback()if c:GetOption('alert')and not ffta.AlertOnce then print("|cffffcc88Reset Soon|r")l("na")ffta.AlertOnce=true else print("|cffcccc88Reset detected : New FisherFriendToday|r")l("a")l("")ffta.AlertOnce=nil end end;SlashCmdList["FFT"]=l;SLASH_RL1="/rl"SlashCmdList["RL"]=function()ReloadUI()end;local function A()function ffta:OnEnable()l("")if c:GetOption('announce')then ffta.TimerD=ffta:ScheduleTimer("TimerD1",ffta.adel)end end;local B=a:NewDataObject("FisherFriendToday",{type="data source",icon="Interface\\Icons\\Inv_misc_2h_draenorfishingpole_b_01",OnClick=function(C,D)if D=="LeftButton"then if IsShiftKeyDown()then l("m")else if IsControlKeyDown()then else l("w")end end else l("n")end end,label="FFT",text="FisherFriendToday"})local E=CreateFrame("frame")E:SetScript("OnUpdate",function(self,F)B.text=" "..j end)function B:OnTooltipShow()self:AddLine("Left click for current FFT waypoint")self:AddLine("Shift + Left click for Margoss")self:AddLine("Right click for next FFT waypoint")self:AddLine("|cffffcc88 /ffto for options|r")self:AddLine("|cffcccc88 /fft ? for help|r")self:AddLine("|cffcc8888 Reset time: "..ffta.art.."|r")end;function B:OnEnter()GameTooltip:SetOwner(self,"ANCHOR_NONE")GameTooltip:SetPoint("TOPLEFT",self,"BOTTOMLEFT")GameTooltip:ClearLines()B.OnTooltipShow(GameTooltip)GameTooltip:Show()end;function B:OnLeave()GameTooltip:Hide()end end;A()