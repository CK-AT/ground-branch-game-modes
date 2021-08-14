local Groups = require('Spawns.Groups')
local Spawns = require('Spawns.Common')
local Exfiltration = require('Objectives.Exfiltration')
local GameMessageBroker = require('UI.GameMessageBroker')

--#region Properties

local BreakOut = {
	UseReadyRoom = true,
	UseRounds = true,
	StringTables = {'BreakOut'},
	PlayerTeams = {
		BluFor = {
			TeamId = 1,
			Loadout = 'Captive',
		},
	},
	Settings = {
		OpForPreset = {
			Min = 0,
			Max = 4,
			Value = 2,
		},
		Difficulty = {
			Min = 0,
			Max = 4,
			Value = 2,
		},
		RoundTime = {
			Min = 10,
			Max = 60,
			Value = 60,
		},
		AllowRespawns = {
			Min = 0,
			Max = 1,
			Value = 0
		}
	},
	Players = {
		WithLives = {}
	},
	OpFor = {
		Tag = 'OpFor',
		CalculatedAiCount = 0,
	},
	Timers = {
		-- Delays
		CheckBluForCount = {
			Name = 'CheckBluForCount',
			TimeStep = 1.0,
		},
		CheckReadyUp = {
			Name = 'CheckReadyUp',
			TimeStep = 0.25,
		},
		CheckReadyDown = {
			Name = 'CheckReadyDown',
			TimeStep = 0.1,
		},
		CheckSpawnedAi ={
			Name = 'CheckSpawnedAi',
			TimeStep = 4.1
		}
	}
}

--#endregion

--#region Spawns

local GroupSpawns
local ObjectiveExfil
local MessagesObjective

--#endregion

--#region Preparation

function BreakOut:PreInit()
	print('Initializing Break Out')
	-- Initalize game message broker
	MessagesObjective = GameMessageBroker:Create(self.Players.WithLives, 'upper')
	-- Gathers all OpFor spawn points by groups
	GroupSpawns = Groups:Create()
	-- Initialize Exfiltration objective
	ObjectiveExfil = Exfiltration:Create(
		MessagesObjective,
		nil,
		self,
		self.Exfiltrate,
		self.PlayerTeams.BluFor.TeamId,
		#self.Players.WithLives,
		5.0,
		1.0
	)
end

function BreakOut:PostInit()
	gamemode.AddGameObjective(self.PlayerTeams.BluFor.TeamId, 'ExfiltrateBluFor', 1)
	gamemode.AddGameObjective(self.PlayerTeams.BluFor.TeamId, 'ExfiltrateAll', 2)
	print('Added game mode objectives')
end

--#endregion

--#region Common

