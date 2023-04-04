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
type PaycheckMachine = Types.PaycheckMachine

--\\ Variables //--
local paycheckMachineFolder: Folder = workspace.PaycheckMachines
local paycheckMachines: {PaycheckMachine} = paycheckMachineFolder:GetChildren()

-- Remotes
local Remotes: Folder = ReplicatedStorage:WaitForChild("Remotes")
local RequestPaycheck: RemoteFunction = Remotes.RequestPaycheck

local janitor: typeof(Janitor) = Janitor.new()

local debounce = 0

--\\ Module Code //--
local PaycheckMachineHandler = {}

local function addTouchListener(pad: BasePart)
    -- Prohibit continuation without necessary information.
    if not ( pad ) then return end

    janitor:Add(pad.Touched:Connect(function()
        local timeNow = workspace:GetServerTimeNow() -- Save the number, no need to call function again later
        if ( (timeNow - debounce) < 1 ) then
            return false
        end
        print("BRUV")
        debounce = timeNow
    end))
end

local function addAttributeListener(moneyDisplay: BasePart)
    -- Prohibit continuation without necessary information.
    if not ( moneyDisplay ) then return end

    janitor:Add(moneyDisplay:GetAttributeChangedSignal("Amount"):Connect(function()
        local amount: number = moneyDisplay:GetAttribute("Amount")
        local moneyLabel: TextLabel = moneyDisplay:FindFirstChild("MoneyLabel", true)
        moneyLabel.Text = amount -- No need to convert to string when setting text
    end))
end

function PaycheckMachineHandler.Init()
    for _, paycheckMachine in ipairs(paycheckMachines) do
        local pad: BasePart = paycheckMachine.PadComponents:FindFirstChild("Pad")
        local MoneyInfo: BasePart = paycheckMachine:FindFirstChild("Money_Info_Text")
        if not ( pad and MoneyInfo ) then return end

        addTouchListener(pad)
        addAttributeListener(MoneyInfo)
    end
end

return PaycheckMachineHandler