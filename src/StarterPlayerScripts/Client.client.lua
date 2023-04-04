--!strict

-- Author: Alex/EnDarke
-- Description: Handles client code runtime bootstrapping

local Parent = script.Parent

--\\ Services //--
local Players = game:GetService("Players")

--\\ Handlers //--
local Handlers: Folder = Parent.Handlers
local PaycheckMachineHandler = require(Handlers.PaycheckMachineHandler)
local UserInterfaceHandler = require(Handlers.UserInterfaceHandler)

--\\ Variables //--
local Player: Player = Players.LocalPlayer

function init()
    PaycheckMachineHandler.Init()
    UserInterfaceHandler.Init()
end

-- Wait for player's data to load
local DataLoaded: boolean = Player:GetAttribute("DataLoaded") == true or Player:GetAttributeChangedSignal("DataLoaded"):Wait()

-- Continue with client runtime code
init()