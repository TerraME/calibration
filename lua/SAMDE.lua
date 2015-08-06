SAMDE_ = {
	type_ = "SAMDE",
}

metaTableSAMDE_ = {
	__index = SAMDE_
}

---Type to calibrate a model, returns a SAMDE type with the fittest individual,
-- the fit value and the number of generations.
-- @arg data a table containing the described variables.
-- @tabular Data
-- Variables  & Description \
-- "model" & A model. \
-- "parameters" & A table of parameters to be calibrated. \
-- "fit" & A function that receives a Model and calibrated parameters
--  to calculate the instance fitness value. \
-- "size" & the population size for each generation. \
-- "maxGen" & If a model generation reach this value, the function stops. \
-- "threshold" & If a model fitness reach this value, the function stops. \
-- "maximize" & An optional paramaters that determines if the models fitness values
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
	mandatoryTableArgument(data, "size", "number")
	mandatoryTableArgument(data, "maxGen", "number")
	mandatoryTableArgument(data, "threshold", "number")
	if data.mutation ~= nil and type(data.mutation) ~= "number" then
		incompatibleTypeError("mutation", "number", data.mutation)
	end

	if data.fit == nil or type(data.fit) ~= "function" then
		customError("Function 'fit' was not implemented.")
	end

	verifyUnnecessaryArguments(data, {"model", "parameters", "maximize", "fit", "maxGen", "mutation", "size", "crossing", "threshold"})
	checkParameters(data.model, data)
	local best = {fit, instance, generations}
	if data.maximize == nil then
		data.maximize = false
	end

	best = SAMDECalibrate(data.parameters, data.model, data.finalTime, data.fit, data.maximize, data.size, data.maxGen, data.threshold, data.mutation)
	forEachOrderedElement(best, function(idx, att, type)
		data[idx] = att
	end)
	setmetatable(data, metaTableSAMDE_)
	return data
end

