--!strict

-- Author: Alex/EnDarke
-- Description: Handles client code runtime bootstrapping

local Parent = script.Parent

--\\ Handlers //--
local Handlers: Folder = Parent.Handlers
local PaycheckMachineHandler = require(Handlers.PaycheckMachineHandler)

PaycheckMachineHandler.Init()