BagList = {}

local ItemsTable = {
	bright_powder = 3,
	--teru_sama = 6,
	moon_stone = 8,
	antidote = 9,
	burn_heal = 10,
	ice_heal = 11,
	awakening = 12,
	paralyze_heal = 13,
	full_restore = 14,
	max_potion = 15,
	hyper_potion = 16,
	super_potion = 17,
	potion = 18,
	escape_rope = 19,
	repel = 20,
	--carbos = 38,
	rare_candy = 32,
	--helix_fossil = 42,
	--nugget = 49,
	--pokedoll = 51,
	super_repel = 42,
	--fresh_water = 60,
	--soda_pop = 61,
	--pokeflute = 73,
	--ether = 80,
	--max_ether = 81,
	--elixer = 82,
	bitter_berry = 83,
	--x_accuracy = 46,
	--x_speed = 67,
	--x_special = 68,
	berry = 173,
	gold_berry = 174,
	--horn_drill = 207,
	--bubblebeam = 211,
	--water_gun = 212,
	--ice_beam = 213,
	--thunderbolt = 224,
	--earthquake = 226,
	--dig = 228,
	--tm34 = 234,
	--rock_slide = 248,
}

local MovesTable = {
	cut = 15,
	fly = 19,
	surf = 57,
	strength = 70,
	teleport = 100,
	watefall = 127,
	whirlpool = 250,
}

local BallsTable = {
	masterball = 1,
	ultraball = 2,
	greatball = 4,
	pokeball = 5,
}

local KeysTable = {
	bicycle = 7,
	coin_case = 54,
	squirtbottle = 175,
}

--Get item
local function items(Name)
	if ItemsTable[Name] then
		return ItemsTable[Name]
	else
		return false
	end
end
BagList.items = items

--Get move
local function moves(Name)
	if MovesTable[Name] then
		return MovesTable[Name]
	else
		return false
	end
end
BagList.moves = moves

--Get balls
local function balls(Name)
	if BallsTable[Name] then
		return BallsTable[Name]
	else
		return false
	end
end
BagList.balls = balls

--Get key items
local function keys(Name)
	if KeysTable[Name] then
		return KeysTable[Name]
	else
		return false
	end
end
BagList.keys = keys

return BagList

