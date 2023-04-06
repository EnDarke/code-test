--!strict

-- Author: Alex/EnDarke
-- Description: Holds player data format

--\\ Services //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--\\ Modules //--
local Modules = ReplicatedStorage.Modules
local Util = require(Modules.Util)

return Util:ReadOnly({
    Coins = {
        SoundId = "rbxassetid://631557324",
    },
    Money = {
        SoundId = "rbxassetid://2310331251",
    },
    Build = {
        SoundId = "rbxassetid://13016534712",
    }
})