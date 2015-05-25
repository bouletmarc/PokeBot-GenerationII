local Bridge = {}

local socket
if INTERNAL then
	socket = require("socket")
end

local utils = require("util.utils")

local client = nil
local timeStopped = true

local function send(prefix, body)
	if client then
		local message = prefix
		if body then
			message = message..","..body
		end
		client:send(message.."\n")
		return true
	end
end

local function readln()
	if client then
		local s, status, partial = client:receive("*l")
		if status == "closed" then
			client = nil
			return nil
		end
		if s and s ~= "" then
			return s
		end
	end
end

-- Wrapper functions

function Bridge.init()
	if socket then
		-- io.popen("java -jar Main.jar")
		client = socket.connect("127.0.0.1", 13378)
		if client then
			client:settimeout(0.005)
			client:setoption("keepalive", true)
			print("Connected to Java!");
			return true
		else
			print("Error connecting to Java!");
		end
	end
end

function Bridge.tweet(message)
	if INTERNAL and STREAMING_MODE then
		print("tweet::"..message)
		return send("tweet", message)
	end
end

function Bridge.pollForName()
	Bridge.polling = true
	send("poll_name")
end

function Bridge.chat(message, extra, newLine)
	if extra then
		p(message.." || "..extra, newLine)
	else
		p(message, newLine)
	end
	return send("msg", "/me "..message)
end

function Bridge.time(message)
	if not timeStopped then
		return send("time", message)
	end
end

function Bridge.stats(message)
	return send("stats", message)
end

function Bridge.command(command)
	return send("livesplit_command", command);
end

function Bridge.comparisonTime()
	return send("livesplit_getcomparisontime");
end

function Bridge.process()
	local response = readln()
	if response then
		-- print(">"..response)
		if response:find("name:") then
			return response:gsub("name:", "")
		else

		end
	end
end

function Bridge.input(key)
	send("input", key)
end

function Bridge.caught(name)
	if name then
		send("caught", name)
	end
end

function Bridge.hp(curr, max)
	send("hp", curr..","..max)
end

function Bridge.liveSplit()
	send("start")
	timeStopped = false
end

function Bridge.split(finished)
	if finished then
		timeStopped = true
	end
	send("split")
end

function Bridge.encounter()
	send("encounter")
end

function Bridge.reset()
	send("reset")
	timeStopped = false
end

function Bridge.close()
	if client then
		client:close()
		client = nil
	end
	print("Bridge closed")
end

return Bridge
