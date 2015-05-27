local Strategies = {}

local Combat = require "ai.combat"
local Control = require "ai.control"

local Battle = require "action.battle"
local Textbox = require "action.textbox"
local Walk = require "action.walk"

local Bridge = require "util.bridge"
local Input = require "util.input"
local Memory = require "util.memory"
local Menu = require "util.menu"
local Player = require "util.player"
local Utils = require "util.utils"

local Inventory = require "storage.inventory"
local Pokemon = require "storage.pokemon"

--local yellow = YELLOW
local splitNumber, splitTime = 0, 0
local resetting, itemPos1, itemPos2, itemNumber

local status = {tries = 0, canProgress = nil, initialized = false, tempDir = false}
Strategies.status = status

local strategyFunctions

-- RISK/RESET

function Strategies.getTimeRequirement(name)
	return Strategies.timeRequirements[name]()
end

-- RISK/RESET

function Strategies.hardReset(message, extra, wait)
	resetting = true
	if Strategies.seed then
		if extra then
			extra = extra.." | "..Strategies.seed
		else
			extra = Strategies.seed
		end
	end
	--Reset values
	--RUNNING4CONTINUE = false
	--RUNNING4NEWGAME = true
	
	Bridge.chat(message, extra)
	if wait and INTERNAL and not STREAMING_MODE then
		strategyFunctions.wait()
	else
		client.reboot_core()
	end
	return true
end

function Strategies.reset(reason, extra, wait)
	local time = Utils.elapsedTime()
	local resetMessage = "reset"
	if time then
		resetMessage = resetMessage.." after "..time
	end
	resetMessage = resetMessage.." at "..Control.areaName
	local separator
	if Strategies.deepRun and not Control.yolo then
		separator = " BibleThump"
	else
		separator = ":"
	end
	resetMessage = resetMessage..separator.." "..reason
	if status.tweeted then
		Strategies.tweetProgress(resetMessage)
	end
	return Strategies.hardReset(resetMessage, extra, wait)
end

-- RESET TO CONTINUE

--[[function Strategies.SkipReset(message)
	RUNNING4CONTINUE = true
	EXTERNALDONE = false
	client.reboot_core()
	return true
end]]

function Strategies.death(extra)
	local reason = "Died"
	--[[local reason
	if Control.missed then
		reason = "Missed"
	elseif Control.criticaled then
		reason = "Critical'd"
	elseif Control.yolo then
		reason = "Yolo strats"
	else
		reason = "Died"
	end]]
	return Strategies.reset(reason, extra)
end

function Strategies.overMinute(min)
	if type(min) == "string" then
		min = Strategies.getTimeRequirement(min)
	end
	return Utils.igt() > (min * 60)
end

function Strategies.resetTime(timeLimit, reason, once)
	if Strategies.overMinute(timeLimit) then
		reason = "Took too long to "..reason
		if RESET_FOR_TIME then
			return Strategies.reset(reason)
		end
		if once then
			print(reason.." "..Utils.elapsedTime())
		end
	end
end

-- HELPERS

function Strategies.initialize()
	if not status.initialized then
		status.initialized = true
		return true
	end
end

function Strategies.buffTo(buff, defLevel, usePPAmount, secondAttack)
	if Battle.isActive() then
		status.canProgress = true
		local forced
		--go by def level
		if not usePPAmount then
			if defLevel and Memory.double("battle", "opponent_defense") > defLevel then
				forced = buff
			end
		--go by use PP amount
		else
			local AvailablePP = Battle.pp(buff)
			if usePPAmount ~= "infinite" then
				if Strategies.initialize() then
					status.tempDir = AvailablePP-usePPAmount
				end
				if AvailablePP > status.tempDir and AvailablePP > 0 then
					forced = buff
				end
			else
				if AvailablePP > 0 then
					forced = buff
				end
			end
		end
		--second attack
		if forced ~= buff and secondAttack ~= nil then
			local AvailablePP = Battle.pp(secondAttack)
			if AvailablePP > 0 then
				forced = secondAttack
			end
		end
		Battle.automate(forced, true)
	elseif status.canProgress then
		return true
	else
		Battle.automate()
	end
end

