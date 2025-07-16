--!strict
-- Stage Info Module


---------- Module ----------

local Module = {}


---------- Imports ----------

local Stage_Config = require(script.Parent.Stage_Config)


---------- Types ----------

export type StageInfo = {
	StageNumber: number,
	StartPart: BasePart,
}


---------- Instances ----------

local StageStartParts_Folder = workspace._Workspace.StageStartParts_Folder


---------- Variables ----------

local stage_stageInfos: {string: StageInfo} = {}


---------- Local functions ----------

local function getInfo(stage: string)
	return stage_stageInfos[`{stage}`]
end

local function initializeStageInfos()
	for _, object in StageStartParts_Folder:GetChildren() do
		if not object:IsA("BasePart") then
			return
		end

		if stage_stageInfos[object.Name] then
			warn(`Stage {object.Name} has duplicate start parts!`)
		end

		stage_stageInfos[object.Name] = {
			StageNumber = Stage_Config[object.Name].StageNumber,
			StartPart = object,
		}
	end
end


---------- Calling / connecting functions ----------

initializeStageInfos()


---------- Module variables ----------

Module.getInfo = getInfo

table.freeze(stage_stageInfos)
Module.stage_stageInfos = stage_stageInfos


---------- Return module ----------

return Module
