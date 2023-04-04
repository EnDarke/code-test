--!strict

-- Author(s): Voldex Code Test, Alex/EnDarke
-- Description: Handles server code runtime bootstrapping.

local Parent = script.Parent

--\\ Services //--
local Players = game:GetService("Players")

--\\ Systems //--
local Systems: Folder = Parent.Systems
local DataSystem = require(Systems.DataSystem)
local PaycheckSystem = require(Systems.PaycheckSystem)

--\\ Server Code //--
Players.PlayerAdded:Connect(function(player)
    DataSystem.PlayerAdded(player)
    PaycheckSystem.PlayerAdded(player)
end)