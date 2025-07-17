--!strict
-- Stage Config Module


---------- Module ----------

local Module = {}


---------- Types ----------

export type StageConfig = {
	AwardBadge: {
		id: number,
		name: string,
	}?,
	StageNumber: number,
	RequiredStages: {string},
}


---------- Local functions ----------

local function createStageConfig(stageConfig: StageConfig)
	local resultConfig = {
		AwardBadge = nil,
		StageNumber = 0,
		RequiredStages = {},
	}
	for key, value in stageConfig do
		resultConfig[key] = value
	end
	return resultConfig
end

local function setUpNumericalstages()
	Module["0"] = createStageConfig({StageNumber = 0, RequiredStages = {}})
	for i = 1, 352 do
		Module[`{i}`] = createStageConfig({
			StageNumber = i,
			RequiredStages = {`{i - 1}`}
		})
	end
end


---------- Module variables ----------

setUpNumericalstages()


----- Special stages -----

Module["VIP"] = createStageConfig({StageNumber = 0, RequiredStages = {"50"}})


----- Badges -----

-- Badge to be awarded when player reaches a certain stage

Module["11"].AwardBadge = {id = 789814114821364, name = "Easy!"}
Module["21"].AwardBadge = {id = 3253708757579534, name = "Medium!"}
Module["31"].AwardBadge = {id = 2374725864829239, name = "Hard!"}
Module["41"].AwardBadge = {id = 756192758946717, name = "Difficult!"}
Module["51"].AwardBadge = {id = 992528828101604, name = "Challenging!"}
Module["61"].AwardBadge = {id = 3874200696213912, name = "Intense!"}
Module["71"].AwardBadge = {id = 191557371598085, name = "Starkova!"}
Module["81"].AwardBadge = {id = 3185853378607390, name = "Insane!"}
Module["91"].AwardBadge = {id = 3198591324583428, name = "Extreme!"}
Module["101"].AwardBadge = {id = 2225580072230917, name = "Terrifying!"}
Module["111"].AwardBadge = {id = 3259176744654180, name = "Catastrophic!"}


---------- Return module ----------

return Module
