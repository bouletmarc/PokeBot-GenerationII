local Pokemon = {}

local Bridge = require "util.bridge"
local Input = require "util.input"
local Memory = require "util.memory"
local Menu = require "util.menu"

local PokemonList = require "storage.pokemonlist"

local moveList = {
	cut = 15,
	fly = 19,
	surf = 57,
	strength = 70,
	teleport = 100,
	watefall = 127,
	whirlpool = 250,
	
	sand_attack = 28,
	horn_attack = 30,
	horn_drill = 32,
	tackle = 33,
	thrash = 37,
	tail_whip = 39,
	poison_sting = 40,
	leer = 43,
	growl = 45,
	water_gun = 55,
	ice_beam = 58,
	bubblebeam = 61,
	leech_seed = 73,
	thunderbolt = 85,
	earthquake = 89,
	dig = 91,
	rage = 99,
	rock_slide = 157,
}

local data = {
	held = {1},
	move1 = {2},
	move2 = {3},
	move3 = {4},
	move4 = {5},
	exp = {7, true, true}, --0x1CE7
	pp1 = {23},
	pp2 = {24},
	pp3 = {25},
	pp4 = {26},
	level = {31},
	status = {32},
	hp = {34, true},
	max_hp = {36, true},
	attack = {38, true},
	defense = {40, true},
	speed = {42, true},
	special_attack = {44, true},
	special_defense = {46, true},
}

local previousPartySize

local function getAddress(index)
	return 0x1CDF + index * 0x30
end

local function index(index, offset)
	local double
	local triple
	if not offset then
		offset = 0
	else
		local dataTable = data[offset]
		offset = dataTable[1]
		double = dataTable[2]
		triple = dataTable[3]
	end
	
	local address = getAddress(index) + offset
	local value = Memory.raw(address)
	if double and not triple then
		value = value + Memory.raw(address + 1)
	elseif double and triple then
		--read double exp
		value = value * 256 + Memory.raw(address + 1)
		--read triple exp
		value = value * 256 + Memory.raw(address + 2)
	end
	return value
end
Pokemon.index = index

local function indexOf(...)
	for ni,name in ipairs(arg) do
		local pid = PokemonList.ID(name)
		--local pid = pokeIDs[name]
		for i=0,5 do
			local atIdx = index(i)
			if atIdx == pid then
				return i
			end
		end
	end
	return -1
end
Pokemon.indexOf = indexOf

local function indexOfbyID(ID)
	for i=0,5 do
		local PokemonID = Memory.raw(getAddress(i))
		if PokemonID == ID then
			return i
		end
	end
	return -1
end
Pokemon.indexOfbyID = indexOfbyID

-- Table functions

function Pokemon.battleMove(name)
	local mid = moveList[name]
	local PokemonID = Memory.value("battle", "our_id")
	local PokemonIndex = indexOfbyID(PokemonID)
	for i=1,4 do
		local SearchString = "move"..i
		local MoveID = index(PokemonIndex, SearchString)
		--if mid == Memory.raw(0x062E + i) then
		if mid == MoveID then
			return i
		end
	end
end

function Pokemon.moveIndex(move, pokemon)
	local pokemonIdx
	if pokemon then
		pokemonIdx = indexOf(pokemon)
	else
		pokemonIdx = 0
	end
	local address = getAddress(pokemonIdx) + 1
	local mid = moveList[move]
	for i=1,4 do
		if mid == Memory.raw(address + i) then
			return i
		end
	end
end

function Pokemon.info(name, offset)
	return index(indexOf(name), offset)
end

function Pokemon.getID(name)
	--return pokeIDs[name]
	return PokemonList.ID(name)
end

function Pokemon.getName(id)
	return PokemonList.PokemonName(id)
	--for name,pid in pairs(pokeIDs) do
	--	if pid == id then
	--		return name
	--	end
	--end
end

function Pokemon.getSacrifice(...)
	for i,name in ipairs(arg) do
		local pokemonIndex = indexOf(name)
		if pokemonIndex ~= -1 and index(pokemonIndex, "hp") > 0 then
			return name
		end
	end
end

