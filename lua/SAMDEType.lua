SAMDE_ = {
	type_ = "SAMDE",
}

metaTableSAMDE_ = {
	__index = SAMDE_
}

---Type to calibrate a model, returns a SAMDE type with the fittest individual,
-- the fit value and the number of generations.
-- @arg data a Table containing: {model = A model,
-- parameters = a table of parameters to be calibrated,
-- size = the population size for each generation,
-- maxGen = If a model generation reach this value, the function stops,
-- threshold = If a model fitness reach this value, the function stops,
-- maximize = An optional paramaters that determines if the models fitness values
-- must be must be maximized instead of minimized, default is false}.
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
	local samdeValues = {}
	local samdeParam = {}
	local SamdeParamQuant = 0
	local samdeParamInfo = {}
	forEachOrderedElement(data.parameters, function (idx, attribute, atype)
		table.insert(samdeParam, idx)
		samdeParamInfo[idx] = {}
		if idx ~= "finalTime" then
			if attribute.min ~= nil then
				samdeParamInfo[idx].group = false
				if attribute.step ~= nil then
					samdeParamInfo[idx].step = true
					samdeParamInfo[idx].stepValue = attribute.step
				else 
					samdeParamInfo[idx].step = false
				end

				if attribute.max ~=nil then
					table.insert(samdeValues, {attribute.min, attribute.max})
				else
					table.insert(samdeValues, {attribute.min, math.huge()})
				end

			elseif attribute.max ~= nil then
					samdeParamInfo[idx].group = false
					if attribute.step ~= nil then
						samdeParamInfo[idx].step = true
						samdeParamInfo[idx].stepValue = attribute.step
					else 
						samdeParamInfo[idx].step = false
					end

					table.insert(samdeValues, { -1*math.huge(), attribute.max})
			else
				samdeParamInfo[idx].step = false
				samdeParamInfo[idx].group = true
				table.insert(samdeValues, attribute.values)
			end
		end

		SamdeParamQuant = SamdeParamQuant + 1
	end)
	if data.maximize == nil then
		data.maximize = false
	end

	best = SAMDECalibrate(samdeValues, SamdeParamQuant, data.model, data.finalTime, samdeParam, samdeParamInfo, data.fit, data.maximize, data.size, data.maxGen, data.threshold, data.mutation)
	forEachOrderedElement(best, function(idx, att, type)
		data[idx] = att
	end)
	setmetatable(data, metaTableSAMDE_)
	return data
end

