local Memory = {}

local memoryNames = {
	setting = {
		text_speed = 0x04E8,		--247=1 // 248=2 // 249=3 ###### 139-136-128
		battle_animation = 0x0510,	--141=no // 142=yes	###### 141=on 133=off
		battle_style = 0x0538,		--130=shift // 131=set ##### 135=shift 132=set
		sound_style = 0x0562,		--132=stereo // 141=mono ##### 142=mono 145=stereo
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
		item_base = 0x1893,
	},
	menu = {
		row = 0x0F88,
		input_row = 0x0FA9,
		settings_row = 0x0F63,
		hours_row = 0x061C,		--(0-23)
		minutes_row = 0x0626,	--(0-59)
		days_row = 0x1002,		--(0-6)
		
		column = 0x0F65,
		current = 0x00DF,		--32=off 79=on instead of 20=on
		size = 0x0FA3,
		option_current = 0x0F84,--DONE used while settings options (5=startmenu, 7=optionmenu)
		shop_current = 0x0F87,	--DONE 95=main 94=buy 80=ammount 30=accept 74=sell instead of 32=main 158/161=amount 20=buy/accept 248=sell
		selection = 0x0F78,		--DONE ?? going like 1 or 2 or 4 etc...
		text_input = 0x0F69,	--DONE 65=inputing
		text_length = 0x06D2,	--DONE
		main = 0x04AA,			--DONE 121=open
		--pokemon = 0x0C51,			--TO DO, USED WHILE EVOLVING
		--selection_mode = 0x0C35,	--TO DO, USED WHEN SWAPING MOVE
		--transaction_current = 0x0F8B,--TODO, USED FOR SHOPPING
		--################################################################
		--main_current = 0x0C27,		--NOT USED??
		--scroll_offset = 0x0C36,		--NOT USED
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
		battle_type = 0x1230,	--ex:7=shiny/cant escape
		ingame = 0x02CE,
		textbox = 0x10ED,		--1=false 65=On
		--textbox = 0x0FA4,		--or 0x0FAA
		--inside_area = 0x02D0,	--can be used while inside a area we can use escape_rope?
	},
	time = {
		hours = 0x14C4,			--DONE or 0xD4C5
		minutes = 0x14C6,		--DONE
		seconds = 0x14C7,		--DONE
		frames = 0x14C8,		--DONE
	},
	shop = {
		transaction_amount = 0x110C,--DONE
	},
	battle = {
		text = 0x0FCF,				--DONE 1=11(texting) // 3=1(not)
		menu = 0x0FB6,				--DONE 106=106(att) // 186=94(free) // 128=233(item) // 145=224(pkmon)
		menuX = 0x0FAA,				--DONE used for battle Row-X
		menuY = 0x0FA9,				--DONE used for battle Row-Y
		battle_turns = 0x06DD,		--DONE?? USED FOR DSUM ESCAPE??
		
		opponent_id = 0x1206,		--DONE or 0x1204
		opponent_level = 0x1213,	--DONE
		opponent_type1 = 0x1224,	--DONE
		opponent_type2 = 0x1225,	--DONE
		opponent_move_id = 0x1208,		--DONE used to get opponent moves ID
		opponent_move_pp = 0x120E,		--DONE used to get opponent moves PP

		our_id = 0x1205,			--DONE old=1014
		our_status = 0x063A,		--DONE
		our_level = 0x0639,			--DONE
		our_type1 = 0x064A,			--DONE
		our_type2 = 0x064B,			--DONE
		our_move_id = 0x062E,		--DONE used to get our moves ID
		our_move_pp = 0x0634,		--DONE used to get our moves PP
		
		--attack_turns = 0x06DC,	--DONE?? NOT USED??
		--accuracy = 0x0D1E,
		--x_accuracy = 0x1063,
		--disabled = 0x0CEE,
		--paralyzed = 0x1018,
		--critical = 0x105E,
		--miss = 0x105F,
		--our_turn = 0x1FF1,
		
		--TO DO GET SLEEPING STATUS
		--TO DO GET CONFUSED STATUS
		--TO DO GET PARALIZED STATUS ?
		--TO DO GET CRITICAL'D STATUS ?

		--opponent_next_move = 0x0CDD,	--C6E4 ?? NOT USED?
		--opponent_last_move = 0x0FCC,
		--opponent_bide = 0x106F,
	},
	
	--[[pokemon = {
		exp1 = 0x1179,
		exp2 = 0x117A,	--NOT USED, WAS ONLY FOR REMOVE LAST ADVENTURE
		exp3 = 0x117B,
	},]]
}

local doubleNames = {
	battle = {
		opponent_hp = 0x1216,			--DONE 10FF index +278? // 
		opponent_max_hp = 0x1218,		--DONE
		opponent_attack = 0x121A,		--DONE
		opponent_defense = 0x121C,		--DONE
		opponent_speed = 0x121E,		--DONE
		opponent_special_attack = 0x1220,--DONE
		opponent_special_defense = 0x1222,--DONE

		our_hp = 0x063C,				--DONE
		our_max_hp = 0x063E,			--DONE
		our_attack = 0x0640,			--DONE
		our_defense = 0x0642,			--DONE
		our_speed = 0x0644,				--DONE
		our_special_attack = 0x0646,	--DONE
		our_special_defense = 0x0648,	--DONE
	},
	
	--[[pokemon = {
		attack = 0x117E,
		defense = 0x1181,	--NOT USED AT ALL??
		speed = 0x1183,
		special = 0x1185,
	},]]
}

--local yellow = YELLOW

local function raw(address)
--local function raw(address, forYellow)
	--if yellow and not forYellow and address > 0x0F12 and address < 0x1F00 then
	--	address = address - 1
	--end
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

function Memory.value(section, key, forYellow)
	local memoryAddress = memoryNames[section]
	if key then
		memoryAddress = memoryAddress[key]
	end
	return raw(memoryAddress, forYellow)
end

return Memory
