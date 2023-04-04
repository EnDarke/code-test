--!strict

-- Author(s): Voldex Code Test, Alex/EnDarke
-- Description: Handles player data loading, saving, and any alterations.

local Parent = script.Parent

--\\ Services //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

--\\ Server Modules //--
local ServerModules = Parent.Parent.Modules
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

local Remotes: Folder = ReplicatedStorage.Remotes
local UpdateUI: RemoteEvent = Remotes.UpdateUI

local ServerData: {PlayerData} = {}

local function createDataKey(userId: number)
    return ("DEMO_%d"):format(userId and userId)
end

--\\ Module Code //--
local DataSystem: Module = {}

-- Gets player data
function DataSystem:Get(player: Player, specific: any): PlayerData | nil
    -- Prohibit continuation without necessary information.
    if not ( player ) then return end

    -- Local Variables
    local userId: number = player.UserId

    -- Get player data
    local playerData: PlayerData = ServerData[userId]
    if not ( playerData ) then return end

    if ( specific ) then
        if not ( playerData[specific] ) then return end
        return playerData[specific]
    end

    return playerData
end

-- Sets player data type to inputted value
function DataSystem:Set(player: Player, dataType: string, value: any, add: boolean): boolean | nil
    -- Prohibit continuation without necessary information.
    if not ( player and dataType and value ) then return end

    -- Get player data, check for player data.
    local playerData: PlayerData = DataSystem:Get(player)
    if not ( playerData[dataType] ) then return end

    -- If you want to add, then set the changed value to the added amount.
    if ( add and typeof(value) == "number" ) then
        value = playerData[dataType] + value
    end

    -- Set data type
    playerData[dataType] = value

    -- Let player know!
    UpdateUI:FireClient(player, dataType, value)

    return true
end

function DataSystem.PlayerAdded(player: Player): boolean | nil
    -- Prohibit continuation without necessary information.
    if not ( player ) then return end

    -- Local Variables
    local userId: number = player.UserId
    local playerData: PlayerData = nil

    -- Find player data!
    PlayerStore:UpdateAsync(createDataKey(userId), function(oldData)
        playerData = oldData
    end)

    -- New player? Give them new data!
    if not ( playerData ) then
        playerData = Util:DeepCopy(DataFormat)
    end

    -- Add player's data to server archive
    ServerData[userId] = playerData

    -- Let player know their data has finished loading
    player:SetAttribute("DataLoaded", true)

    return true
end

function DataSystem.PlayerRemoved(player: Player): boolean | nil
    -- Prohibit continuation without necessary information.
    if not ( player ) then return end

    -- Local Variables
    local userId: number = player.UserId
    local playerData: PlayerData = DataSystem:Get(player)
    if not ( playerData ) then return end

    -- Save player data
    PlayerStore:UpdateAsync(createDataKey(userId), function(oldData)
        return playerData
    end)
end

return DataSystem