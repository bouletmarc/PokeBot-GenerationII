--##################################################
--#############							############
--#############			SETTING  		############
--#############							############
--##################################################

--Reset Settings
RESET_FOR_TIME = false 			-- Set to false if you just want to see the bot finish a run without reset for time
RESET_FOR_ENCOUNTERS = false 	-- Set to false if you just want to see the bot finish a run without reset for encounters

--Game Settings
GAME_NAME = "Crystal"			-- Set to Gold/Silver(not done) or Crystal
GAME_RUN = ""					-- Set to "" or "" for the run you want
GAME_HOURS = 17					-- Set the internal game hour (0-23h)
GAME_MINUTES = 35				-- Set the internal game minutes (0-59min)
GAME_DAY = 3 					-- Set the internal game day (0-6 // sunday-saturday)
GAME_GENDER = 1					-- Set the player gender (1-2 // boy-girl)

GAME_TEXT_SPEED = 128			-- Set the Text Speed (247-249 // slow-fast)
GAME_BATTLE_ANIMATION = 133		-- Set the battle animation (141-142 // no-yes)
GAME_BATTLE_STYLE = 132			-- Set the battle style (130-131 // choice-set)
GAME_SOUND_STYLE = 145			-- Set the sound style (132 or 141 // stereo-mono)
GAME_PRINT_STYLE = 127			-- Set the print style (64=normal // 96=dark // 127=dark+ // 0=clear+ // 32=clear)
GAME_ACCOUNT_STYLE = 0			-- Set the account style (0-1 // no-yes)
GAME_WINDOWS_STYLE = 3			-- Set the windows style (0-7)

--Connection Settings
INTERNAL = false				-- Allow connection with LiveSplit ?
STREAMING_MODE = false			-- Enable Streaming mode

--Script Settings
CUSTOM_SEED = nil		 		-- Set to a known seed to replay it, or leave nil for random runs
PAINT_ON    = true 				-- Display contextual information while the bot runs

--Names Settings 
PLAYER_NAME = "TeSt"			-- Player name
RIVAL_NAME = "URRival"			-- Rival name
TOTODILE_NAME = "ToTo"			-- Set Totodile name

--Advanced area Settings
PATH_IDX = 0					-- Start the bot to the specified path idx
STEP_IDX = 0					-- Start the bot to the specified step idx
PRINT_PATH = false				-- Print the current path in the console.
PRINT_STEP = false				-- Print the current step in the console.

--NAMES SETTINGS TIPS : 
--		- Can use up to 7 letter ingame
--		- Upper and Lower case allowed
--		- Specials Characters : <=Special X, {=Pk, }=Mn

--#####################################################################################
--#####################################################################################
--###########															###############
--###########   PLEASE DON'T EDIT ANYTHING BELLOW, IT'S AT YOUR RISK   	###############
--###########				 START CODE (hard hats on)					###############
--###########															###############
--#####################################################################################
--#####################################################################################

-- SET VALUES

local VERSION = "0.2-BETA"

local START_WAIT = 99
local hasAlreadyStartedPlaying = false
local oldSeconds
local running = true
local lastHP

--RUNNING4CONTINUE = false		--used to continue a game
--RUNNING4NEWGAME = true			--used to make a new game (remove last save also)
--EXTERNALDONE = false			--used when the above settings are done externally
--local InternalDone = false 		--used when the above settings are done internally
--local UsingCustomPath = false	--used when we set a custom path

-- LOAD DIR

local LowerGameName = string.lower(GAME_NAME)

local Battle = require "action.battle"
local Textbox = require "action.textbox"
local Walk = require "action.walk"

local Combat = require "ai.combat"
local Control = require "ai.control"
local Strategies = require("ai."..LowerGameName..".strategies")

local Bridge = require "util.bridge"
local Input = require "util.input"
local Memory = require "util.memory"
local Menu = require "util.menu"
local Paint = require "util.paint"
local Utils = require "util.utils"
local Settings = require "util.settings"

local Pokemon = require "storage.pokemon"

-- GLOBAL

function p(...)	--print
	local string
	if #arg == 0 then
		string = arg[0]
	else
		string = ""
		for i,str in ipairs(arg) do
			if str == true then
				string = string.."\n"
			else
				string = string..str.." "
			end
		end
	end
	print(string)
end

-- RESET

local function resetAll()
	Strategies.softReset()
	Combat.reset()
	Control.reset()
	Walk.reset()
	Paint.reset()
	Bridge.reset()
	oldSeconds = 0
	running = false
	-- client.speedmode = 200
	
	if CUSTOM_SEED then
		Strategies.seed = CUSTOM_SEED
		p("RUNNING WITH A FIXED SEED ("..Strategies.seed.."), every run will play out identically!", true)
	else
		Strategies.seed = os.time()
		p("Starting a new run with seed "..Strategies.seed, true)
	end
	math.randomseed(Strategies.seed)
end

-- EXECUTE

local OWNER = "Bouletmarc"
p("Welcome to PokeBot Version "..VERSION, true)
p("Actually running Pokemon "..GAME_NAME.." Speedruns by "..OWNER, true)

Control.init()

--STREAMING_MODE = not walk.init()
if INTERNAL and STREAMING_MODE then
	RESET_FOR_TIME = true
end

if CUSTOM_SEED then
	client.reboot_core()
else
	hasAlreadyStartedPlaying = Utils.ingame()
end

Strategies.init(hasAlreadyStartedPlaying)
if RESET_FOR_TIME and hasAlreadyStartedPlaying then
	RESET_FOR_TIME = false
	p("Disabling time-limit resets as the game is already running. Please reset the emulator and restart the script if you'd like to go for a fast time.", true)
end
if STREAMING_MODE then
	Bridge.init()
else
	Input.setDebug(true)
end

--if PATH_IDX ~= 0 and STEP_IDX ~= 0 then
--	UsingCustomPath = true
--end

-- MAIN LOOP

local previousMap
local previousMap2

local RebootDone = false

while true do
	local currentMap = Memory.value("game", "map")
	local currentMap2 = Memory.value("game", "map2")
	if currentMap ~= previousMap or currentMap2 ~= previousMap2 then
		Input.clear()
		previousMap = currentMap
		previousMap2 = currentMap2
	end
	if Strategies.frames then
		if Memory.value("game", "battle") == 0 then
			Strategies.frames = Strategies.frames + 1
		end
		Utils.drawText(0, 80, Strategies.frames)
	end
	--if Bridge.polling then
	--	Settings.pollForResponse()
	--end

	if not Input.update() then
		if not Utils.ingame() and currentMap == 0 then
		--if not Utils.ingame() and currentMap == 0 and currentMap2 == 0 then
			if running then
				if not hasAlreadyStartedPlaying then
					client.reboot_core()
					hasAlreadyStartedPlaying = true
				else
					--if not RUNNING4CONTINUE then
						resetAll()	--reset if not running to continue
						--RUNNING4NEWGAME = true --set back on in case we done a reboot
					--else
					--	running = false	 --continue adventure
					--end
				end
			else
				--if UsingCustomPath then
				--	if not EXTERNALDONE then	--continue adventure
				--		RUNNING4CONTINUE, RUNNING4NEWGAME = true, false
				--	elseif EXTERNALDONE and InternalDone then
				--		RUNNING4NEWGAME = true	--set back to new game
				--	end
				--end
				Settings.startNewAdventure(START_WAIT) --start/continue adventure
			end
		else
			if not running then
				Bridge.liveSplit()
				running = true
			end
			--if RUNNING4NEWGAME then	--remove last save game
			--	Settings.RemoveLastAdventure(START_WAIT)
			--elseif RUNNING4CONTINUE then   --continue the last adventure
			--	EXTERNALDONE = true
			--	InternalDone = true
			--	Settings.ContinueAdventure()
			--else
				local battleState = Memory.value("game", "battle")
				Control.encounter(battleState)
				local curr_hp = Pokemon.index(0, "hp")
				if curr_hp == 0 and not Control.canDie() and Pokemon.index(0) > 0 then
					Strategies.death(currentMap, currentMap2)
				elseif Walk.strategy then
					if Strategies.execute(Walk.strategy) then
						Walk.traverse(currentMap, currentMap2)
					end
				elseif battleState > 0 then
					if not Control.shouldCatch(partySize) then
						Battle.automate()
					end
				elseif Textbox.handle() then
					Walk.traverse(currentMap, currentMap2)
				end
			--end
		end
	end

	if STREAMING_MODE then
		local newSeconds = Memory.value("time", "seconds")
		if newSeconds ~= oldSeconds and (newSeconds > 0 or Memory.value("time", "frames") > 0) then
			Bridge.time(Utils.elapsedTime())
			oldSeconds = newSeconds
		end
	elseif PAINT_ON then
		Paint.draw(currentMap, currentMap2)
	end

	Input.advance()
	emu.frameadvance()
end

Bridge.close()
