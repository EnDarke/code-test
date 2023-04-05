--!strict

-- Author: Alex/EnDarke
-- Description: Utility functions for server and client code.

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

return Util