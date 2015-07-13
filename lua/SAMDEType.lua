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
	if data.fit == nil or type(data.fit) ~= "function" then
		customError("Function 'fit' was not implemented.")
	end
	verifyUnnecessaryArguments(data, {"model", "parameters", "maximize", "fit", "maxGen", "mutation", "size", "crossing", "threshold"})
	checkParameters(data.model, data)
	local startParams = {} 
	-- A table with the first possible values for the parameters to be tested.
	forEachOrderedElement(data.parameters, function(idx, attribute, atype)
		if idx ~= "finalTime" then
			if attribute.min ~= nil then
				startParams[idx] = attribute.min
			else
				startParams[idx] = attribute[1]
			end
		else
			startParams[idx] = attribute
		end
	end)
	local m = data.model(startParams) -- test the model with it's first possible values
	m:execute()
	local best = {fit = data.fit(m), instance = m, generations = 1}
	local samdeValues = {}
	local samdeParam = {}
	local SamdeParamQuant = 0
	forEachOrderedElement(data.parameters, function (idx, attribute, atype)
		table.insert(samdeParam, idx)
		if idx ~= "finalTime" then
			if attribute.min ~= nil then
				if attribute.max ~=nil then
					table.insert(samdeValues, {attribute.min, attribute.max})
				else
					table.insert(samdeValues, {attribute.min, math.huge()})
				end
			elseif attribute.max ~= nil then
					table.insert(samdeValues, { -1*math.huge(), attribute.max})
			else
				customError("Current version of SaMDE do not suport parameters with a group of values, without a min or max range")
				-- local bigger = attribute[1]
				-- local smaller = attribute[1]
				-- forEachOrderedElement(attribute, function(idx2, att2, atyp2)
				-- 	if att2 > bigger then
				-- 		bigger = att2
				-- 	elseif att2 < smaller then
				-- 		smaller = att2
				-- 	end
				-- end)
				-- table.insert(samdeValues, {smaller, bigger})
			end
		end

		SamdeParamQuant = SamdeParamQuant + 1
	end)
	if data.maximize == nil then
		data.maximize = false
	end
	best = SAMDECalibrate(samdeValues, SamdeParamQuant, data.model, data.finalTime, samdeParam, data.fit, data.maximize, data.size, data.maxGen, data.threshold)
	forEachOrderedElement(best, function(idx, att, type)
		data[idx] = att
	end)
	setmetatable(data, metaTableSAMDE_)
	return data
end

