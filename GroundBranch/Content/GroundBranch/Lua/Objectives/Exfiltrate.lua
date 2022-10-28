local Callback = require('common.Callback')

local Exfiltrate = {
    PlayersIn = 0,
    Team = 1,
    ExfilTimer = {
        Name = 'ExfilTimer',
        DefaultTime = 5.0,
        CurrentTime = 5.0,
        TimeStep = 1.0,
    },
	PromptTimer = {
		Name = 'ExfilPromptTimer',
		ShowTime = 5.0,
		DelayTime = 15.0,
	},
    Points = {
        All = {},
        Active = nil,
        AllMarkers = {}
    },
}

Exfiltrate.__index = Exfiltrate

---Creates a new object of type Objectives Exfiltrate. This prototype can be
---used for setting up and tracking an exifltration objective for a specific team.
---If messageBroker is provided will display objective related messages to players.
---If promptBroker is provided will display objective prompts to players.
---@param onObjectiveCompleteCallback table A callback object to be called when the objective is completed.
---@param team table the team object of the eligible team.
---@param timeToExfil number How long the exfiltration should take.
---@param timeStep number How much time should pass between each exfiltration check.
---@return table Exfiltrate The newly created Exfiltrate object.
function Exfiltrate:Create(
    onObjectiveCompleteCallback,
    team,
    timeToExfil,
    timeStep
)
	local self = setmetatable({}, Exfiltrate)
    self.OnObjectiveCompleteCallback = onObjectiveCompleteCallback
    self.Team = team
	self.PlayersIn = 0
    self.ExfilTimer.CurrentTime = timeToExfil or Exfiltrate.ExfilTimer.CurrentTime
    self.ExfilTimer.DefaultTime = timeToExfil or Exfiltrate.ExfilTimer.DefaultTime
    self.ExfilTimer.TimeStep = timeStep or Exfiltrate.ExfilTimer.TimeStep
	self.Points.All = {}
	self.ExfilDone = false
	self.AllowExfil = false
	local allExtractionPoints = gameplaystatics.GetAllActorsOfClass(
		'/Game/GroundBranch/Props/GameMode/BP_ExtractionPoint.BP_ExtractionPoint_C'
	)
	for _, extractionPoint in ipairs(allExtractionPoints) do
		if actor.GetTeamId(extractionPoint) == self.Team:GetId() then
			getmetatable(extractionPoint).__tostring = function(obj)
				return actor.GetName(obj)
			end
			table.insert(self.Points.All, extractionPoint)
		end
	end
    print('Found ' .. #self.Points.All .. ' extraction points')
    for i = 1, #self.Points.All do
		local Location = actor.GetLocation(self.Points.All[i])
		self.Points.AllMarkers[i] = gamemode.AddObjectiveMarker(
			Location,
			self.Team:GetId(),
			'Extraction',
			'Extraction',
			false
		)
	end
	print('Added inactive objective markers for extraction points')
	print('Hooking to callbacks')
	if gamemode.script.OnGameTriggerBeginOverlapCallback ~= nil then
		gamemode.script.OnGameTriggerBeginOverlapCallback:Add(Callback:Create(self, self.OnGameTriggerBeginOverlap))
	else
		AdminTools:ShowDebug("Exfiltrate: gamemode doesn't define OnGameTriggerBeginOverlapCallback, cant't hook to it")
	end
	if gamemode.script.OnGameTriggerEndOverlapCallback ~= nil then
		gamemode.script.OnGameTriggerEndOverlapCallback:Add(Callback:Create(self, self.OnGameTriggerEndOverlap))
	else
		AdminTools:ShowDebug("Exfiltrate: gamemode doesn't define OnGameTriggerEndOverlapCallback, cant't hook to it")
	end
	print('Initialized Objective Exfiltrate ' .. tostring(self))
    return self
end

---Resets the object attributes to default values. Should be called before every round.
function Exfiltrate:Reset()
	self.PlayersIn = 0
	self.ExfilDone = false
	self.AllowExfil = false
end

function Exfiltrate:GetCompletedObjectives()
	if self.ExfilDone then
		return {'ExfiltrateBluFor'}
	else
		return {}
	end
end

---Randomly selects the extraction point that should be active in the given round.
---If activeFromStart parameter is set to false, the extration point will not be
---active, and Exfiltrate:SelectedPointSetActive should be called to activate it
---when needed.
---@param activeFromStart boolean Should the selected extraction point be active from round start.
---@param activeIndex number The index of the active point (nil for random)
function Exfiltrate:SelectPoint(activeFromStart, activeIndex)
	if activeIndex == nil then
		activeIndex = math.random(#self.Points.All)
	end
    self.Points.Active = self.Points.All[activeIndex]
    for i = 1, #self.Points.All do
		local bActive = (i == activeIndex)
		print('Setting Exfil marker ' .. i .. ' to ' .. tostring(bActive))
		actor.SetActive(self.Points.All[i], false)
		actor.SetActive(self.Points.AllMarkers[i], bActive)
	end
	actor.SetActive(self.Points.Active, activeFromStart)
end

---Sets the selected point active state.
---@param active boolean should the point be active.
function Exfiltrate:SelectedPointSetActive(active)
	actor.SetActive(self.Points.Active, active)
	timer.Set(
		self.PromptTimer.Name,
		self,
		self.GuideToExtractionTimer,
		self.PromptTimer.DelayTime,
		true
	)
end

function Exfiltrate:EnableExfiltration()
	self:SelectedPointSetActive(true)
	self.AllowExfil = true
end

---Returns the selected extraction point.
---@return userdata ExtractionPoint the selected extraction point.
function Exfiltrate:GetSelectedPoint()
	return self.Points.Active
end

---Get the tag of the currently selected exfill point.
function Exfiltrate:GetSelectedPointTag()
	return actor.GetTag(self:GetSelectedPoint(), 1) or "Unknown"
end

---Displays a world prompt at the extraction zone.
function Exfiltrate:GuideToExtractionTimer()
	self.Team:DisplayPromptToAlivePlayers(
		actor.GetLocation(self.Points.Active),
		'Extraction',
		self.PromptTimer.ShowTime,
		'ObjectivePrompt'
	)
end

---Checks if the trigger is the selected extraction zone, and that the player
---is part of the team assigned to this extraction point.
---@param trigger userdata the game trigger that the player entered.
---@param playerIn userdata the player that entered the game trigger.
---@return boolean enteredOwnZone true if player entered theirs extraction zone, false otherwise.
function Exfiltrate:CheckTriggerAndPlayer(trigger, playerIn)
    if trigger == self.Points.Active then
        local playerCharacter = player.GetCharacter(playerIn)
        if playerCharacter ~= nil then
            return true
        end
    end
    return false
end

function Exfiltrate:OnGameTriggerBeginOverlap(GameTrigger, Player)
	if self:CheckTriggerAndPlayer(GameTrigger, Player) then
		self:PlayerEnteredExfiltration()
	end
end

function Exfiltrate:OnGameTriggerEndOverlap(GameTrigger, Player)
	if self:CheckTriggerAndPlayer(GameTrigger, Player) then
		self:PlayerLeftExfiltration()
	end
end

---Updates the player in extraction zone count when player enters extraction zone
---and, if exfil is allowed, starts the exfiltration check timer.
function Exfiltrate:PlayerEnteredExfiltration()
	self.PlayersIn = self.PlayersIn + 1
	if self.AllowExfil then
		self:CheckExfilTimer()
	end
end

---Updates the player in extraction zone count when player leaves extraction zone.
function Exfiltrate:PlayerLeftExfiltration()
	local total = math.max(self.PlayersIn - 1, 0)
	self.PlayersIn = total
end

---Checks how many players are in the extraction zone and based on the result:
---* if players in zone count is equal or bigger then required count
---will count down time to exfiltration,
---* if playres in zone count is bigger than 0 but lower then required count
---pauses the timer, or
---* if there are no players in the extraction zone
---cancels the exfiltration.
function Exfiltrate:CheckExfilTimer()
	if self.ExfilTimer.CurrentTime <= 0 then
		if self.Team:GetAlivePlayersCount() > 0 then
			self.ExfilDone = true
		end
		self.OnObjectiveCompleteCallback:Call()
		timer.Clear(self, self.ExfilTimer.Name)
		self.ExfilTimer.CurrentTime = self.ExfilTimer.DefaultTime
		return
	end
	if self.PlayersIn <= 0 then
		self.Team:DisplayMessageToAlivePlayers(
			'ExfilCancelled',
			'Upper',
			self.ExfilTimer.TimeStep*2,
			'ObjectiveMessage'
		)
		self.ExfilTimer.CurrentTime = self.ExfilTimer.DefaultTime
		return
	elseif self.PlayersIn < self.Team:GetAlivePlayersCount() then
		self.Team:DisplayMessageToAlivePlayers(
			'ExfilPaused',
			'Upper',
			self.ExfilTimer.TimeStep-0.05,
			'ObjectiveMessage'
		)
	else
		self.Team:DisplayMessageToAlivePlayers(
			'ExfilInProgress_'..math.floor(self.ExfilTimer.CurrentTime),
			'Upper',
			self.ExfilTimer.TimeStep-0.05,
			'ObjectiveMessage'
		)
		self.ExfilTimer.CurrentTime = self.ExfilTimer.CurrentTime - self.ExfilTimer.TimeStep
	end
	timer.Set(
		self.ExfilTimer.Name,
		self,
		self.CheckExfilTimer,
		self.ExfilTimer.TimeStep,
		false
	)
end

return Exfiltrate