function Strategies.useItem(item, pokemon, Close, Option)
	if Strategies.initialize() then
		status.tempDir = false
		status.canProgress = false
	end
	--set options
	if not Option then
		Option = 1 --use
		status.canProgress = true
	elseif Option == "give" then
		--check if the pokemon held a item before give it
		if not status.canProgress then
			if Pokemon.index(Pokemon.indexOf(pokemon), "held") ~= 0 then
				return true
			elseif Pokemon.index(Pokemon.indexOf(pokemon), "held") == 0 then
				status.canProgress = true
			end
		end
		Option = 2
	end
	--select/give/use items
	if status.canProgress then
		local MainMenu = Memory.value("menu", "main")
		local Row = Memory.value("menu", "row")
		local ItemRow = Memory.value("menu", "input_row")
		local Column = Memory.value("menu", "column")
		local ShopCurrent = Memory.value("menu", "shop_current")
		local MenuSize = Memory.value("menu", "size")
		--open menu
		if MainMenu ~= 50 and MainMenu ~= 121 and MainMenu ~= 127 and not status.tempDir then
			Input.press("Start", 2)
		--close menu
		elseif MainMenu == 1 and status.tempDir then
			return true
		--item menu
		elseif MainMenu == 50 then
			--select bitter berry and go equip it to totodile
			if not status.tempDir then
				if Column ~= 0 then
					Input.press("Right", 2)
				else
					--select item
					if ShopCurrent ~= 66 then
						local ItemIdx = Inventory.indexOf(item)
						if ItemRow ~= ItemIdx+1 then
							Input.press("Down", 2)
						else
							Input.press("A", 2)
						end
					--option menu
					else
						--reset option with menu size
						if MenuSize == 3 and Option == 2 then
							Option = 1
						end
						--use/give/toss
						if ItemRow ~= Option then
							Input.press("Down", 2)
						else
							Input.press("A", 2)
						end
					end
				end
			--switch to next function
			else
				if not Close then
					return true
				else
					Input.press("B", 2)
				end
			end
		--pokemon menu
		elseif MainMenu == 127 then
			local PokemonIdx = Pokemon.indexOf(pokemon)
			if ItemRow ~= PokemonIdx+1 then
				Input.press("Down", 2)
			else
				Input.press("A", 2)
				status.tempDir = true
			end
		--start menu(open bag)
		elseif MainMenu == 121 and not status.tempDir then
			if Row < 3 then
				Input.press("Down", 2)
			elseif Row > 3 then
				Input.press("Up", 2)
			else
				Input.press("A", 2)
			end
		--start menu(close)
		elseif MainMenu == 121 and status.tempDir then
			Input.press("B", 2)
		end
	end
end

--[[function Strategies.dodgeUp(npc, sx, sy, dodge, offset)
	if not Battle.handleWild() then
		return false
	end
	local px, py = Player.position()
	if py < sy - 1 then
		return true
	end
	local wx, wy = px, py
	if py < sy then
		wy = py - 1
	elseif px == sx or px == dodge then
		if px - Memory.raw(npc) == offset then
			if px == sx then
				wx = dodge
			else
				wx = sx
			end
		else
			wy = py - 1
		end
	end
	Walk.step(wx, wy)
end

local function dodgeH(options)
	local left = 1
	if options.left then
		left = -1
	end
	local px, py = Player.position()
	if px * left > options.sx * left + (options.dist or 1) * left then
		return true
	end
	local wx, wy = px, py
	if px * left > options.sx * left then
		wx = px + 1 * left
	elseif py == options.sy or py == options.dodge then
		if py - Memory.raw(options.npc) == options.offset then
			if py == options.sy then
				wy = options.dodge
			else
				wy = options.sy
			end
		else
			wx = px + 1 * left
		end
	end
	Walk.step(wx, wy)
end]]

-- GENERALIZED STRATEGIES

