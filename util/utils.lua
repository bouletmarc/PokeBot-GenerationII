local Utils = {}

local Memory = require "util.memory"

local EMP = 1

-- GENERAL

function Utils.dist(x1, y1, x2, y2)
	return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2))
end

function Utils.each(table, func)
	for key,val in pairs(table) do
		func(key.." = "..tostring(val)..",")
	end
end

function Utils.eachi(table, func)
	for idx,val in ipairs(table) do
		if val then
			func(idx.." "..val)
		else
			func(idx)
		end
	end
end

function Utils.match(needle, haystack)
	for i,val in ipairs(haystack) do
		if needle == val then
			return true
		end
	end
	return false
end

function Utils.key(needle, haystack)
	for key,val in pairs(haystack) do
		if needle == val then
			return key
		end
	end
	return nil
end

function Utils.capitalize(string)
	return string:sub(1, 1):upper()..string:sub(2)
end

-- GAME

function Utils.canPotionWith(potion, forDamage, curr_hp, max_hp)
	local potion_hp
	if potion == "full_restore" then
		potion_hp = 9001
	elseif potion == "super_potion" then
		potion_hp = 50
	else
		potion_hp = 20
	end
	return math.min(curr_hp + potion_hp, max_hp) >= forDamage - 1
end

function Utils.ingame()
	return Memory.value("game", "ingame") > 0
end

function Utils.onPokemonSelect(battleMenu)
	--return battleMenu == 8 or battleMenu == 48 or battleMenu == 184 or battleMenu == 224
	return battleMenu == 145
end

function Utils.drawText(x, y, message)
	gui.text(x * EMP, y * EMP, message)
end

-- TIME

function Utils.igt()
	local hours = Memory.value("time", "hours")
	local mins = Memory.value("time", "minutes")
	local secs = Memory.value("time", "seconds")
	return (hours * 60 + mins) * 60 + secs
end

local function clockSegment(unit)
	if unit < 10 then
		unit = "0"..unit
	end
	return unit
end

function Utils.timeSince(prevTime)
	local currTime = Utils.igt()
	local diff = currTime - prevTime
	local timeString
	if diff > 0 then
		local secs = diff % 60
		local mins = math.floor(diff / 60)
		timeString = clockSegment(mins)..":"..clockSegment(secs)
	end
	return currTime, timeString
end

function Utils.elapsedTime()
	local secs = Memory.value("time", "seconds")
	local mins = Memory.value("time", "minutes")
	local hours = Memory.value("time", "hours")
	return hours..":"..clockSegment(mins)..":"..clockSegment(secs)
end

function Utils.frames()
	local totalFrames = Memory.value("time", "hours") * 60
	totalFrames = (totalFrames + Memory.value("time", "minutes")) * 60
	totalFrames = (totalFrames + Memory.value("time", "seconds")) * 60
	totalFrames = totalFrames + Memory.value("time", "frames")
	return totalFrames
end

return Utils
