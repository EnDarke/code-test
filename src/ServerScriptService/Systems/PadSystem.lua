--!strict

-- Author(s): Voldex Code Test, Alex/EnDarke
-- Description: Handles all pad functionality and interactions.

local Parent = script.Parent

--\\ Services //--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--\\ Packages //--
local Packages: Folder = ReplicatedStorage.Packages
local Janitor = require(Packages.Janitor)

--\\ Systems //--
local DataSystem = require(Parent.DataSystem)
local PlotSystem = nil

--\\ Replicated Modules //--
local ReplicatedModules: Folder = ReplicatedStorage.Modules
local Util = require(ReplicatedModules.Util)
local Types = ReplicatedModules.Types

--\\ Types //--
type Module = Types.Module
type PlayerData = Types.PlayerData
type Plot = Types.Plot
type Pad = Types.Pad

--\\ Assets //--
local scriptables: Folder = workspace.Scriptables
local plotsFolder: Folder = scriptables.Plots

local serverAssets: Folder = ServerStorage.Assets
local buildingsFolder: Folder = serverAssets.Buildings

--\\ Module Code //--
local PadSystem: Module = {}
PadSystem._janitor = Janitor.new()

-- Used to loop through pads to run a function
function PadSystem.ForEachPad(pads: { Pad }, funcName: string, ...): nil
    -- Prohibit continuation without necessary information.
    if not ( funcName ) then return end
    if not ( PadSystem[funcName] ) then return end

    -- Run for loop for paycheck machines.
    for _, pad: Pad in ipairs(pads) do
        -- Run Machine Function
        PadSystem[funcName](pad, ...)
    end
end

function PadSystem.CheckIfPlayerOwnsPad(player: Player, pad: Pad, nextPad: Pad)
    -- Prohibit continuation without necessary information.
    if not ( player and pad ) then return end

    -- Find player pad data
    local padData: {} = DataSystem:Get(player, false, "PadsPurchased")
    if not ( padData ) then return end

    -- Check if pad is within purchased pads data
    if ( table.find(padData, pad.Name) ) then
        -- Force purchase the pad
        PadSystem.OnPadPurchase(player, pad, pad:GetAttribute("TargetName"))

        -- Setting dependent finished on next pad
        nextPad:SetAttribute("DependentFinished", true)

        return true
    end
end

-- Runs when player purchases a pad or force loads a pad
function PadSystem.OnPadPurchase(player: Player, pad: Pad, targetName: string): boolean | nil
    -- Prohibit continuation without necessary information.
    if not ( player and pad and targetName ) then return end

    -- Protection from recursive module loading error
    if not ( PlotSystem ) then
        PlotSystem = require(Parent.PlotSystem)
    end

    -- Find player's plot!
    local plotId: string = PlotSystem.FindPlayerPlot(player)
    if not ( plotId ) then return end
    local playerPlot: Model = plotsFolder:FindFirstChild(plotId)
    if not ( playerPlot ) then return end

    -- Get building position!
    local buildingAttachment: Attachment = pad:FindFirstChild("BuildingPosition", true)
    if not ( buildingAttachment ) then return end
    local buildingCFrame: CFrame = buildingAttachment.WorldCFrame

    -- Spawn building!
    local buildingReference: Instance = buildingsFolder:FindFirstChild(targetName, true)
    local building: Instance = buildingReference and buildingReference:Clone()
    Util:SafeTeleport(building, buildingCFrame)
    building.Parent = playerPlot.Buildings

    -- Delete pad
    pad:Destroy()
end

function PadSystem.SetupPad(pad: Pad, player: Player): nil
    -- Prohibit continuation without necessary information.
    if not ( pad and player ) then return end

    -- Check attributes
    local isEnabled: boolean = pad:GetAttribute("isEnabled")
    local isFinished: boolean = pad:GetAttribute("isFinished")
    local price: number = pad:GetAttribute("Price")
    local targetName: string = pad:GetAttribute("TargetName")
    if not ( isEnabled and price and targetName ) and isFinished then return end

    -- Find dependency
    local dependenctObject: ObjectValue = pad:FindFirstChild("Dependency")
    if not ( dependenctObject ) then return end
    local dependency: Pad = dependenctObject.Value
    if not ( dependency ) then return end

    -- Find next pad
    local nextObject: ObjectValue = pad:FindFirstChild("Next")
    if not ( nextObject ) then return end
    local nextPad: Pad = nextObject.Value
    if not ( nextPad ) then return end

    -- Find touch pad
    local touchPad: BasePart = pad:FindFirstChild("Pad")
    if not ( touchPad ) then return end

    -- Check if player already owns pad
    if ( PadSystem.CheckIfPlayerOwnsPad(player, pad, nextPad) ) then return end

    -- Add listener
    PadSystem._janitor:Add(touchPad.Touched:Connect(function(hit: Part)
        -- Check to see if it was a player who touched the pad!
        local playerThatTouched: Instance = Players:GetPlayerFromCharacter(hit.Parent)
        if not ( playerThatTouched ) then return end

        -- Check if the player was the owner
        if not ( playerThatTouched == player ) then return end

        -- Check Debounce
        local timeNow: number = workspace:GetServerTimeNow()
        local debounce: number | nil = DataSystem:Get(player, true, "Debounce")
        if not ( debounce ) then return end
        if not ( (timeNow - debounce) > 1 ) then return end
        DataSystem:Set(player, true, "Debounce", timeNow)

        -- Check to see if previous button was completed!
        if not ( dependency == pad ) then
            if not ( pad:GetAttribute("DependentFinished") ) then return end
        end

        -- Check for player's funds and if it's enough!
        local playerMoney: number = DataSystem:Get(player, false, "Money")
        if not ( playerMoney ) then return end
        if not ( playerMoney > price ) then return end

        -- Spawn buildings in!
        PadSystem.OnPadPurchase(player, pad, targetName)

        -- Take player's money!
        DataSystem:Set(player, false, "Money", -price, true)

        -- Save pads
        local padData: {} = DataSystem:Get(player, false, "PadsPurchased")
        if not ( padData ) then return end
        table.insert(padData, pad.Name)

        -- Setting dependent finished on next pad
        nextPad:SetAttribute("DependentFinished", true)
    end))
end

function PadSystem.Init(): nil
    -- print("PadSystem Initiated!")
end

return PadSystem