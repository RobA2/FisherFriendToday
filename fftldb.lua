local addonName, addon = ...

--local UPDATEPERIOD, elapsed = 0.5, 0
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:NewDataObject("FisherFriendToday",
	{type = "data source",
		icon = "Interface\\Icons\\Inv_misc_2h_draenorfishingpole_b_01",
		OnClick = addon.fftmain("w"),
		label = "FFT",
		text = "FisherFriendToday"})
local f = CreateFrame("frame")

f:SetScript("OnUpdate", function(self, elap)
	dataobj.text = string.format("%q", addon.fftbl[ff])
end)


function dataobj:OnTooltipShow()
	self:AddLine("Left click for FFT current waypoint") -- Always keep Right click for waypoint
	--self:AddLine("Right click for FFT next waypoint") -- make dropdown but retain the basic right click?
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