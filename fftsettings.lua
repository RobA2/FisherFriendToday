-- Author      : Rob
-- Create Date : 2/17/2025 7:48:42 PM

local _, addon = ...
local L = addon.L

--local function formatPercentage(value)
--	--return PERCENTAGE_STRING:format(math.floor((value * 100) + 0.5))
--	return PERCENTAGE_STRING:format(value)
--end

--local function formatN(value)
--return tonumber(value)
--end
--nav,announce,fftframe,adj,adjshow


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
		key = 'fftframe', --placeholder? use frame for display vs ldb
		type = 'toggle',
		title = L['Show FFT frame?'],
		tooltip = L['**PLACEHOLDER** Turn the FFT frame on/off'],
		default = true,
	},
	--{
	--	key = 'adjn',
	--	type = 'slider', -- sliders are not usually a thing, so need to check event to see what is triggering wrong
	--	title = L['Adjustment number in case the app shows the wrong Fisherfriend'],
	--	tooltip = L['Unless something really crazy happens' .. '\n\n|cffffaaaa' .. L['This should always be 0!'] .. '|r'],
	--	default = 0,
	--	minValue = 0,
	--	maxValue = 5,
	--	valueStep = 1,
	--	--valueFormat = formatN, --it REALLY wants this to be a string :/
	--	valueFormat = formatPercentage,
	--},
	-- next menu item not required
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

