--!strict
-- Stage Unlock Script

-- Handles unlocking stages when a player touches its start part


---------- Services ----------

local Players = game:GetService("Players")


---------- Imports ----------

local ServerEvents = require(script.Parent.Events)

local Stage_Config = require(script.Parent.StageModules.Stage_Config)
local StageInfo = require(script.Parent.StageModules.StageInfo)

local Player_Leaderstats = require(script.Parent.Player_Leaderstats)

local Player_Profile = require(script.Parent.Player_Profile)

local BadgeAward = require(script.Parent.BadgeAward)


---------- Variables ----------

local TOUCH_DISTANCE_EPSILON = 7


---------- Local functions ----------

local function onStagePartTouched(part: BasePart, stage: string, stagePart: BasePart)
	-- Validate player
	local character = part.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end

	-- Validate alive
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if humanoid.Health <= 0 then return end

	-- Get and validate player profile
	local playerProfile = Player_Profile.getPlayerProfile(player)
	if not playerProfile then return end

	-- Validate stage configs
	local stageConfig = Stage_Config[stage]
	if not stageConfig then
		warn(`[Stage Unlock]: Player {player.UserId}, no config found for stage {stage}!`)
		return
	end

	-- Validate stage info
	local stageInfo = StageInfo.getInfo(stage)
	if not stageInfo then
		warn(`[Stage Unlock]: Player {player.UserId}, no info found for stage {stage}!`)
		return
	end

	-- Get player's previous stage
	local previousStage = playerProfile.Data.CurrentStage

	-- Validate stage info
	local previousStageInfo = StageInfo.getInfo(previousStage)
	if not previousStageInfo then
		warn(`[Stage Unlock]: Player {player.UserId}, no info found for previous stage {previousStage}!`)
		return
	end

	-- Validate different stages
	if previousStage == stage then
		return
	end

	-- Validate touched part close to stage part
	local partPosition = part.CFrame.Position
	local stagePartPosition = stagePart.CFrame.Position
	local touchDistance = (partPosition - stagePartPosition).Magnitude
	if touchDistance > (part.ExtentsSize.Magnitude + stagePart.ExtentsSize.Magnitude) / 2 + TOUCH_DISTANCE_EPSILON then
		-- print(`[Stage Unlock]: Player {player.UserId} invald touch detected, stage {previousStage} => {stage}`)
		return
	end

	print(`[Stage Unlock]: Player {player.UserId}, stage {previousStage} => {stage}`)

	-- Validate required stages
	local requiredStages = stageConfig.RequiredStages
	if not requiredStages then return end
	for _, requiredStage in requiredStages do
		if playerProfile.Data.UnlockedStages[requiredStage] ~= true then
			print(`[Stage Unlock]: Player {player.UserId} stage {stage} unlock failed`)
			return
		end
	end

	-- Unlock stage if not unlocked
	if playerProfile.Data.UnlockedStages[stage] ~= true then
		playerProfile.Data.UnlockedStages[stage] = true
	end

	-- Award badge
	if stageConfig.AwardBadge and previousStage == stageConfig.AwardBadge.fromStage then
		BadgeAward.resolveAwardBadge(player, stageConfig.AwardBadge.id, stageConfig.AwardBadge.name)
	end

	-- Update best stage
	local previousBestStage = playerProfile.Data.BestStage
	local previousBestStage_config = Stage_Config[previousBestStage]
	local previousBestStage_number = previousBestStage_config and previousBestStage_config.StageNumber or 0
	if stageConfig.StageNumber > previousBestStage_number then
		playerProfile.Data.BestStage = stage
		task.defer(function()
			Player_Leaderstats.getPlayerLeaderstats(player)["Stage"].Value = stage
		end)
	end

	-- Select stage if not already
	if playerProfile.Data.CurrentStage ~= stage then
		playerProfile.Data.CurrentStage = stage
		ServerEvents.StageSelect_Bindable:Fire("Select Stage No Move", player, stage)
	end
end

local function setUpStages()
	for stage, stageInfo: StageInfo.StageInfo in StageInfo.stage_stageInfos do
		stageInfo.StartPart.Touched:Connect(function(otherPart: BasePart)
			onStagePartTouched(otherPart, stage, stageInfo.StartPart)
		end)
	end
end


---------- Calling / connecting functions ----------

setUpStages()
