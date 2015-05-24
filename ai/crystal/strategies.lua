
local Combat = require "ai.combat"
local Control = require "ai.control"
local Strategies = require "ai.strategies"

local Battle = require "action.battle"
local Shop = require "action.shop"
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

local status = Strategies.status

local strategyFunctions = Strategies.functions

--local bulbasaurScl
--local UsingSTRATS = ""

-- TIME CONSTRAINTS

Strategies.timeRequirements = {

	--[[charmander = function()
		return 2.39
	end,
	
	pidgey = function()
		local timeLimit = 7.55
		return timeLimit
	end,
	
	glitch = function()
		local timeLimit = 10.15
		if Pokemon.inParty("pidgey") then
			timeLimit = timeLimit + 0.67
		end
		return timeLimit
	end,]]
	
}

-- HELPERS

--[[local function pidgeyDSum()
	local sx, sy = Player.position()
	if status.tries == nil then
		if status.tries then
			status.tries.idx = 1
			status.tries.x, status.tries.y = sx, sy
		else
			status.tries = 0
		end
	end
	if status.tries ~= 0 and Control.escaped then
		if status.tries[status.tries.idx] == 0 then
			tries.idx = tries.idx + 1
			if tries.idx > 3 then
				tries = 0
			end
			return pidgeyDSum()
		end
		if status.tries.x ~= sx or status.tries.y ~= sy then
			status.tries[status.tries.idx] = status.tries[status.tries.idx] - 1
			status.tries.x, status.tries.y = sx, sy
		end
		sy = 47
	else
		sy = 48
	end
	if sx == 8 then
		sx = 9
	else
		sx = 8
	end
	Walk.step(sx, sy)
end

local function tackleDSum()
	local sx, sy = Player.position()
	if status.tries == nil then
		if status.tries then
			status.tries.idx = 1
			status.tries.x, status.tries.y = sx, sy
		else
			status.tries = 0
		end
	end
	if status.tries ~= 0 and Control.escaped then
		if status.tries[status.tries.idx] == 0 then
			tries.idx = tries.idx + 1
			if tries.idx > 3 then
				tries = 0
			end
			return tackleDSum()
		end
		if status.tries.x ~= sx or status.tries.y ~= sy then
			status.tries[status.tries.idx] = status.tries[status.tries.idx] - 1
			status.tries.x, status.tries.y = sx, sy
		end
		--sx = 1
	--else
		--sx = 2
	end
	if sy == 6 then
		sy = 8
	else
		sy = 6
	end
	Walk.step(sx, sy)
end]]

-- STRATEGIES

local strategyFunctions = Strategies.functions

--[[strategyFunctions.grabPCPotion = function()
	if Inventory.contains("potion") then
		return true
	end
	Player.interact("Up")
end
	
strategyFunctions.checkStrats = function()
	UsingSTRATS = STRATS
	return true
end]]

strategyFunctions.talk_mom = function()
	if Strategies.initialize() then
		status.tempDir = false
	end
	local Direction = Memory.value("player", "facing")
	if Direction == 8 then
		Input.press("Down", 2)
	else
		local CurrentMenu = Memory.value("menu", "current")
		if CurrentMenu == 32 and not status.tempDir then
			Input.press("A", 2)
		elseif CurrentMenu == 32 and status.tempDir then
			return true
		--elseif CurrentMenu == 79 then	--french
		elseif CurrentMenu == 110 then	--english
			local OptionMenu = Memory.value("menu", "option_current")
			local DaysRow = Memory.value("menu", "days_row")
			if OptionMenu == 0 or OptionMenu == 11 then
				Input.press("A", 2)
			elseif OptionMenu == 17 then
				status.tempDir = true
				--set days
				if DaysRow < GAME_DAY then
					Input.press("Up", 2)
				elseif DaysRow > GAME_DAY then
					Input.press("Down", 2)
				else
					Input.press("A", 2)
				end
			end
		end
	end
end

