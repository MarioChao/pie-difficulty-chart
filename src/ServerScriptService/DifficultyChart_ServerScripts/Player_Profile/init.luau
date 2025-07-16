--!strict
-- Player Profile Module


---------- Module ----------

local Module = {}


---------- Profile store preparation ----------

local ProfileStore = require(script.ProfileStore)


local PROFILE_TEMPLATE = {
	BestStage = 0,
	CurrentStage = 0,
	UnlockedStages = {["0"] = true} :: {[string]: boolean},
}
local DifficultyChart_PlayerStore = ProfileStore.New("DifficultyChart_PlayerStore", PROFILE_TEMPLATE)


---------- Variables ----------

local player_profile: {[Player]: typeof(DifficultyChart_PlayerStore:StartSessionAsync())} = {}


---------- Services ----------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")


---------- Local functions ----------

local function getPlayerProfile(player: Player, timeout: number?)
	timeout = timeout or 5

	local profile = player_profile[player]
	local startTime = time()

	while not profile do
		-- Wait
		RunService.Heartbeat:Wait()

		-- Check timeout
		if time() - startTime > timeout then
			print(`Profile for user {player.UserId} not found.`)
			break
		end

		-- Get profile
		profile = player_profile[player]
	end

	return profile
end


---------- Event functions ----------

local function PlayerAdded(player)

	-- Start a profile session for this player's data:

	local profile = DifficultyChart_PlayerStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	-- Handling new profile session or failure to start it:

	if profile ~= nil then

		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from PROFILE_TEMPLATE (optional)

		profile.OnSessionEnd:Connect(function()
			player_profile[player] = nil
			player:Kick(`Profile session end - Please rejoin`)
		end)

		if player.Parent == Players then
			player_profile[player] = profile
			print(`Profile loaded for {player.DisplayName}!`)
		else
			-- The player has left before the profile session started
			profile:EndSession()
		end

	else
		-- This condition should only happen when the Roblox server is shutting down
		player:Kick(`Profile load fail - Please rejoin`)
	end

end


---------- Calling./ connecting functions ----------

-- In case Players have joined the server earlier than this script ran:
for _, player in Players:GetPlayers() do
   task.spawn(PlayerAdded, player)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
   local profile = player_profile[player]
   if profile ~= nil then
      profile:EndSession()
   end
end)


---------- Module variables ----------

Module.getPlayerProfile = getPlayerProfile


---------- Return module ----------

return Module
