local teamelimination = {
	UseReadyRoom = true,
	UseRounds = true,
	StringTables = { "Geronimo" },
	
	-- Limit dead bodies and dropped items.
	MaxDeadBodies = 8,
	MaxDroppedItems = 32,
	
	-- override other values
	
	MissionTypeDescription = "[PvPvE] Eliminate the opposing team. BLUFOR also needs to recover intel and exfil without civilian casualties.",
	-- displayed on mission selection screen
	
	PlayerTeams = {
		Blue = {
			TeamId = 1,
			Loadout = "NoTeam",
		},
		Red = {
			TeamId = 2,
			Loadout = "NoTeam",
		},
	},
	Settings = {
		RoundTime = {
			Min = 5,
			Max = 60,
			Value = 40,
			AdvancedSetting = false,
		},
		DisplaySearchLocations = {
			Min = 1,
			Max = 3,
			Value = 3,
			AdvancedSetting = false,
		},		
		SearchTime = {
			Min = 1,
			Max = 30,
			Value = 1,
			AdvancedSetting = true,
		},
		OpForCount = {
			Min = 1,
			Max = 40,
			Value = 20,
			AdvancedSetting = false,
		},
		CivilianCount = {
			Min = 0,
			Max = 40,
			Value = 15,
			AdvancedSetting = false,
		},
		AcceptedCivilianCasualities = {
			Min = 0,
			Max = 4,
			Value = 0,
			AdvancedSetting = false,
			
			--medieval -- (4)
			--slack --  (3)
			--acceptable- (2)
			--realistic-- (1)
			--operator -- (0)
		},
		Difficulty = {
			Min = 0,
			Max = 4,
			Value = 2,
			AdvancedSetting = false,
		},
	},
	
	MaxSpawns = 100,
	ExtractionPoints = {},
	ExtractionPointMarkers = {},
	ExtractionPointIndex = 0,
	
	RoundResult = "",
	InsertionPoints = {},
	NumInsertionPointGroups = 0,
	PrevGroupIndex = 0,
	
	
	MissionLocationMarkers = {},
	MissionLocationMarkersRed = {},
	
	LaptopLocationNameList = {},
	RealLaptopLocationNameList = {},
	
	
	LaptopObjectiveMarkerName = "",
	
	CurrentInsertionPoints = {},
	-- index is TeamId, value is index in InsertionPoints{} of currently selected points for red and blue teams
	
	CompletedARound = true,
	-- used to stop readying up and readying down causing spawns to randomise
	
	
	CivSpawn={},
	CivTeamTag = "Civ",
	CivTeamId=99,
	
	OpForTeamTag = "OpFor",
	PriorityTags = { "AISpawn_1", "AISpawn_2", "AISpawn_3", "AISpawn_4", "AISpawn_5",
		"AISpawn_6_10", "AISpawn_11_20", "AISpawn_21_30", "AISpawn_31_40", "AISpawn_41_50" },
	OpforTeamId=100,
	
	SpawnPriorityGroupIDs = { "AISpawn_11_20", "AISpawn_31_40" },
	
	-- these define the start of priority groups, e.g. group 1 = everything up to AISPawn_11_20 (i.e. from AISpawn_1 to AISpawn_6_10), group 2 = AISpawn_11_20 onwards, group 3 = AISpawn_31_40 onwards
	-- everything in the first group is spawned as before. Everything is spawned with 100% certainty until the T count is reached
	-- subsequent priority groups are capped, ensuring that some lower priority AI is spawned, and everything else is randomised as much as possible
	-- so overall the must-spawn AI will spawn (priority group 1) and a random mix of more important and (a few) less important AI will spawn fairly randomly

	SpawnPriorityGroups = {},
	-- this stores the actual groups as separate tables of spawns indexed by priority group
	
	LastSpawnPriorityGroup = 0,
	-- the last priority group in which spawns were found
	
	ProportionOfPriorityGroupToSpawn = 0.7,
	-- after processing all group 1 spawns, a total of N spawns remain. Spawn 70% of those as group 2 , then 70% of the remaining number as group 3, ... (or 100% if no more groups exist) 
	
	TotalNumberOfSpawnsFound = 0,
	-- simple total of spawns placed in all priority groups
		
	AlwaysUseEveryPriorityOneSpawn = false,
	-- if true, priority one spawns will be used up entirely before considering lower priorities
	-- if false, behaviour differs depending on T count and number of P1 spawns. At least N% of spawns will be not P1 spawns, preventing all P1 spawns being used if need be
	MinimumProportionOfNonPriorityOneSpawns = 0.15,
	-- in which case, always use this proportion of non P1 spawns (15% by default), rounded down
		
	PriorityGroupedSpawns = {},
	-- used for old AI spawn method
	
	CivilianCasualties = 0,
	TotalCivilianCasualties = 0,
	
	extractactivated = false,
	
	
	TeamScoreTypes = {
		OperativesDeceased = {   -- red or blue players dead
			Score = -1,
			OneOff = false,
			Description = "Operatives killed in line of duty:",
		},
		OperativesSurvived = {   -- red or blue players alive by end of round
			Score = 1,
			OneOff = false,
			Description = "Operatives survived:",
		},
		CivEscaped = {     -- civ alive by the end of the round
			Score = 1,
			OneOff = true,
			Description = "Civilian(s) escaped with their lives:",
		},
		CivDead  = {     -- civ killed by bluefor
			Score = -1,
			OneOff = false,
			Description = "Civilian(s) killed by BlueFor:",
		},
		CivCrossfire = {   -- civ killed by anyone but bluefor
			Score = -1,
			OneOff = false,
			Description = "Civilian(s) killed in crossfire:",
		},
		OpForDead = {       -- kill count for bluefor ( this will add points to blue team)
			Score = 1,
			OneOff = false,
			Description = "OpFor members eliminated:",
		},
		OpForDead2 = {    -- same kill count as opfordead (this will remove points from red team) 
			Score = -1,
			OneOff = false,
			Description = "OpFor members eliminated:",
		},
		
		KilledBlue = {     -- members of the blue team killed by red team
			Score = 1,
			OneOff = false,
			Description = "BluFor players eliminated:",
		},
		KilledRed = {     -- members of the red team killed by red team
			Score = 1,
			OneOff = false,
			Description = "OpFor players eliminated:",
		},
		OpForEscaped = {    -- count for enemies that were alive at the end of the round ( this will remove points from blue team)
			Score = -1,
			OneOff = true,
			Description = "OpFor members escaped:",
		},	
		OpForEscaped2 = {  -- same as opforescaped ( this will add points to the red team)
			Score = 1,
			OneOff = true,
			Description = "Friendly forces members escaped:",
		},
		IntelCollected = {
			Score = 1,
			OneOff = false,
			Description = "Intel collected:",
		},
		RedAliveAtEnd = {     -- if there was any red player still alive when the bluefor exfiled
			Score = -1,
			OneOff = false,
			Description = "HTV alive:",
		},
		BlueExfil = {      --  if bluefor managed to exfil
			Score = 1,
			OneOff = true,
			Description = "BluFor exfiled:",
		},
		RedExfil = {      --  if opfor managed to exfil
			Score = 1,
			OneOff = true,
			Description = "HTV escaped:",
		},
		
	},
	
	PlayerScoreTypes = {
		SurvivedRound = {
			Score = 1,
			OneOff = true,
			Description = "Survived round:",
		},
		IntelCollected = {
			Score = 1,
			OneOff = false,
			Description = "Intel collected:",
		},
		OpForKilled = {
			Score = 1,
			OneOff = false,
			Description = "Eliminated OpFor:",
		},
		CivKilled = {
			Score = -1,
			OneOff = false,
			Description = "Friendly fire on civilian:",
		},
		KilledTeammate =  {
			Score = -1,
			OneOff = false,
			Description = "Friendly fire on teannate:",
		},
		KilledRed = {
			Score = 1,
			OneOff = false,
			Description = "HTV killed:",
		},
		KilledBlue = {
			Score = 1,
			OneOff = false,
			Description = "BluFor killed:",
		},
		
	},
	
	DebugMode = false,
	-- allows game to be started with only one player on server, and a few other tweaks for testing
	
	BumRushMode = false,
	
	
}

