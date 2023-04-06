--!strict

-- Author(s): Voldex Code Test, Alex/EnDarke
-- Description: Handles server code runtime bootstrapping.

local Parent = script.Parent

--\\ Services //--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--\\ Systems //--
local Systems: Folder = Parent.Systems

--\\ Replicated Modules //--
local ReplicatedModules = ReplicatedStorage.Modules
local Types = ReplicatedModules.Types

--\\ Types //--
type Module = Types.Module

--\\ Server Setup //--
local ServerSystems: { [string]: Module } = {}

--\\ Server Code //--
function foreachModule(modules: {}, funcName: string, ...)
    for name, module: ModuleScript | Module in pairs(modules) do
        -- Check if the module is already required
        if ( type(module) == "table" ) then
            -- We check for funcName here because it only is used here
            -- return will fully close function so it still only checks once before closing
            if not ( funcName ) then return end
            if not ( ServerSystems[name] ) then continue end
            if not ( ServerSystems[name][funcName] ) then continue end

            -- Run module function
            if ( funcName == "PlayerAdded" ) then -- Filter player added so we can run task.spawns. This way player data can load the game without issue.
                local tuple = ...
                task.spawn(function()
                    ServerSystems[name][funcName](tuple)
                end)
            else
                ServerSystems[name][funcName](...)
            end
        elseif ( module:IsA("ModuleScript") ) then
            -- Setup module
            ServerSystems[module.Name] = require(module)
            ServerSystems[module.Name].Init()
        end
    end
end

function init()
    -- Instantiate modules
    foreachModule(Systems:GetChildren())

    -- Apply player listeners
    for _, player: Player in ipairs(Players:GetPlayers()) do
        foreachModule(ServerSystems, "PlayerAdded", player)
    end
    Players.PlayerAdded:Connect(function(player: Player)
        foreachModule(ServerSystems, "PlayerAdded", player)
    end)
    Players.PlayerRemoving:Connect(function(player: Player)
        foreachModule(ServerSystems, "PlayerRemoving", player)
    end)
end

init()