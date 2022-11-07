--[[
Kill Confirmed (Semi-Permissive)
PvE Ground Branch game mode by Bob/AT
2022-05-08

https://github.com/JakBaranowski/ground-branch-game-modes/issues/26

Notes for Mission Editing:

  1. Start with a regular 'Kill Confirmed' mission
  2. Add non-combatants
  - use team id = 10
  - assign a group tag with the pattern CIV_Unarmed<GroupNumber>
  - one of the unarmed 'Civ*' kits)
  2. Add armed (uprising) civilians
  - use team id = 20
  - assign a group tag with the pattern CIV_Armed<GroupNumber>
  - a matching armed civ kit

]]--

local Tables = require("Common.Tables")
local AvoidFatality = require("Objectives.AvoidFatality")
local NoSoftFail = require("Objectives.NoSoftFail")
local AdminTools = require('AdminTools')
local MSpawnsGroups         = require('Spawns.Groups')
local Callback 				= require('common.Callback')
local MTeams                = require('Agents.Team')

-- Create a deep copy of the singleton
local super = Tables.DeepCopy(require("KillConfirmed"))

-- Our sub-class of the singleton
local Mode = setmetatable({}, { __index = super })

-- Add new score types
Mode.PlayerScoreTypes.CollateralDamage = {
	Score = -250,
	OneOff = false,
	Description = 'Killed a non-combatant'
}
Mode.TeamScoreTypes.CollateralDamage = {
	Score = -250,
	OneOff = false,
	Description = 'Killed a non-combatant'
}
-- Add additional objectives
Mode.Objectives.AvoidFatality = AvoidFatality.new('NoCollateralDamage')
Mode.Objectives.NoSoftFail = NoSoftFail.new()

-- Add additional settings
Mode.Settings.UpriseOnHVTKillChance = {
	Min = 0,
	Max = 100,
	Value = 0,
	AdvancedSetting = false,
}
Mode.Settings.InitialUpriseChance = {
	Min = 0,
	Max = 100,
	Value = 50,
	AdvancedSetting = false,
}
Mode.Settings.ChanceIncreasePerCollateral = {
	Min = 0,
	Max = 100,
	Value = 20,
	AdvancedSetting = false,
}
Mode.Settings.GlobalCIVUpriseSize = {
	Min = 0,
	Max = 30,
	Value = 10,
	AdvancedSetting = false,
}
Mode.Settings.LocalCIVUpriseSize = {
	Min = 0,
	Max = 30,
	Value = 10,
	AdvancedSetting = false,
}
Mode.Settings.CIVPopulation = {
	Min = 0,
	Max = 30,
	Value = 10,
	AdvancedSetting = false,
}

-- Add additional teams
Mode.AiTeams.CIVUnarmed = {
	Name = 'CIV_Unarmed',
	Tag = 'CIV_Unarmed',
	TeamId = 10,
	CalculatedAiCount = 0,
	Spawns = nil
}
Mode.AiTeams.CIVArmed = {
	Name = 'CIV_Armed',
	Tag = 'CIV_Armed',
	TeamId = 20,
	CalculatedAiCount = 0,
	Spawns = nil
}

-- Indicates that the uprise is triggered already
Mode.IsUprise = false

-- Current effective uprise chance
Mode.UpriseChance = 0

function Mode:PreInit()
	super.PreInit(self)
	self.AiTeams.CIVUnarmed.Script = MTeams:Create(self.AiTeams.CIVUnarmed)
	self.AiTeams.CIVArmed.Script = MTeams:Create(self.AiTeams.CIVArmed)
	self.AiTeams.CIVUnarmed.Spawns = MSpawnsGroups:Create(self.AiTeams.CIVUnarmed.Tag)
	self.AiTeams.CIVArmed.Spawns = MSpawnsGroups:Create(self.AiTeams.CIVArmed.Tag)
	self.PlayerTeams.BluFor.Script:AddHealableTeam(self.AiTeams.CIVUnarmed.TeamId)
	self.AgentsManager:AddDefaultEliminationCallback(self.AiTeams.CIVUnarmed.TeamId, Callback:Create(self, self.OnCivDied))
end

function Mode:TakeChance(chance)
	return math.random(0, 99) < chance
end

function Mode:PostInit()
	super.PostInit(self)
	gamemode.AddGameObjective(self.PlayerTeams.BluFor.TeamId, 'NoCollateralDamage', 1)
end

function Mode:OnRoundStageSet(RoundStage)
	super.OnRoundStageSet(self, RoundStage)
	if RoundStage == 'PostRoundWait' or RoundStage == 'TimeLimitReached' then
		-- Make sure the 'SOFT FAIL' message is cleared
		gamemode.BroadcastGameMessage('Blank', 'Center', -1)
	elseif RoundStage == 'PreRoundWait' then
		self.IsUprise = false
		self.UpriseChance = self.Settings.InitialUpriseChance.Value
		self:SpawnCIVs()
	end
end

function Mode:SpawnCIVs()
	self.AiTeams.CIVUnarmed.Spawns:AddRandomSpawns()
	self.AiTeams.CIVUnarmed.Spawns:Spawn(0.0, 0.5, self.Settings.CIVPopulation.Value, self.AiTeams.CIVUnarmed.Tag)