function teamelimination:DumbTableCopy(MyTable)
	local ReturnTable = {}
	
	for Key, TableEntry in ipairs(MyTable) do
		table.insert(ReturnTable, TableEntry)
	end
	
	return ReturnTable
end


function teamelimination:PreInit()
	local AllSpawns = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBAISpawnPoint')
	local PriorityIndex = 1
	
	local TotalSpawns = 0

	local CurrentPriorityGroup = 1
	local CurrentGroupTotal = 0
	local CurrentPriorityGroupSpawns = {}
	-- this needs to be outside the loop
	
	self.SpawnPriorityGroups = {}
	
	gamemode.ResetTeamScores()
	gamemode.ResetPlayerScores()
	
	gamemode.SetTeamScoreTypes( self.TeamScoreTypes )
	gamemode.SetPlayerScoreTypes( self.PlayerScoreTypes )
	
	--gamemode.SetPlayerTeamRole(PlayerTeams.BluFor.TeamId, "Attackers")
	-- only need to set this once

	-- Orders spawns by priority while allowing spawns of the same priority to be randomised.
	for i, PriorityTag in ipairs(self.PriorityTags) do
		local bFoundTag = false

		if CurrentPriorityGroup <= #self.SpawnPriorityGroupIDs then
			if PriorityTag == self.SpawnPriorityGroupIDs[CurrentPriorityGroup] then
				-- we found the priority tag corresponding to the start of the next priority group
				self.SpawnPriorityGroups[CurrentPriorityGroup] = self:DumbTableCopy(CurrentPriorityGroupSpawns)
				print("PreInit(): " .. CurrentGroupTotal .. " total spawns found for priority group " .. CurrentPriorityGroup )
				CurrentPriorityGroup = CurrentPriorityGroup + 1
				CurrentGroupTotal = 0
				CurrentPriorityGroupSpawns = {}
			end
		end

		
		for j, SpawnPoint in ipairs(AllSpawns) do
			if actor.HasTag(SpawnPoint, PriorityTag) then
				bFoundTag = true
				if self.PriorityGroupedSpawns[PriorityIndex] == nil then
					self.PriorityGroupedSpawns[PriorityIndex] = {}
				end
				-- Ensures we can't spawn more AI then this map can handle.
				TotalSpawns = TotalSpawns + 1 
				table.insert(self.PriorityGroupedSpawns[PriorityIndex], SpawnPoint)
				-- this is the table for the old method, which we may still want to use e.g. at low T counts

				table.insert(CurrentPriorityGroupSpawns, SpawnPoint)
				CurrentGroupTotal = CurrentGroupTotal + 1
				-- also store in the table of spawnpoints for the new method
			end
		end

		-- Ensures we don't create empty tables for unused priorities.
		if bFoundTag then
			PriorityIndex = PriorityIndex + 1
			self.LastSpawnPriorityGroup = CurrentPriorityGroup
		end
	end
	
	self.SpawnPriorityGroups[CurrentPriorityGroup] = CurrentPriorityGroupSpawns
	print("PreInit(): " .. CurrentGroupTotal .. " total spawns found for priority group " .. CurrentPriorityGroup )
	self.TotalNumberOfSpawnsFound = TotalSpawns
	
	TotalSpawns = math.min(ai.GetMaxCount(), TotalSpawns)
	
	-- Disable setting spawns higher then value allowed (40)
	--self.Settings.OpForCount.Max = TotalSpawns
	--self.Settings.OpForCount.Value = math.min(self.Settings.OpForCount.Value, TotalSpawns) -- self.Settings.CivilianCount.Value

	--print("Value for bots is: " .. self.Settings.OpForCount.Value)
	--self.MaxSpawns = TotalSpawns
	--self.MaxSpawns = math.min(self.MaxSpawns, TotalSpawns)
	
	local AllCivSpawns = gameplaystatics.GetAllActorsOfClassWithTag('GroundBranch.GBAISpawnPoint', self.CivTeamTag)
	
	if AllCivSpawns == {} or AllCivSpawns == nil then
		print("WARNING - no ai with the CIV tag. **********")
	end
	
	-- ADDED IR code
	
	self.ExtractionPoints = gameplaystatics.GetAllActorsOfClass('/Game/GroundBranch/Props/GameMode/BP_ExtractionPoint.BP_ExtractionPoint_C')
	
	for i = 1, #self.ExtractionPoints do
		local Location = actor.GetLocation(self.ExtractionPoints[i])
		local ExtName = actor.GetTag(self.ExtractionPoints[i] , 2)
		local ExtractionMarkerName = self:GetModifierTextForObjective( self.ExtractionPoints[i] ) .. ExtName -- "EXTRACTION"
		
		-- allow the possibility of down chevrons, up chevrons, level numbers, etc
				
		self.ExtractionPointMarkers[i] = gamemode.AddObjectiveMarker(Location, self.PlayerTeams.Blue.TeamId, ExtractionMarkerName, "Extraction", false)
		-- NB new penultimate parameter of MarkerType ("Extraction" or "MissionLocation", at present)
	end
	
	
	-- now sort laptops
	
	self.Laptops = gameplaystatics.GetAllActorsOfClass('/Game/GroundBranch/Props/Electronics/MilitaryLaptop/BP_Laptop_Usable.BP_Laptop_Usable_C')
	
	
	local nottheseones = gameplaystatics.GetAllActorsWithTag("NoDel")	
	for ib, whichlaptop in ipairs(nottheseones) do 
	
		for ia, removelaptop in ipairs(self.Laptops) do 
	
			if removelaptop == whichlaptop then
				table.remove(self.Laptops,ia)
			end
		end
		
	end

	-- set up laptop intel rings for ops board
	local AllInsertionPoints = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBInsertionPoint')
	
	self.MissionLocationMarkers = {}
	self.MissionLocationMarkersRed = {}
	
	for i = 1, #AllInsertionPoints do
		if actor.HasTag( AllInsertionPoints[i], "Defenders" ) then
			local Location = actor.GetLocation(AllInsertionPoints[i])
			local InsertionPointName = gamemode.GetInsertionPointName(AllInsertionPoints[i])
			local MarkerName = self.LaptopObjectiveMarkerName
			
			MarkerName = self:GetModifierTextForObjective( AllInsertionPoints[i] ) .. MarkerName
			-- this checks tags on the specified actor and produces a prefix if appropriate, for interpretation within the WBP_ObjectiveMarker widget
			-- you can give the insertion point tags to add the relevant symbol before "INTEL?"
			
			self.MissionLocationMarkers[InsertionPointName] = gamemode.AddObjectiveMarker(Location, self.PlayerTeams.Blue.TeamId, MarkerName, "MissionLocation", false)
			self.MissionLocationMarkersRed[InsertionPointName] = gamemode.AddObjectiveMarker(Location, self.PlayerTeams.Red.TeamId, MarkerName, "MissionLocation", false)
			-- NB new penultimate parameter of MarkerType ("Extraction" or "MissionLocation", at present)
		end
	end
	
	
	--[[
	if #AllInsertionPoints > 2 then
		local GroupedInsertionPoints = {}
		
		for i, InsertionPoint in ipairs(AllInsertionPoints) do
			if #actor.GetTags(InsertionPoint) > 1 then
				local Group = actor.GetTag(InsertionPoint, 1)
				if GroupedInsertionPoints[Group] == nil then
					GroupedInsertionPoints[Group] = {}
					self.NumInsertionPointGroups = self.NumInsertionPointGroups + 1
				end
				table.insert(GroupedInsertionPoints[Group], InsertionPoint)
			end
		end

		if self.NumInsertionPointGroups > 1 then
			self.InsertionPoints = GroupedInsertionPoints
		else
			self.InsertionPoints = AllInsertionPoints
		end
	else
		self.InsertionPoints = AllInsertionPoints
		for i, InsertionPoint in ipairs(self.InsertionPoints) do
			if actor.GetTeamId(InsertionPoint) ~= 255 then
				-- Disables insertion point randomisation.
				self.bFixedInsertionPoints = true
				break
			end
		end
	end
	--]]


