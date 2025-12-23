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

local _Modules = script.Parent.Parent.Modules
local BadgeUtil = require(_Modules.BadgeUtil)


---------- Constants ----------

local Constants = {}
Constants.touchDistanceEpsilon = 7

table.freeze(Constants)


---------- Globals ----------

local Globals = {}
Globals.stage_player_touchThrottled = {} :: {[string]: {[Player]: boolean}}


---------- Local functions ----------

local unlockStage
local onStagePartTouched
local onStageUnlockQueryEvent
local setUpStages


----- Unlock -----

unlockStage = function(player: Player, stage: string)
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
		task.defer(function()
			BadgeUtil.awardBadgeLoop(player, stageConfig.AwardBadge.id, stageConfig.AwardBadge.name)
		end)
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
		ServerEvents.StageSelectQuery_Bindable:Fire("Select Stage No Move", player, stage)
	end
end

onStagePartTouched = function(part: BasePart, stage: string, stagePart: BasePart)
	-- Validate player
	local character = part.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not character then return end
	if not player then return end

	-- Validate alive
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then return end
	if humanoid.Health <= 0 then return end

	-- Validate touched part close to stage part
	local partPosition = part.CFrame.Position
	local stagePartPosition = stagePart.CFrame.Position
	local touchDistance = (partPosition - stagePartPosition).Magnitude
	if touchDistance > (part.ExtentsSize.Magnitude + stagePart.ExtentsSize.Magnitude) / 2 + Constants.touchDistanceEpsilon then
		-- print(`[Stage Unlock]: Player {player.UserId} invalid touch detected, stage {previousStage} => {stage}`)
		return
	end

	-- Validate player stage touch throttled
	if not Globals.stage_player_touchThrottled[stage] then
		Globals.stage_player_touchThrottled[stage] = {}
	end
	if Globals.stage_player_touchThrottled[stage][player] then
		return
	end
	Globals.stage_player_touchThrottled[stage][player] = true
	task.delay(0.1, function()
		Globals.stage_player_touchThrottled[stage][player] = nil
	end)

	-- Unlock
	unlockStage(player, stage)
end

onStageUnlockQueryEvent = function(mode: string, ...)
	if mode == "Player Unlock Stage" then
		unlockStage(...)
	end
end


----- Set up -----

setUpStages = function()
	for stage, stageInfo: StageInfo.StageInfo in StageInfo.stage_stageInfos do
		if Stage_Config[stage].Unlock_ByTouch then
			stageInfo.StartPart.Touched:Connect(function(otherPart: BasePart)
				onStagePartTouched(otherPart, stage, stageInfo.StartPart)
			end)
		end
	end
end


----- Main -----

local function main()
	ServerEvents.StageUnlockQuery_Bindable.Event:Connect(onStageUnlockQueryEvent)
	setUpStages()
end


---------- Calling functions ----------

main()
