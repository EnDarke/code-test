--!strict

-- Author(s): Voldex Code Test, Alex/EnDarke
-- Description: Handles paycheck machine client-side interacting.

--\\ Services //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

--\\ Packages //--
local Packages: Folder = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(Packages.Janitor)

--\\ Modules //--
local Modules: Folder = ReplicatedStorage:WaitForChild("Modules")
local Types: ModuleScript = Modules.Types

--\\ Types //--
type PlayerData = Types.PlayerData
type PaycheckMachine = Types.PaycheckMachine

--\\ Remotes //--
local Remotes: Folder = ReplicatedStorage:WaitForChild("Remotes")
local UpdatePaycheckMachines: RemoteEvent = Remotes.UpdatePaycheckMachines
local RequestPlayerData: RemoteFunction = Remotes.RequestPlayerData

--\\ Assets //--
local scriptables: Folder = workspace:WaitForChild("Scriptables")
local plotsFolder: Folder = scriptables.Plots

--\\ Module Code //--
local PaycheckMachineHandler = {}
PaycheckMachineHandler._janitor = Janitor.new()

-- Used to loop through paycheck machines to run a function
function PaycheckMachineHandler.ForEachMachine(paycheckMachines: { PaycheckMachine }, funcName: string, ...): nil
    -- Prohibit continuation without necessary information.
    if not ( funcName ) then return end
    if not ( PaycheckMachineHandler[funcName] ) then return end

    -- Run for loop for paycheck machines.
    for _, paycheckMachine: PaycheckMachine in ipairs(paycheckMachines) do
        -- Run Machine Function
        PaycheckMachineHandler[funcName](paycheckMachine, ...)
    end
end

-- Updates paycheck machine display
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
function PaycheckMachineHandler.Init(): nil
    -- Listen for paycheck machine updates
    PaycheckMachineHandler._janitor:Add(UpdatePaycheckMachines.OnClientEvent:Connect(function(amount: number)
        -- Prohibit continuation without necessary information.
        if not ( amount ) then return end

        -- Find player's plot
        local playerPlotId: string = RequestPlayerData:InvokeServer(true, "Plot")
        if not ( playerPlotId ) then return end
        local playerPlot: Model = plotsFolder:FindFirstChild(playerPlotId)
        if not ( playerPlot ) then return end

        -- Get all paycheck machines
        local paycheckMachines: { PaycheckMachine } = playerPlot.PaycheckMachines:GetChildren()

        -- Update paycheck displays
        PaycheckMachineHandler.ForEachMachine(paycheckMachines, "UpdatePaycheckDisplay", amount)
    end))
end

return PaycheckMachineHandler