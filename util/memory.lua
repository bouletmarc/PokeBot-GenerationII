local Memory = {}

local memoryNames = {
	setting = {
		text_speed = 0x04E8,		--139-136-128
		battle_animation = 0x0510,	--141=on 133=off
		battle_style = 0x0538,		--135=shift 132=set
		sound_style = 0x0562,		--142=mono 145=stereo
		print_style = 0x0FD0,		--64=normal // 96=darker // 127=darkest // 0=lightest // 32=lighter
		account_style = 0x0FD1,		--0=no // 1=yes
		windows_style = 0x0FCE,		--0 to 7
	},
	text_inputing = {
		column = 0x0330,
		row = 0x0331,
	},
	inventory = {
		item_count = 0x1892,
		--item_base = 0x1893,
	},
	menu = {
		row = 0x0F88,
		pc_row = 0x0B2B,
		input_row = 0x0FA9,
		settings_row = 0x0F63,
		hours_row = 0x061C,		--(0-23)
		minutes_row = 0x0626,	--(0-59)
		days_row = 0x1002,		--(0-6)
		
		item_row = 0x110C,
		item_row_size = 0x110D,
		
		column = 0x0F65,
		current = 0x00DF,		--32=off 79=on instead of 20=on
		size = 0x0FA3,
		option_current = 0x0F84,
		shop_current = 0x0F87,
		selection = 0x0F78,
		text_input = 0x0F69,	--65=inputing
		text_length = 0x06D2,
		main = 0x04AA,
		--pokemon = 0x0C51,			--TO DO, USED WHILE EVOLVING
		--selection_mode = 0x0C35,	--TO DO, USED WHEN SWAPING MOVE
		--transaction_current = 0x0F8B,--TODO, USED FOR SHOPPING
		--################################################################
		--main_current = 0x0C27,		--NOT USED??
		--scroll_offset = 0x0C36,		--NOT USED IN GEN2
		--################################################################
	},
	player = {
		name = 0x147D,
		name2 = 0x1493,
		moving = 0x14E1,		--if not 1 then moving
		x = 0x1CB8,
		y = 0x1CB7,
		facing = 0x14DE,		--0=S // 4=N // 8=W // 12=E instead of 4=S // 8=N // 2=W // 1=E
		repel = 0x1CA1,
		party_size = 0x1CD7,
	},
	game = {
		map = 0x1CB6,
		map2 = 0x1CB5,
		battle = 0x122D,		--1=wild 2=trainer
		battle_type = 0x1230,	--ex:7=shiny/cant escape (not used yet)
		ingame = 0x02CE,
		textbox = 0x10ED,		--1=false 64/65=On
	},
	time = {
		hours = 0x14C4,
		minutes = 0x14C6,
		seconds = 0x14C7,
		frames = 0x14C8,
	},
	shop = {
		transaction_amount = 0x110C,
	},
	battle = {
		text = 0x0FCF,				--1=11(texting) // 3=1(not)
		menu = 0x0FB6,				--106=106(att) // 186=94(main) // 128=233(item) // 145=224(pkmon)
		menuX = 0x0FAA,				--used for battle menu Row-X
		menuY = 0x0FA9,				--used for battle menu Row-Y
		battle_turns = 0x06DD,		--USED FOR DSUM ESCAPE??
		
		opponent_id = 0x1206,		--or 0x1204??
		opponent_level = 0x1213,
		opponent_type1 = 0x1224,
		opponent_type2 = 0x1225,
		--opponent_move_id = 0x1208,	--used to get opponent moves ID's
		--opponent_move_pp = 0x120E,	--used to get opponent moves PP's

		our_id = 0x1205,
		our_status = 0x063A,
		our_level = 0x0639,
		our_type1 = 0x064A,
		our_type2 = 0x064B,
		--our_move_id = 0x062E,		--used to get our moves ID's
		--our_move_pp = 0x0634,		--used to get our moves PP's
		
		--our_pokemon_list = 0x1288	--used to retract any of our Pokemons values (slot 1-6)
		
		--attack_turns = 0x06DC,	--NOT USED??
		--accuracy = 0x0D1E,		--NOT DONE YET
		--x_accuracy = 0x1063,		--NOT DONE YET
		--disabled = 0x0CEE,		--NOT DONE YET
		--paralyzed = 0x1018,		--NOT DONE YET
		--critical = 0x105E,		--NOT DONE YET
		--miss = 0x105F,			--NOT DONE YET
		--our_turn = 0x1FF1,		--NOT DONE YET
		
		--opponent_next_move = 0xC6E4,	--NOT USED??
		--opponent_last_move = 0x0FCC,	--NOT DONE YET AND NOT USED??
		--opponent_bide = 0x106F,		--NOT DONE YET AND NOT USED??
	},
	
	--[[pokemon = {
		exp1 = 0x1179,
		exp2 = 0x117A,	--NOT DONE YET
		exp3 = 0x117B,
	},]]
}

local doubleNames = {
	battle = {
		opponent_hp = 0x1216,
		opponent_max_hp = 0x1218,
		opponent_attack = 0x121A,
		opponent_defense = 0x121C,
		opponent_speed = 0x121E,
		opponent_special_attack = 0x1220,
		opponent_special_defense = 0x1222,

		our_hp = 0x063C,
		our_max_hp = 0x063E,
		our_attack = 0x0640,
		our_defense = 0x0642,
		our_speed = 0x0644,
		our_special_attack = 0x0646,
		our_special_defense = 0x0648,
	},
	
	--[[pokemon = {
		attack = 0x117E,
		defense = 0x1181,	--NOT DONE YET
		speed = 0x1183,
		special = 0x1185,
	},]]
}

--local yellow = YELLOW

local function raw(address)
	return memory.readbyte(address)
end
Memory.raw = raw

function Memory.string(first, last)
	local a = "ABCDEFGHIJKLMNOPQRSTUVWXYZ():;[]abcdefghijklmnopqrstuvwxyz?????????????????????????????????????????-???!.????????*?/.?0123456789"
	local str = ""
	while first <= last do
		local v = raw(first) - 127
		if v < 1 then
			return str
		end
		str = str..string.sub(a, v, v)
		first = first + 1
	end
	return str
end

function Memory.double(section, key)
	local first = doubleNames[section][key]
	return raw(first) + raw(first + 1)
end

function Memory.value(section, key)
	local memoryAddress = memoryNames[section]
	if key then
		memoryAddress = memoryAddress[key]
	end
	return raw(memoryAddress)
end

function Memory.getAddress(section, key)
	local memoryAddress = memoryNames[section]
	if key then
		memoryAddress = memoryAddress[key]
	end
	return memoryAddress
end

return Memory
