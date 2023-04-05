--!strict

-- Author: Alex/EnDarke
-- Description: Handles pads on the client and any displaying necessary.

--\\ Services //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

--\\ Packages //--
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(Packages.Janitor)

--\\ Modules //--
local Modules = ReplicatedStorage.Modules
local Types = Modules.Types

--\\ Types //--
type Module = Types.Module
type Pad = Types.Pad

--\\ Assets //--
local scriptables: Folder = workspace:WaitForChild("Scriptables")
local plotsFolder: Folder = scriptables.Plots

local assetFolder: Folder = ReplicatedStorage.Assets
local uiAssets: Folder = assetFolder.UI

local padBillboard: BillboardGui = uiAssets:WaitForChild("PadBillboard")

--\\ Module Code //--
local PadHandler: Module = {}
PadHandler._janitor = Janitor.new()

function PadHandler.ForEachPad(pads: { Pad }, funcName: string, ...)
    -- Prohibit continuation without necessary information.
    if not ( funcName ) then return end
    if not ( PadHandler[funcName] ) then return end

    -- Run for loop for paycheck machines.
    for _, pad: Pad in ipairs(pads) do
        -- Run Machine Function
        PadHandler[funcName](pad, ...)
    end
end

function PadHandler.SetupBillboard(pad: Pad)
    -- Prohibit continuation without necessary information.
    if not ( pad ) then return end
    if not ( CollectionService:HasTag(pad, "Pad") ) then return end

    -- Find all labels and set them accordingly via pad attributes
    local newBillboard: BillboardGui = padBillboard:Clone()
    local titleLabel: TextLabel = newBillboard:FindFirstChild("TitleLabel", true)
    local priceLabel: TextLabel = newBillboard:FindFirstChild("Price", true)
    if not ( titleLabel ) then return end
    if not ( priceLabel ) then return end
    titleLabel.Text = pad:GetAttribute("TargetName")
    priceLabel.Text = pad:GetAttribute("Price")

    -- Set billboard to pad
    newBillboard.Parent = pad
end

function PadHandler.Init(): nil
    -- Run current pads with billboard setups
    PadHandler.ForEachPad(plotsFolder:GetDescendants(), "SetupBillboard")

    -- Start listening to setup new pads with billboards
    PadHandler._janitor:Add(plotsFolder.DescendantAdded:Connect(function(descendant: Pad?)
        PadHandler.SetupBillboard(descendant)
    end))
end

return PadHandler