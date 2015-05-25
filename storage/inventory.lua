local Inventory = {}

local Input = require "util.input"
local Memory = require "util.memory"
local Menu = require "util.menu"
local Utils = require "util.utils"

local Pokemon = require "storage.pokemon"

local ItemList = require "storage.itemlist"

local ITEM_BASE = Memory.value("inventory", "item_base")

-- Data

function Inventory.indexOf(name)
	--local searchID = items[name]
	local searchID = ItemList.items[name]
	for i=0,19 do
		--local iidx = ITEM_BASE + i * 2
		local SubIndex =  i * 2
		local iidx = ITEM_BASE + SubIndex
		if Memory.raw(iidx) == searchID then
			return i
		end
	end
	return -1
end

function Inventory.count(name)
	local index = Inventory.indexOf(name)
	if index ~= -1 then
		local SubIndex = index * 2
		return Memory.raw(ITEM_BASE + SubIndex + 1)
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

function Inventory.use(item, poke, midfight, BagMenu)
	if midfight then
		local battleMenu = Memory.value("battle", "menu")
		--open bag menu
		if battleMenu == 186 then
			local rowSelected = Memory.value("battle", "menuY")
			local ColumnSelected = Memory.value("battle", "menuX")
			if ColumnSelected == 1 then
				if rowSelected == 1 then
					Input.press("Down")
				else
					--select bag
					Input.press("A")
				end
			else
				Input.press("Left")
			end
		--inside bag menu
		elseif battleMenu == 128 then
			--if its not done
			if not give_done then
				if column ~= BagMenu then
					--select proper bag menu
					Menu.setCol(BagMenu)
				else
					if Memory.value("menu", "shop_current") ~= 70 then
						--select the item
						Menu.select(Inventory.indexOf(item)+1, "accelerate", "input")
					else
						--accept the use
						Menu.select(1, true, "input")
					end
				end
			--if its done
			else
				Menu.close()
			end
		elseif Utils.onPokemonSelect(battleMenu) then
			if poke then
				if type(poke) == "string" then
					poke = Pokemon.indexOf(poke)
				end
				Menu.select(poke, true, "input")
			else
				Input.press("A")
			end
		else
			Input.press("B")
		end
		return
	end

	local main = Memory.value("menu", "main")
	local column = Menu.getCol()
	local give_done = false
	--select item menu
	if main == 121 then
		Menu.select(3, true)
	--inside bag menu
	elseif main == 50 then
		--if its not done
		if not give_done then
			if column ~= BagMenu then
				--select proper bag menu
				Menu.setCol(BagMenu)
			else
				if Memory.value("menu", "shop_current") ~= 66 then
					--select the item
					Menu.select(Inventory.indexOf(item)+1, "accelerate", "input")
				else
					--accept the use
					Menu.select(1, true, "input")
				end
			end
		--if its done
		else
			Menu.close()
		end
	--inside pokemon menu
	elseif main == 127 then
		local idx = 1
		if poke then
			idx = poke
		end
		if Memory.value("menu", "input_row") ~= idx then
			Menu.select(idx, true, "input")
		else
			Input.press("A", 1)
			give_done = true
		end
	else
		return false
	end
	return true
end

return Inventory

