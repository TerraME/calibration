SAMDE_ = {
	type_ = "SAMDE",
}

metaTableSAMDE_ = {
	__index = SAMDE_
}

--- Type to calibrate a model, returns a SAMDE type with the fittest individual,
-- the fit value and the number of generations.
-- @arg data a table containing the described variables.
-- @arg data.model  A model.
-- @arg data.parameters  A table of parameters to be calibrated.
-- @arg data.fit  A function that receives a Model and calibrated parameters
--  to calculate the instance fitness value.
-- @arg data.size  the population size for each generation.
-- @arg data.maxGen  If a model generation reach this value, the function stops.
-- @arg data.threshold  If a model fitness reach this value, the function stops.
-- @arg data.maximize  An optional paramaters that determines if the models fitness values
--  must be must be maximized instead of minimized, default is false. 
-- @usage c = SAMDE{
--     model = MyModel,
--     parameters = {x = Choice{min = 1, max = 10, step = 2}, finalTime = 1},
--     fit = function(model, parameter)
--     		...	
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

