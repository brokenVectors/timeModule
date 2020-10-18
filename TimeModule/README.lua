--[[
	TimeModule:Track(BasePart part) Track the given object.
	TimeModule:Untrack(BasePart part) Stop tracking the given object.
	TimeModule:SetSpeed(unsigned integer speed) Set the speed. Only works when in reverse.
	TimeModule:IsReverse() Returns whether time is in reverse or not.
	TimeModule:Reverse() Reverse time.
	TimeModule:Unreverse() Unreverse time. Note that this doesn't replay all next frames, it lets time go back to normal after a reverse.
	TimeModule:Update(float deltaTime) Store the current position of all tracked parts.
]]--
