SAMDE_ = {
	type_ = "SAMDE",
	--- Returns the fitness of a model, function must be implemented by the user.
	-- @arg model Model fo calibration.
	-- @usage c:fit(model, parameter)
}

metaTableSAMDE_ = {
	__index = SAMDE_
}

---Type to calibrate a model, returns a SAMDE type with the fittest individual,
-- the fit value and the number of generations.
-- @arg data a Table containing: A model constructor, with the model that will be calibrated,
-- a table of parameters and a fit function to determine the fitness of a model
-- @usage c = SAMDE{
--     model = MyModel,
--     parameters = {x = {min = 1, max = 10, step = 2}},
--     fit = function(model, parameter)
--     		...	
--     end
-- }
-- 
--c = SAMDE{
--     model = MyModel,
--     parameters = { x = {1, 3, 4, 7}},
--     fit = function(model, parameter)
--     		...	
--     end
-- }
function SAMDE(data)
	mandatoryTableArgument(data, "model", "Model")
	mandatoryTableArgument(data, "parameters", "table")
	mandatoryTableArgument(data, "size", "number")
	mandatoryTableArgument(data, "maxGen", "number")
	if data.fit == nil or type(data.fit) ~= "function" then
		customError("Function 'fit' was not implemented.")
	end
	verifyUnnecessaryArguments(data, {"model", "parameters", "maximize", "fit", "maxGen", "mutation", "size", "crossing"})
	checkParameters(data.model, data)
	local startParams = {} 
	-- A table with the first possible values for the parameters to be tested.
	forEachOrderedElement(data.parameters, function(idx, attribute, atype)
		if attribute.min ~= nil then
			startParams[idx] = attribute.min
		else
			startParams[idx] = attribute[1]
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
		if attribute.min ~= nil then
			if attribute.max ~=nil then
				table.insert(samdeValues, {attribute.min, attribute.max})
			else
				table.insert(samdeValues, {attribute.min, math.huge()})
			end
		elseif attribute.max ~= nil then
				table.insert(samdeValues, { -1*math.huge(), attribute.max})
		else
			local bigger = attribute[1]
			local smaller = attribute[1]
			forEachOrderedElement(attribute, function(idx2, att2, atyp2)
				if att2 > bigger then
					bigger = att2
				elseif att2 < smaller then
					smaller = att2
				end
			end)
			table.insert(samdeValues, {smaller, bigger})
		end

		SamdeParamQuant = SamdeParamQuant + 1
	end)
	if data.maximize == nil then
		data.maximize = false
	end
	best = SAMDECalibrate(samdeValues, SamdeParamQuant, data.model, samdeParam, data.fit, data.maximize, data.size, data.maxGen)
	forEachOrderedElement(best, function(idx, att, type)
		data[idx] = att
	end)
	setmetatable(data, metaTableSAMDE_)
	return data
end

