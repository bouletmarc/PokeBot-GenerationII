local Battle = {}

local Textbox = require "action.textbox"

local Combat = require "ai.combat"
local Control = require "ai.control"

local Memory = require "util.memory"
local Menu = require "util.menu"
local Input = require "util.input"
local Utils = require "util.utils"

local Inventory = require "storage.inventory"
local Pokemon = require "storage.pokemon"

-- HELPERS

local function potionsForHit(potion, curr_hp, max_hp)
	if not potion then
		return
	end
	local ours, killAmount = Combat.inKillRange()
	if ours then
		return Utils.canPotionWith(potion, killAmount, curr_hp, max_hp)
	end
end

local function recover()
	if Control.canRecover() then
		local currentHP = Pokemon.index(0, "hp")
		if currentHP > 0 then
			local maxHP = Pokemon.index(0, "max_hp")
			if currentHP < maxHP then
				local first, second
				if potionIn == "full" then
					first, second = "full_restore", "super_potion"
					if maxHP - currentHP > 54 then
						first = "full_restore"
						second = "super_potion"
					else
						first = "super_potion"
						second = "full_restore"
					end
				else
					if maxHP - currentHP > 22 then
						first = "super_potion"
						second = "potion"
					else
						first = "potion"
						second = "super_potion"
					end
				end
				local potion = Inventory.contains(first, second)
				if potionsForHit(potion, currentHP, maxHP) then
					Inventory.use(potion, nil, true)
					return true
				end
			end
		end
	end
	--[[if Memory.value("battle", "paralyzed") == 64 then
		local heals = Inventory.contains("paralyze_heal", "full_restore")
		if heals then
			Inventory.use(heals, nil, true)
			return true
		end
	end]]
end

local function openBattleMenu()
	--if Memory.value("battle", "text") == 1 then
	if Memory.value("battle", "text") == 3 then
		Input.cancel()
		return false
	end
	local battleMenu = Memory.value("battle", "menu")
	--local col = Menu.getCol()
	--if battleMenu == 106 or (battleMenu == 94 and col == 5) then
	if battleMenu == 106 then
		return true
	--elseif battleMenu == 94 then
	elseif battleMenu == 186 then
		local rowSelected = Memory.value("battle", "menuY")
		local columnSelected = Memory.value("battle", "menuX")
		if columnSelected == 0 then
			if rowSelected == 1 then
				Input.press("Up")
			else
				Input.press("A")
			end
		else
			Input.press("Left")
		end
	else
		Input.press("B")
	end
end

local function attack(attackIndex)
	if Memory.double("battle", "opponent_hp") < 1 then
		Input.cancel()
	elseif openBattleMenu() then
		--Menu.select(attackIndex, true, false, false, false, 3)
		Menu.select(attackIndex, true, false, false, 3)
	end
end

function movePP(name)
	local midx = Pokemon.battleMove(name)
	if not midx then
		return 0
	end
	--return Memory.raw(0x102C + midx)
	return Memory.raw(0x0634 + midx)
end
Battle.pp = movePP

-- UTILS

--[[function Battle.swapMove(sidx, fidx)
	if openBattleMenu() then
		local selection = Memory.value("menu", "selection_mode")
		local swapSelect
		if selection == sidx then
			swapSelect = fidx
		else
			swapSelect = sidx
		end
		if Menu.select(swapSelect, false, false, nil, true, 3) then
			Input.press("Select")
		end
	end
end]]

function Battle.isActive()
	return Memory.value("game", "battle") > 0
end

function Battle.isTrainer()
	local battleType = Memory.value("game", "battle")
	if battleType == 2 then
		return true
	end
	if battleType == 1 then
		Battle.handle()
	else
		Textbox.handle()
	end
end

function Battle.opponent()
	return Pokemon.getName(Memory.value("battle", "opponent_id"))
end

-- HANDLE

function Battle.run()
	if Memory.double("battle", "opponent_hp") < 1 then
		Input.cancel()
	--elseif Memory.value("battle", "menu") ~= 94 then
	elseif Memory.value("battle", "menu") ~= 186 then
		--if Memory.value("menu", "text_length") == 127 then
		--	Input.press("B")
		--else
			Input.press("B", 2)
			--Input.cancel()
		--end
	elseif Memory.value("battle", "menu") == 186 then
	--elseif Textbox.handle() then
		--local rowSelected = Memory.value("battle", "menuY")
		--local columnSelected = Memory.value("battle", "menuX")
		--local selected = Memory.value("menu", "selection")
		--if selected == 239 then
		--if rowSelected == 2 and columnSelected == 2 then
		--	Input.press("A", 2)
		--else
			Input.escape()
		--end
	end
end

function Battle.handle()
	--if not Control.shouldCatch() then
		--if Control.shouldFight() then
		--	Battle.fight()
		--else
			Battle.run()
		--end
	--end
end

function Battle.handleWild()
	if Memory.value("game", "battle") ~= 1 then
		return true
	end
	Battle.handle()
end

function Battle.fight(move, skipBuffs)
	if move then
		if type(move) ~= "number" then
			move = Pokemon.battleMove(move)
		end
		attack(move)
	else
		move = Combat.bestMove()
		if move then
			--Battle.accurateAttack = move.accuracy == 100
			attack(move.midx)
		--elseif Memory.value("menu", "text_length") == 127 then
		--	Input.press("B")
		else
			Input.cancel()
		end
	end
end

--[[function Battle.swap(target)
	local battleMenu = Memory.value("battle", "menu")
	if Utils.onPokemonSelect(battleMenu) then
		if Menu.getCol() == 0 then
			Menu.select(Pokemon.indexOf(target), true)
		else
			Input.press("A")
		end
	elseif battleMenu == 94 then
		local selected = Memory.value("menu", "selection")
		if selected == 199 then
			Input.press("A", 2)
		elseif Menu.getCol() == 9 then
			Input.press("Right", 0)
		else
			Input.press("Up", 0)
		end
	else
		Input.cancel()
	end
end]]

function Battle.automate(moveName, skipBuffs)
	--if not recover() then
		local state = Memory.value("game", "battle")
		if state == 0 then
			Input.cancel()
		else
			if moveName and movePP(moveName) == 0 then
				moveName = nil
			end
			if state == 1 then
				--if Control.shouldFight() then
				--	Battle.fight(moveName, skipBuffs)
				--else
					Battle.run()
				--end
			elseif state == 2 then
				Battle.fight(moveName, skipBuffs)
			end
		end
	--end
end

-- SACRIFICE

--[[function Battle.sacrifice(...)
	local sacrifice = Pokemon.getSacrifice(...)
	if sacrifice then
		Battle.swap(sacrifice)
		return true
	end
	return false
end

function Battle.redeployNidoking()
	if Pokemon.isDeployed("nidoking") then
		return false
	end
	local battleMenu = Memory.value("battle", "menu")
	if Utils.onPokemonSelect(battleMenu) then
		Menu.select(0, true)
	elseif battleMenu == 95 and Menu.getCol() == 1 then
		Input.press("A")
	else
		local __, turns = Combat.bestMove()
		if turns == 1 then
			if Pokemon.isDeployed("spearow") then
				forced = "growl"
			else
				forced = "sand_attack"
			end
		end
		Battle.automate(forced)
	end
	return true
end]]

return Battle
