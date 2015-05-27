PokemonList = {}

local pokeIDs = {
	pidgey = 16,
	spearow = 21,
	rattata = 19,
	nidoranF = 29,
	nidoranM = 32,
	
	poliwag = 60,
	poliwhirl = 61,
	poliwrath = 62,
	abra = 63,
	kadabra = 64,
	alakazam = 65,
	machop = 66,
	machoke = 67,
	machamp = 68,
	bellsprout = 69,
	weepinbell = 70,
	victreebel = 71,
	
	chikorita = 152,
	bayleef = 153,
	meganium = 154,
	
	cyndaquil = 155,
	quilava = 156,
	typhlosion = 157,
	
	totodile = 158,
	croconaw = 159,
	feraligatr = 160,
	
	sentret = 161,
	furret = 162,
	hoothoot = 163,
	marill = 183,
	azumarill = 184,
	sudowoodo = 185,
	politoed = 186,
	hoppip = 187,
}

--Get id
local function ID(Pokemon)
	return pokeIDs[Pokemon]
end
PokemonList.ID = ID

--Get name
local function PokemonName(ID)
	for name,pid in pairs(pokeIDs) do
		if pid == ID then
			return name
		end
	end
end
PokemonList.PokemonName = PokemonName

return PokemonList

