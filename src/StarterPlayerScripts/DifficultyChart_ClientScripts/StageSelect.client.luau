--!strict
-- Stage Select Script


---------- Services ----------

local ContextActionService = game:GetService("ContextActionService")
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
local CurrentStage_TextButton = StageSelect_Frame:WaitForChild("CurrentStage_TextButton")
local StageInput_TextBox = StageSelect_Frame:WaitForChild("StageInput_TextBox")


---------- Variables ----------

local currentStage = ""

local action_actionName = {
	Retry = "StageSelect: Retry",
}


---------- Local functions ----------

local function selectStage(stage: string)
	SharedEvents.StageSelect_Remote:FireServer("Select Stage", stage)
end

local function changeStageBy(delta: number)
	SharedEvents.StageSelect_Remote:FireServer("Change Stage By", delta)
end

local function serverSetStage(stage: string, stageNumber: number)
	-- Clear input if same
	if StageInput_TextBox.Text == stage then
		StageInput_TextBox.Text = ""
	end

	-- Set stage
	CurrentStage_TextButton.Text = stage
	currentStage = stage
end

local function initializeUIs()
	-- Set up connections
	Previous_TextButton.MouseButton1Click:Connect(function() changeStageBy(-1) end)
	Next_TextButton.MouseButton1Click:Connect(function() changeStageBy(1) end)
	CurrentStage_TextButton.MouseButton1Click:Connect(function() selectStage(currentStage) end)
	StageInput_TextBox.FocusLost:Connect(function(enterPressed: boolean)
		if enterPressed then
			selectStage(StageInput_TextBox.Text)
		end
	end)
end


---------- Action functions ----------

local function handleAction(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
	local isBeginState = (inputState == Enum.UserInputState.Begin)
	local isCancelOrEndState = (inputState == Enum.UserInputState.Cancel) or (inputState == Enum.UserInputState.End)

	task.defer(function()
		if actionName == action_actionName.Retry then
			-- Retry / restart stage
			if isBeginState then
				selectStage(currentStage)
			end
		end
	end)
end

local function setKeybinds()
	ContextActionService:BindAction(action_actionName.Retry, handleAction, false, Enum.KeyCode.R)
end


---------- Event functions ----------

local function onStageSelectClientEvent(mode: string, ...)
	if mode == "Set Stage" then
		serverSetStage(...)
	elseif mode == "Select Fail" then
		-- Do nothing
	end
end


---------- Calling / connecting functions ----------

task.defer(initializeUIs)
task.defer(setKeybinds)

SharedEvents.StageSelect_Remote.OnClientEvent:Connect(onStageSelectClientEvent)
