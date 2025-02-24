local _, addon = ...

function Frame1_OnLoad()
	--end
	C_Timer.After(0, function() -- leave at 0
		C_Timer.After(6, function() -- main timer is 3... set this to 6?
			--addon.fftmain();-- no output here, just run
			Frame1:Show();
		end)
	end)
end
function Frame1_OnEvent(ADDON_LOADED,FisherFriend_Today)
	--if addon.fftshow then
	print("GAHHHHHHHHHHH")
	FontString2:SetText("Can you work now?")
	--FontString2:SetText(addon.fftshow); --this will be the output
	--end
end

function Button1_OnClick()
	Frame1:Hide();
end


--/etrace ??