function BreakOut:OnRoundStageSet(RoundStage)
	print('Started round stage ' .. RoundStage)
	timer.ClearAll()
	if RoundStage == 'WaitingForReady' then
		self:PreRoundCleanUp()
		ObjectiveExfil:SelectPoint(true)
	elseif RoundStage == 'PreRoundWait' then
		self:SetUpOpForSpawns()
		self:SpawnOpFor()
	elseif RoundStage == 'InProgress' then
		self.Players.WithLives = gamemode.GetPlayerListByLives(
			self.PlayerTeams.BluFor.TeamId,
			1,
			false
		)
		MessagesObjective:SetRecipients(self.Players.WithLives)
		ObjectiveExfil:SetPlayersRequiredForExfil(#self.Players.WithLives)
	end
end

function BreakOut:OnCharacterDied(Character, CharacterController, KillerController)
	if
		gamemode.GetRoundStage() == 'PreRoundWait' or
		gamemode.GetRoundStage() == 'InProgress'
	then
		if CharacterController ~= nil then
			if actor.HasTag(CharacterController, self.OpFor.Tag) then
				print('OpFor eliminated')
			else
				print('BluFor eliminated')
				if self.Settings.AllowRespawns.Value == 0 then
					player.SetLives(
						CharacterController,
						player.GetLives(CharacterController) - 1
					)
				end
				self.Players.WithLives = gamemode.GetPlayerListByLives(
					self.PlayerTeams.BluFor.TeamId,
					1,
					false
				)
				MessagesObjective:SetRecipients(self.Players.WithLives)
				ObjectiveExfil:SetPlayersRequiredForExfil(#self.Players.WithLives)
				timer.Set(
					self.Timers.CheckBluForCount.Name,
					self,
					self.CheckBluForCountTimer,
					self.Timers.CheckBluForCount.TimeStep,
					false
				)
			end
		end
	end
end

--#endregion

--#region Player Status

function BreakOut:PlayerInsertionPointChanged(PlayerState, InsertionPoint)
	if InsertionPoint == nil then
		timer.Set(
			self.Timers.CheckReadyDown.Name,
			self,
			self.CheckReadyDownTimer,
			self.Timers.CheckReadyDown.TimeStep,
			false
		)
	else
		timer.Set(
			self.Timers.CheckReadyUp.Name,
			self,
			self.CheckReadyUpTimer,
			self.Timers.CheckReadyUp.TimeStep,
			false
		)
	end
end

function BreakOut:PlayerReadyStatusChanged(PlayerState, ReadyStatus)
	if ReadyStatus ~= 'DeclaredReady' then
		timer.Set(
			self.Timers.CheckReadyDown.Name,
			self,
			self.CheckReadyDownTimer,
			self.Timers.CheckReadyDown.TimeStep,
			false
		)
	elseif
		gamemode.GetRoundStage() == 'PreRoundWait' and
		gamemode.PrepLatecomer(PlayerState)
	then
		gamemode.EnterPlayArea(PlayerState)
	end
end

function BreakOut:CheckReadyUpTimer()
	if
		gamemode.GetRoundStage() == 'WaitingForReady' or
		gamemode.GetRoundStage() == 'ReadyCountdown'
	then
		local ReadyPlayerTeamCounts = gamemode.GetReadyPlayerTeamCounts(true)
		local BluForReady = ReadyPlayerTeamCounts[self.PlayerTeams.BluFor.TeamId]
		if BluForReady >= gamemode.GetPlayerCount(true) then
			gamemode.SetRoundStage('PreRoundWait')
		elseif BluForReady > 0 then
			gamemode.SetRoundStage('ReadyCountdown')
		end
	end
end

function BreakOut:CheckReadyDownTimer()
	if gamemode.GetRoundStage() == 'ReadyCountdown' then
		local ReadyPlayerTeamCounts = gamemode.GetReadyPlayerTeamCounts(true)
		if ReadyPlayerTeamCounts[self.PlayerTeams.BluFor.TeamId] < 1 then
			gamemode.SetRoundStage('WaitingForReady')
		end
	end
end

function BreakOut:ShouldCheckForTeamKills()
	if gamemode.GetRoundStage() == 'InProgress' then
		return true
	end
	return false
end

function BreakOut:PlayerCanEnterPlayArea(PlayerState)
	if player.GetInsertionPoint(PlayerState) ~= nil then
		return true
	end
	return false
end

function BreakOut:PlayerEnteredPlayArea(PlayerState)
	player.SetAllowedToRestart(PlayerState, self.Settings.AllowRespawns.Value == 1)
end

function BreakOut:LogOut(Exiting)
	if
		gamemode.GetRoundStage() == 'PreRoundWait' or
		gamemode.GetRoundStage() == 'InProgress'
	then
		timer.Set(
			self.Timers.CheckBluForCount.Name,
			self,
			self.CheckBluForCountTimer,
			self.Timers.CheckBluForCount.TimeStep,
			false
		)
	end
end

--#endregion

--#region Spawns

function BreakOut:SetUpOpForSpawns()
	print('Setting up AI spawns by groups')
	local maxAiCount = math.min(
		GroupSpawns:GetTotalSpawnPointsCount(),
		ai.GetMaxCount()
	)
	self.OpFor.CalculatedAiCount = Spawns.GetAiCountWithDeviationPercent(
		5,
		maxAiCount,
		gamemode.GetPlayerCount(true),
		5,
		self.Settings.OpForPreset.Value,
		5,
		0.1
	)
	-- Select groups guarding extraction and add their spawn points to spawn list
	print('Adding group closest to exfil')
	local aiCountPerExfilGroup = Spawns.GetAiCountWithDeviationNumber(
		3,
		10,
		gamemode.GetPlayerCount(true),
		1,
		self.Settings.OpForPreset.Value,
		1,
		0
	)
	local exfilLocation = actor.GetLocation(ObjectiveExfil:GetSelectedPoint())
	GroupSpawns:AddSpawnsFromClosestGroup(aiCountPerExfilGroup, exfilLocation)
	print('Adding random spawns from remaining')
	GroupSpawns:AddRandomSpawns()
	print('Adding random spawns from reserve')
	GroupSpawns:AddRandomSpawnsFromReserve()
end

function BreakOut:SpawnOpFor()
	GroupSpawns:Spawn(4.0, self.OpFor.CalculatedAiCount, self.OpFor.Tag)
	timer.Set(
		self.Timers.CheckSpawnedAi.Name,
		self,
		self.CheckSpawnedAiTimer,
		self.Timers.CheckSpawnedAi.TimeStep,
		false
	)
end

function BreakOut:CheckSpawnedAiTimer()
	local aiControllers = ai.GetControllers(
		'GroundBranch.GBAIController',
		self.OpFor.Tag,
		255,
		255
	)
	print('Spawned ' .. #aiControllers .. ' AI')
end

--#endregion

--#region Objective: Extraction

function BreakOut:OnGameTriggerBeginOverlap(GameTrigger, Player)
	if ObjectiveExfil:CheckTriggerAndPlayer(GameTrigger, Player) then
		ObjectiveExfil:PlayerEnteredExfiltration(true)
	end
end

function BreakOut:OnGameTriggerEndOverlap(GameTrigger, Player)
	if ObjectiveExfil:CheckTriggerAndPlayer(GameTrigger, Player) then
		ObjectiveExfil:PlayerLeftExfiltration()
	end
end

function BreakOut:Exfiltrate()
	if gamemode.GetRoundStage() ~= 'InProgress' then
		return
	end
	gamemode.AddGameStat('Result=Team1')
	if #self.Players.WithLives >= gamemode.GetPlayerCount(true) then
		gamemode.AddGameStat('CompleteObjectives=ExfiltrateBluFor,ExfiltrateAll')
		gamemode.AddGameStat('Summary=BluForExfilSuccess')
	else
		gamemode.AddGameStat('CompleteObjectives=ExfiltrateBluFor')
		gamemode.AddGameStat('Summary=BluForExfilPartialSuccess')
	end
	gamemode.SetRoundStage('PostRoundWait')
end

--#endregion

--#region Fail condition

function BreakOut:CheckBluForCountTimer()
	if gamemode.GetRoundStage() ~= 'InProgress' then
		return
	end
	if #self.Players.WithLives == 0 then
		timer.Clear(self, 'CheckBluForExfil')
		gamemode.AddGameStat('Result=None')
		gamemode.AddGameStat('Summary=BluForEliminated')
		gamemode.SetRoundStage('PostRoundWait')
	end
end

--#endregion

--region Helpers

function BreakOut:PreRoundCleanUp()
	ai.CleanUp(self.OpFor.Tag)
	self.Players.WithLives = {}
	MessagesObjective:SetRecipients(self.Players.WithLives)
	ObjectiveExfil:Reset()
end

--#endregion

return BreakOut
