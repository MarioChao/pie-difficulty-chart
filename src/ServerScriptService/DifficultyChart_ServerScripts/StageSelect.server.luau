--!strict
-- Stage Select Script

-- Handles selecting stage upon joining and upon client request


---------- Services ----------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")


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
		return false
	end

	-- Validate stage unlocked for player
	if playerProfile.Data.UnlockedStages[stage] ~= true then
		return false
	end

	-- Get and validate stage
	local stageInfo = StageInfo.getInfo(stage)
	if not stageInfo then
		return false
	end

	-- Move to stage
	if moveToStage then
		movePlayerToPart(player, stageInfo.StartPart)
	end

	-- Change current stage
	playerProfile.Data.CurrentStage = stage

	-- Change stage on client
	SharedEvents.StageSelect_Remote:FireClient(player, "Set Stage", stage, stageInfo.StageNumber)

	-- Return success
	return true
end

local function changeStageBy(player: Player, delta: number?)
	-- Sanitize input
	delta = tonumber(delta)

	-- Validate input
	if not delta then
		return false
	end

	-- Validate player profile
	local playerProfile = Player_Profile.getPlayerProfile(player)
	if not playerProfile then
		return false
	end

	-- Get player's current stage
	local currentStage = playerProfile.Data.CurrentStage

	-- Validate stage info
	local currentStageInfo = StageInfo.getInfo(currentStage)
	if not currentStageInfo then
		return false
	end

	-- Select stage
	selectStage(true, player, tostring(currentStageInfo.StageNumber + delta))

	return true
end


---------- Event functions ----------

local function onStageSelectServerEvent(player: Player, mode: string, ...)
	if mode == "Select Stage" then
		local success = selectStage(true, player, ...)
		if not success then
			SharedEvents.StageSelect_Remote:FireClient(player, "Select Fail")
		end
	elseif mode == "Change Stage By" then
		local success = changeStageBy(player, ...)
		if not success then
			SharedEvents.StageSelect_Remote:FireClient(player, "Select Fail")
		end
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
		Player_Leaderstats.getPlayerLeaderstats(player)["Stage"].Value = Player_Profile.getPlayerProfile(player).Data.BestStage
	end)

	-- Set current stage
	selectStage(true, player, Player_Profile.getPlayerProfile(player).Data.CurrentStage)

	-- Respawn at current stage
	player.CharacterAdded:Connect(function(character: Model)
		RunService.Heartbeat:Wait()
		selectStage(true, player, Player_Profile.getPlayerProfile(player).Data.CurrentStage)
	end)
end


---------- Calling / connecting functions ----------

SharedEvents.StageSelect_Remote.OnServerEvent:Connect(onStageSelectServerEvent)
ServerEvents.StageSelect_Bindable.Event:Connect(onStageSelectBindableEvent)

for _, player in Players:GetPlayers() do
	task.defer(onPlayerAdded, player)
end
Players.PlayerAdded:Connect(onPlayerAdded)
