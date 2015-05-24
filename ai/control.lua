local Control = {}

local Battle
local Strategies
local Combat = require "ai.combat"
local Bridge = require "util.bridge"
local Memory = require "util.memory"
local Paint = require "util.paint"
local Utils = require "util.utils"
local Inventory = require "storage.inventory"
local Pokemon = require "storage.pokemon"

local potionInBattle = true
local encounters = 0

local canDie, shouldFight, minExp
local shouldCatch, attackIdx
local extraEncounter, maxEncounters
local battleYolo

Control.areaName = "Unknown"
Control.moonEncounters = nil
Control.getMoonExp = true
Control.yolo = false

--[[local function withinOneKill(forExp)
	return Pokemon.getExp() + 80 > forExp
end]]

local controlFunctions = {
	
	a = function(data)
		Control.areaName = data.a
		return true
	end,

	potion = function(data)
		if data.b ~= nil then
			Control.battlePotion(data.b)
		end
		battleYolo = data.yolo
	end,

	encounters = function(data)
		if RESET_FOR_TIME then
			maxEncounters = data.limit
			extraEncounter = data.extra
		end
	end,

	pp = function(data)
		Combat.factorPP(data.on)
	end,

	setThrash = function(data)
		Combat.disableThrash = data.disable
	end,

	disableCatch = function()
		shouldCatch = nil
		shouldFight = nil
	end,

	-- EXP
	
	--[[viridianExp = function()
		minExp = 210
		shouldFight = {{name="rattata",lvl={2,3}}, {name="pidgey",lvl={2}}}
	end,

	viridianBackupExp = function()
		minExp = 210
		shouldFight = {{name="rattata",lvl={2,3}}, {name="pidgey",lvl={2,3}}}
	end,
	
	nidoranBackupExp = function()
		minExp = 210
		shouldFight = {{name="rattata"}, {name="pidgey"}, {name="nidoran"}, {name="nidoranf",lvl={2}}}
	end,

	-- CATCH
	
	catchNidoran = function()
		shouldCatch = {{name="nidoran",lvl={3,4}}, {name="spearow"}}
	end,

	catchFlier = function()
		shouldCatch = {{name="spearow",alt="pidgey",hp=15}, {name="pidgey",alt="spearow",hp=15}}
	end,]]

}

-- COMBAT

function Control.battlePotion(enable)
	potionInBattle = enable
end

function Control.canDie(enabled)
	if enabled == nil then
		return canDie
	end
	canDie = enabled
end

local function isNewFight()
	if Memory.double("battle", "opponent_hp") == Memory.double("battle", "opponent_max_hp") then
		return true
	end
end

