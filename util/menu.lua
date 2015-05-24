local Menu = {}

local Input = require "util.input"
local Memory = require "util.memory"

--local yellow = GAME_NAME == "yellow"

local sliding = false

--Menu.pokemon = yellow and 51 or 103
--Menu.pokemon = 103 	--NOT USED?

-- Private functions

--local function getRow(menuType, scrolls)
local function getRow(menuType)
	if menuType then
		menuType = menuType.."_row"
	else
		menuType = "row"
	end
	local row = Memory.value("menu", menuType)
	--if scrolls then
	--	row = row + Memory.value("menu", "scroll_offset")
	--end
	return row
end

--local function setRow(desired, throttle, scrolls, menuType, loop)
local function setRow(desired, throttle, menuType, loop)
	--local currentRow = getRow(menuType, scrolls)
	local currentRow = getRow(menuType)
	if throttle == "accelerate" then
		if sliding then
			throttle = false
		else
			local dist = math.abs(desired - currentRow)
			if dist < 15 then
				throttle = true
			else
				throttle = false
				sliding = true
			end
		end
	else
		sliding = false
	end
	--if menuType ~= "hours" or menuType ~= "minutes" then
		return Menu.balance(currentRow, desired, true, loop, throttle)
	--else
	--	return Menu.balance(currentRow, desired, false, loop, throttle)
	--end
end

local function isCurrently(desired, menuType)
	if menuType then
		if menuType ~= "main" then
			menuType = menuType.."_current"
		end
	else
		menuType = "current"
	end
	return Memory.value("menu", menuType) == desired
end
Menu.isCurrently = isCurrently

-- Menu

function Menu.getCol()
	return Memory.value("menu", "column")
end

function Menu.open(desired, atIndex, menuType)
	if isCurrently(desired, menuType) then
		return true
	end
	Menu.select(atIndex, false, menuType)
	return false
end

--function Menu.select(option, throttle, scrolls, menuType, dontPress, loop)
function Menu.select(option, throttle, menuType, dontPress, loop)
	--Reset MenuType
	local menuTypeSent
	if menuType == "option" then
		menuTypeSent = nil
	else
		menuTypeSent = menuType
	end
	--if setRow(option, throttle, scrolls, menuType, loop) then
	if setRow(option, throttle, menuTypeSent, loop) then
		local delay = 1
		if throttle or menuType == "option" then
			delay = 2
		end
		if not dontPress then
			Input.press("A", delay)
		end
		return true
	end
end

function Menu.cancel(desired, menuType)
	if not isCurrently(desired, menuType) then
		return true
	end
	Input.press("B")
	return false
end

-- Selections

function Menu.balance(current, desired, inverted, looping, throttle)
	if current == desired then
		sliding = false
		return true
	end
	if not throttle then
		throttle = 0
	else
		throttle = 1
	end
	--local goUp = current > desired == inverted
	local goUp
	if inverted then
		if desired < current then
			goUp = true
		else
			goUp = false
		end
	else
		goUp = false
	end
	if looping and math.abs(current - desired) > math.floor(looping / 2) then
		goUp = not goUp
	end
	if goUp then
		Input.press("Up", throttle)
	else
		Input.press("Down", throttle)
	end
	return false
end

function Menu.sidle(current, desired, looping, throttle)
	if current == desired then
		return true
	end
	if not throttle then
		throttle = 0
	else
		throttle = 1
	end
	local goLeft = current > desired
	if looping and math.abs(current - desired) > math.floor(looping / 2) then
		goLeft = not goLeft
	end
	if goLeft then
		Input.press("Left", throttle)
	else
		Input.press("Right", throttle)
	end
	return false
end

function Menu.setCol(desired, looping, throttle)
	return Menu.sidle(Menu.getCol(), desired, looping, throttle)
end

-- Options

function Menu.setOption(name, desired)
	local rowFor = {
		text_speed = 0,
		battle_animation = 1,
		battle_style = 2,
		sound_style = 3,
		print_style = 4,
		account_style = 5,
		windows_style = 6
	}
	if Memory.value("setting", name) == desired then
		return true
	end
	--if setRow(rowFor[name], true, false, "settings") then
	if setRow(rowFor[name], 2, "settings") then
		Menu.setCol(desired, false, 2)
	end
	return false
end

-- Pause menu

function Menu.isOpen()
	return Memory.value("game", "textbox") == 1 or Memory.value("menu", "current") == 79
	--return Memory.value("game", "textbox") == 1 or Memory.value("menu", "current") == 24
end

function Menu.close()
	--if Memory.value("game", "textbox") == 0 and Memory.value("menu", "main") < 8 then
	if Memory.value("game", "textbox") == 0 and Memory.value("menu", "main") == 0 then
		return true
	end
	Input.press("B")
end

function Menu.pause()
	if Memory.value("game", "textbox") == 1 then
		--if Memory.value("battle", "menu") == 95 then
		if Memory.value("battle", "text") == 3 then
			Input.cancel()
		--[[else
			local main = Memory.value("menu", "main")
			if main > 2 and main ~= 64 then
				return true
			end
			Input.press("B")]]
		elseif Memory.value("battle", "text") == 11 then
			return true
		else
			Input.press("B")
		end
	else
		Input.press("Start", 2)
	end
end

return Menu
