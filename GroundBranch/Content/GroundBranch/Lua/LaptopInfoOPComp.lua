local laptop = {
	CurrentTime = 0,
}

function laptop:ServerUseTimer(User, DeltaTime)
	self.CurrentTime = self.CurrentTime + DeltaTime
	--local SearchTime = gamemode.script.Settings.SearchTime.Value
	local SearchTime = 1.0
	self.CurrentTime = math.max(self.CurrentTime, 0)
	self.CurrentTime = math.min(self.CurrentTime, SearchTime)

	local Result = {}
--	Result.Message = "Hello World"
	Result.Equip = false
	Result.Percentage = self.CurrentTime / SearchTime
	Result.Message = "Recommended Insurgent Kit"
	if Result.Percentage == 1.0 then
		self.CurrentTime = 0
		Result.Percentage = 0.0
		player.ShowGameMessage(User, "The recommended kit for this mission is Insurgent look", "Center", 10.0)
		player.ShowGameMessage(User, "Recommended Uniform: Shirt, Jeans and Shemag", "Center", 10.0)
		player.ShowGameMessage(User, "Recommended Weapons: AK, Dragunov or Fal with no sights", "Center", 10.0)
	elseif Result.Percentage == 0.0 then
		
		--[[	
		TODO - Change player to specific kit
		]]
	end
	return Result
end

function laptop:OnReset()
	self.CurrentTime = 0
end

function laptop:CarriedLaptopDestroyed()
	--[[
	if actor.HasTag(self.Object, gamemode.script.LaptopTag) then
		if gamemode.GetRoundStage() == "PreRoundWait" or gamemode.GetRoundStage() == "InProgress" then
			gamemode.BroadcastGameMessage("LaptopDestroyed", "Center", 10.0)
		end
	end
	]]
end

return laptop