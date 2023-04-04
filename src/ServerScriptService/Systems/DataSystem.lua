--!strict

-- Author(s): Voldex Code Test, Alex/EnDarke
-- Description: Handles player data loading, saving, and any alterations.

local Parent = script.Parent

--\\ Services //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

--\\ Server Modules //--
local ServerModules = Parent.Modules
local DataFormat = require(ServerModules.DataFormat)

--\\ Replicated Modules //--
local ReplicatedModules = ReplicatedStorage.Modules
local Types = require(ReplicatedModules.Types)
local Util = require(ReplicatedModules.Util)

--\\ Types //--
type Module = Types.Module
type PlayerData = Types.PlayerData

--\\ Variables //--
local PlayerStore: DataStore = DataStoreService:GetDataStore("DEMO_PlayerStore")

local ServerData: {PlayerData} = {}

--\\ Module Code //--
local DataSystem: Module = {}

-- Gets player data
function DataSystem:Get(player: Player): {}
    -- Prohibit continuation without necessary information.
    if not ( player ) then return end

    -- Local Variables
    local userId: number = player.UserId

    -- Get player data
    local playerData: PlayerData = ServerData[userId]
    if not ( playerData ) then return end

    return playerData
end

-- Sets player data type to inputted value
function DataSystem:Set(player: Player, dataType: string, value: any, add: boolean): boolean
    -- Prohibit continuation without necessary information.
    if not ( player and dataType and value ) then return end

    -- Get player data, check for player data.
    local playerData: PlayerData = DataSystem:Get(player)
    if not ( playerData ) then return end
    if not ( playerData[dataType] ) then return end

    -- If you want to add, then set the changed value to the added amount.
    if ( add ) then
        value = playerData[dataType] + value
    end

    -- Set data type
    playerData[dataType] = value

    return true
end

function DataSystem.PlayerAdded(player: Player): boolean | nil
    -- Prohibit continuation without necessary information.
    if not ( player ) then return end

    
end

return DataSystem