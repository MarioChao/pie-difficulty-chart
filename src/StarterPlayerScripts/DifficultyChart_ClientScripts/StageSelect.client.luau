--!strict
-- Stage Select Script


---------- Services ----------

local ReplicatedStorage = game:GetService("ReplicatedStorage")


---------- Imports ----------

local DifficultyChart_SharedStorage = ReplicatedStorage:WaitForChild("DifficultyChart_SharedStorage")
local SharedEvents = require(DifficultyChart_SharedStorage:WaitForChild("Events"))


---------- Instances ----------

local PlayerGui = require(script.Parent:WaitForChild("GetPlayerGui"))
local DifficultyChart_ScreenGui = PlayerGui:WaitForChild("DifficultyChart_ScreenGui")
local StageSelect_Frame = DifficultyChart_ScreenGui:WaitForChild("StageSelect_Frame")

local Previous_TextButton = StageSelect_Frame:WaitForChild("Previous_TextButton")
local Next_TextButton = StageSelect_Frame:WaitForChild("Next_TextButton")
local StageNumber_TextBox = StageSelect_Frame:WaitForChild("StageNumber_TextBox")


---------- Variables ----------

local currentStage = ""
local currentStageNumber = 0


---------- Local functions ----------

local function selectStage(stage: string)
	SharedEvents.StageSelect_Remote:FireServer("Select Stage", stage)
end

local function changeStageBy(delta: number)
	-- currentStageNumber += delta
	selectStage(currentStageNumber + delta)
end

local function initializeUIs()
	-- Set up connections
	Previous_TextButton.MouseButton1Click:Connect(function() changeStageBy(-1) end)
	Next_TextButton.MouseButton1Click:Connect(function() changeStageBy(1) end)
	StageNumber_TextBox.FocusLost:Connect(function(enterPressed: boolean)
		if enterPressed then
			selectStage(StageNumber_TextBox.Text)
		else
			StageNumber_TextBox.Text = currentStage
		end
	end)
end

local function serverSetStage(stage: string, stageNumber: number)
	-- Set stage
	StageNumber_TextBox.Text = stage
	currentStage = stage
	currentStageNumber = stageNumber
end


---------- Event functions ----------

local function onStageSelectClientEvent(mode: string, ...)
	if mode == "Set Stage" then
		serverSetStage(...)
	end
end


---------- Calling / connecting functions ----------

initializeUIs()
SharedEvents.StageSelect_Remote.OnClientEvent:Connect(onStageSelectClientEvent)
