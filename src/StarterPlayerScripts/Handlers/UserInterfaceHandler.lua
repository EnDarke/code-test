--!strict

-- Author(s): Voldex Code Test, Alex/EnDarke
-- Description: Handles UserInterface updating

local Parent = script.Parent

--\\ Services //--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--\\ Packages //--
local Packages: Folder = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(Packages.Janitor)

--\\ Handlers //--
local PaycheckMachineHandler: ModuleScript = require(Parent.PaycheckMachineHandler)
local SoundHandler: ModuleScript = require(Parent.SoundHandler)

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

function UserInterfaceHandler.RunSFX(isSound: boolean, sound: string): nil
    -- Prohibit continuation without necessary information.
    if not ( isSound and sound ) then return end
    SoundHandler.PlaySFXFromName(sound)
end

-- Updates paycheck withdrawal amount
function UserInterfaceHandler.PaycheckWithdrawalAmount(amount: number, isSound: boolean): nil
    -- Prohibit continuation without necessary information.
    if not ( amount ) then return end
    PaycheckMachineHandler.OnUpdateUIEvent(amount)

    -- Play SFX
    UserInterfaceHandler.RunSFX(isSound, "Money")
end

function UserInterfaceHandler.Money(amount: number, isSound: boolean): nil
    -- Prohibit continuation without necessary information.
    if not ( amount ) then return end
    Label.Text = amount

    -- Play SFX
    UserInterfaceHandler.RunSFX(isSound, "Coins")
end

-- Initialize module code
function UserInterfaceHandler.Init(): nil
    --print("UserInterfaceHandler Initiated!")

    -- Grab player's current funds
    UserInterfaceHandler.Money(RequestCurrentMoney:InvokeServer())

    -- UpdateUI Listener
    UserInterfaceHandler._janitor:Add(UpdateUI.OnClientEvent:Connect(function(dataType: string, ...)
        if not ( dataType and ... ) then return end
        UserInterfaceHandler[dataType](...)
    end))
end

return UserInterfaceHandler