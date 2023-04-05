--!strict

-- Author(s): Voldex Code Test, Alex/EnDarke
-- Description: Handles UserInterface updating

--\\ Services //--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--\\ Packages //--
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(Packages.Janitor)

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

-- Initialize module code
function UserInterfaceHandler.Init(): nil
    -- Local Functions
    local function setPlayerMoney(amount: number)
        if not ( amount ) then return end
        Label.Text = amount -- Setting text natively converts to string from number
    end

    -- Grab player's current funds
    setPlayerMoney(RequestCurrentMoney:InvokeServer())

    -- UpdateUI Listener
    UserInterfaceHandler._janitor:Add(UpdateUI.OnClientEvent:Connect(function(dataType: string, value: any)
        if not ( dataType and value ) then return end

        if ( dataType == "Money" ) then
            setPlayerMoney(value)
        end
    end))
end

return UserInterfaceHandler