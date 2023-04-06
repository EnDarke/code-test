-- !strict

-- Author: Alex/EnDarke
-- Description: Handles playing sounds on the client.

--\\ Services //--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--\\ Packages //--
local Packages: Folder = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(Packages.Janitor)

--\\ Modules //--
local Modules: Folder = ReplicatedStorage:WaitForChild("Modules")
local Database = require(Modules.Database)
local Types = Modules.Types

local SoundEffects = Database.SoundEffects

--\\ Types //--
type Module = Types.Module
type SoundData = Types.SoundData
type NewInstanceFunc = Types.NewInstanceFunc

--\\ Globals //--
local instance: NewInstanceFunc = Instance.new

--\\ Remotes //--
local Remotes: Folder = ReplicatedStorage:WaitForChild("Remotes")
local PlaySFXFromName: RemoteEvent = Remotes.PlaySFXFromName

--\\ Module Code //--
local SoundHandler: Module = {}
SoundHandler._janitor = Janitor.new()

function SoundHandler.PlaySFXFromName(name: string): nil
    -- Prohibit continuation without necessary information.
    if not ( name ) then return end

    -- Run sound code
    task.spawn(function()
        -- Find sound data
        local soundData: SoundData = SoundEffects[name]
        if not ( soundData ) then return end

        -- Create new sound object
        local soundObj: Sound = instance("Sound")
        soundObj.SoundId = soundData.SoundId
        soundObj.Volume = 0.5 -- Baseline 0.5 is pretty decent default
        soundObj.Parent = script

        -- Play sound object
        soundObj:Play()
        soundObj.Ended:Wait()

        -- Clean up
        soundObj:Destroy()
    end)
end

-- Runs initiation code
function SoundHandler.Init(): nil
    --print("SoundHandler Initiated!")

    -- Start listeners!
    SoundHandler._janitor:Add(PlaySFXFromName.OnClientEvent:Connect(SoundHandler.PlaySFXFromName))
end

return SoundHandler