end

function teamelimination:GetModifierTextForObjective( TaggedActor )
	-- consider moving to gamemode
			
	if actor.HasTag( TaggedActor, "AddUpArrow") then
		return "(U)" 
	elseif actor.HasTag( TaggedActor, "AddDownArrow") then
		return "(D)" 
	elseif actor.HasTag( TaggedActor, "AddUpStaircase") then
		return "(u)" 
	elseif actor.HasTag( TaggedActor, "AddDownStaircase") then
		return "(d)"
	elseif actor.HasTag( TaggedActor, "Add1") then
		return "(1)" 
	elseif actor.HasTag( TaggedActor, "Add2") then
		return "(2)" 
	elseif actor.HasTag( TaggedActor, "Add3") then
		return "(3)"
	elseif actor.HasTag( TaggedActor, "Add4") then
		return "(4)" 
	elseif actor.HasTag( TaggedActor, "Add5") then
		return "(5)" 
	elseif actor.HasTag( TaggedActor, "Add6") then
		return "(6)" 
	elseif actor.HasTag( TaggedActor, "Add7") then
		return "(7)" 
	elseif actor.HasTag( TaggedActor, "Add8") then
		return "(8)" 
	elseif actor.HasTag( TaggedActor, "Add9") then
		return "(9)" 
	elseif actor.HasTag( TaggedActor, "Add0") then
		return "(0)" 
	elseif actor.HasTag( TaggedActor, "Add-1") then
		return "(-)"
	elseif actor.HasTag( TaggedActor, "Add-2") then
		return "(=)"
	end
		
	return ""
end

