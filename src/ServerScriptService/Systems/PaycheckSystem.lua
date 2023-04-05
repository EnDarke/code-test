--!strict

-- Author(s): Voldex Code Test, Alex/EnDarke
-- Description: Handles player paychecks

local Parent = script.Parent

--\\ Services //--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

--\\ Packages //--
local Packages: Folder = ReplicatedStorage.Packages
local Janitor = require(Packages.Janitor)

--\\ Systems //--
local DataSystem = require(Parent.DataSystem)

--\\ Replicated Modules //--
local ReplicatedModules: Folder = ReplicatedStorage.Modules
local Types = ReplicatedModules.Types

--\\ Types //--
type Module = Types.Module
type PaycheckMachine = Types.PaycheckMachine
type Pad = Types.Pad

--\\ Remotes //--
local Remotes: Folder = ReplicatedStorage.Remotes
local RequestCurrentMoney: RemoteFunction = Remotes.RequestCurrentMoney
local UpdatePaycheckMachines: RemoteEvent = Remotes.UpdatePaycheckMachines

--\\ Constants //--
local PAYCHECK_UPDATE_INTERVAL = 3
local PAYCHECK_INCREMENTAL_VALUE = 100

--\\ Module Code //--
local PaycheckSystem: Module = {}
PaycheckSystem._janitor = Janitor.new()

-- Used to loop through paycheck machines to run a function
function PaycheckSystem.ForEachMachine(paycheckMachines: { Pad }, funcName: string, ...): nil
    -- Prohibit continuation without necessary information.
    if not ( funcName ) then return end
    if not ( PaycheckSystem[funcName] ) then return end

    -- Run for loop for paycheck machines.
    for _, paycheckMachine: PaycheckMachine in ipairs(paycheckMachines) do
        -- Run Machine Function
        PaycheckSystem[funcName](paycheckMachine, ...)
    end
end

-- Requests to give player paycheck from machine
function PaycheckSystem.RequestPaycheck(player: Player): boolean | nil
    -- Prohibit continuation without necessary information.
    if not ( player ) then return end

    -- Get player paycheck
    local paycheck: number | nil = DataSystem:Get(player, false, "PaycheckWithdrawalAmount")
    if not ( paycheck ) then return end

    -- Give player paycheck money
    local givePlayerMoney: boolean | nil = DataSystem:Set(player, false, "Money", paycheck, true)
    if not ( givePlayerMoney ) then return end

    -- Reset PaycheckWithdrawalAmount
    local resetPaycheck: boolean | nil = DataSystem:Set(player, false, "PaycheckWithdrawalAmount", 0)
    if not ( resetPaycheck ) then return end

    -- Update remaining Paycheck Machines
    UpdatePaycheckMachines:FireClient(player, DataSystem:Get(player, false, "PaycheckWithdrawalAmount"))

    return true
end

-- Requests player's current money
function PaycheckSystem.RequestCurrentMoney(player: Player): number | nil
    -- Prohibit continuation without necessary information.
    if not ( player ) then return end

    -- Get player current money
    local money: number | nil = DataSystem:Get(player, false, "Money")
    if not ( money ) then return end

    return money
end

-- Adds a touch listener to inputted paycheck machine
function PaycheckSystem.SetupMachine(paycheckMachine: Model, player: Player): nil
    -- Prohibit continuation without necessary information.
    if not ( paycheckMachine and player ) then return end

    -- Find pad
    local touchPad: BasePart = paycheckMachine.PadComponents:FindFirstChild("Pad")
    if not ( touchPad ) then return end

    -- Add touched event to machine pad
    PaycheckSystem._janitor:Add(touchPad.Touched:Connect(function(hit: Part)
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

        -- Give player payout
        PaycheckSystem.RequestPaycheck(player)
    end))
end

-- Runs when player is added
function PaycheckSystem.PlayerAdded(player: Player): boolean | nil
    -- Prohibit continuation without necessary information.
    if not ( player ) then return end

    -- Start player paycheck machines
    task.spawn(function()
        while true do
            task.wait(PAYCHECK_UPDATE_INTERVAL)
            DataSystem:Set(player, false, "PaycheckWithdrawalAmount", PAYCHECK_INCREMENTAL_VALUE, true)
            UpdatePaycheckMachines:FireClient(player, DataSystem:Get(player, false, "PaycheckWithdrawalAmount"))
        end
    end)
end

function PaycheckSystem.Init(): nil
    -- print("PaycheckSystem Initiated!")
    -- Invoke Setup
    RequestCurrentMoney.OnServerInvoke = PaycheckSystem.RequestCurrentMoney
end

return PaycheckSystem