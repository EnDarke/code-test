--!strict

-- Author(s): Voldex Code Test, Alex/EnDarke
-- Description: Handles UserInterface updating

--\\ Services //--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--\\ Packages //--
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(Packages.Janitor)

--\\ Variables //--
local Player: Player = Players.LocalPlayer
local PlayerGui: PlayerGui = Player.PlayerGui

-- Declaring remotes
local Remotes: Folder = ReplicatedStorage:WaitForChild("Remotes")
local UpdateUI: RemoteEvent = Remotes.UpdateUI
local RequestCurrentMoney: RemoteFunction = Remotes.RequestCurrentMoney

-- Declaring ui
local MoneyGui: ScreenGui = PlayerGui:WaitForChild("MoneyDisplay")
local MoneyFrame: Frame = MoneyGui.MainFrame
local Label: TextLabel = MoneyFrame.Label

--\\ Module Code //--
local UserInterfaceHandler = {}
UserInterfaceHandler.janitor = Janitor.new() -- Added to UserInterfaceHandler in case of use to cleanup janitor from external code

-- Initialize module code
function UserInterfaceHandler.Init()
    -- Local Functions
    local function setPlayerMoney(amount: number)
        if not ( amount ) then return end
        Label.Text = amount -- Setting text natively converts to string from number
    end

    -- Grab player's current funds
    setPlayerMoney(RequestCurrentMoney:InvokeServer())

    -- UpdateUI Listener
    UserInterfaceHandler.janitor:Add(UpdateUI.OnClientEvent:Connect(function(dataType: string, value: any)
        if not ( dataType and value ) then return end

        if ( dataType == "Money" ) then
            setPlayerMoney(value)
        end
    end))
end

return UserInterfaceHandler