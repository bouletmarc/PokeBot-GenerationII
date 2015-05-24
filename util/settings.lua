local Settings = {}

local Textbox = require "action.textbox"

local Bridge = require "util.bridge"
local Input = require "util.input"
local Memory = require "util.memory"
local Menu = require "util.menu"
local Utils = require "util.utils"

--local START_WAIT = 99

--local tempDir

local settings_menu = 7
local settings_done = false
local Setting_done = false

local desired = {}
desired.text_speed = GAME_TEXT_SPEED
desired.battle_animation = GAME_BATTLE_ANIMATION
desired.battle_style = GAME_BATTLE_STYLE
desired.sound_style = GAME_SOUND_STYLE
desired.print_style = GAME_PRINT_STYLE
desired.account_style = GAME_ACCOUNT_STYLE
desired.windows_style = GAME_WINDOWS_STYLE

local function isEnabled(name)
	return Memory.value("setting", name) == desired[name]
end

-- PUBLIC

function Settings.set(...)
	if not settings_done then
		for i,name in ipairs(arg) do
			if not isEnabled(name) then
				if Menu.open(settings_menu, 2, "option") then
					Menu.setOption(name, desired[name])
				end
				return false
			end
		end
		--setting done
		settings_done = true
	end
	--close option menu
	local OptionValue = Memory.value("menu", "option_current")
	if OptionValue ~= 5 then
		Input.press("B", 1)
	end
	if OptionValue == 5 then
		settings_done = false
		return true
	end
end

function Settings.startNewAdventure(startWait)
	local startMenu = Memory.value("menu", "main")
	local MenuCurrent = Memory.value("menu", "current")
	local ShopCurrent = Memory.value("menu", "shop_current")
	local InputRow = Memory.value("menu", "input_row")
	local HoursRow = Memory.value("menu", "hours_row")
	local MinutesRow = Memory.value("menu", "minutes_row")
	
	--set settings
	if startMenu == 122 then
		if not Setting_done then
			if Settings.set("text_speed", "battle_animation", "battle_style", "sound_style", "print_style", "account_style", "windows_style") then
				Setting_done = true
			end
		else
			Input.press("A", 2)
		end
	--press A or Start
	elseif startMenu == 127 then
		--if MenuCurrent == 59 then	--french
		if MenuCurrent == 104 then	--english
			Input.press("A", 2)
		else
			if not Setting_done and math.random(0, startWait) == 0 then
				Input.press("Start")
			end
		end
	else
		--Set Name
		--if MenuCurrent == 79 then	--french
		if MenuCurrent == 110 then	--english
			if InputRow == 1 and GAME_GENDER == 2 then
				Input.press("Down", 2)
			elseif InputRow == 2 and GAME_GENDER == 1 then
				Input.press("Up", 2)
			else
				Input.press("A", 2)
			end
		--Set hours/minutes/name
		elseif MenuCurrent == 32 or MenuCurrent == 107 then
			--if ShopCurrent == 77 then	--french
			if ShopCurrent == 78 then	--english
				--set hours
				if HoursRow < GAME_HOURS then
					Input.press("Up", 1)
				elseif HoursRow > GAME_HOURS then
					Input.press("Down", 1)
				elseif HoursRow == GAME_HOURS then
					Input.press("A", 1)
				end
			elseif ShopCurrent == 30 then
				--set minutes
				if MinutesRow < GAME_MINUTES then
					Input.press("Up", 1)
				elseif MinutesRow > GAME_MINUTES then
					Input.press("Down", 1)
				elseif MinutesRow == GAME_MINUTES then
					Input.press("A", 1)
				end
			end
		--elseif MenuCurrent == 231 then	--french
		elseif MenuCurrent == 232 then	--english
			--remake setting not done
			Setting_done = false
			--set our name
			Textbox.name(PLAYER_NAME, true)
		else
			Input.press("A")
		end
	end
end

--[[function Settings.FirstSpawn()
	if not FirstSpawnDone then
		local MenuValue = Memory.value("menu", "main")
		if MenuValue == 121 then
			Input.press("B", 2)
			FirstSpawnDone2 = true
		elseif MenuValue == 0 then
			if Textbox.isActive() then
				Input.press("Start", 2)
			elseif not Textbox.isActive() and FirstSpawnDone2 then
				FirstSpawnDone = true
				return true
			end
		end
	else
		return true
	end
end]]

--[[function Settings.RemoveLastAdventure(startWait)
	if not tempDir then
		if Memory.value("menu", "size") ~= 2 and math.random(0, startWait) == 0 then
			Input.press("Start")
		elseif Memory.value("menu", "size") == 2 then
			Input.press("B")
			tempDir = true
		end
	else
		if Utils.ingame() then
			if Memory.value("menu", "pokemon") ~= 0 then
				Input.press("B")
			elseif Memory.value("menu", "pokemon") == 0 then
				if Memory.value("menu", "size") == 2 then
					Input.press("", 0, false, true)
				else
					if Memory.value("menu", "row") == 1 then
						Input.press("A")
					else
						Input.press("Down")
					end
				end
			end
		else
			tempDir = false
			RUNNING4NEWGAME = false		--stop the function after removed
		end
	end
end]]

--[[function Settings.ContinueAdventure()
	local current = Memory.value("menu", "current")
	local row = Memory.value("menu", "row")
	if row == 0 then
		if current == 32 then
			RUNNING4CONTINUE = false	--stop ContinueAdventure
		elseif current ~= 55 then
			Input.press("A")
		end
	else
		Input.press("Up")
	end
end]]

--[[function Settings.choosePlayerNames()
	local name = PLAYER_NAME
	if dirText ~= "glitch" then
		if (Memory.value("player", "name") ~= 141) or (Memory.value("player", "name2") ~= 136) then
			name = RIVAL_NAME
		end
	else
		if (Memory.value("player", "name") ~= 141) or (Memory.value("player", "name2") ~= 136) then
			name = "> "
		end
	end
	Textbox.name(name, true)
end

function Settings.pollForResponse()
	local response = Bridge.process()
	if response then
		Bridge.polling = false
		Textbox.setName(tonumber(response))
	end
end]]

return Settings
