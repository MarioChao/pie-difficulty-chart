--!strict
-- Stage Select Script

-- Handles selecting stage upon joining and upon client request


---------- Services ----------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


---------- Imports ----------

local DifficultyChart_SharedStorage = ReplicatedStorage.DifficultyChart_SharedStorage
local SharedEvents = require(DifficultyChart_SharedStorage.Events)

local ServerEvents = require(script.Parent.Events)

local StageInfo = require(script.Parent.StageModules.StageInfo)

local Player_Leaderstats = require(script.Parent.Player_Leaderstats)

local Player_Profile = require(script.Parent.Player_Profile)


---------- Local functions ----------

local function movePlayerToPart(player: Player, part: BasePart)
	-- Get and validate character
	local character = player.Character
	if not character then
		return
	end

	-- Move character
	local targetOffsetY = part.Size.Y / 2 + 3
	local targetCFrame = part.CFrame + Vector3.new(0, targetOffsetY, 0)
	character:PivotTo(targetCFrame)
end

local function selectStage(moveToStage: boolean, player: Player, stage: string)
	-- Sanitize input
	stage = `{stage}`

	-- Validate player profile
	local playerProfile = Player_Profile.getPlayerProfile(player)
	if not playerProfile then
		return
	end

	-- Validate stage unlocked for player
	if playerProfile.Data.UnlockedStages[stage] ~= true then
		return
	end

	-- Get and validate stage
	local stageInfo = StageInfo.getInfo(stage)
	if not stageInfo then
		return
	end

	-- Move to stage
	if moveToStage then
		movePlayerToPart(player, stageInfo.StartPart)
	end

	-- Change current stage
	playerProfile.Data.CurrentStage = stage
	task.defer(function()
		Player_Leaderstats.getPlayerLeaderstats(player).Current_Stage.Value = stage
	end)

	-- Change stage on client
	SharedEvents.StageSelect_Remote:FireClient(player, "Set Stage", stage, stageInfo.StageNumber)
end


---------- Event functions ----------

local function onStageSelectServerEvent(player: Player, mode: string, ...)
	if mode == "Select Stage" then
		selectStage(true, player, ...)
	end
end

local function onStageSelectBindableEvent(mode: string, ...)
	if mode == "Select Stage No Move" then
		selectStage(false, ...)
	end
end

local function onPlayerAdded(player: Player)
	-- Sync leaderstats
	task.defer(function()
		Player_Leaderstats.getPlayerLeaderstats(player).Best_Stage.Value = Player_Profile.getPlayerProfile(player).Data.BestStage
	end)

	-- Set current stage
	selectStage(true, player, Player_Profile.getPlayerProfile(player).Data.CurrentStage)
end


---------- Calling / connecting functions ----------

SharedEvents.StageSelect_Remote.OnServerEvent:Connect(onStageSelectServerEvent)
ServerEvents.StageSelect_Bindable.Event:Connect(onStageSelectBindableEvent)

for _, player in Players:GetPlayers() do
	task.defer(onPlayerAdded, player)
end
Players.PlayerAdded:Connect(onPlayerAdded)
