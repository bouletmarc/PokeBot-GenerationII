local Inventory = {}

local Input = require "util.input"
local Memory = require "util.memory"
local Menu = require "util.menu"
local Utils = require "util.utils"

local Pokemon = require "storage.pokemon"

local BagList = require "storage.baglist"

local ITEM_BASE = 0x1893
local BALL_BASE = 0x18D8
local KEY_BASE = 0x18BD

-- Data

function Inventory.indexOf(name)
	--local searchID = items[name]
	local searchID
	local SEARCH_BASE
	if BagList.items(name) then
		SEARCH_BASE = ITEM_BASE
		searchID = BagList.items(name)
	elseif BagList.balls(name) then
		SEARCH_BASE = BALL_BASE
		searchID = BagList.balls(name)
	else
		return -1
	end
	for i=0,19 do
		local iidx = SEARCH_BASE + i * 2
		local read = Memory.raw(iidx)
		if Memory.raw(iidx) == searchID then
			return i
		end
	end
	return -1
end

function Inventory.count(name)
	--get menu
	local SEARCH_BASE
	if BagList.items(name) then
		SEARCH_BASE = ITEM_BASE
	elseif BagList.balls(name) then
		SEARCH_BASE = BALL_BASE
	else
		return 0
	end
	local index = Inventory.indexOf(name)
	if index ~= -1 then
		return Memory.raw(SEARCH_BASE + index + 1)
	end
	return 0
end

function Inventory.contains(...)
	for i,name in ipairs(arg) do
		if Inventory.count(name) > 0 then
			return name
		end
	end
end

-- Actions

--[[function Inventory.teach(item, poke, replaceIdx, altPoke)
	local main = Memory.value("menu", "main")
	local column = Menu.getCol()
	if main == 144 then
		if column == 5 then
			Menu.select(replaceIdx, true)
		else
			Input.press("A")
		end
	elseif main == 128 then
		if column == 5 then
			Menu.select(Inventory.indexOf(item), "accelerate", true)
		elseif column == 11 then
			Menu.select(2, true)
		elseif column == 14 then
			Menu.select(0, true)
		end
	elseif main == Menu.pokemon then
		Input.press("B")
	elseif main == 64 or main == 96 or main == 192 then
		if column == 5 then
			Menu.select(replaceIdx, true)
		elseif column == 14 then
			Input.press("A")
		elseif column == 15 then
			Menu.select(0, true)
		else
			local idx = 0
			if poke then
				idx = Pokemon.indexOf(poke, altPoke)
			end
			Menu.select(idx, true)
		end
	else
		return false
	end
	return true
end]]

function Inventory.isFull()
	return Memory.value("inventory", "item_count") == 20
end

function Inventory.use(item, poke, BagMenu)
	if not BagMenu then
		BagMenu = 0
	end
	local column = Memory.value("menu", "column")
	local battleMenu = Memory.value("battle", "menu")
	local battleText = Memory.value("battle", "text")
	local itemRow = Memory.value("menu", "input_row")
	local OptionMenu = Memory.value("menu", "option_current")
	--open bag menu
	if battleText == 1 then
		if battleMenu == 186 then
			local rowSelected = Memory.value("battle", "menuY")
			local ColumnSelected = Memory.value("battle", "menuX")
			if ColumnSelected == 1 then
				if rowSelected == 1 then
					Input.press("Down", 2)
				else
					--select bag
					Input.press("A", 2)
				end
			else
				Input.press("Left", 2)
			end
		--inside bag menu
		elseif battleMenu == 128 then
			if OptionMenu ~= 17 then
				if column ~= BagMenu then
					--select proper bag menu
					Input.press("Right", 2)
				else
					if Memory.value("menu", "shop_current") == 74 then
						--select the item
						local Index = Inventory.indexOf(item)
						if itemRow < Index then
							Input.press("Down", 2)
						else
							Input.press("A", 2)
						end
					else
						--accept the use
						Input.press("A", 2)
					end
				end
			else
				--cancel menu (or set name)
				Input.press("B", 2)
			end
		elseif Utils.onPokemonSelect(battleMenu) then
			if poke then
				local Index
				if type(poke) == "string" then
					Index = Pokemon.indexOf(poke)+1
				else
					Index = poke
				end
				if itemRow < Index then
					Input.press("Down", 2)
				else
					Input.press("A", 2)
				end
				--Menu.select(poke, true, "input")
			else
				Input.press("A", 2)
			end
		else
			Input.press("B", 2)
		end
	else
		Input.press("A", 2)
	end
	--return true
	return
end

return Inventory