end

function Mode:PreRoundCleanUp()
	super.PreRoundCleanUp(self)
	self.AgentsManager:SetTeamAttitude(self.PlayerTeams.BluFor.Script, self.AiTeams.CIVUnarmed.Script, 'Neutral')
	self.AgentsManager:SetTeamAttitude(self.AiTeams.CIVArmed.Script, self.AiTeams.OpFor.Script, 'Friendly')
	self.AgentsManager:SetTeamAttitude(self.AiTeams.CIVArmed.Script, self.AiTeams.SuicideSquad.Script, 'Neutral')
	self.AgentsManager:SetTeamAttitude(self.AiTeams.CIVUnarmed.Script, self.AiTeams.OpFor.Script, 'Friendly')
	self.AgentsManager:SetTeamAttitude(self.AiTeams.CIVUnarmed.Script, self.AiTeams.SuicideSquad.Script, 'Neutral')
	self.AgentsManager:SetTeamAttitude(self.AiTeams.CIVUnarmed.Script, self.AiTeams.CIVArmed.Script, 'Friendly')
end

function Mode:Uprise()
	if not self.IsUprise then
		local tiUprise = math.random(50, 150) * 0.1
		AdminTools:ShowDebug("Uprise triggered, spawning armed CIVs in " .. tiUprise .. "s")
		self.IsUprise = true
		local sizeUprise = self.Settings.GlobalCIVUpriseSize.Value
		if sizeUprise > 0 then
			self.AiTeams.CIVArmed.Spawns:AddRandomSpawns()
			self.AiTeams.CIVArmed.Spawns:Spawn(tiUprise, 0.4, sizeUprise, self.AiTeams.CIVArmed.Tag, Callback:Create(self, self.OnUpriseSpawned), nil, true)
		end
	end
end

function Mode:OnUpriseSpawned()
	self.PlayerTeams.BluFor.Script:DisplayMessageToAlivePlayers('INTEL: Civilians are uprising, no more "mistakes" are permitted...', 'Upper', 5.0, 'Always')
end

function Mode:LocalUprise(killedCivLocation)
	local tiUprise = math.random(50, 150) * 0.1
	local sizeUprise = math.random(0, self.Settings.LocalCIVUpriseSize.Value)
	AdminTools:ShowDebug("Local uprise triggered, spawning " .. sizeUprise .. " armed CIVs close in " .. tiUprise .. "s")
	if sizeUprise > 0 then
		self.AiTeams.CIVArmed.Spawns:AddSpawnsFromClosestGroup(sizeUprise, killedCivLocation)
		self.AiTeams.CIVArmed.Spawns:Spawn(tiUprise, 0.4, sizeUprise, self.AiTeams.CIVArmed.Tag, Callback:Create(self, self.OnLocalUpriseSpawned), nil, true)
	end
end

function Mode:OnLocalUpriseSpawned()
	self.PlayerTeams.BluFor.Script:DisplayMessageToAlivePlayers('INTEL: Armed civilians spotted nearby!', 'Upper', 5.0, 'Always')
end

function Mode:OnCivDied(killData)
	if killData.KillerTeam == self.PlayerTeams.BluFor.TeamId then
		self.Objectives.AvoidFatality:ReportFatality()
		killData.KillerAgent:AwardPlayerScore('CollateralDamage')
		killData.KillerAgent:AwardTeamScore('CollateralDamage')
		local message = 'Collateral damage by ' .. tostring(killData.KillerAgent)
		self.PlayerTeams.BluFor.Script:DisplayMessageToAllPlayers(message, 'Engine', 5.0, 'ScoreMilestone')
		if self.IsUprise then
			self.Objectives.NoSoftFail:Fail()
			self.PlayerTeams.BluFor.Script:DisplayMessageToAlivePlayers('SoftFail', 'Upper', 10.0, 'Always')
			gamemode.SetRoundStage('PostRoundWait')
		end
		self:LocalUprise(killData:GetLocation())
		if self:TakeChance(self.UpriseChance) then
			self:Uprise()
		end
		self.UpriseChance = self.UpriseChance + self.Settings.ChanceIncreasePerCollateral.Value
		if self.IsUprise == false then
			AdminTools:ShowDebug("Uprise chance on next collateral damage: " .. self.UpriseChance .. "%")
		end
	end
end

function Mode:OnHVTDied(killData)
	super.OnHVTDied(self, killData)
	if self:TakeChance(self.Settings.UpriseOnHVTKillChance.Value) then
		self:Uprise()
	end
end

function Mode:OnPlayerDied(killData)
	super.OnPlayerDied(self, killData)
	if killData.KilledTeam == killData.KillerTeam then
		-- Count fratricides as collateral damage
		self.Objectives.AvoidFatality:ReportFatality()
	end
end

function Mode:UpdateGameStatsOnExfil()
	if self.Objectives.NoSoftFail:IsOK() then
		gamemode.AddGameStat('Summary=HVTsConfirmed')
		gamemode.AddGameStat('Result=Team1')
	else
		gamemode.AddGameStat('Summary=SoftFail')
		gamemode.AddGameStat('Result=None')
	end
end

return Mode
