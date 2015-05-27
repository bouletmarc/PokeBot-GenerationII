local Walk = {}

local Control = require "ai.control"

local Paths = require "data.paths"

local Input = require "util.input"
local Memory = require "util.memory"
local Player = require "util.player"

local Pokemon = require "storage.pokemon"


local path, stepIdx, currentMap, currentMap2
local pathIdx = 21	--0 or 14(after elm) or 21(inside gym)
local customIdx = 1
local customDir = 1
--local custom_done = false

-- Private functions

local function setPath(index, region, region2)
	if PRINT_PATH then
		print("Path Idx : "..index.." *******")
	end
	pathIdx = index
	stepIdx = 3
	currentMap = region
	currentMap2 = region2
	path = Paths[index]
end

--[[local function setPathCustom(index, region, Idx)
	if PRINT_PATH then
		print("Path Idx : "..index.." *******")
	end
	if PRINT_STEP then
		print("Step Idx : "..stepIdx)
	end
	pathIdx = index
	stepIdx = Idx
	currentMap = region
	path = Paths[index]
	custom_done = true
end]]

local function completeStep(region, region2)
	if PRINT_STEP then
		print("Step Idx : "..stepIdx)
	end
	stepIdx = stepIdx + 1
	return Walk.traverse(region, region2)
end

-- Helper functions

function dir(px, py, dx, dy)
	local direction
	if py > dy then
		direction = "Up"
	elseif py < dy then
		direction = "Down"
	elseif px > dx then
		direction = "Left"
	else
		direction = "Right"
	end
	return direction
end
Walk.dir = dir

function step(dx, dy, hold)
	local px, py = Player.position()
	if px == dx and py == dy then
		return true
	end
	--get waiting before inputing
	local Waiting = Input.isWaiting()
	if not Waiting then
		Input.press(dir(px, py, dx, dy), 0, hold)
	end
end
Walk.step = step

-- Table functions

function Walk.reset()
	path = nil
	pathIdx = 0
	customIdx = 1
	customDir = 1
	currentMap = nil
	currentMap2 = nil
	Walk.strategy = nil
end

function Walk.init()
	local region = Memory.value("game", "map")
	local region2 = Memory.value("game", "map2")
	local px, py = Player.position()
	if region == 0 or region2 == 0 and px == 0 and py == 0 then
		return false
	end
	for tries=1,2 do
		for i,p in ipairs(Paths) do
			if i > 2 and p[1] == region and p[2] == region2 then
				local origin = p[3]
				if tries == 2 or (origin[1] == px and origin[2] == py) then
					setPath(i, region, region2)
					return tries == 1
				end
			end
		end
	end
end

function Walk.traverse(region, region2)
	local newIndex
	if not path or currentMap ~= region or currentMap2 ~= region2 then
		Walk.strategy = nil
		customIdx = 1
		customDir = 1
		--if PATH_IDX ~= 0 and STEP_IDX ~= 0 and not custom_done then
		--	setPathCustom(PATH_IDX, region, STEP_IDX)
		--	newIndex = pathIdx
		--else
			setPath(pathIdx + 1, region, region2)
			newIndex = pathIdx
		--end
	elseif stepIdx > #path then
		return
	end
	local tile = path[stepIdx]
	if tile.c then
		Control.set(tile)
		return completeStep(region, region2)
	end
	if tile.s then
		if Walk.strategy then
			Walk.strategy = nil
			return completeStep(region, region2)
		end
		Walk.strategy = tile
	elseif step(tile[1], tile[2]) then
		Pokemon.updateParty()
		return completeStep(region, region2)
	end
	return newIndex
end

function Walk.canMove()
	--return Memory.value("player", "moving") == 0 and Memory.value("player", "fighting") == 0
	--return Memory.value("player", "moving") == 1 and Memory.value("game", "battle") == 0
	return Memory.value("player", "moving") == 1
end

-- Custom path

function Walk.invertCustom(silent)
	if not silent then
		customIdx = customIdx + customDir
	end
	customDir = customDir * -1
end

function Walk.custom(cpath, increment)
	if not cpath then
		customIdx = 1
		customDir = 1
		return
	end
	if increment then
		customIdx = customIdx + customDir
	end
	local tile = cpath[customIdx]
	if not tile then
		if customIdx < 1 then
			customIdx = #cpath
		else
			customIdx = 1
		end
		return customIdx
	end
	local t1, t2 = tile[1], tile[2]
	if t2 == nil then
		if Player.face(t1) then
			Input.press("A", 2)
		end
		return t1
	end
	if step(t1, t2) then
		customIdx = customIdx + customDir
	end
end

return Walk
