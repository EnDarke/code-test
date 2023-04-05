--!strict

-- Author(s): Voldex Code Test, Alex/EnDarke
-- Description: Handles UserInterface updating

local Parent = script.Parent

--\\ Services //--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--\\ Packages //--
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(Packages.Janitor)

--\\ Handlers //--
local PaycheckMachineHandler: ModuleScript = require(Parent.PaycheckMachineHandler)

--\\ Player //--
local Player: Player = Players.LocalPlayer
local PlayerGui: PlayerGui = Player.PlayerGui

--\\ Remotes //--
local Remotes: Folder = ReplicatedStorage:WaitForChild("Remotes")
local UpdateUI: RemoteEvent = Remotes.UpdateUI
local RequestCurrentMoney: RemoteFunction = Remotes.RequestCurrentMoney

--\\ User Interface //--
local MoneyGui: ScreenGui = PlayerGui:WaitForChild("MoneyDisplay")
local MoneyFrame: Frame = MoneyGui.MainFrame
local Label: TextLabel = MoneyFrame.Label

--\\ Module Code //--
local UserInterfaceHandler = {}
UserInterfaceHandler._janitor = Janitor.new()

-- Updates paycheck withdrawal amount
function UserInterfaceHandler.PaycheckWithdrawalAmount(amount: number)
    -- Prohibit continuation without necessary information.
    if not ( amount ) then return end
    PaycheckMachineHandler.OnUpdateUIEvent(amount)
end

function UserInterfaceHandler.Money(amount: number)
    -- Prohibit continuation without necessary information.
    if not ( amount ) then return end
    Label.Text = amount
end

-- Initialize module code
function UserInterfaceHandler.Init(): nil
    -- print("UserInterfaceHandler Initiated!")

    -- Grab player's current funds
    UserInterfaceHandler.Money(RequestCurrentMoney:InvokeServer())

    -- UpdateUI Listener
    UserInterfaceHandler._janitor:Add(UpdateUI.OnClientEvent:Connect(function(dataType: string, ...)
        if not ( dataType and ... ) then return end
        UserInterfaceHandler[dataType](...)
    end))
end

return UserInterfaceHandler