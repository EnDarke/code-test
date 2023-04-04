--!strict

-- Author(s): Voldex Code Test, Alex/EnDarke
-- Description: Handles paycheck machine client-side interacting.

--\\ Services //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--\\ Packages //--
local Packages: Folder = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(Packages.Janitor)

--\\ Modules //--
local Modules: Folder = ReplicatedStorage:WaitForChild("Modules")
local Types: ModuleScript = require(Modules.Types)

--\\ Types //--
type PlayerData = Types.PlayerData
type PaycheckMachine = Types.PaycheckMachine

--\\ Variables //--
local paycheckMachineFolder: Folder = workspace.PaycheckMachines
local paycheckMachines: {PaycheckMachine} = paycheckMachineFolder:GetChildren()

-- Remotes
local Remotes: Folder = ReplicatedStorage:WaitForChild("Remotes")
local RequestPaycheck: RemoteFunction = Remotes.RequestPaycheck
local UpdatePaycheckMachines: RemoteEvent = Remotes.UpdatePaycheckMachines

local debounce = 0

--\\ Module Code //--
local PaycheckMachineHandler = {}
PaycheckMachineHandler.janitor = Janitor.new()

function PaycheckMachineHandler.AddTouchListener(paycheckMachine: Model)
    -- Prohibit continuation without necessary information.
    if not ( paycheckMachine ) then return end

    -- Find pad
    local pad: BasePart = paycheckMachine.PadComponents:FindFirstChild("Pad")
    if not ( pad ) then return end

    PaycheckMachineHandler.janitor:Add(pad.Touched:Connect(function()
        local timeNow = workspace:GetServerTimeNow() -- Save the number, no need to call function again later
        if ( (timeNow - debounce) < 1 ) then
            return false
        end

        -- Tell the server for payout
        RequestPaycheck:InvokeServer()

        debounce = timeNow
    end))
end

function PaycheckMachineHandler.UpdatePaycheckDisplay(paycheckMachine: PaycheckMachine, amount: number): nil
    -- Prohibit continuation without necessary information.
    if not ( paycheckMachine ) then return end

    -- Find Money Label
    local moneyLabel: BasePart = paycheckMachine:FindFirstChild("MoneyLabel", true)
    if not ( moneyLabel ) then return end

    -- Set Money Label's Text
    moneyLabel.Text = amount -- No need to convert to string when setting text
end

-- Initialize module code
function PaycheckMachineHandler.Init()
    local function foreachMachine(funcName: string, ...)
        -- Prohibit continuation without necessary information.
        if not ( funcName ) then return end

        -- Run for loop for paycheck machines.
        for _, paycheckMachine: PaycheckMachine in ipairs(paycheckMachines) do
            -- Run Machine Function
            PaycheckMachineHandler[funcName](paycheckMachine, ...)
        end
    end

    -- Setup listeners for paycheck machine interaction
    foreachMachine("AddTouchListener")

    -- Listen for paycheck machine updates
    PaycheckMachineHandler.janitor:Add(UpdatePaycheckMachines.OnClientEvent:Connect(function(amount: number)
        -- Prohibit continuation without necessary information.
        if not ( amount ) then return end
        foreachMachine("UpdatePaycheckDisplay", amount)
    end))
end

return PaycheckMachineHandler