local Textbox = {}

local Input = require "util.input"
local Memory = require "util.memory"
local Menu = require "util.menu"

local alphabet_upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ -?1/.,   "
local alphabet_lower = "abcdefghijklmnopqrstuvw<yz x():;[]{}"
-- < = special X
-- { = Pk
-- } = mon

local nidoName = "A"
local nidoIdx = 1

local TableNumber = 1
local ActualUpper = 1

--[[local function getLetterAt(index)
	return alphabet:sub(index, index)
end]]
local function getIndexForLetter(letter, Caps)
	if Caps then
		return alphabet_upper:find(letter, 1, true)
	else
		return alphabet_lower:find(letter, 1, true)
	end
end

function Textbox.name(letter, randomize)
	local inputting = false
	if letter ~= TOTODILE_NAME and Memory.value("menu", "current") == 232 then
		inputting = true
	elseif letter == TOTODILE_NAME and Memory.value("menu", "option_current") == 17 then
		inputting = true
	end
	if inputting then
		-- Values
		local lidx
		local crow
		local drow
		local ccol
		local dcol
		local NameTable = {}
		
		--if letter then
			--RUNNING4NEWGAME = false	--make sure it's not running if we begin a game
			local StringLenght = string.len(letter)
			letter:gsub(".",function(letter2)
				table.insert(NameTable,letter2)
				
				if NameTable[TableNumber] then
					local GetUpper = true
					--Set Special Chars & Get UpperCase
					--[[if NameTable[TableNumber] == "<" then
						GetUpper = false
						lidx = 28
					elseif NameTable[TableNumber] == "{" then
						GetUpper = false
						lidx = 35
					elseif NameTable[TableNumber] == "}" then
						GetUpper = false
						lidx = 36
					else]]
						--its a letter
						if string.match(NameTable[TableNumber], '%a') then
							if string.match(NameTable[TableNumber], '%u') then
								--the letter was uppercase
								GetUpper = true
							elseif string.match(NameTable[TableNumber], '%l') then
								--the letter was lowercase
								GetUpper = false
							end
						--its anything but not a letter
						else
							if string.find(alphabet_upper, NameTable[TableNumber]) ~= nil then
								GetUpper = true
							elseif string.find(alphabet_lower, NameTable[TableNumber]) ~= nil then
								GetUpper = false
							end
						end
						lidx = getIndexForLetter(NameTable[TableNumber], GetUpper)
					--end
					--Check For Waiting
					local Waiting = Input.isWaiting()
					--Proceed
					if not Waiting then
						--Get/set Lower/Upper
						if GetUpper == false and ActualUpper == 1 or GetUpper ~= false and ActualUpper == 0 then
							crow = Memory.value("text_inputing", "row")
							if crow ~= 4 then
								Input.press("Down", 2)
							elseif crow == 4 then
								ccol = Memory.value("text_inputing", "column")
								if ccol <= 2 then
									Input.press("A", 2)
									if ActualUpper == 1 then
										ActualUpper = 0
									elseif ActualUpper == 0 then
										ActualUpper = 1
									end
								elseif ccol > 2 then
									Input.press("Left", 2)
								end
							end
						--Get/Set Letter
						else
							crow = Memory.value("text_inputing", "row")
							drow = math.ceil(lidx/9)-1
							if crow < drow then
								Input.press("Down", 2)
							elseif crow > drow then
								Input.press("Up", 2)
							elseif crow == drow then
								ccol = Memory.value("text_inputing", "column")
								dcol = math.fmod(lidx - 1, 9)
								if ccol < dcol then
									Input.press("Right", 2)
								elseif ccol > dcol then
									Input.press("Left", 2)
								elseif ccol == dcol then
									Input.press("A", 2)
									if Memory.value("menu", "text_length") == TableNumber then
										TableNumber = TableNumber + 1
									end
								end
							end
						end
					end
				end
			end)
			local Waiting = Input.isWaiting()
			if TableNumber > StringLenght and not Waiting then
				if Memory.value("menu", "text_length") > 0 then
					--get column/row
					crow = Memory.value("text_inputing", "row")
					ccol = Memory.value("text_inputing", "column")
					if crow ~= 4 then
						Input.press("Start", 2)
					elseif ccol < 6 then
						Input.press("Start", 2)
					elseif crow == 4 and ccol >= 6 then
						Input.press("A", 2)
						TableNumber = 1
						ActualUpper = 1
						NameTable = {}
						return true
					end
				end
			end
		--[[else
			if Memory.value("menu", "text_length") > 0 then
				Input.press("Start")
				return true
			end
			
			lidx = nidoIdx
			
			crow = Memory.value("menu", "input_row")
			drow = math.ceil(lidx / 9)
			if Menu.balance(crow, drow, true, 6, true) then
				ccol = math.floor(Memory.value("menu", "column") / 2)
				dcol = math.fmod(lidx - 1, 9)
				if Menu.sidle(ccol, dcol, 9, true) then
					Input.press("A")
				end
			end]]
		--end
	else
		--Reset Values
		TableNumber = 1
		ActualUpper = 1
		NameTable = {}
		
		--if Memory.raw(0x10B7) == 3 then
		--	Input.press("A", 2)
		--elseif randomize then
		if randomize then
			Input.press("A", math.random(1, 5))
		else
			Input.press("A", 2)
			--Input.cancel()
		end
	end
end

--[[function Textbox.getName()
	if nidoName == "a" then
		return "ポ"
	end
	if nidoName == "b" then
		return "モ"
	end
	if nidoName == "m" then
		return "♂"
	end
	if nidoName == "f" then
		return "♀"
	end
	return nidoName
end]]

--[[function Textbox.setName(index)
	if index >= 0 and index < #alphabet then
		nidoIdx = index + 1
		nidoName = getLetterAt(index)
	end
end]]

function Textbox.isActive()
	if Memory.value("game", "textbox") == 65 then
		return true
	elseif Memory.value("game", "textbox") == 1 then
		return false
	end
end

function Textbox.handle()
	if not Textbox.isActive() then
		return true
	end
	Input.cancel()
end

return Textbox