Strategies.functions = {

	split = function(data)
		Bridge.split(data and data.finished)
		if not INTERNAL then
			splitNumber = splitNumber + 1

			local timeDiff
			splitTime, timeDiff = Utils.timeSince(splitTime)
			if timeDiff then
				print(splitNumber..". "..Control.areaName..": "..Utils.elapsedTime().." ("..timeDiff..")")
			end
		end
		return true
	end,

	interact = function(data)
		if Battle.handleWild() then
			if Battle.isActive() then
				return true
			end
			if Textbox.isActive() then
				if status.tries > 0 then
					return true
				end
				status.tries = status.tries - 1
				Input.cancel()
			elseif Player.interact(data.dir) then
				status.tries = status.tries + 1
			end
		end
	end,
	
	setDirection = function(data)
		if Player.isFacing(data.dir) then
			return true
		else
			Input.press(data.dir, 2)
			return true
		end
	end,
	
	openTextbox = function()
		if Textbox.isActive() then
			return true
		else
			Input.press("A", 2)
		end
	end,
	
	use = function(data)
		local Option
		if not data.option then
			Option = false
		else
			Option = data.option
		end
		if Strategies.useItem(data.item, data.poke, data.close, Option) then
			return true
		end
	end,

	confirm = function(data)
		if Battle.handleWild() then
			if Textbox.isActive() then
				status.tries = status.tries + 1
				Input.cancel(data.type or "A")
			else
				if status.tries > 0 then
					return true
				end
				Player.interact(data.dir)
			end
		end
	end,

	--[[teleport = function(data)
		if Memory.value("game", "map") == data.map then
			return true
		end
		if not Pokemon.use("teleport") then
			Menu.pause()
		end
	end,]]
	
	speak = function()
		if Strategies.initialize() then
			status.tempDir = false
		end
		if Textbox.isActive() then
			Input.press("A", 2)
			status.tempDir = true
		else
			if status.tempDir then
				status.tempDir = false
				return true
			else
				Input.press("A", 2)
			end
		end
	end,
	
	--[[deposeAll = function(data)
		if Memory.value("player", "party_size") == 1 then
			if Menu.close() then
				return true
			end
		else
			if not Textbox.isActive() then
				Player.interact("Up")
			else
				local pc = Memory.value("menu", "size")
				if Memory.value("battle", "menu") ~= 95 and (pc == 2 or pc == 4) then
					local menuColumn = Menu.getCol()
					if menuColumn == 10 then
 						Input.press("A")
					elseif menuColumn == 5 then
						local depositIndex = 0
						if Pokemon.indexOf(data.keep) == 0 then
							depositIndex = 1
						end
						Menu.select(depositIndex)
					else
 						Menu.select(1)
 					end
				else
					Input.press("A")
				end
			end
		end
	end,
	
	swapItem = function(data)
		if Strategies.initialize() then
			status.tempDir = false
		end
		if not data.pos2 then -- 1x position mode + item name
			itemPos1 = Inventory.indexOf(data.item)
			itemPos2 = data.pos1-1
		else -- 2x position mode
			itemPos1 = data.pos1-1
			itemPos2 = data.pos2-1
		end
		local main = Memory.value("menu", "main")
		local selection = Memory.value("menu", "selection_mode")
		if status.tempDir and selection == 0 then
			return true
		end
		if main == 128 then
			if Menu.getCol() ~= 5 then
				Menu.select(2, true)
			else
				if selection == 0 then
					if Menu.select(itemPos1, 1, true, nil, true) then
						Input.press("Select")
					end
				else
					if Menu.select(itemPos2, 1, true, nil, true) then
						Input.press("Select")
						status.tempDir = true
					end
				end
			end
		else
			Menu.pause()
		end
	end,
	
	tossItem = function(data)
		if Strategies.initialize() then
			status.canProgress = false
			if not data.item then
				itemPos1 = data.pos-1
				status.tempDir = Memory.raw(0x131E+itemPos1*2+1)
			else
				status.tempDir = Inventory.count(data.item)
			end
			if data.amount then
				itemNumber = data.amount
			else
				itemNumber = status.tempDir
			end
		end
		if not data.pos then --tossing by item name
			itemPos1 = Inventory.indexOf(data.item)
		else	--tossing by item position
			itemPos1 = data.pos-1
		end
		local main = Memory.value("menu", "main")
		if main == 60 and Memory.value("menu", "shop_current") == 20 and status.canProgress then
			return true
		end
		if main == 128 or Menu.getCol() == 14 and main ~= 209 then
			if Menu.getCol() ~= 5 and Menu.getCol() ~= 14 then
				Menu.select(2, true)
			else
				if Memory.value("menu", "text_input") == 146 then
					if Memory.value("menu", "row") == 0 then
						Menu.select(1, true)
					else
						if Memory.value("menu", "shop_current") ~= 248 then
							Input.press("A")
						else
							local currAmount = Memory.value("shop", "transaction_amount")
							if Menu.balance(currAmount, itemNumber, false, 99, true) then
								Input.press("A")
								status.canProgress = true
							end
						end
					end
				else
					if Menu.select(itemPos1, 1, true, nil, true) then
						Input.press("A")
					end
				end
			end
		elseif main == 209 then
			Input.press("A")
		else
			Menu.pause()
		end
	end,
	
	tossTM = function(data)
		if Strategies.initialize() then
			status.canProgress = false
			status.tries = 0
			if data.amount then
				itemNumber = data.amount
			else
				itemPos1 = data.pos-1
				status.tempDir = Memory.raw(0x131E+itemPos1*2+1)
				itemNumber = status.tempDir
			end
		end
		if not data.pos then --tossing by item name
			itemPos1 = Inventory.indexOf(data.item)
		else	--tossing by item position
			itemPos1 = data.pos-1
		end
		local main = Memory.value("menu", "main")
		if main == 60 and Memory.value("menu", "shop_current") == 20 and status.canProgress then
			return true
		end
		if status.tries == 0 then
			if main == 128 or Menu.getCol() == 14 and main ~= 209 then
				if Menu.getCol() ~= 5 and Menu.getCol() ~= 14 then
					Menu.select(2, true)
				else
					if Memory.value("menu", "text_input") == 146 then
						if Memory.value("menu", "row") == 0 then
							Menu.select(1, true, false, nil, true)
						else
							if main == 128 then
								Input.press("A")
							else
								status.tries = 1
							end
						end
					else
						if Menu.select(itemPos1, 1, true, nil, true) then
							Input.press("A")
						end
					end
				end
			end
		else
			if main == 128 or Menu.getCol() == 14 and main ~= 209 then
				local currAmount = Memory.value("shop", "transaction_amount")
				if Menu.balance(currAmount, itemNumber, false, 99, true) then
					Input.press("A")
					status.canProgress = true
				end
			else
				Input.press("A")
			end
		end
	end,]]
	
	openMenu = function()
		if Textbox.isActive() then
			return true
		else
			Input.press("Start", 2)
		end
	end,
	
	closeMenu = function()
		if not Textbox.isActive() then
			return true
		else
			Input.press("B")
		end
	end,

	allowDeath = function(data)
		Control.canDie(data.on)
		return true
	end,

	--[[champion = function()
		if status.canProgress then
			if status.tries > 1500 then
				return Strategies.hardReset("Beat the game in "..status.canProgress.." !")
			end
			if status.tries == 0 then
				Bridge.tweet("Beat Pokemon "..GAME_NAME.." in "..status.canProgress.."!")
				if Strategies.seed then
					print(Utils.frames().." frames, with seed "..Strategies.seed)
					print("Please save this seed number to share, if you would like proof of your run!")
				end
			end
			status.tries = status.tries + 1
		elseif Memory.value("menu", "shop_current") == 252 then
			Strategies.functions.split({finished=true})
			status.canProgress = Utils.elapsedTime()
		else
			Input.cancel()
		end
	end]]
}

strategyFunctions = Strategies.functions

function Strategies.execute(data)
	if strategyFunctions[data.s](data) then
		status = {tries=0}
		Strategies.status = status
		Strategies.completeGameStrategy()
		-- print(data.s)
		if resetting then
			return nil
		end
		return true
	end
	return false
end

function Strategies.init(midGame)
	if not STREAMING_MODE then
		splitTime = Utils.timeSince(0)
	end
	if midGame then
		Combat.factorPP(true)
	end
end

function Strategies.softReset()
	status = {tries=0}
	Strategies.status = status
	stats = {}
	Strategies.stats = stats
	Strategies.updates = {}

	splitNumber, splitTime = 0, 0
	resetting = nil
	Strategies.deepRun = false
	Strategies.resetGame()
end

return Strategies
