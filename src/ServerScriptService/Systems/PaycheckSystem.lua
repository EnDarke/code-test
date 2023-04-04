--!strict

-- Author(s): Voldex Code Test, Alex/EnDarke
-- Description: Handles player paychecks

local Parent = script.Parent

--\\ Services //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--\\ Modules //--
local Modules = ReplicatedStorage.Modules
local Types = require(Modules.Types)

local DataSystem = require(Parent.DataSystem)

--\\ Types //--
type Module = Types.Module

--\\ Variables //--
local Remotes: Folder = ReplicatedStorage.Remotes
local RequestPaycheck: RemoteFunction = Remotes.RequestPaycheck
local RequestCurrentMoney: RemoteFunction = Remotes.RequestCurrentMoney
local UpdatePaycheckMachines: RemoteEvent = Remotes.UpdatePaycheckMachines

local PAYCHECK_UPDATE_INTERVAL = 3
local PAYCHECK_INCREMENTAL_VALUE = 100

--\\ Module Code //--
local PaycheckSystem: Module = {}

function PaycheckSystem.RequestPaycheck(player: Player): boolean | nil
    -- Prohibit continuation without necessary information.
    if not ( player ) then return end

    -- Get player paycheck
    local paycheck: number | nil = DataSystem:Get(player, "PaycheckWithdrawalAmount")
    if not ( paycheck ) then return end

    -- Give player paycheck money
    local givePlayerMoney: boolean | nil = DataSystem:Set(player, "Money", paycheck, true)
    if not ( givePlayerMoney ) then return end

    -- Reset PaycheckWithdrawalAmount
    local resetPaycheck: boolean | nil = DataSystem:Set(player, "PaycheckWithdrawalAmount", 0)
    if not ( resetPaycheck ) then return end

    -- Update remaining Paycheck Machines
    UpdatePaycheckMachines:FireClient(player, DataSystem:Get(player, "PaycheckWithdrawalAmount"))

    return true
end

function PaycheckSystem.RequestCurrentMoney(player: Player): number | nil
    -- Prohibit continuation without necessary information.
    if not ( player ) then return end

    -- Get player current money
    local money: number | nil = DataSystem:Get(player, "Money")
    if not ( money ) then return end

    return money
end

function PaycheckSystem.PlayerAdded(player: Player): boolean | nil
    -- Prohibit continuation without necessary information.
    if not ( player ) then return end

    -- Start player paycheck machines
    task.spawn(function()
        while true do
            DataSystem:Set(player, "PaycheckWithdrawalAmount", PAYCHECK_INCREMENTAL_VALUE, true)
            UpdatePaycheckMachines:FireClient(player, DataSystem:Get(player, "PaycheckWithdrawalAmount"))
            task.wait(PAYCHECK_UPDATE_INTERVAL)
        end
    end)
end

function PaycheckSystem.Init()
    -- Invoke Setup
    RequestPaycheck.OnServerInvoke = PaycheckSystem.RequestPaycheck
    RequestCurrentMoney.OnServerInvoke = PaycheckSystem.RequestCurrentMoney
end

return PaycheckSystem