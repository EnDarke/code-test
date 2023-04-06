--!strict

-- Author(s): Voldex Code Test, Alex/EnDarke
-- Description: Handles player data loading, saving, and any alterations.

local Parent = script.Parent

--\\ Services //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

--\\ Systems //--
local PlotSystem = nil

--\\ Server Modules //--
local ServerModules: Folder = Parent.Parent.Modules
local ServerDatabase = require(ServerModules.ServerDatabase)
local DataFormat = ServerDatabase.DataFormat

--\\ Replicated Modules //--
local ReplicatedModules: Folder = ReplicatedStorage.Modules
local Util = require(ReplicatedModules.Util)
local Types = ReplicatedModules.Types

--\\ Types //--
type Module = Types.Module
type PlayerData = Types.PlayerData
type TemporaryData = Types.TemporaryData
type Plot = Types.Plot

--\\ Remotes //--
local Remotes: Folder = ReplicatedStorage.Remotes
local UpdateUI: RemoteEvent = Remotes.UpdateUI
local RequestPlayerData: RemoteFunction = Remotes.RequestPlayerData

--\\ System Setup //--
local PlayerStore: DataStore = DataStoreService:GetDataStore("Voldex_Code_Test")
local ServerData: { [string]: PlayerData } = {}
local TemporaryData: { [string]: TemporaryData } = {}
local ClientDataSharingWhitelist: { string } = { "Money", "PaycheckWithdrawalAmount" }

--\\ Assets //--
local scriptables: Folder = workspace.Scriptables
local plotSpawns: Folder = scriptables.PlotSpawns
local plotsFolder: Folder = scriptables.Plots

--\\ Local Utility Functions //--
local function createDataKey(userId: number)
    return ("DEMO_%d"):format(userId and userId)
end

--\\ Module Code //--
local DataSystem: Module = {}

-- Gets player data
function DataSystem:Get(player: Player, isTemporaryData: boolean, specific: any): PlayerData | nil
    -- Prohibit continuation without necessary information.
    if not ( player ) then return end
    if not ( player:GetAttribute("DataLoaded") ) then
        player:GetAttributeChangedSignal("DataLoaded"):Wait()
    end

    -- Local Variables
    local userId: number = player.UserId

    -- Get player data | changes what data to pull if it's temporary data or serverdata
    local playerData: PlayerData = isTemporaryData and TemporaryData[userId] or ServerData[userId]
    if not ( playerData ) then return end

    if ( specific ) then
        if not ( playerData[specific] ) then return end
        return playerData[specific]
    end

    return playerData
end

-- Sets player data type to inputted value
function DataSystem:Set(player: Player, isTemporaryData: boolean, dataType: string, value: any, add: boolean, isSound: boolean): boolean | nil
    -- Prohibit continuation without necessary information.
    if not ( player and dataType and value ) then return end
    if not ( player:GetAttribute("DataLoaded") ) then
        player:GetAttributeChangedSignal("DataLoaded"):Wait()
    end

    -- Get player data, check for player data.
    local playerData: PlayerData | TemporaryData = DataSystem:Get(player, isTemporaryData)
    if not ( playerData[dataType] ) then return end

    -- If you want to add, then set the changed value to the added amount.
    if ( add and typeof(value) == "number" ) then
        value = playerData[dataType] + value
    end

    -- Set data type
    playerData[dataType] = value

    -- Let the player know!
    if ( table.find(ClientDataSharingWhitelist, dataType) ) then
        UpdateUI:FireClient(player, dataType, value, isSound)
    end

    return true
end

-- Runs when player is added
function DataSystem.PlayerAdded(player: Player): boolean | nil
    task.spawn(function()
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
            playerData = Util:DeepCopy(DataFormat.Permanent)
        end

        -- Add player's data to server archive
        ServerData[userId] = playerData
        TemporaryData[userId] = Util:DeepCopy(DataFormat.Temporary)

        -- Let player know their data has finished loading
        player:SetAttribute("DataLoaded", true)

        return true
    end)
end

-- Runs when player is removing
function DataSystem.PlayerRemoving(player: Player): boolean | nil
    -- Prohibit continuation without necessary information.
    if not ( player ) then return end
    if not ( player:GetAttribute("DataLoaded") ) then return end

    -- Make sure plot system is there | This is a patch for requiring modules recursively.
    if not ( PlotSystem ) then
        PlotSystem = require(Parent.PlotSystem)
    end

    -- Local Variables
    local userId: number = player.UserId
    local playerData: PlayerData = DataSystem:Get(player, false)
    if not ( playerData ) then return end

    -- Find player plot
    local plotId: string = PlotSystem.FindPlayerPlot(player)
    if not ( plotId ) then return end
    local plot: Plot = plotSpawns:FindFirstChild(plotId)
    if not ( plot ) then return end
    PlotSystem.SetPlotStatus(plot)

    -- Delete physical plot
    local physicalPlot: Model = plotsFolder:FindFirstChild(plotId)
    if not ( physicalPlot ) then return end
    physicalPlot:Destroy()

    -- Save player data
    PlayerStore:UpdateAsync(createDataKey(userId), function(oldData)
        return playerData
    end)
end

function DataSystem.Init(): nil
    -- print("DataSystem Initiated!")
    -- Listen for player requesting data
    RequestPlayerData.OnServerInvoke = function(...)
        return DataSystem:Get(...)
    end
end

return DataSystem