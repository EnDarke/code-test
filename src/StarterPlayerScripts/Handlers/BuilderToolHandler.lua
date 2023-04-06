--!strict

-- Author: Alex/EnDarke
-- Description:  Handles builder tool on the client.

--\\ Services //--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--\\ Packages //--
local Packages: Folder = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(Packages.Janitor)

--\\ Modules //--
local Modules: Folder = ReplicatedStorage:WaitForChild("Modules")
local Types = Modules.Types

--\\ Remote //--
local Remotes: Folder = ReplicatedStorage:WaitForChild("Remotes")
local ReplicateBuilds: RemoteEvent = Remotes.ReplicateBuilds
local RequestBuild: RemoteFunction = Remotes.RequestBuild

--\\ Types //--
type Module = Types.Module
type NewInstanceFunc = Types.NewInstanceFunc
type NewVector3Func = Types.NewVector3Func
type NewCFrameFunc = Types.NewCFrameFunc
type NewTweenInfoFunc = Types.NewTweenInfoFunc

--\\ Globals //--
local instance: NewInstanceFunc = Instance.new
local vector3: NewVector3Func = Vector3.new
local cframe: NewCFrameFunc = CFrame.new
local tweenInfo: NewTweenInfoFunc = TweenInfo.new

--\\ Player //--
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

--\\ Assets //--
local scriptables: Folder = workspace:WaitForChild("Scriptables")
local buildingReplication: Folder = scriptables.Buildings

local assetFolder: Folder = ReplicatedStorage:WaitForChild("Assets")
local buildables: Folder = assetFolder.Buildables

--\\ Tweens //--
local numberTweenInfo: TweenInfo = tweenInfo(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

--\\ Local Utility Functions //--
local function calcBuildingPlacement(building: Model, position: Vector3)
    -- Prohibit continuation without necessary information.
    if not ( building and position ) then return end
    local halfBuildingSize: number = building:GetExtentsSize().Y / 2
    return position + vector3(0, halfBuildingSize, 0)
end

--\\ Module Code //--
local BuilderToolHandler: Module = {}
BuilderToolHandler._janitor = Janitor.new()

-- Replicates the building placements for clients
function BuilderToolHandler.ReplicateBuilds(position: Vector3, randomNumber: number): boolean | nil
    -- Prohibit continuation without necessary information.
    if not ( position and randomNumber ) then return end

    -- Find building and place
    local buildingReference: Model = buildables:GetChildren()[randomNumber]
    if not ( buildingReference ) then return end
    local building: Model = buildingReference:Clone()
    if not ( building ) then return end
    building:PivotTo(cframe(calcBuildingPlacement(building, position)))
    building.Parent = buildingReplication

    -- Prep tween
    local newNumberValue: NumberValue = instance("NumberValue")
    newNumberValue.Value = 0

    -- Create and play tween
    local numberTween: Tween = TweenService:Create(newNumberValue, numberTweenInfo, { Value = 1 })
    numberTween:Play()

    -- Listen for number change
    BuilderToolHandler._janitor:Add(newNumberValue.Changed:Connect(function(value: number)
        building:ScaleTo(value)
    end))

    -- Wait for completion and clean up!
    numberTween.Completed:Wait()
    numberTween:Destroy()
    newNumberValue:Destroy()

    return true
end


function BuilderToolHandler.RequestBuild()
    -- Find player character
    local character = Player.Character or Player.CharacterAppearanceLoaded:Wait()
    -- Find tool in player character
    local buildTool: Tool = character:FindFirstChild("BuildTool", true)
    if not ( buildTool and buildTool:IsA("Tool") ) then return end

    -- Get mouse position and start!
    local mousePosition: Vector3 = Mouse.Hit.Position
    RequestBuild:InvokeServer(mousePosition)
end

function BuilderToolHandler.Init()
    -- print("BuilderToolHandler Initiated!")

    -- Add listeners!
    BuilderToolHandler._janitor:Add(Mouse.Button1Down:Connect(BuilderToolHandler.RequestBuild)) -- When computer player clicks, fire this.
    BuilderToolHandler._janitor:Add(ReplicateBuilds.OnClientEvent:Connect(BuilderToolHandler.ReplicateBuilds)) -- When client is told to build object
end

return BuilderToolHandler