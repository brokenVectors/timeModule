local TweenService = game:GetService('TweenService')
local module = {}
module.positions = {}
module.tracking = {}
module.indepTracking = {}
module.anchored = {}
module.time = 0
module.speed = 1
module.reverse = false

function module:Track(obj, independent)
	module.positions[obj] = {}
	
	if independent then
		module.indepTracking[obj] = {
			reverse = false;
			time = 0;
			speed = module.speed;
		}
	else
		table.insert(module.tracking, obj)
	end

	if obj.Anchored then
		table.insert(module.anchored, obj)
	end
end

function module:Untrack(obj)
	assert(table.find(module.tracking, obj) or module.indepTracking[obj], "Cannot untrack a non-tracked object!")

	module.positions[obj] = nil
	module.indepTracking[obj] = nil
	table.remove(module.tracking, table.find(module.tracking, obj))
end

function module:Update(dt)
	assert(dt, "Please provide a delta time as the first argument.")
	
	-- Update independent parts 
	for obj, info in pairs(module.indepTracking) do
		coroutine.wrap(function()
			if info.reverse and info.time > 0 then
				module.indepTracking[obj].time -= info.speed
				obj.Anchored = true
			elseif info.reverse then
				module:Unreverse(obj)
				script.IndependentReverseFinished:Fire(obj)
				return
			else
				module.indepTracking[obj].time += info.speed
			end
			
			if not module.positions[obj] then
				module.positions[obj] = {}
			end
			
			if not module.positions[obj][module.indepTracking[obj].time] then
				module.positions[obj][module.indepTracking[obj].time] = obj.CFrame
			end
			
			if info.reverse then
				-- support time reversing
				local tween = TweenService:Create(obj, TweenInfo.new(dt, Enum.EasingStyle.Linear), {["CFrame"] = module.positions[obj][info.time]})
				tween:Play()
			end
		end)()
	end
	
	-- Update dependent parts
	if module.time < 0 then
		module:Unreverse()
		script.DependentReverseFinished:Fire()
	end
	
	if module.reverse then
		module.time -= module.speed
	elseif #module.tracking > 0 then
		module.time += module.speed
	end
	
	for _, obj in ipairs(module.tracking) do
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

function module:SetSpeed(speed, obj)
	assert(speed == math.abs(speed), "Speed must be a positive integer!")
	assert(module:IsReverse(obj), "Sorry, this module cannot change time speed when not in reverse! I'm trying to find ways to implement this, don't worry.")
	
	if obj then
		module.indepTracking[obj].speed = speed
		return
	end
	
	module.speed = speed
end

function module:IsReverse(obj)
	
	if obj and module.indepTracking[obj] then
		return module.indepTracking[obj].reverse
	end
	
	return module.reverse
end

function module:Unreverse(obj)
	assert(module:IsReverse(obj), "Unreverse can only be called when time is in reverse!")
	
	local function CheckAnchor(part)
		if not table.find(module.anchored, obj) then
			module.positions[part] = nil -- just in case
			part.Anchored = false
		end
	end
	
	if obj and module:IsReverse(obj) then
		CheckAnchor(obj)
		module.indepTracking[obj].reverse = false
		return
	end
	
	-- module:IsReverse() returned true
	for _, obj in ipairs(module.tracking) do
		CheckAnchor(obj)
	end
	module.reverse = false
end

function module:Reverse(obj)
	if obj then
		module.indepTracking[obj].reverse = true
		return
	end
	
	module.reverse = true
end

return module
