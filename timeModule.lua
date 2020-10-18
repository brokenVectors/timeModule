local TweenService = game:GetService('TweenService')
local module = {}
module.positions = {}
module.tracking = {}
module.anchored = {}
module.time = 0
module.speed = 1
module.reverse = false

function module:Track(obj)
	table.insert(module.tracking, obj)
	module.positions[obj] = {}

	if obj.Anchored then
		table.insert(module.anchored, obj)
	end
end

function module:Untrack(obj)
	assert(table.find(module.tracking, obj), "Cannot untrack a non-tracked object!")
	
	module.positions[obj] = nil
	table.remove(module.tracking, table.find(module.tracking, obj))
end

function module:Update(dt)
	assert(dt, "Please provide a delta time as the first argument.")
	
	if module.time < 0 then
		module:Unreverse()
		script.ReverseFinished:Fire()
	end
	
	if module.reverse then
		module.time -= module.speed
	else
		module.time += module.speed
	end
	
	for _,obj in ipairs(module.tracking) do
		if module.reverse then
			obj.Anchored = true
		end
		if not module.positions[obj] then
			module.positions[obj] = {}
		end
		if not module.positions[obj][module.time] then
			module.positions[obj][module.time] = obj.CFrame
		end
		if module.reverse then
			-- support time reversing
			local tween = TweenService:Create(obj, TweenInfo.new(dt, Enum.EasingStyle.Linear), {["CFrame"] = module.positions[obj][module.time]})
			tween:Play()
		end
	end
end

function module:SetSpeed(speed)
	assert(speed == math.abs(speed), "Speed must be a positive integer!")
	assert(module:IsReverse(), "Sorry, this module cannot change time speed when not in reverse! I'm trying to find ways to implement this, don't worry.")
	
	module.speed = speed
end

function module:IsReverse()
	return module.reverse
end

function module:Unreverse()
	assert(module:IsReverse(), "Unreverse can only be called when time is in reverse!")
	for _,obj in ipairs(module.tracking) do
		if not table.find(module.anchored, obj) then
			module.positions = {} -- just in case
			obj.Anchored = false
		end
	end
	module.reverse = false
	
end

function module:Reverse()
	module.reverse = true
end

return module
