--!strict
-- Events Module (Server)


---------- Module ----------

local Module = {}


---------- Instances ----------

local Events = script:WaitForChild("Events")


---------- Module variables ----------

Module.StageSelectQuery_Bindable = Events.StageSelectQuery_Bindable
Module.StageSelected_Bindable = Events.StageSelected_Bindable
Module.StageUnlockQuery_Bindable = Events.StageUnlockQuery_Bindable


---------- Return module ----------

return Module
