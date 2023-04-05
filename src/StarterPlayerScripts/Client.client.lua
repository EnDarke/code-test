--!strict

-- Author: Alex/EnDarke
-- Description: Handles client code runtime bootstrapping

local Parent = script.Parent

--\\ Services //--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--\\ Handlers //--
local Handlers: Folder = Parent.Handlers

--\\ Modules //--
local Modules = ReplicatedStorage.Modules
local Types = Modules.Types

--\\ Types //--
type Module = Types.Module

--\\ Variables //--
local Player: Player = Players.LocalPlayer

--\\ Client Setup //--
local ClientHandlers: { [string]: Module } = {}

--\\ Client Code //--
function foreachModule(modules: {}, funcName: string, ...)
    for name, module: ModuleScript | Module in pairs(modules) do
        -- Check if the module is already required
        if ( type(module) == "table" ) then
            -- We check for funcName here because it only is used here
            -- return will fully close function so it still only checks once before closing
            if not ( funcName ) then return end
            if not ( ClientHandlers[name] ) then continue end
            if not ( ClientHandlers[name][funcName] ) then continue end

            -- Run module function
            ClientHandlers[name][funcName](...)
        elseif ( module:IsA("ModuleScript") ) then
            -- Setup module
            ClientHandlers[module.Name] = require(module)
            ClientHandlers[module.Name].Init()
        end
    end
end

function init()
    -- Instantiate modules
    foreachModule(Handlers:GetChildren())
end

-- Wait for player's data to load
local DataLoaded: boolean = Player:GetAttribute("DataLoaded") == true or Player:GetAttributeChangedSignal("DataLoaded"):Wait()

-- Continue with client runtime code
init()