function teamelimination:RandomiseObjectives()
	-- called to reset and randomise the mission objectives
	if gamemode.GetRoundStage() ~= "InProgress" then
		-- first, pick a random extraction point
		self.ExtractionPointIndex = umath.random(#self.ExtractionPoints)
		-- this is the current extraction point

		for i = 1, #self.ExtractionPoints do
			local bActive = (i == self.ExtractionPointIndex)
			
			actor.SetActive(self.ExtractionPointMarkers[i], bActive)		
			actor.SetActive(self.ExtractionPoints[i], false)
			-- set extraction marker to active but don't turn on flare yet
			
		end
		
		-- activate exit triggers for bluefor
		local FlareStartup = gameplaystatics.GetAllActorsOfClassWithTag('GroundBranch.GBGameTrigger', "StartFlare")	

		for i, FlarePoint in ipairs(FlareStartup) do -- look through all triggers 
			actor.SetActive(FlarePoint, true)	-- deactivate the guard point
			print("started exit triggers")
		end
		
		
		-- activate exit triggers for opfor
		local ExfilRed = gameplaystatics.GetAllActorsOfClassWithTag('GroundBranch.GBGameTrigger', "RedExfil")	
		
		for ii, RedExfil in ipairs(ExfilRed) do -- look through all triggers 
			actor.SetActive(RedExfil, true)	-- activate all exfil for red team
			print("started hvt exfil triggers")
		end
		

		gamemode.ClearSearchLocations()
		
		self.CurrentSearchObjectives = {}
		self.CurrentSearchObjectivesRed = {}
		
		self:AddObjectivesToGame()

		self.LaptopLocationNameList = {}
		self.RealLaptopLocationNameList = {}
		local AllFakeLocationNames = {}
		local LocationName

		self.RandomLaptopIndex = umath.random(#self.Laptops);
		
		print("----picking laptop " .. self.RandomLaptopIndex .. " (" .. actor.GetName(self.Laptops[self.RandomLaptopIndex]) .. ") out of " .. #self.Laptops .. " possible")
			
		
		LocationName = self:GetInsertionPointNameForLaptop(self.Laptops[self.RandomLaptopIndex])
		table.insert(self.LaptopLocationNameList, LocationName)
		table.insert(self.RealLaptopLocationNameList, LocationName)
		
		

		if not self.TestAllLaptops then
				
			for i = 1, #self.Laptops do
				--actor.SetActive(self.Laptops[i], true)
				if (i == self.RandomLaptopIndex) then
					actor.AddTag(self.Laptops[i], self.LaptopTag)
					actor.SetActive(self.Laptops[i], true)
					-- make laptop visible and usable
				else
					actor.SetActive(self.Laptops[i], false)
					-- make laptop disappear
					
					actor.RemoveTag(self.Laptops[i], self.LaptopTag)
					LocationName = self:GetInsertionPointNameForLaptop(self.Laptops[i])
					if LocationName ~= self.LaptopLocationNameList[1] then
						self:AddToTableIfNotAlreadyPresent( AllFakeLocationNames, LocationName )
					end
				end
			end
		
		else

			for i = 1, #self.Laptops do
				actor.AddTag(self.Laptops[i], self.LaptopTag)
				actor.SetActive(self.Laptops[i], true)
					-- make laptop visible and usable
					
				LocationName = self:GetInsertionPointNameForLaptop(self.Laptops[i])
				if LocationName ~= self.LaptopLocationNameList[1] then
					self:AddToTableIfNotAlreadyPresent( AllFakeLocationNames, LocationName )
				end
			end
		
		end
		
		
		for i = #AllFakeLocationNames, 1, -1 do
			local j = umath.random(i)
			AllFakeLocationNames[i], AllFakeLocationNames[j] = AllFakeLocationNames[j], AllFakeLocationNames[i]
			table.insert(self.LaptopLocationNameList, AllFakeLocationNames[i])
		end
		-- LaptopLocationNames contains random sequence of laptop locations, with the true location at [1]
		
		local NumberOfSearchLocations = self.Settings.DisplaySearchLocations.Value --self:GetNumberOfSearchLocations()
		local NumberOfSearchLocationsRed = 1 --self:GetNumberOfSearchLocations()
		
		for i = 1, #self.LaptopLocationNameList do
			local bActive
			if i <= NumberOfSearchLocations then
				bActive = true
			else
				bActive = false
			end
			
			actor.SetActive( self.MissionLocationMarkers[ self.LaptopLocationNameList[i] ], bActive )
		end
			
		-- ops board text to show where the laptops are
		
		local LocationIndices = {}

		-- this is convoluted but we can't shuffle order of LaptopLocationNameList because that screws up AI spawns
		for i = 1, math.min( #self.LaptopLocationNameList, NumberOfSearchLocations ) do
			LocationIndices[i] = i
		end
		
		
		-- now one last shuffly thing to create objective names
		for i = math.min( #self.LaptopLocationNameList, NumberOfSearchLocations ), 1, -1 do
			local j = umath.random(i)
			LocationIndices[i], LocationIndices[j] = LocationIndices[j], LocationIndices[i]
			
			local NewObjective = self.LaptopLocationNameList[ LocationIndices[i] ]
			table.insert(self.CurrentSearchObjectives, NewObjective)
			gamemode.AddSearchLocation(self.PlayerTeams.Blue.TeamId, NewObjective, 1)
			
			
			-- need to add objectives in random order else attackers get a big clue...
		end

		gamemode.AddSearchLocation(self.PlayerTeams.Red.TeamId, self.RealLaptopLocationNameList[ 1 ], 1) -- NOTE: Single laptop shown in opsboard
	
		
	end
	
end


function teamelimination:AddToTableIfNotAlreadyPresent( AllLocationNames, NewLocationName )
	if NewLocationName ~= nil then
		for _, LocationName in ipairs(AllLocationNames) do
			if LocationName == NewLocationName then
				return
			end
		end

		table.insert( AllLocationNames, NewLocationName )
	end
end


function teamelimination:IsItemInTable( TableToCheck, ItemToCheck )
	-- not actually used right now
	for _, TableItem in ipairs(TableToCheck) do
		if TableItem == ItemToCheck then
			return true
		end
	end
	return false
end

function teamelimination:AddObjectivesToGame()

	gamemode.ClearGameObjectives()
	
	gamemode.AddGameObjective(self.PlayerTeams.Blue.TeamId, "EliminateAnyHVT", 1)
	gamemode.AddGameObjective(self.PlayerTeams.Blue.TeamId, "SecureIntel", 1)
	gamemode.AddGameObjective(self.PlayerTeams.Blue.TeamId, "ReachGreenMarker", 1)
	gamemode.AddGameObjective(self.PlayerTeams.Blue.TeamId, "AvoidCivilianCasualties", 1)
	
	gamemode.AddGameObjective(self.PlayerTeams.Red.TeamId, "EliminateAttackingForce", 1)
	gamemode.AddGameObjective(self.PlayerTeams.Red.TeamId, "SecureIntel", 2)
	gamemode.AddGameObjective(self.PlayerTeams.Red.TeamId, "CallForHelpAtRadioTower", 2)
	gamemode.AddGameObjective(self.PlayerTeams.Red.TeamId, "Escape", 2)
	
	
end

function teamelimination:PostInit()
	self:AddObjectivesToGame()
end

function teamelimination:PlayerInsertionPointChanged(PlayerState, InsertionPoint)
	if InsertionPoint == nil then
		timer.Set("CheckReadyDown", self, self.CheckReadyDownTimer, 0.1, false);

	else
		timer.Set("CheckReadyUp", self, self.CheckReadyUpTimer, 0.25, false);
	end
end

function teamelimination:PlayerReadyStatusChanged(PlayerState, ReadyStatus)

--[[	if ReadyStatus == "NotReady" then
		if actor.GetTeamId(PlayerState) ==  self.PlayerTeams.Red.TeamId then
			player.ShowGameMessage(PlayerState, "Remember to disable NOTARGET if you are moving to BLUFOR", "Center", 20.0)
			player.ShowGameMessage(PlayerState, " ", "Center", 20.0)
			player.ShowGameMessage(PlayerState, " ", "Center", 20.0)
			player.ShowGameMessage(PlayerState, " ", "Center", 20.0)
		end
	end
	if ReadyStatus == "WaitingToReadyUp" then
		if actor.GetTeamId(PlayerState) ==  self.PlayerTeams.Red.TeamId then
			player.ShowGameMessage(PlayerState, " If you are joining OPFOR you MUST have NOTARGET enabled", "Center", 10.0)
			player.ShowGameMessage(PlayerState, " ", "Center", 20.0)
			player.ShowGameMessage(PlayerState, "       Press console key ` and type NOTARGET to confirm", "Center", 20.0)
			player.ShowGameMessage(PlayerState, " ", "Center", 20.0)
		end
	end
	--]]
	
	if ReadyStatus ~= "DeclaredReady" then
		timer.Set("CheckReadyDown", self, self.CheckReadyDownTimer, 0.1, false)
	--else
		--timer.Set("CheckReadyUp", self, self.CheckReadyUpTimer, 0.25, false);
	--	if gamemode.PrepLatecomer(PlayerState) then
	--		gamemode.EnterPlayArea(PlayerState)
	--	end
	end
	
	
	if ReadyStatus == "WaitingToReadyUp" 
	and gamemode.GetRoundStage() == "PreRoundWait" 
	and gamemode.PrepLatecomer(PlayerState) then
		gamemode.EnterPlayArea(PlayerState)
	end
end

function teamelimination:CheckReadyUpTimer()
	if gamemode.GetRoundStage() == "WaitingForReady" or gamemode.GetRoundStage() == "ReadyCountdown" then
		local ReadyPlayerTeamCounts = gamemode.GetReadyPlayerTeamCounts(true)
		local BlueReady = ReadyPlayerTeamCounts[self.PlayerTeams.Blue.TeamId]
		local RedReady = ReadyPlayerTeamCounts[self.PlayerTeams.Red.TeamId]
		if (BlueReady > 0 ) or self.DebugMode then
			if BlueReady + RedReady >= gamemode.GetPlayerCount(true) then
				gamemode.SetRoundStage("PreRoundWait")
			else
				gamemode.SetRoundStage("ReadyCountdown")
			end
		end
	end
end

function teamelimination:CheckReadyDownTimer()
	if gamemode.GetRoundStage() == "ReadyCountdown" then
		local ReadyPlayerTeamCounts = gamemode.GetReadyPlayerTeamCounts(true)
		local BlueReady = ReadyPlayerTeamCounts[self.PlayerTeams.Blue.TeamId]
		local RedReady = ReadyPlayerTeamCounts[self.PlayerTeams.Red.TeamId]
		if (not self.DebugMode and (BlueReady < 1 or RedReady < 1))
		or (    self.DebugMode and (BlueReady < 1 and RedReady < 1)) then
			gamemode.SetRoundStage("WaitingForReady")
		end
	end
end

function teamelimination:SpawnOpFor()
	-- reorganised 8/9 September 2021 by MF to improve randomisation and use of all spawns while still respecting priorities
	-- (it gets quite complicated)

	local OrderedSpawns = {}

	-------------------------
	if "UseOldMethod" == "True" then
		-- just park this here for now - old method, not used
		for Key, Group in ipairs(self.PriorityGroupedSpawns) do
			for i = #Group, 1, -1 do
				local j = umath.random(i)
				Group[i], Group[j] = Group[j], Group[i]
				table.insert(OrderedSpawns, Group[i])
			end
		end
	end
	--------------------
	
	local RejectedSpawns = {}
	local Group 
	local AILeftToSpawn

	for CurrentPriorityGroup = 1, self.LastSpawnPriorityGroup do
						
		AILeftToSpawn =  math.max( 0, self.Settings.OpForCount.Value - #OrderedSpawns )
		-- this will be zero if the T count is already reached
		
		local CurrentAISpawnTarget 
		-- number of spawns to try and add from this priority group
		
		-- determine how many spawns we're aiming for:
		if AILeftToSpawn > 0 then
			if CurrentPriorityGroup == 1 then
				if self.AlwaysUseEveryPriorityOneSpawn then
					CurrentAISpawnTarget = AILeftToSpawn
				else
					CurrentAISpawnTarget = math.ceil( AILeftToSpawn * (1 - self.MinimumProportionOfNonPriorityOneSpawns) )
					-- leave a few slots spare for lower priorities (default 15%)
					-- if the number of priority 1 spawns is lower than this number, then all priority 1 spawns will be used
					-- (this only has an effect if there are lots of P1 spawns and not a big T count)
				end
				
			elseif CurrentPriorityGroup == self.LastSpawnPriorityGroup then
				CurrentAISpawnTarget = AILeftToSpawn
				-- if this is the first group, or the last group, then try spawn all of the AI
				
			else
				local CurrentNumberOfSpawns = #self.SpawnPriorityGroups[CurrentPriorityGroup]
				local RemainingSpawnsInLowerPriorities = math.max( 0, self.TotalNumberOfSpawnsFound - CurrentNumberOfSpawns - #OrderedSpawns)
				local CurrentProportionOfSpawnsLeft =  CurrentNumberOfSpawns / ( CurrentNumberOfSpawns + (RemainingSpawnsInLowerPriorities * self.ProportionOfPriorityGroupToSpawn) ) 
				-- spawn a suitable number of spawns in dependence on the number of spawns in this group vs number of spawns remaining in lower groups, but fudge it to be bigger than the actual proportion
				
				CurrentAISpawnTarget = math.ceil(AILeftToSpawn * CurrentProportionOfSpawnsLeft)
				
				--print("SpawnOpFor(): found " .. CurrentNumberOfSpawns .. " spawns in current priority group " .. CurrentPriorityGroup .. ", vs " .. RemainingSpawnsInLowerPriorities .. " spawns in lower priorities.")
				--print("SpawnOpFor(): using fudged proportion of " .. CurrentProportionOfSpawnsLeft)
				
				-- starting with 70%, so if 10 AI are left to spawn, we will attempt to spawn 7 of them from this group
			end
		else
			CurrentAISpawnTarget = 0
			-- no AI left to spawn so don't bother spawning any - just dump straight into RejectedSpawns{}
		end


		print("SpawnOpFor(): Picking max " .. CurrentAISpawnTarget .. " AI from priority group " .. CurrentPriorityGroup .. " with " .. AILeftToSpawn .. " AI left to spawn out of " .. self.Settings.OpForCount.Value .. " total.")

		-- now transfer the appropriate number of spawns (randomly picked) to the target list (OrderedSpawns)
		-- and dump the remainder in the RejectedSpawns table (to be added to the end of the target list once completed)
		
		Group = self.SpawnPriorityGroups[CurrentPriorityGroup]

		if Group == nil then
			print("SpawnOpFor(): Table entry for priority group " .. CurrentPriorityGroup.. " was unexpectedly nil")
		else
		
			print("SpawnOpFor(): actually found " .. #Group .. " AI in group " .. CurrentPriorityGroup)
		
			if #Group > 0 then
				for i = #Group, 1, -1 do
					local j = umath.random(i)
					Group[i], Group[j] = Group[j], Group[i]

					if CurrentAISpawnTarget > 0 then
						table.insert(OrderedSpawns, Group[i])
						CurrentAISpawnTarget = CurrentAISpawnTarget - 1
					else
						table.insert(RejectedSpawns, Group[i])
					end
				end
				-- ^ shuffle this group to randomise
					
			else
				print("SpawnOpFor(): Priority group " .. CurrentPriorityGroup.. " was unexpectedly empty")
			end
			
		end
	end
	
	
	-- now add all the rejected spawns onto the list, in case extra spawns are needed
	-- if we ran out of spawns in the above process, this will still provide a sensible selection of spawns
	
	--print("SpawnOpFor(): topping off list of spawns with " .. #RejectedSpawns .. " excess/rejected spawns")
	
	for i = 1, #RejectedSpawns do
		table.insert(OrderedSpawns, RejectedSpawns[i])
	end
	
	
	--OrderedSpawns = OrderedSpawns + self.CivSpawn
	
	gamemode.SetTeamAttitude(100, 2, "Friendly") -- doesn't like self.Settings.PlayerTeams.Red.TeamId for some reason
	gamemode.SetTeamAttitude(2 , 100,  "Friendly")
	
	gamemode.SetTeamAttitude(99, 2, "Friendly") -- doesn't like self.Settings.PlayerTeams.Red.TeamId for some reason
	gamemode.SetTeamAttitude(2 , 99,  "Friendly")
	
	gamemode.SetTeamAttitude(100, 99, "Friendly")
	gamemode.SetTeamAttitude(99, 100,  "Friendly")

	ai.CreateOverDuration(4.0, self.Settings.OpForCount.Value, OrderedSpawns, self.OpForTeamTag)
	--local OpForControllers = ai.GetControllers('GroundBranch.GBAIController', self.OpForTeamTag, 255, 255)
end

function teamelimination:OnRoundStageSet(RoundStage)
	if RoundStage == "WaitingForReady" then
	
		timer.Clear("DisplayTickets")
		timer.ClearAll()
		ai.CleanUp(self.OpForTeamTag)
		ai.CleanUp(self.CivTeamTag)
		self.BumRushMode = false
		
		gamemode.ClearGameStats()
		
		if self.CompletedARound then
			self:RandomiseObjectives()
		end


		self.extractactivated = false
		self.CompletedARound = false
		
	elseif RoundStage == "PreRoundWait" then
		gamemode.ResetTeamScores()
		gamemode.ResetPlayerScores()
		
		gamemode.SetDefaultRoundStageTime("InProgress", self.Settings.RoundTime.Value)
		self:SpawnOpFor()

	elseif RoundStage == "InProgress" then
		
		self:SpawnCiv()


	elseif RoundStage == "PostRoundWait" then

		self.CompletedARound = true
		self:RandomiseObjectives()
		-- cause randomisation of objectives

	end
end


function teamelimination:SpawnCiv()

	self.CivSpawn = {} -- reset the civ array
	local AllCivSpawns = gameplaystatics.GetAllActorsOfClassWithTag('GroundBranch.GBAISpawnPoint', self.CivTeamTag) -- get all the ai spawns with the "OpFor" tag - if not then don't get the various sets
	for i, CivInd in ipairs(AllCivSpawns) do	-- go through all the Opfor ai and test if have the set tags
		if actor.HasTag(CivInd, self.CivTeamTag) then
			table.insert(self.CivSpawn, CivInd)
		end
	end
	
	
	self.CivilianCasualties = 0
	self.TotalCivilianCasualties = 0
	
	
	gamemode.SetTeamAttitude( 99, 1 , "Enemy") -- doesn't like self.Settings.PlayerTeams.Blue.TeamId
	gamemode.SetTeamAttitude( 1 , 99 ,  "Enemy")
	
	gamemode.SetTeamAttitude(99, 2, "Neutral") -- doesn't like self.Settings.PlayerTeams.Red.TeamId for some reason
	gamemode.SetTeamAttitude(2 , 99,  "Neutral")
	
	gamemode.SetTeamAttitude(100, 99, "Neutral")
	gamemode.SetTeamAttitude(99, 100,  "Neutral")
	
	ai.CreateOverDuration(4.0, self.Settings.CivilianCount.Value, self.CivSpawn, self.CivTeamTag)
end


function teamelimination:OnRoundStageTimeElapsed(RoundStage)


	if RoundStage == "InProgress" then
		self:ScoreTeamAtEndOfRound()
		gamemode.AddGameStat("Result=None")
		gamemode.AddGameStat("Summary=ReachedTimeLimit")
		gamemode.SetRoundStage("PostRoundWait")
		
		return true
	end
end





function teamelimination:OnCharacterDied(Character, CharacterController, KillerController)

	
	if gamemode.GetRoundStage() == "PreRoundWait" or gamemode.GetRoundStage() == "InProgress" then
	
		if CharacterController ~= nil and KillerController ~= nil then
			--local PlayerLives = player.GetLives(CharacterController)
			local DeadId = actor.GetTeamId(Character)
			local KillerId = actor.GetTeamId(KillerController)

		
			if DeadId == 99 then -- code for  self.CivTeamId doesn't seem to accept it
				
				self.TotalCivilianCasualties = self.TotalCivilianCasualties + 1
				
				local isitblue = actor.GetTeamId(KillerController)
				print("Civilian Killed by TeamId: ( " .. isitblue .. " )" )	
					
				if isitblue ==  self.PlayerTeams.Blue.TeamId then
				
					self.CivilianCasualties = self.CivilianCasualties + 1
					
					
					print("Civilian Casualties: " .. self.CivilianCasualties)
					
					gamemode.AwardTeamScore( self.PlayerTeams.Blue.TeamId , "CivDead" ,  1 )
					player.AwardPlayerScore( KillerController , "CivKilled" ,  1 )
					
					
					if self.CivilianCasualties > self.Settings.AcceptedCivilianCasualities.Value then
						self:CheckEndRoundTimer()
					end
				else
					gamemode.AwardTeamScore( self.PlayerTeams.Blue.TeamId , "CivCrossfire" ,  1 )
					gamemode.AwardTeamScore( self.PlayerTeams.Red.TeamId , "CivCrossfire" ,  1 )
				end
				
			elseif DeadId == 100 then -- code for self.OpforTeamID
				print("Baddie Killed")	

				gamemode.AwardTeamScore( self.PlayerTeams.Blue.TeamId , "OpForDead" , 1  )
				gamemode.AwardTeamScore( self.PlayerTeams.Red.TeamId , "OpForDead2" , 1  )
				
				if KillerId == self.PlayerTeams.Blue.TeamId then
					player.AwardPlayerScore( KillerController , "OpForKilled" ,  1 )
				end
				
			elseif DeadId == nil then
				print("PlayerTeam unexpectedly nil")
				
				
			elseif DeadId == self.PlayerTeams.Blue.TeamId then
			
				
				gamemode.AwardTeamScore( self.PlayerTeams.Red.TeamId , "KilledBlue" , 1  )
				gamemode.AwardTeamScore( self.PlayerTeams.Blue.TeamId , "OperativesDeceased" , 1  )	
				
				if KillerId == self.PlayerTeams.Blue.TeamId and CharacterController ~= KillerController then -- team kill
					player.AwardPlayerScore( KillerController , "KilledTeammate" ,  1 )
				elseif KillerId == self.PlayerTeams.Red.TeamId then -- RED killed BLUE
					player.AwardPlayerScore( KillerController , "KilledBlue" ,  1 )
				end
			
			elseif DeadId == self.PlayerTeams.Red.TeamId then

				gamemode.AwardTeamScore( self.PlayerTeams.Red.TeamId , "OperativesDeceased" , 1  )
				gamemode.AwardTeamScore( self.PlayerTeams.Blue.TeamId , "KilledRed" , 1  )
				
				if KillerId == self.PlayerTeams.Red.TeamId and CharacterController ~= KillerController then -- team kill
					player.AwardPlayerScore( KillerController , "KilledTeammate" ,  1 )
				elseif KillerId == self.PlayerTeams.Blue.TeamId then -- BLUE killed RED
					player.AwardPlayerScore( KillerController , "KilledRed" ,  1 )
				end
			
			
			elseif DeadId ~= self.PlayerTeams.Blue.TeamId and DeadId ~= self.PlayerTeams.Red.TeamId then
				print("PlayerTeam ( " .. DeadId .. " ) was unexpectedly not from a known team")
			end
			
			
			
			local BluePlayersWithLives = gamemode.GetPlayerListByLives(self.PlayerTeams.Blue.TeamId, 1, true)
			local RedPlayersWithLives = gamemode.GetPlayerListByLives(self.PlayerTeams.Red.TeamId, 1, true)
			local CivWithLives = ai.GetControllers('GroundBranch.GBAIController', self.CivTeamTag, 255, 255) 
			local BaddiesWithLives = ai.GetControllers('GroundBranch.GBAIController', self.OpForTeamTag, 255, 255) 
			


			if actor.HasTag(CharacterController, self.OpForTeamTag) then  -- bot was killed
				timer.Set("CheckEndRound", self, self.CheckEndRoundTimer, 1.0, false)
			else
				if #BluePlayersWithLives < 1 then
					self:CheckEndRoundTimer()
					-- call immediately because round is about to end and nothing more can happen
				
				elseif #RedPlayersWithLives < 1 then
					timer.Set("CheckEndRound", self, self.CheckEndRoundTimer, 1.0, false)
				
				else
					timer.Set("CheckEndRound", self, self.CheckDeathCountTimer, 1.0, false)
				end
			end
		end
	end
end



function teamelimination:PlayerBecomesSpectator(Player)
	--print ("----PlayerBecomesSpectator() called")

	local RoundStage = gamemode.GetRoundStage()
	
	if RoundStage == 'InProgress'
	or RoundStage == 'PreRoundWait' then
		timer.Set("CheckEndRound", self, self.CheckEndRoundTimer, 1.0, false);	
	end
	
	-- this new callback catches a game over condition that was otherwise lost (last player on team who still has lives/reinforcements chooses to spectate rather than respawn)
end


function teamelimination:PlayerEnteredReadyRoom(Player)
	local RoundStage = gamemode.GetRoundStage()
	
	if RoundStage == 'InProgress'
	or RoundStage == 'PreRoundWait' then
		--timer.Set("CheckEndRound", self, self.CheckEndRoundTimer, 1.0, false);
		self:CheckEndRoundTimer()
		--print("----PlayerEnteredReadyRoom(): completed CheckEndRoundTimer() check")
		--print("----current RoundStage: " .. gamemode.GetRoundStage())
		-- we can't put this on a timer because the game mode immediately resets to WaitingForReady
	end
end




function teamelimination:CheckEndRoundTimer()


	local BluePlayersWithLives = gamemode.GetPlayerListByLives(self.PlayerTeams.Blue.TeamId, 1, false)
	local RedPlayersWithLives = gamemode.GetPlayerListByLives(self.PlayerTeams.Red.TeamId, 1, false)
	local OpForControllers = ai.GetControllers('GroundBranch.GBAIController', self.OpForTeamTag, 255, 255)
	local CivControllers = ai.GetControllers('GroundBranch.GBAIController', self.CivTeamTag, 255, 255)
	
	
	

	if DebugMode == true then

		
		print("Blue team : " .. #BluePlayersWithLives)
		print("Red team : " .. #RedPlayersWithLives)
		
		print("Civvis : " .. #CivControllers)
		print("Baddies : " .. #OpForControllers)

	end
	
--	if self.DebugMode == true then
--		return
		-- the round never ends!
--	end

	if self.CivilianCasualties > self.Settings.AcceptedCivilianCasualities.Value then
	--	print("Civilian casualties too high: ".. self.CivilianCasualties)
		self:ScoreTeamAtEndOfRound( )
		gamemode.AddGameStat("Result=Team2")
		gamemode.AddGameStat("Summary=TooManyCivilianCasualties")
		gamemode.SetRoundStage("PostRoundWait")
	end
	
--	if #RedPlayersWithLives == 0   then 
--		print("Extraction active")
--		actor.SetActive(self.ExtractionPoints[self.ExtractionPointIndex], true)
--	end
	
	if #BluePlayersWithLives > 0 and #RedPlayersWithLives == 0 and OpForControllers == 0 then -- and not self.DebugMode then
		self:ScoreTeamAtEndOfRound( )
		gamemode.AddGameStat("Result=Team1")
		gamemode.AddGameStat("Summary=RedEliminated")
		gamemode.AddGameStat("CompleteObjectives=EliminateAnyHVT")
		
		if self.CivilianCasualties == 0 then
			gamemode.AddGameStat("CompleteObjectives=AvoidCivilianCasualties")
		end
		gamemode.SetRoundStage("PostRoundWait")

	elseif #BluePlayersWithLives == 0  then -- and not self.DebugMode then
		self:ScoreTeamAtEndOfRound( )
		gamemode.AddGameStat("Result=Team2")
		gamemode.AddGameStat("Summary=BlueEliminated")
		gamemode.AddGameStat("CompleteObjectives=EliminateAttackingForce")
		gamemode.SetRoundStage("PostRoundWait")
	end
	
	

	
end


function teamelimination:OnTargetCaptured()
	-- this is called from the laptop IntelTarget.lua script when a laptop is successfully hacked
 	--actor.SetActive(self.ExtractionPoints[self.ExtractionPointIndex], true)
	print("Closed laptop")

end

function teamelimination:OnLaptopPickedUp()
	-- laptop has been picked up, so disable proximity alert 
	--print("OnLaptopPickedUp() called")
	print("Picked up laptop")
	self.extractactivated = false
	
	local BlueWithLives = gamemode.GetPlayerListByLives(self.PlayerTeams.Blue.TeamId, 1, false)
	local RedWithLives = gamemode.GetPlayerListByLives(self.PlayerTeams.Red.TeamId, 1, false)
	
	for i = 1, #BlueWithLives do
		local PlayerCharacter = player.GetCharacter(BlueWithLives[i])
		
		if player.HasItemWithTag(PlayerCharacter, self.LaptopTag) then
	
			gamemode.AwardTeamScore( self.PlayerTeams.Blue.TeamId , "IntelCollected" ,  1 )
			player.AwardPlayerScore( PlayerCharacter , "IntelCollected" ,  1 )		
		end
	end
	
	for ib = 1, #RedWithLives do
		local PlayerCharacter = player.GetCharacter(RedWithLives[ib])
		
		if player.HasItemWithTag(PlayerCharacter, self.LaptopTag) then
	
			gamemode.AwardTeamScore( self.PlayerTeams.Red.TeamId , "IntelCollected" ,  1 )
			-- player.AwardPlayerScore( PlayerCharacter , "IntelCollected" ,  1 )		 -- red doesn't get any personal points for collecting intel since they have intel from the start
		end
	end
	
	
--	if self.Settings.ProximityAlert.Value == 1  then
--		gamemode.SetObjectiveLocation( nil ) 
--	end
end



function teamelimination:OnLaptopPlaced(NewLaptop)
	-- called when the laptop is dropped or replaced (e.g. carrier is killed)
	-- want to start the proximity alert again at its location
	
	-- (this is redundant the first time the laptop is captured)
	
	--print("OnLaptopPlaced() called")

	return
	-- this isn't working so let's just turn it off for now
	
	--if self.Settings.ProximityAlert.Value == 1 and NewLaptop ~= nil then
	--	local NewLaptopLocation = actor.GetLocation( NewLaptop )
	--	if NewLaptopLocation ~= nil then
	--		gamemode.SetObjectiveLocation( NewLaptopLocation ) 
	--		print("Resetting objective location to (" .. NewLaptopLocation.x .. ", " .. NewLaptopLocation.y .. ", " .. NewLaptopLocation.z .. ")")
	--	end
	--end
end





function teamelimination:OnGameTriggerBeginOverlap(GameTrigger, Character)

	
	if player.HasItemWithTag(Character, self.LaptopTag) == true then
	
		-- NOTE: Trying to get exit to come up only when you are near the correct exit
		
		if self.extractactivated == false then
		
			if actor.GetTeamId(Character) ==  self.PlayerTeams.Red.TeamId then
			
			
				-- NOTE - HVT with laptop attemping to escape with intel and gets burned
				local FlareStartup = gameplaystatics.GetAllActorsOfClassWithTag('GroundBranch.GBGameTrigger', "StartFlare")	

				for i, FlarePoint in ipairs(FlareStartup) do 
					if FlarePoint == GameTrigger then
						gamemode.BroadcastGameMessage("Informat spotted POI near an extraction zone", "Lower", 3.0)
						self.extractactivated = true  -- this red player has been burned and can no longer escape
					end
				end
				
				-- NOTE - HVT with laptop contacting informant to get smoke in extraction zone
				local RedExfil = gameplaystatics.GetAllActorsOfClassWithTag('GroundBranch.GBGameTrigger', "RedExfil")	
				
				for ii, ExfilRed in ipairs(RedExfil) do 
					if ExfilRed == GameTrigger then
					
						local chanceofgettingmessage = math.random(0,1) -- 50% chanceofgettingmessage
						if chanceofgettingmessage == 0 then
							player.ShowGameMessage(Character, "                Help will come to rescue you soon.", "Lower", 7.0)
							player.ShowGameMessage(Character, "We will mark the escape zone for you in 30 seconds. Be ready!", "Lower", 7.0)
							print("Red player at informant point")
							timer.Set("HVTExfilTimer", self, self.HVTExfilTimer, 30, false);
							self.extractactivated = true
							
							for iii, ExfilRedTurnoff in ipairs(RedExfil) do 
								actor.SetActive(ExfilRedTurnoff, false)
								print("Comms tower offline")
							end
						else
							player.ShowGameMessage(Character, "This radio tower is not working.", "Lower", 7.0)
							actor.SetActive(ExfilRed, false)
						end
					end
				end

				
			else
				actor.SetActive(self.ExtractionPoints[self.ExtractionPointIndex], true)
				self.extractactivated = true
			
				local FlareStartup = gameplaystatics.GetAllActorsOfClassWithTag('GroundBranch.GBGameTrigger', "StartFlare")	

				for i, FlarePoint in ipairs(FlareStartup) do -- look through all the guard points for the initial one
					actor.SetActive(FlarePoint, false)	-- deactivate the trigger point
					print("deactivated exit triggers")
				end
			end
			
		end
		
		--actor.SetActive(self.ExtractionPoints[self.ExtractionPointIndex], true) -- flare goes on
		
		if actor.GetTeamId(Character) ==  self.PlayerTeams.Red.TeamId then
			timer.Set("CheckOPFORExfil", self, self.CheckOPFORExfilTimer, 1.0, true)
			print("Red with laptop at extraction point")
		else
			timer.Set("CheckBLUFORExfil", self, self.CheckBLUFORExfilTimer, 1.0, true)
			print("Blue with laptop at extraction point")
		end
	
	end
end	


function teamelimination:ScoreTeamAtEndOfRound( TeamScores )

		local RedWithLives = gamemode.GetPlayerListByLives(self.PlayerTeams.Red.TeamId, 1, false)
		gamemode.AwardTeamScore( self.PlayerTeams.Blue.TeamId , "RedAliveAtEnd" , #RedWithLives )
		
		if TeamScores ~= nil then
			
			if TeamScores == self.PlayerTeams.Blue.TeamId then -- team 1 managed to exfil
				gamemode.AwardTeamScore( self.PlayerTeams.Blue.TeamId , "BlueExfil" ,  1 )
			elseif TeamScores == self.PlayerTeams.Red.TeamId then -- team 1 managed to exfil
				gamemode.AwardTeamScore( self.PlayerTeams.Red.TeamId , "RedExfil" ,  1 )
			end
			
		end
		
		local civiliansalive = self.Settings.CivilianCount.Value - self.TotalCivilianCasualties
		print(civiliansalive)
		
		local opforescaped = ai.GetControllers('GroundBranch.GBAIController', self.OpForTeamTag, 255, 255)
	
		gamemode.AwardTeamScore( self.PlayerTeams.Blue.TeamId , "CivEscaped" , civiliansalive )
		gamemode.AwardTeamScore( self.PlayerTeams.Blue.TeamId , "OpForEscaped" ,  #opforescaped )
		gamemode.AwardTeamScore( self.PlayerTeams.Red.TeamId , "OpForEscaped2" ,  #opforescaped )
			
		
		
end


function teamelimination:HVTExfilTimer()
	if gamemode.GetRoundStage() == "InProgress" then 
		local RedPlayersWithLives = gamemode.GetPlayerListByLives(self.PlayerTeams.Red.TeamId, 1, true)
		if #RedPlayersWithLives > 0 then -- at least one of the reds is still alive, open up the extraction
			actor.SetActive(self.ExtractionPoints[self.ExtractionPointIndex], true)
			print("Exfil point activated by Red team")
		else
			self.extractactivated = false -- red died, let the bluefor capture laptop
		end
	end
 end

function teamelimination:CheckBLUFORExfilTimer()
	local Overlaps = actor.GetOverlaps(self.ExtractionPoints[self.ExtractionPointIndex], 'GroundBranch.GBCharacter')
	local PlayersWithLives = gamemode.GetPlayerListByLives(self.PlayerTeams.Blue.TeamId, 1, true)
	
	local bExfiltrated = false
	local bLivingOverlap = false
	local bLaptopSecure = false
	local PlayerWithLapTop = nil
	
	local RedPlayersWithLives = gamemode.GetPlayerListByLives(self.PlayerTeams.Red.TeamId, 1, true)

	for i = 1, #PlayersWithLives do
		bExfiltrated = false

		local PlayerCharacter = player.GetCharacter(PlayersWithLives[i])
	
		-- May have lives, but no character, alive or otherwise.
		if PlayerCharacter ~= nil then
			for j = 1, #Overlaps do
				if Overlaps[j] == PlayerCharacter then  -- NOTE: needs to be changed to two players only
					bLivingOverlap = true
					bExfiltrated = true
					if player.HasItemWithTag(PlayerCharacter, self.LaptopTag) then
						bLaptopSecure = true
						PlayerWithLapTop = PlayersWithLives[i]
					end
					break
				end
			end
		end

		if bExfiltrated == false then
			break
		end
	end
	
	if bLaptopSecure then
		if bExfiltrated then
		 	timer.Clear(self, "CheckBLUFORExfil")
		 	gamemode.AddGameStat("Result=Team1")
			
			
			self:ScoreTeamAtEndOfRound( self.PlayerTeams.Blue.TeamId )
			
			if  self.TotalCivilianCasualties == 0 and #RedPlayersWithLives == 0 then
				gamemode.AddGameStat("Summary=GoldStar")
				gamemode.AddGameStat("CompleteObjectives=EliminateAnyHVT,SecureIntel,ReachGreenMarker,AvoidCivilianCasualties")
			elseif #RedPlayersWithLives == 0 then
				gamemode.AddGameStat("HTVdown")
				gamemode.AddGameStat("CompleteObjectives=EliminateAnyHVT,SecureIntel,ReachGreenMarker")
			elseif self.TotalCivilianCasualties == 0 then
				gamemode.AddGameStat("Summary=IntelRetrievedNC")
				gamemode.AddGameStat("CompleteObjectives=SecureIntel,ReachGreenMarker,AvoidCivilianCasualties")
			else
				gamemode.AddGameStat("Summary=IntelRetrieved")
				gamemode.AddGameStat("CompleteObjectives=SecureIntel,ReachGreenMarker")
			end
			
		 	gamemode.SetRoundStage("PostRoundWait")
		elseif PlayerWithLapTop ~= nil and self.TeamExfilWarning == false then
			self.TeamExfilWarning = true
		end
	end
end


function teamelimination:CheckOPFORExfilTimer()
	local Overlaps = actor.GetOverlaps(self.ExtractionPoints[self.ExtractionPointIndex], 'GroundBranch.GBCharacter')
	--local PlayersWithLives = gamemode.GetPlayerListByLives(self.PlayerTeams.Red.TeamId, 1, true)
	
	local bExfiltrated = false
	local bLivingOverlap = false
	local bLaptopSecure = false
	local PlayerWithLapTop = nil
	
	local RedPlayersWithLives = gamemode.GetPlayerListByLives(self.PlayerTeams.Red.TeamId, 1, true)

	for i = 1, #RedPlayersWithLives do
		bExfiltrated = false

		local PlayerCharacter = player.GetCharacter(RedPlayersWithLives[i])
	
		-- May have lives, but no character, alive or otherwise.
		if PlayerCharacter ~= nil then
			for j = 1, #Overlaps do
				if Overlaps[j] == PlayerCharacter then  -- NOTE: needs to be changed to two players only
					bLivingOverlap = true
					bExfiltrated = true
					if player.HasItemWithTag(PlayerCharacter, self.LaptopTag) then
						bLaptopSecure = true
						PlayerWithLapTop = RedPlayersWithLives[i]
					end
					break
				end
			end
		end

		if bExfiltrated == false then
			break
		end
	end
	
	if bLaptopSecure then
		if bExfiltrated then
		
			self:ScoreTeamAtEndOfRound( self.PlayerTeams.Red.TeamId )
			
		 	timer.Clear(self, "CheckOPFORExfil")
		 	gamemode.AddGameStat("Result=Team2")
			gamemode.AddGameStat("Summary=RedEscaped")
			gamemode.AddGameStat("CompleteObjectives=SecureIntel,CallForHelpAtRadioTower,Escape") 
		 	gamemode.SetRoundStage("PostRoundWait")
		elseif PlayerWithLapTop ~= nil and self.TeamExfilWarning == false then
			self.TeamExfilWarning = true
		end
	end
end



function teamelimination:GetInsertionPointNameForLaptop(Laptop)
	local AllInsertionPoints = gameplaystatics.GetAllActorsOfClass('GroundBranch.GBInsertionPoint')
	local InsertionPointName

	for i, InsertionPoint in ipairs(AllInsertionPoints) do
		if actor.HasTag(InsertionPoint, "Defenders") then
			InsertionPointName = gamemode.GetInsertionPointName(InsertionPoint)
			if actor.HasTag(Laptop, InsertionPointName) then
				return InsertionPointName
			end
		end
	end
	
	-- self:ReportError("Selected laptop did not have a tag corresponding to a defender insertion point, so no intel can be provided.")
	return nil
end


function teamelimination:GetNumberOfSearchLocations()
		-- 0 = none
		-- 1 = one (true location)
		-- 2 = two
		-- 3 = half
		-- 4 = all but one
		-- 5 = all
	
	return #self.LaptopLocationNameList
	
--[[	if self.Settings.DisplaySearchLocations.Value <= 2 then
		return self.Settings.DisplaySearchLocations.Value
	elseif self.Settings.DisplaySearchLocations.Value == 3 then
		return math.floor(#self.LaptopLocationNameList / 2)
		-- round down
	elseif self.Settings.DisplaySearchLocations.Value == 4 then
		return #self.LaptopLocationNameList - 1
	else
		return #self.LaptopLocationNameList
	end
	]]--
	--return 3
	-- shouldn't get here
	
end

function teamelimination:OnMissionSettingChanged(Setting, NewValue)
	-- NB this may be called before some things are initialised
	-- need to avoid infinite loops by setting new mission settings
	
	
	if Setting == 'DisplaySearchLocations' then
		self:RandomiseObjectives()
	
	end
end




function teamelimination:ShouldCheckForTeamKills()
	if gamemode.GetRoundStage() == "InProgress" then 
		return true
	end
	return false
end


function teamelimination:PlayerCanEnterPlayArea(PlayerState)
	if player.GetInsertionPoint(PlayerState) ~= nil then
		return true
	end
	return false
end


function teamelimination:LogOut(Exiting)
	if gamemode.GetRoundStage() == "PreRoundWait" or gamemode.GetRoundStage() == "InProgress" then
		timer.Set("CheckEndRound", self, self.CheckEndRoundTimer, 1.0, false);
	end
end



return teamelimination