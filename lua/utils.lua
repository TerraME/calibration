function checkParameters(tModel, tParameters)
	mandatoryTableArgument(tParameters, "model", "Model")
	mandatoryTableArgument(tParameters, "parameters", "table")

	forEachElement(tModel(), function(idx, att, mtype)
    	if idx ~= "init" and idx ~="finalTime" then
			local Param = tParameters.parameters[idx]
			if type(Param) == "Choice" then
	    		if att.min ~= nil then
	    			if Param.min == nil or Param.max == nil then
	    				customError("Parameter"..idx.." must have min and max values")
	    			end

	    			if att.min > Param.min or att.max < Param.max then
	    				customError("Parameter"..idx.." is out of the model "..idx.." range.")
	    			elseif att.step ~= nil then
	    				if Param.step == nil then
	    					mandatoryTableArgument(tParameters.parameters, step, "number")
	    				elseif Param.step % att.step > 0 then
	    					customError("Parameter step"..idx.." is out of the model "..idx.." range.")
		    			elseif (Param.min - att.min) % att.step > 0 then
		    				customError("Parameter min"..idx.." is out of the model "..idx.." range.")
		    			elseif (att.max - Param.max) % att.step < 0 then
		    				customError("Parameter max"..idx.." is out of the model "..idx.." range.")
		    			end
		    		end

		    	else
		    		--print(idx)
		    		--print(att.values[1])
		    		--print(type(tParameters.parameters))
		    		forEachOrderedElement(tParameters.parameters, function(idx2, _, tp2)
		    		--	print(idx2, tp2)
		    		end)
		    		--print(type(tParameters.parameters[idx]))
		    		--print(type(tParameters.parameters[idx].values))
		    		local belongsTable = {}
		    		forEachOrderedElement(att.values, function(idx2, att2, type2)
						belongsTable[att2] = true
		    		end)
		    		forEachOrderedElement(tParameters.parameters[idx].values, function(idx2, att2, type2)
		    			if belongsTable[att2] == nil then
		    				customError("Parameter"..idx.." is out of the model "..idx.." range.")
		    			end
		    		end)
		    	end
	    	
		    	
			elseif mtype == "Mandatory" then
			-- else
			-- 	forEachOrderedElement(att, function(idx2, _, tp2)
			-- 		print(idx2, tp2)
			-- 	end)
			end
    	end
	end)
	-- tParameters.strategy
	-- check each parameter for infinite possibilites
	-- check if belongs to the model 
end

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