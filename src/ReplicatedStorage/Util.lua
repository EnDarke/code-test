--!strict

-- Author: Alex/EnDarke
-- Description: Utility functions for server and client code.

--\\ Module Code //--
local Util = {}

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

return Util