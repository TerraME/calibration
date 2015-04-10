-- -- local function valid(data, array)
-- --  local valid = {}
-- --  for i = 1, #array do
-- --   valid[array[i]] = true
-- --  end
-- --  if valid[data] then
-- --   return true
-- --  else
-- --   return false
-- --  end
-- -- end
-- function checkParameters(tModel, tParameters)
-- 	mandatoryTableArgument(tParameters, "model", "Model")
-- 	mandatoryTableArgument(tParameters, "parameters", "table")
-- 	if type(tParameters) == "MultipleRuns" then
-- 		switch(tParameters.parameters, "strategy"):caseof{
-- 			factorial = function()
-- 			end,
-- 			repeated = function()
-- 				mandatoryTableArgument(tParameters, "quantity", "number")
-- 				forEachOrderedElement(tParameters.parameters,function(idx, att, typ)
-- 					if type(att) == "Choice" then
-- 						customError("Parameters used in repeated strategy must be a single variable and not a Choice Table")
-- 					end
-- 				end)
-- 			end,
-- 			selected = function()
-- 				forEachOrderedElement(tParameters.parameters,function(idx, att, typ)
-- 					mandatoryTableArgument(tParameters.parameters, att, "table")
-- 					forEachOrderedElement(tParameters.parameters,function(idx2, att2, typ2)
-- 						if type(att2) == "Choice" then
-- 							customError("Parameters used in each selected strategy scenario must be a single variable and not a Choice Table")
-- 						end
-- 					end)
-- 				end)
-- 			end,
-- 			sample = function()
-- 				mandatoryTableArgument(tParameters, "quantity", "number")
-- 				if data.parameters.seed ~= nil or data.model.seed ~= nil then
--     				customError("Models using repeated strategy cannot use random seed.")
--     			end	
-- 			end
-- 		}
-- 	end
-- 	forEachOrderedElement(tParameters.parameters, function (idx, att, typ)
-- 		if idx ~= "finalTime" and idx ~= "seed" then
-- 			print(idx)
-- 			print(type(tParameters.parameters))
-- 			print(type(att))
-- 			print(type(tParameters.parameters.idx))
-- 			if tModel.idx.min ~= nil then
-- 				if (tParameters.parameters.idx.min - tModel.idx.min) % tParameters.parameters.idx.step then
-- 					if tParameters.parameters.idx.min >= tModel.idx.min then
-- 						if tParameters.parameters.idx.step ~= nil then
-- 							if (tParameters.parameters.idx.min - tModel.idx.min) % tParameters.parameters.idx.step then

-- 						end


-- 				end 
			 
-- 			min(calibration) = min(model) + k * step(model), with k integer >= 0
-- 			max(calibration) = max(model) + k * step(model), with k integer <= 0
-- 			step(calibration) = step(model) * k, with k integer >= 0
-- 		end
-- 	end)
	
-- 	-- tParameters.strategy
-- 	-- check each parameter for infinite possibilites
-- 	-- check if belongs to the model 
-- end

function randomModel(tModel, tParameters)
	-- The possible values for each parameter is being put in a table indexed by numbers.
	-- example:
	-- Params = {{id = "x", min =  1, max = 10, elements = nil, ranged = true, step = 2},
	-- {id = "y", min = nil, max = nil, elements = {1, 3, 5}, ranged = false, steps = 1}}
	local Params = {}
	forEachOrderedElement(tParameters, function (idx, attribute, atype)
		local range = true
		local steps = 1
		local parameterElements
		if idx ~= "finalTime" and idx ~= "seed" then
			if tParameters[idx].min == nil or tParameters[idx].max == nil then
				range = false
				parameterElements = attribute
			else
				if tParameters[idx].step == nil then
					mandatoryTableArgument(tParameters[idx], idx..".step", "Choice")
				end
				steps = tParameters[idx].step
			end

			Params[#Params + 1] = {id = idx, min = tParameters[idx].min, 
			max = tParameters[idx].max, elements = parameterElements, ranged = range, step = steps}
		end
	end)
	if tParameters.seed == nil then
		math.randomseed(os.time())
	else
		math.randomseed(tParameters.seed)
	end
	local sampleParams = {}
	local sampleValue
	for i = 1, #Params do
		if Params[i].ranged == true then
			sampleValue = math.random(Params[i].min, Params[i].max)
			sampleParams[Params[i].id] = sampleValue
		else
			sampleValue = Params[i].elements[math.random(1, #Params[i].elements)]
			sampleParams[Params[i].id] =  sampleValue
		end
	end
	local m = tModel(sampleParams)
	m:execute()
	return m
end