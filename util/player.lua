local Player = {}

local Textbox = require "action.textbox"

local Input = require "util.input"
local Memory = require "util.memory"

local facingDirections = {Up=4, Right=12, Left=8, Down=0}

function Player.isFacing(direction)
	return Memory.value("player", "facing") == facingDirections[direction]
end

function Player.face(direction)
	if Player.isFacing(direction) then
		return true
	end
	if Textbox.handle() then
		Input.press(direction, 0)
	end
end

function Player.interact(direction, opposite)
	if Player.face(direction) then
		if not opposite then
			Input.press("A", 2)
		else
			Input.press("B", 2)
		end
		return true
	end
end

function Player.isMoving()
	return Memory.value("player", "moving") ~= 1
end

function Player.position()
	return Memory.value("player", "x"), Memory.value("player", "y")
end

return Player
