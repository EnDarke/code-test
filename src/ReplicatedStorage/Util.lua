--!strict

-- Author: Alex/EnDarke
-- Description: Utility functions for server and client code.

--\\ Services //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Server specific services
local ServerScriptService = nil

if ( RunService:IsServer() ) then
	ServerScriptService = game:GetService("ServerScriptService")
end

--\\ Modules //--
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Types = Modules.Types

--\\ Types //--
type Module = Types.Module

--\\ Systems //--
local DataSystem: Module = nil

--\\ Module Code //--
local Util = {}

-- Makes a hard copy of a dictionary
function Util:DeepCopy(dictionary: {}): {}
    local copy = {}
    for index, value in pairs(dictionary) do
        if type(value) == "table" then
            value = Util:DeepCopy(value)
        end
        copy[index] = value
    end
    return copy
end

-- Deep freezes tables to make them only readable
function Util:ReadOnly(t)
	local function freeze(tab)
		for key, value in pairs(tab) do
			if type(value) == "table" then
				freeze(value)
			end
		end
		return table.freeze(tab)
	end
	return freeze(t)
end

-- Safely teleports objects and players to inputted location
function Util:SafeTeleport(object: Instance, location: CFrame)
	-- Prohibit continuation without necessary information.
	if not ( object and location ) then
		return
	end

	-- Attempt the teleport
	xpcall(function()
		object:PivotTo(location)
        return true
	end, function(errMessage)
		warn(errMessage)
		return
	end)
end

-- Checks player debounces
function Util:CheckDebounce(player: Player)
	-- Prohibit continuation without necessary information.
	if not ( player ) then return end

	-- Check if this is being run on the server
	if not ( RunService:IsServer() ) then return end

	-- Find DataSystem or setup DataSystem
	if not ( DataSystem ) then
		DataSystem = require(ServerScriptService.Game.Systems.DataSystem)
	end

	-- Check Debounce
	local timeNow: number = workspace:GetServerTimeNow()
	local debounce: number | nil = DataSystem:Get(player, true, "Debounce")
	if not ( debounce ) then return end
	if not ( (timeNow - debounce) > 1 ) then return end
	DataSystem:Set(player, true, "Debounce", timeNow)

	return true
end

return Util