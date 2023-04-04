--!strict

-- Author(s): Voldex Code Test, Alex/EnDarke
-- Description: Handles player paychecks

local Parent = script.Parent

--\\ Services //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--\\ Modules //--
local Modules = ReplicatedStorage.Modules
local Types = require(Modules.Types)

local DataSystems = require(Parent.DataSystem)

--\\ Types //--
type Module = Types.Module

--\\ Module Code //--
local PaycheckSystem: Module = {}

function PaycheckSystem.PlayerAdded(player: Player): boolean | nil
    -- Prohibit continuation without necessary information.
    if not ( player ) then return end

    
end

return PaycheckSystem