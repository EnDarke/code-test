--!strict

-- Author: Alex/EnDarke
-- Description: Handles the builder tool on the server.

--\\ Services //--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--\\ Packages //--
local Packages: Folder = ReplicatedStorage.Packages
local Janitor = require(Packages.Janitor)

--\\ Replicated Modules //--
local ReplicatedModules: Folder = ReplicatedStorage.Modules
local Util = require(ReplicatedModules.Util)
local Types = ReplicatedModules.Types

--\\ Types //--
type Module = Types.Module
type ToolGiver = Types.ToolGiver
type NewRandomFunc = Types.NewRandomFunc

--\\ Remotes //--
local Remotes: Folder = ReplicatedStorage.Remotes
local ReplicateBuilds: RemoteEvent = Remotes.ReplicateBuilds
local RequestBuild: RemoteFunction = Remotes.RequestBuild

--\\ Globals //--
local random: NewRandomFunc = Random.new

--\\ Assets //--
local scriptables: Folder = workspace.Scriptables
local plotsFolder: Folder = scriptables.Plots

local assetFolder: Folder = ReplicatedStorage.Assets
local buildables: Folder = assetFolder.Buildables

local serverAssets: Folder = ServerStorage.Assets
local toolFolder: Folder = serverAssets.Tools
local toolVisualsFolder: Folder = toolFolder.Visuals

--\\ Module Code //--
local ToolSystem: Module = {}
ToolSystem._janitor = Janitor.new()

function ToolSystem.ForEachGiver(givers: {}, funcName: string, ...)
    -- Prohibit continuation without necessary information.
    if not ( funcName ) then return end
    if not ( ToolSystem[funcName] ) then return end

    -- Run for loop for paycheck machines.
    for _, pad: ToolGiver in ipairs(givers) do
        -- Run Machine Function
        ToolSystem[funcName](pad, ...)
    end
end

function ToolSystem.RequestBuild(player: Player, position: Vector3)
    -- Prohibit continuation without necessary information.
    if not ( player and position ) then return end

    -- Find random building and send off to clients
    local randomBuilding: number = random():NextInteger(1, #buildables:GetChildren())
    ReplicateBuilds:FireAllClients(position, randomBuilding)
end

function ToolSystem.GiveTool(player: Player, toolName: string)
    -- Prohibit continuation without necessary information.
    if not ( player and toolName ) then return end

    -- Find player character
    local character: CharacterAppearance = player.Character

    -- Check if player already has the tool or not.
    local checkForToolInPlayer = character:FindFirstChild(toolName, true)
    local checkForToolInBackpack = player.Backpack:FindFirstChild(toolName, true)
    if ( checkForToolInPlayer or checkForToolInBackpack ) then return end

    -- Give player tool
    local tool: Tool = toolFolder:FindFirstChild(toolName)
    if not ( tool ) then return end
    tool.Parent = player.Backpack
end

-- Sets up tool giver pad
function ToolSystem.SetupGiver(giver: ToolGiver)
    -- Prohibit continuation without necessary information.
    if not ( giver ) then return end

    -- Find what tool it gives
    local toolName: string = giver:GetAttribute("ToolName")
    if not ( toolName ) then return end

    -- Find giver visual position
    local visualPosition: Attachment = giver:FindFirstChild("VisualPosition", true)
    if not ( visualPosition ) then return end

    -- Setup tool visual
    local toolVisualReference: Model = toolVisualsFolder:FindFirstChild(toolName)
    if not ( toolVisualReference ) then return end
    local toolVisual: Model = toolVisualReference:Clone()
    toolVisual:PivotTo(visualPosition.WorldCFrame)
    toolVisual.Parent = giver

    -- Find touch pad
    local touchPad: BasePart = giver:FindFirstChild("TouchPad", true)
    if not ( touchPad ) then return end

    -- Setup touch signal
    ToolSystem._janitor:Add(touchPad.Touched:Connect(function(hit: Part)
        -- Check to see if it was a player who touched the pad!
        local playerThatTouched: Instance = Players:GetPlayerFromCharacter(hit.Parent)
        if not ( playerThatTouched ) then return end

        -- Check debounce
        local checkDebounce: boolean | nil = Util:CheckDebounce(playerThatTouched)
        if not ( checkDebounce ) then return end

        -- Give player tool!
        ToolSystem.GiveTool(playerThatTouched, toolName)
    end))
end

function ToolSystem.Init()
    -- print("BuilderToolSystem Initiated!")

    -- Listen for build requests
    RequestBuild.OnServerInvoke = ToolSystem.RequestBuild

    -- Run current pads with billboard setups
    ToolSystem.ForEachGiver(plotsFolder:GetDescendants(), "SetupGiver")

    -- Start listening to setup new pads with billboards
    ToolSystem._janitor:Add(plotsFolder.DescendantAdded:Connect(function(descendant: ToolGiver?)
        ToolSystem.SetupGiver(descendant)
    end))
end

return ToolSystem