function Pokemon.inParty(...)
	for i,name in ipairs(arg) do
		if indexOf(name) ~= -1 then
			return name
		end
	end
end

function Pokemon.forMove(move)
	local moveID = moveList[move]
	for i=0,5 do
		local address = getAddress(i)
		for j=2,5 do
			if Memory.raw(address + j) == moveID then
				return i
			end
		end
	end
	return -1
end

function Pokemon.hasMove(move)
	return Pokemon.forMove(move) ~= -1
end

function Pokemon.updateParty()
	local partySize = Memory.value("player", "party_size")
	if partySize ~= previousPartySize then
		--local poke = Pokemon.inParty("tododile", "paras", "spearow", "pidgey", "nidoran", "squirtle")
		local poke = Pokemon.inParty("tododile", "sentret", "poliwag", "bellsprout")
		if poke then
			Bridge.caught(poke)
			previousPartySize = partySize
		end
	end
end

function Pokemon.pp(index, move)
	local midx = Pokemon.battleMove(move)
	--return Memory.raw(getAddress(index) + 28 + midx)
	return Memory.raw(getAddress(index) + 22 + midx) --movePP address = +22
end

-- General

function Pokemon.isOpponent(...)
	local oid = Memory.value("battle", "opponent_id")
	for i,name in ipairs(arg) do
		--if oid == pokeIDs[name] then
		if oid == PokemonList.ID(name) then
			return name
		end
	end
end

function Pokemon.isDeployed(...)
	local deployedID = Memory.value("battle", "our_id")
	for i,name in ipairs(arg) do
		--if deployedID == pokeIDs[name] then
		if deployedID == PokemonList.ID(name) then
			return name
		end
	end
end

function Pokemon.isEvolving()
	return false
	--return Memory.value("menu", "pokemon") == 144
end

function Pokemon.getExp(name)
	local Index = 0
	if name then
		Index = indexOf(name)
	end
	return index(Index, "exp")
	--return Memory.raw(0x117A) * 256 + Memory.raw(0x117B)
end

function Pokemon.inRedBar()
	local curr_hp, max_hp = index(0, "hp"), index(0, "max_hp")
	return curr_hp / max_hp <= 0.2
end

function Pokemon.use(move)
	--local main = Memory.value("menu", "main")
	local battlemenu = Memory.value("battle", "menu")
	local pokeName = Pokemon.forMove(move)
	local column = Memory.value("battle", "menuX")
	local row = Memory.value("battle", "menuY")
	if battlemenu == 186 then
		if column == 2 then
			Input.press("Left", 1)
		else
			if row == 2 then
				Input.press("Up", 1)
			else
				--select move menu
				Input.press("A", 1)
			end
		end
	elseif battlemenu == 106 then
		local midx = 1
		if move then
			midx = move
		end
		Menu.select(midx, true, "input")
	else
		return false
	end
	
	
	--[[if main == 141 then
		Input.press("A")
	elseif main == 128 then
		local column = Menu.getCol()
		if column == 11 then
			Menu.select(1, true)
		elseif column == 10 or column == 12 then
			local midx = 0
			local menuSize = Memory.value("menu", "size")
			if menuSize == 4 then
				if move == "dig" then
					midx = 1
				elseif move == "surf" then
					if Pokemon.inParty("paras") then
						midx = 1
					end
				end
			elseif menuSize == 5 then
				if move == "dig" then
					midx = 2
				elseif move == "surf" then
					midx = 1
				end
			end
			Menu.select(midx, true)
		else
			Input.press("B")
		end
	elseif main == Menu.pokemon then
		Menu.select(pokeName, true)
	elseif main == 228 then
		Input.press("B")
	else
		return false
	end]]
	return true
end

function Pokemon.getDVs(name)
	local index = Pokemon.indexOf(name)
	local baseAddress = getAddress(index)
	local attackDefense = Memory.raw(baseAddress + 0x14)	--+20 index
	local speedSpecial = Memory.raw(baseAddress + 0x15)		--+21 index
	return bit.rshift(attackDefense, 4), bit.band(attackDefense, 15), bit.rshift(speedSpecial, 4), bit.band(speedSpecial, 15)
end

return Pokemon

