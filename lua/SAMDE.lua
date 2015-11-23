SAMDE_ = {
	type_ = "SAMDE",
}

metaTableSAMDE_ = {
	__index = SAMDE_
}

--- Type to calibrate a model using genetic algorithm. It returns a SAMDE type with the
-- fittest individual (a Model), its fit value, and the number of generations of the
-- simulation.
-- @arg data.model A Model.
-- @arg data.parameters A table with the possible parameter values. They can be
-- values or Choices. All Choices will be calibrated.
-- @arg data.fit A user-defined function that gets a model instance as argument and 
-- returns a numeric value of that particular model fitness,
-- this value will be minimized or maximized by SAMDE according to the maximize parameter. 
-- @arg data.size The maximum population size in each generation.
-- @arg data.maxGen The maximum number of generations. If the simulation reaches this value,
-- it stops and returns the Model that has the fittest result? TODO.
-- @arg data.threshold If the fitness of a model reaches this value, SAMDE stops and
-- returns such model.
-- @arg data.maximize An optional paramaters that determines if the fit will be maximized (true)
-- or minimized (false, default value).
-- @arg data.seed Optional seed parameter for Random(), default is system time.
--  must be must be maximized instead of minimized, default is false. 
-- @usage
-- import("calibration")
-- local MyModel = Model{
-- 	x = Choice{min = -100, max = 100},
-- 	y = Choice{min = 1, max = 10},
-- 	finalTime = 1,
-- 	init = function(self)
-- 		self.timer = Timer{
-- 			Event{action = function()
-- 				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
-- 			end}
-- 	}
-- 	end
-- }
-- c = SAMDE{
--     model = MyModel,
--     parameters = {x = Choice{min = -100, max = 100}, y = Choice {min = 1, max = 10}, finalTime = 1},
--     fit = function(model)
--     		return model.value
--     end
-- }
function SAMDE(data)
	mandatoryTableArgument(data, "model", "Model")
	mandatoryTableArgument(data, "parameters", "table")
	if data.fit == nil or type(data.fit) ~= "function" then
		customError("Function 'fit' was not implemented.")
	end

	verifyUnnecessaryArguments(data, {"model", "parameters", "maximize", "fit", "maxGen", "size", "threshold", "seed"})
	checkParameters(data.model, data)
	local best = {fit, instance, generations}
	if data.maximize == nil then
		data.maximize = false
	end

	best = SAMDECalibrate(data.parameters, data.model, data.fit, data.maximize, data.size, data.maxGen, data.threshold, data.seed)
	forEachOrderedElement(best, function(idx, att, type)
		data[idx] = att
	end)
	setmetatable(data, metaTableSAMDE_)
	return data
end

