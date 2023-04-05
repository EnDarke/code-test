--!strict

-- Author: Alex/EnDarke
-- Description: Handles player's plot loading, unloading, and assigning.

local Parent = script.Parent

--\\ Services //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--\\ Systems //--
local DataSystem = require(Parent.DataSystem)
local PadSystem = require(Parent.PadSystem)
local PaycheckSystem = require(Parent.PaycheckSystem)

--\\ Replicated Modules //--
local ReplicatedModules: Folder = ReplicatedStorage.Modules
local Util = require(ReplicatedModules.Util)
local Types = ReplicatedModules.Types

--\\ Types //--
type Module = Types.Module
type Plot = Types.Plot
type PaycheckMachine = Types.PaycheckMachine
type Pad = Types.Pad

--\\ Assets //--
local scriptables: Folder = workspace.Scriptables
local plotSpawns: Folder = scriptables.PlotSpawns
local plots: Folder = scriptables.Plots

local assetFolder: Folder = ServerStorage.Assets
local plotsFolder: Folder = assetFolder.Plots

local plotTemplate: Model = plotsFolder.PlotTemplate

--\\ Module Code //--
local PlotSystem: Module = {}

-- Used to loop through plots to run a function
function PlotSystem.ForEachPlot(funcName: string, ...): any | nil
    -- Prohibit continuation without necessary information.
    if not ( funcName ) then return end
    if not ( PlotSystem[funcName] ) then return end

    -- Run for loop for paycheck machines.
    for _, plot: Plot in ipairs(plotSpawns:GetChildren()) do
        -- Run Machine Function
        local hasReturn: any | nil = PlotSystem[funcName](plot, ...)
        if ( hasReturn ) then
            return hasReturn
        end
    end
end

-- Gets inputted player's plot
function PlotSystem.FindPlayerPlot(player: Player): string | nil
    -- Prohibit continuation without necessary information.
    if not ( player ) then return end

    -- Find player plot id
    local playerPlotId: string = DataSystem:Get(player, true, "Plot")
    if not ( playerPlotId ) then return end

    return playerPlotId
end

-- Finds the next available plot
function PlotSystem.FindNextAvailablePlot(plot: Plot, player: Player): Plot | nil
    -- Prohibit continuation without necessary information.
    if not ( plot and player ) then return end

    -- Check if plot is available
    if ( plot:GetAttribute("Owner") == "" ) then
        PlotSystem.SetPlotStatus(plot, player)
        return plot
    end
end

-- Sets plot ownership status
function PlotSystem.SetPlotStatus(plot: Plot, player: Player): boolean | nil
    -- Prohibit continuation without necessary information.
    if not ( plot ) then return end

    -- Clear plot ownership
    if ( plot:GetAttribute("Owner") ) then
        plot:SetAttribute("Owner", "")
    end

    -- Set plot to player
    if ( player ) then
        plot:SetAttribute("Owner", player.Name)
        DataSystem:Set(player, true, "Plot", plot.Name)
    end

    return true
end

-- Runs when player is added
function PlotSystem.PlayerAdded(player: Player): nil
    -- Prohibit continuation without necessary information.
    if not ( player ) then return end

    -- Get player's plot
    local playerPlotSpawn: Plot = PlotSystem.ForEachPlot("FindNextAvailablePlot", player)
    if not ( playerPlotSpawn ) then return end

    -- Create plot zone
    local playerPlot: Model = plotTemplate:Clone()
    Util:SafeTeleport(playerPlot, playerPlotSpawn:GetPivot())
    playerPlot.Name = playerPlotSpawn.Name
    playerPlot.Parent = plots

    -- Setup purchase pads
    local playerPads: { Pad } = playerPlot.Pads:GetChildren()
    PadSystem.ForEachPad(playerPads, "SetupPad", player)

    -- Setup paycheck machines
    local playerMachines: { PaycheckMachine } = playerPlot.PaycheckMachines:GetChildren()
    PaycheckSystem.ForEachMachine(playerMachines, "SetupMachine", player)

    -- Find plot spawn
    local plotSpawnPoint: BasePart = playerPlot:FindFirstChild("Spawn", true)
    if not ( plotSpawnPoint ) then return end

    -- Get player character
    local character = player.Character or player.CharacterAppearanceLoaded:Wait()
    if not ( character ) then return end

    -- Wait period to bypass Roblox default spawn positioning
    task.wait(0.1)

    -- Teleport player
    Util:SafeTeleport(character, plotSpawnPoint:GetPivot())
end

-- Initialization for plot system
function PlotSystem.Init(): nil
    -- print("PlotSystem Initiated!")
end

return PlotSystem