--!strict
-- Get Player Gui Module


---------- Services ----------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")


---------- Instances ----------

local LocalPlayer = Players.LocalPlayer

local PlayerGui: PlayerGui


---------- Local functions  ----------

local function initializeVariables()
	PlayerGui = LocalPlayer.PlayerGui
	while not PlayerGui do
		RunService.Heartbeat:Wait()
		PlayerGui = LocalPlayer.PlayerGui
	end
end


---------- Calling / connecting functions ----------

initializeVariables()


---------- Return result ----------

return PlayerGui
