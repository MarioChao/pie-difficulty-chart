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


---------- Local functions ----------

local function onStagePartTouched(part: BasePart, stage: string)
	-- Validate player
	local character = part.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end

	-- Get and validate player profile
	local playerProfile = Player_Profile.getPlayerProfile(player)
	if not playerProfile then return end

	-- Validate stage configs
	local stageConfig = Stage_Config[stage]
	if not stageConfig then
		warn(`No config found for stage {stage}!`)
		return
	end

	-- Validate required stages
	local requiredStages = stageConfig.RequiredStages
	if not requiredStages then return end
	for _, requiredStage in requiredStages do
		if playerProfile.Data.UnlockedStages[requiredStage] ~= true then
			return
		end
	end

	-- Unlock stage if not unlocked
	if playerProfile.Data.UnlockedStages[stage] ~= true then
		playerProfile.Data.UnlockedStages[stage] = true
	end

	-- Award badge
	if stageConfig.AwardBadge then
		BadgeAward.resolveAwardBadge(player, stageConfig.AwardBadge.id, stageConfig.AwardBadge.name)
	end

	-- Update best stage
	local previousBestStage = playerProfile.Data.BestStage
	if stageConfig.StageNumber > StageInfo.getInfo(previousBestStage).StageNumber then
		playerProfile.Data.BestStage = stage
		task.defer(function()
			Player_Leaderstats.getPlayerLeaderstats(player).Best_Stage.Value = stage
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
			onStagePartTouched(otherPart, stage)
		end)
	end
end


---------- Calling / connecting functions ----------

setUpStages()