--[[function Control.shouldFight()
	if not shouldFight then
		return false
	end
	local expTotal = Pokemon.getExp()
	if expTotal < minExp then
		local oid = Memory.value("battle", "opponent_id")
		local olvl = Memory.value("battle", "opponent_level")
		for i,p in ipairs(shouldFight) do
			if oid == Pokemon.getID(p.name) and (not p.lvl or Utils.match(olvl, p.lvl)) then
				if oneHits then
					local move = Combat.bestMove()
					if move and move.maxDamage * 0.925 < Memory.double("battle", "opponent_hp") then
						return false
					end
				end
				return true
			end
		end
	end
end`]]

function Control.canCatch(partySize)
	if not partySize then
		partySize = Memory.value("player", "party_size")
	end
	local pokeballs = Inventory.count("pokeball")
	--local minimumCount = 4 - partySize
	local minimumCount = 1
	if pokeballs < minimumCount then
		Strategies.reset("Not enough PokeBalls", pokeballs)
		return false
	end
	return true
end

--[[function Control.shouldCatch(partySize)
	if maxEncounters and encounters > maxEncounters then
		local extraCount = extraEncounter and Pokemon.inParty(extraEncounter)
		if not extraCount or encounters > maxEncounters + 1 then
			Strategies.reset("Too many encounters", encounters)
			return false
		end
	end
	if not shouldCatch then
		return false
	end
	if not partySize then
		partySize = Memory.value("player", "party_size")
	end
	if partySize == 4 then
		shouldCatch = nil
		return false
	end
	if not Control.canCatch(partySize) then
		return true
	end
	local oid = Memory.value("battle", "opponent_id")
	for i,poke in ipairs(shouldCatch) do
		if oid == Pokemon.getID(poke.name) and not Pokemon.inParty(poke.name, poke.alt) then
			if not poke.lvl or Utils.match(Memory.value("battle", "opponent_level"), poke.lvl) then
				local penultimate = poke.hp and Memory.double("battle", "opponent_hp") > poke.hp
				if penultimate then
					penultimate = Combat.nonKill()
				end
				if penultimate then
					require("action.battle").fight(penultimate.midx)
				else
					Inventory.use("pokeball", nil, true)
				end
				return true
			end
		end
	end
end]]

-- Items

function Control.canRecover()
	return potionInBattle and (not battleYolo or not Control.yolo)
end

function Control.set(data)
	controlFunctions[data.c](data)
end

function Control.setYolo(enabled)
	Control.yolo = enabled
end

function Control.setPotion(enabled)
	potionInBattle = enabled
end

function Control.encounters()
	return encounters
end

function Control.encounter(battleState)
	if battleState > 0 then
		local wildBattle = false
		if battleState == 1 then
			wildBattle = true
		end
		--[[local isCritical
		local battleMenu = Memory.value("battle", "menu")
		if battleMenu == 94 then
			isCritical = false
			Control.missed = false
		elseif Memory.double("battle", "our_hp") == 0 then
			if Memory.value("battle", "critical") == 1 then
				isCritical = true
			end
		elseif not Control.missed then
			local turnMarker = Memory.value("battle", "our_turn")
			if turnMarker == 100 or turnMarker == 128 then
				local isMiss = Memory.value("battle", "miss") == 1
				if isMiss then
					if not Control.ignoreMiss and Battle.accurateAttack and Memory.value("battle", "accuracy") == 7 then
						Bridge.chat("gen 1 missed :( (1 in 256 chance)")
					end
					Control.missed = true
				end
			end
		end
		if isCritical ~= nil and isCritical ~= Control.criticaled then
			Control.criticaled = isCritical
		end]]
		if wildBattle then
			local opponentHP = Memory.double("battle", "opponent_hp")
			if not Control.inBattle then
				Control.escaped = false
				if opponentHP > 0 then
					Control.killedCatch = false
					Control.inBattle = true
					encounters = encounters + 1
					Paint.wildEncounters(encounters)
					Bridge.encounter()
					--if Control.moonEncounters then
					--	Control.moonEncounters = Control.moonEncounters + 1
					--end
				end
			else
				--if opponentHP == 0 and shouldCatch and not Control.killedCatch then
				--if opponentHP == 0 and shouldCatch then
					--local gottaCatchEm = {"pidgey", "spearow", "paras", "oddish"}
					--local opponent = Battle.opponent()
					--for i,catch in ipairs(gottaCatchEm) do
					--	if opponent == catch then
					--		if not Pokemon.inParty(catch) then
					--			Bridge.chat("accidentally killed "..Utils.capitalize(catch).." with a "..(isCritical and "critical" or "high damage range").." :(")
					--			Control.killedCatch = true
					--		end
					--		break
					--	end
					--end
				--end
			end
		end
	elseif Control.inBattle then
		if Memory.value("battle", "battle_turns") == 0 then
			Control.escaped = true
		end
		Control.inBattle = false
	end
end

function Control.reset()
	canDie = false
	oneHits = false
	--shouldCatch = nil
	--shouldFight = nil
	extraEncounter = nil
	potionInBattle = true
	encounters = 0
	battleYolo = false
	maxEncounters = nil

	Control.yolo = false
	Control.inBattle = false
end

function Control.init()
	local LowerGameName = string.lower(GAME_NAME)
	Battle = require "action.battle"
	Strategies = require("ai."..LowerGameName..".strategies")
end

return Control
