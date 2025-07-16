--!strict
-- Player Leaderstats Module


---------- Module ----------

local Module = {}


---------- Services ----------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")


---------- Instances ----------

local DefaultLeaderstats = script.leaderstats


---------- Variables ----------

local player_leaderstatsFolder: {[Player]: typeof(DefaultLeaderstats)} = {}


---------- Local functions ----------

local function getPlayerLeaderstats(player: Player, timeout: number?): typeof(DefaultLeaderstats)
	timeout = timeout or 5

	local leaderstatsFolder = player_leaderstatsFolder[player]
	local startTime = time()

	while not leaderstatsFolder do
		-- Wait
		RunService.Heartbeat:Wait()

		-- Check timeout
		if time() - startTime > timeout then
			print(`Leaderstats for user {player.UserId} not found.`)
			break
		end

		-- Get leaderstats
		leaderstatsFolder = player_leaderstatsFolder[player]
	end

	return leaderstatsFolder
end


---------- Set up functions ----------

local function setUpLeaderstats(player: Player)
	-- Get leaderstats folder
	local leaderstatsFolder = player:FindFirstChild("leaderstats")
	if not leaderstatsFolder then
		leaderstatsFolder = DefaultLeaderstats:Clone()
		leaderstatsFolder.Parent = player
	end

	-- Set up leaderstats folder
	for _, object in DefaultLeaderstats:GetChildren() do
		if leaderstatsFolder:FindFirstChild(object.Name) then
			continue
		end
		local newObject = object:Clone()
		newObject.Parent = leaderstatsFolder
	end

	-- Store folder
	if player.Parent == Players then
		player_leaderstatsFolder[player] = leaderstatsFolder
	end
end


---------- Event functions ----------

local function onPlayerAdded(player: Player)
	setUpLeaderstats(player)
end


---------- Calling / connecting functions ----------

for _, player in Players:GetPlayers() do
   task.defer(onPlayerAdded, player)
end

Players.PlayerAdded:Connect(onPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	player_leaderstatsFolder[player] = nil
end)


---------- Module variables ----------

Module.getPlayerLeaderstats = getPlayerLeaderstats


---------- Return module ----------

return Module
