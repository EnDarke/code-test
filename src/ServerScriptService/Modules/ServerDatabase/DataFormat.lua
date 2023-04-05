--!strict

-- Author: Alex/EnDarke
-- Description: Holds player data format

--\\ Services //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--\\ Modules //--
local Modules = ReplicatedStorage.Modules
local Util = require(Modules.Util)

return Util:ReadOnly({
    Permanent = {
        Money = 0,
        PaycheckWithdrawalAmount = 0,
        PadsPurchased = {},
    },
    Temporary = {
        Plot = 0,
        Debounce = 0,
    },
})