--strategyFunctions.bulbasaurIChooseYou = function()
strategyFunctions.totodileIChooseYou = function()
	if Strategies.initialize() then
		status.tempDir = false
	end
	--if Pokemon.inParty("bulbasaur") then
	--if Pokemon.inParty("totodile") then
		--Bridge.caught("bulbasaur")
	--	Bridge.caught("totodile")
	--	return true
	--end
	if Player.face("Up") then
		--if Textbox.isActive() then
		if Textbox.name(TOTODILE_NAME) then
		--	status.tempDir = true
		--else
		--	if status.tempDir then
		--		status.tempDir = false
				return true
		--	else
		--		Input.press("A", 2)
		--	end
		end
		--Textbox.name(BULBASAUR_NAME)
		--Textbox.name(TOTODILE_NAME)
	end
end

--[[strategyFunctions.fightCharmander = function()
	if status.tries < 9000 and Pokemon.index(0, "level") == 6 then
		if status.tries > 200 then
			bulbasaurScl = Pokemon.index(0, "special")
			if bulbasaurScl < 12 then
				if UsingSTRATS == "Pidgey" then
					return Strategies.reset("Bad Bulbasaur for pidgey strats - "..bulbasaurScl.." special")
				else
					UsingSTRATS = "PP"
				end
			end
			status.tries = 9001
			return true
		else
			status.tries = status.tries + 1
		end
	end
	if Battle.isActive() and Memory.double("battle", "opponent_hp") > 0 and Strategies.resetTime(Strategies.getTimeRequirement("charmander"), "kill Charmander") then
		return true
	end
	Battle.automate()
end

strategyFunctions.dodgePalletBoy = function()
	return Strategies.dodgeUp(0x0223, 14, 14, 15, 7)
end

strategyFunctions.shopViridian = function()
	if Strategies.initialize() then
		status.tempDir = 5
	end
	bulbasaurScl = Pokemon.index(0, "special")
	if bulbasaurScl == 16 then
		if UsingSTRATS == "Pidgey" then
			return Strategies.reset("We are already at 16special, we got no chance for Weedle")
		else
			UsingSTRATS = "PP"
		end
	end
	if UsingSTRATS == "PP" then
		status.tempDir = 1
	end
	return Shop.transaction{
		buy = {{name="pokeball", index=0, amount=status.tempDir}, {name="paralyze_heal", index=2, amount=1}, {name="burn_heal", index=3, amount=1}}
	}
end

strategyFunctions.dodgeViridianOldMan = function()
	if UsingSTRATS == "PP" then
		local bidx = Pokemon.indexOf("bulbasaur")
		if Memory.raw(0x101E) ~= 73 then
			if Pokemon.index(bidx, "level") >= 7 then
				return Strategies.reset("We need leech seed for the brock skip glitch")
			end
		end
	end
	return Strategies.dodgeUp(0x0273, 18, 6, 17, 9)
end

strategyFunctions.healTreePotion = function()
	if Battle.handleWild() then
		if Inventory.contains("potion") then
			if Pokemon.info("bulbasaur", "hp") <= 12 then
				if Menu.pause() then
					Inventory.use("potion", "bulbasaur")
				end
			else
				return true
			end
		elseif Menu.close() then
			return true
		end
	end
end

strategyFunctions.catchPidgey = function()
	if UsingSTRATS == "PP" then
		local px, py = Player.position()
		if px < 10 and py < 46 then
			px = 10
		elseif px == 10 and py < 46 then
			py = 46
		elseif px > 8 and py == 46 then
			px = 8
		elseif px == 8 and py == 46 then
			return true
		end
		Walk.step(px, py)
	else
		if Strategies.initialize() then
			status.tempDir = false
			status.tries = nil
			local bidx = Pokemon.indexOf("bulbasaur")
			local scl = Pokemon.index(bidx, "special")
			if scl == 16 then
				if UsingSTRATS == "" then
					UsingSTRATS = "PP"
					return true
				else
					return Strategies.reset("We are already at 16special, we got no chance for Weedle")
				end
			end
		end
		if Battle.isActive() then
			local isPidgey = Pokemon.isOpponent("pidgey")
			status.tries = nil
			if isPidgey then
				local pidgeyHP = Memory.raw(0xCFE7)
				gui.text(100, 134, pidgeyHP.."HP")
				if Memory.value("menu", "text_input") == 240 then
					Textbox.name(PIDGEY_NAME, true)
				elseif Memory.value("battle", "menu") == 95 then
					Input.press("A")
				elseif status.tempDir then
					local pokeballs = Inventory.count("pokeball")
					if pokeballs < 2 then
						if Memory.value("menu", "selection") == 233 then
							Input.press("Right", 2)
						elseif Memory.value("menu", "selection") == 239 then
							Input.press("A", 2)
						end
						--Battle.run()
					elseif not Control.shouldCatch(3) then
						Battle.run()
					end
				else
					local pidgeyHPtable = {17, 16, 15, 13, 10, 8}
					if Utils.match(pidgeyHP, pidgeyHPtable) then
						status.tempDir = true
					elseif not Utils.match(pidgeyHP, pidgeyHPtable) and pidgeyHP > 8 then
						Battle.fight("tackle", false, true)	--perform tackle
					else
						Battle.run()
					end
				end
			else
				if Memory.value("battle", "menu") == 95 then
					Input.cancel()
				elseif not Control.shouldCatch() then
					if Control.shouldFight() then
						Battle.fight()
					else
						Battle.run()
					end
				end
			end
		else
			local hasPidgey = Pokemon.inParty("pidgey")
			Pokemon.updateParty()
			if hasPidgey then
				if status.tempDir then
					Bridge.caught("pidgey")
					status.tempDir = false
				end
				return true
			end
			local pokeballs = Inventory.count("pokeball")
			if pokeballs < 2 then
				if not hasPidgey then
					if UsingSTRATS == "Pidgey" then
						return Strategies.reset("Ran too low on PokeBalls", pokeballs)
					else
						UsingSTRATS = "PP"
						print("Ran too low on PokeBalls, going to PP-Strats")
						return true
					end
				end
			else
				local timeLimit = Strategies.getTimeRequirement("pidgey")
				local resetMessage = "find a Pidgey"
				if Strategies.resetTime(timeLimit, resetMessage, false, true) then
					return true
				end
				pidgeyDSum()
			end
		end
	end
end

strategyFunctions.grabAntidote = function()
	local px, py = Player.position()
	if py < 11 then
		return true
	end
	if Inventory.contains("antidote") then
		py = 10
	else
		Player.interact("Up")
	end
	Walk.step(px, py)
end

strategyFunctions.grabForestPotion = function()
	if Strategies.initialize() then
		status.tempDir = false
	end
	if Battle.handleWild() then
		if not Textbox.isActive() and not status.tempDir then
			Input.press("A", 2)
		elseif Textbox.isActive() and not status.tempDir then
			Input.press("A", 2)
			status.tempDir = true
		elseif not Textbox.isActive() and status.tempDir then
			return true
		end
	end
end

strategyFunctions.fightWeedle = function()
	if Battle.isTrainer() then
		status.canProgress = true
		return Strategies.buffTo("growl", 0, 39) --Peform 1x Growl
	elseif status.canProgress then
		return true
	end
end

strategyFunctions.checkSpec = function()
	if Strategies.initialize() then
		local WillReset
		if not Inventory.contains("potion") then WillReset = true end
		if not Inventory.contains("pokeball") then WillReset = true end
		if not Inventory.contains("antidote") then WillReset = true end
		if not Inventory.contains("paralyze_heal") then WillReset = true end
		if not Inventory.contains("burn_heal") then WillReset = true end
		if WillReset then
			return Strategies.reset("We need 5 items for the brock skip glitch")
		end
	end
	if UsingSTRATS == "" then
		local bidx = Pokemon.indexOf("bulbasaur")
		local scl = Pokemon.index(bidx, "special")
		local hasPidgey = Pokemon.inParty("pidgey")
		if hasPidgey then
			if scl == 16 then
				UsingSTRATS = "Pidgey"
				print("Performing Pidgey Strats")
				return true
			else
				UsingSTRATS = "PP"
			end
		else
			UsingSTRATS = "PP"
		end
	elseif UsingSTRATS == "Pidgey" then
		local bidx = Pokemon.indexOf("bulbasaur")
		local scl = Pokemon.index(bidx, "special")
		if scl == 16 then
			print("Performing Pidgey Strats")
			return true
		else
			return Strategies.reset("We need 16special on Bulbasaur for the brock skip glitch")
		end
	elseif UsingSTRATS == "PP" then
		local bidx = Pokemon.indexOf("bulbasaur")
		if Memory.raw(0x101E) ~= 73 then
			if Pokemon.index(bidx, "level") >= 7 then
				return Strategies.reset("We need leech seed for the brock skip glitch")
			end
		end
		print("Performing PP Strats")
		return true
	end
end

strategyFunctions.equipForGlitch = function()
	if UsingSTRATS == "Pidgey" then
		return true
	else
		if Strategies.initialize() then
			status.tempDir = false
		end
		local TacklePP = Memory.raw(0x102D)
		local GrowlPP = Memory.raw(0x102E)
		local bidx = Pokemon.indexOf("bulbasaur")
		--in Battle
		if Battle.isActive() then
			status.tries = nil
			if Memory.value("battle", "menu") == 95 then
				Input.press("A")
			else
				TacklePP = Memory.raw(0x102D)
				if not status.tempDir then
					if GrowlPP > 36 then
						Battle.fight("growl", false, true)	--perform 3x Growl
					else
						if TacklePP > 16 then	--perform tackle until 16pp
							Battle.fight()
						elseif TacklePP == 16  then
							if Memory.raw(0x101E) ~= 73 then
								return Strategies.reset("We need leech seed for the brock skip glitch")
							else
								status.tempDir = true
							end
						end
					end
				end
				if status.tempDir then
					if Pokemon.battleMove("tackle") == 1 then
						Battle.swapMove(1, 3)
					elseif Pokemon.battleMove("tackle") == 3 then
						Battle.swapMove(3, 2)
					elseif Pokemon.battleMove("tackle") == 2 then
						if Memory.value("battle", "menu") == 106 then
							Input.press("B")
						else
							if Pokemon.index(bidx, "level") ~= 8 then
								status.tempDir = false
								return Strategies.reset("Can't be Lvl"..Pokemon.index(bidx, "level").." for the brock skip glitch with the PP Strats")
							else
								Battle.run()
							end
						end
					end
				end
			end
		else --out battle
			TacklePP = Memory.raw(0x102D)
			if not status.tempDir then
				if TacklePP == 16 then
					if Pokemon.index(bidx, "level") ~= 8 then
						return Strategies.reset("Can't be Lvl"..Pokemon.index(bidx, "level").." for the brock skip glitch with the PP Strats")
					end
					if Memory.raw(0x101E) ~= 73 then
						return Strategies.reset("We need leech seed for the brock skip glitch")
					end
					status.tempDir = true
				elseif TacklePP < 16 then
					return Strategies.reset("Ran too low on Tackle for the PP Strats "..TacklePP.."PP available")
				end
			end
			if status.tempDir then
				if Pokemon.battleMove("tackle") == 2 then
					status.tempDir = false
					return true
				end
			end

			local timeLimit = Strategies.getTimeRequirement("glitch")
			local resetMessage = "perform enough Tackle for the PP Strats glitch"
			if Strategies.resetTime(timeLimit, resetMessage) then
				return true
			end
			tackleDSum()
		end
	end
end

strategyFunctions.checkInventory = function()
	if Strategies.initialize() then
		local WillReset
		if not Inventory.contains("potion") then WillReset = true end
		if not Inventory.contains("pokeball") then WillReset = true end
		if not Inventory.contains("antidote") then WillReset = true end
		if not Inventory.contains("paralyze_heal") then WillReset = true end
		if not Inventory.contains("burn_heal") then WillReset = true end
		if WillReset then
			return Strategies.reset("We need 5 items for the brock skip glitch")
		else
			return true
		end
	end
end

strategyFunctions.checkForPidgey = function()
	if UsingSTRATS == "Pidgey" then
		return true
	else
		if Strategies.initialize() then
			status.tempDir = false
			local hasPidgey = Pokemon.inParty("pidgey")
			if not hasPidgey then
				return true
			end
		end
		local map = Memory.value("game", "map")
		local px, py = Player.position()
		if not status.tempDir then	--go to pc to depose
			if map == 2 then
				if px > 13 then
					px = 13
				else
					if py > 25 then
						py = 25
					end
				end
			elseif map == 58 then
				if py > 5 then
					py = 5
				else
					if px < 13 then
						px = 13
					else
						if py > 4 then
							py = 4
						else	-- deposit pidgey
							if Memory.value("player", "party_size") == 1 then
								if Menu.close() then
									status.tempDir = true
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
											Menu.select(1) 	-- select pidgey
										else
											Menu.select(1)	-- select deposit box
										end
									else
										Input.press("A")
									end
								end
							end
						end
					end
				end
			end
		else	--get back to the spot
			if map == 58 then
				if px > 4 then
					px = 4
				else
					if py < 8 then
						py = 8
					end
				end
			elseif map == 2 then
				if px < 18 then
					px = 18
				else
					return true
				end
			end
		end
		Walk.step(px, py, true)
	end
end

strategyFunctions.prepareSave = function()
	local main = Memory.value("menu", "main")
	local row = Memory.value("menu", "row")
	if main == 128 then
		if row == 4 then
			Input.press("B")
		else
			Input.press("Down")
		end
	else
		if row == 4 then
			return true
		end
		Input.press("Start")
	end
end

strategyFunctions.performSkip = function()
	local current = Memory.value("menu", "current")
	local selection = Memory.value("menu", "selection")
	local skip = Memory.value("menu", "pokemon")
	if current == 15 then
		if Memory.value("menu", "pokemon") ~= 0 then
			Input.press("Start", 0)
		else
			Player.disinteract("left")
		end
	else
		if selection == 115 then
			Input.press("A")
		elseif selection == 65 then
			if skip == 207 then
				return true
			else
				Input.press("A")
			end
		else
			Input.press("Start", 0)
		end
	end
end

strategyFunctions.performReset = function()
	local skip = Memory.value("menu", "pokemon")
	if skip == 197 or skip == 204 then
		return Strategies.SkipReset()
	else
		Input.press("A")
	end
end

strategyFunctions.openPokemonMenu = function()
	if UsingSTRATS == "Pidgey" then
		if Textbox.isActive() then
			return true
		else
			Input.press("Start")
		end
	else
		if Strategies.initialize() then
			status.tempDir = false
		end
		local main = Memory.value("menu", "main")
		local row = Memory.value("menu", "row")
		if main == 128 then
			if status.tempDir then
				Input.press("B")
			else
				if row == 0 then
					Input.press("Down")
				else
					Input.press("A")
				end
			end
		elseif main == 103 then
			status.tempDir = true
			Input.press("B")
		elseif main == 8 then
			status.tempDir = false
			return true
		else
			if status.tempDir then
				Input.press("B")
			else
				Input.press("Start")
			end
		end
	end
end

strategyFunctions.speakToGlithGuy = function()
	local main = Memory.value("menu", "main")
	if not Textbox.isActive() then
		Player.interact("Left")
	else
		if main == 167 then
			return true
		else
			Input.press("A")
		end
	end
end

strategyFunctions.leaveGlitchGuy = function()
	local map = Memory.value("game", "map")
	local px, py = Player.position()
	if map == 2 then	--Pewter City
		if py == 16 then
			px = 40
		end
	elseif map == 14 then	--Route3
		if px < 17 then
			px = 17
		else
			if py > 7 then
				py = 7
			else
				if px < 60 then
					px = 60
				else
					if py > -1 then
						py = -1
					end
				end
			end
		end
	elseif map == 15 then	--Center Route
		if px < 90 then
			px = 90
		end
	elseif map == 3 then	--Cerulean City
		if px < 8 then
			px = 8
		else
			if py < 36 then
				py = 36
			end
		end
	elseif map == 16 then	--Out of Cerulean
		if py < 36 then
			py = 36
		end
	elseif map == 10 then	--Saffron City
		if py < 29 then
			py = 29
		else
			if px < 9 then
				px = 9
			end
		end
	elseif map == 182 then --Saffron City Poke Center
		return true
	end
	Walk.step(px, py, true)
end

strategyFunctions.checkPidgeyHP = function()
	if UsingSTRATS == "PP" then
		return true
	else
		if Strategies.initialize() then
			status.tempDir = false
			status.canProgress = true
		end
		local pidx = Pokemon.indexOf("pidgey")
		local hp = Pokemon.index(pidx, "hp")
		if hp ~= 16 and status.canProgress then
			return true
		else
			status.canProgress = false
			local px, py = Player.position()
			if px < 13 then
				Walk.step(13, py)
			else
				if Memory.value("player", "party_size") == 2 then --Depose Pidgey
					if not Textbox.isActive() then
						Player.interact("Up")
					else
						local pc = Memory.value("menu", "size")
						if Memory.value("battle", "menu") ~= 95 and (pc == 2 or pc == 4) then
							local menuColumn = Menu.getCol()
							if menuColumn == 10 then
								Input.press("A")
							elseif menuColumn == 5 then
								Menu.select(1)	--select pidgey
							else
								Menu.select(1)	--select deposit box
							end
						else
							Input.press("A")
						end
					end
				else
					if not status.tempDir then --swap box for saving
						if Memory.value("menu", "shop_current") == 20 or Memory.value("menu", "shop_current") == 73 then
							if Memory.value("menu", "column") == 1 then
								if Memory.value("menu", "row") ~= 3 then
									Input.press("Down")
								else
									Input.press("A", 2)
								end
							elseif Memory.value("menu", "column") == 15 then --select yes to save
								Input.press("A", 2)
							elseif Memory.value("menu", "column") == 12 then --select box
								if Memory.value("menu", "row") ~= 1 then
									--Menu.select(1) --select box2
									Input.press("Down")
								else
									Input.press("A")
									status.tempDir = true
								end
							end
						else
							Input.press("A")
						end
					else	--Resetting
						if Memory.value("menu", "selection") == 65 then
							return Strategies.SkipReset()
						else
							Input.press("A")
						end
					end
				end
			end
		end
	end
end

strategyFunctions.walkBack = function()
	local px, py = Player.position()
	if px > 3 then
		Walk.step(3, py)
	else
		return true
	end
end

strategyFunctions.getAbra = function()
	local party_size = Memory.value("player", "party_size")
	local text_input = Memory.value("menu", "text_input")
	local textbox_active = Memory.value("game", "textbox")
	local hasAbra = Pokemon.inParty("abra")
	if textbox_active == 1 then
		if party_size == 1 then
			Input.press("A")
		else
			if text_input == 240 then
				Textbox.name(ABRA_NAME, true)
			else
				Input.press("A")
			end
		end
	else
		if hasAbra then
			return true
		else
			Input.press("A")
		end
	end
end

strategyFunctions.performTeleportGlitch = function()
	if Strategies.initialize() then
		status.tempDir = false
	end
	local map = Memory.value("game", "map")
	local main = Memory.value("menu", "main")
	local px, py = Player.position()
	if not status.tempDir then
		if px == 5 then
			status.tempDir = true
			Walk.step(4, py, true)
		end
	else
		if main ~= 128 then
			Input.press("Start", 0)
		else
			status.tempDir = false
			return true
		end
	end
end

strategyFunctions.fightGymGuy = function()
	local abraHP = Pokemon.info("abra", "hp")
	if abraHP == 0 then
		return true
	end
	if Battle.isTrainer() then
		status.canProgress = true
		return Strategies.buffTo("teleport", 0, 1) --Perform teleport
	end
end

strategyFunctions.closingAutomation = function()
	if Memory.value("menu", "shop_current") == 0 then
		return Strategies.reset("We need need to encounter a MissingNo, Not a Trainer")
	else
		if Memory.value("menu", "main") == 123 then
			Input.press("B")
		elseif Memory.value("menu", "main") == 32 then
			return true
		end
	end
end

strategyFunctions.battleMissingNo = function()
	if Battle.isActive() then
		Battle.run()
	else
		if Textbox.isActive() then
			Input.press("A")
		else
			local px, py = Player.position()
			if py < 1 then
				py = 1
			else
				return true
			end
			Walk.step(px, py, true)
		end
	end
end]]

-- PROCESS

function Strategies.completeGameStrategy()
	status = Strategies.status
end

function Strategies.resetGame()
	--maxEtherSkip = false
	status = Strategies.status
	stats = Strategies.stats
end

return Strategies
