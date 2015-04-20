local TestRangedvalues = function(att, Param, idx)
	--test if the range of values in the Calibration/Multiple Runs type are inside the accepted model range of values
	if att.min == nil and att.max == nil then
		customError("Parameter "..idx.." should not be a range of values")
	end

	if Param.min == nil or Param.max == nil then
		customError("Parameter "..idx.." must have min and max values")
	end

	if att.min ~= nil then
		if att.min > Param.min then
			customError("Parameter "..idx.." is out of the model "..idx.." range.")
		end
	end

	if att.max ~= nil then
		if att.max < Param.max then
			customError("Parameter "..idx.." is out of the model "..idx.." range.")
		end
	end

	if att.step ~= nil then
		if Param.step == nil then
			customError("Argument '"..idx..".step' is mandatory.")
		elseif Param.step % att.step ~= 0 then
			customError("Parameter step"..idx.." is out of the model "..idx.." range.")
		end

		if att.min ~= nil then
			if (Param.min - att.min) % att.step ~= 0 then
				customError("Parameter min"..idx.." is out of the model "..idx.." range.")
			end
		end

		if att.max ~= nil then
			if (att.max - Param.max) % att.step ~= 0 then
				customError("Parameter max"..idx.." is out of the model "..idx.." range.")
			end
		end		    		
	end
end

local testSingleValue = function(att, idx, idx2, value)
	--test if a value inside the accepted model range of values
	if att.min ~= nil then
		if value < att.min then
			customError("Parameter "..value.." in #"..idx2.." is smaller than"..idx.." min value")
		end

		if att.step ~= nil then
			if (value - att.min) % att.step ~= 0 then
				customError("Parameter "..value.." in #"..idx2.." is out of "..idx.." range")
			end
		end
	end

	if att.max ~= nil then
		if value > att.max then
			customError("Parameter "..value.." in #"..idx2.." is bigger than "..idx.." max value")
		end

		if att.step ~= nil then
			if (att.max - att.min) % att.step ~= 0 then
				customError("Parameter "..value.." in #"..idx2" is out of "..idx.." range")
			end
		end
	end

	if att.values ~= nil then
		if belong(value, att.values) == false then
			customError("Parameter "..value.." in #"..idx2.." is out of the model "..idx.." range.")
		end
	end
end

local testGroupOfValues = function (att, Param, idx) 
	-- test if the group of values in the Calibration/Multiple Runs type are inside the accepted model range of values
	forEachOrderedElement(Param.values, function(idx2, att2, type2)
		testSingleValue(att, idx, idx2, att2)
	end)
end

function checkParameters(tModel, tParameters)
	mandatoryTableArgument(tParameters, "model", "Model")
	mandatoryTableArgument(tParameters, "parameters", "table")
	-- Tests all model parameters possibilities in Multiple Runs/Calibration to see if they are in the accepted
	-- range of values according to a Model.
	forEachElement(tModel(), function(idx, att, mtype)
		if mtype ~= "function" then
	    	if idx ~= "init" and idx ~="finalTime" and idx ~= "seed" then 
				local Param = tParameters.parameters[idx]
				if mtype == "Choice" then 
					if type(Param) == "Choice" then
						if tParameters.strategy == "selected" or tParameters.strategy == "repeated" then
							customError("Parameters used in repeated or selected strategy cannot be a 'Choice'")
						end
						
						-- if parameter in Multiple Runs/Calibration is a range of values
			    		if Param.min ~= nil  or Param.max ~= nil or Param.step ~= nil then 
			    			TestRangedvalues(att, Param, idx)	
				    	else
				    	-- if parameter Multiple Runs/Calibration is a grop of values
				    		 testGroupOfValues(att, Param, idx)
				    	end

				   	elseif tParameters.strategy == "selected" then
				   		forEachOrderedElement(tParameters.parameters, function(scenario, sParam, sType)
				   			if sType == "Choice" then
				   				customError("Parameters used in repeated or selected strategy cannot be a 'Choice'")
				   			end

				   			testSingleValue(att, idx, 0, sParam[idx])
				   		end)
				   	elseif tParameters.strategy == "repeated" then
				   		testSingleValue(att, idx, 0, tParameters.parameters[idx])	
				   	else
				   		customError("Parameter "..idx.." does not meet the requirements for given strategy")
				   	end

				elseif mtype == "Mandatory" then
					--Check if mandatory argument exists in tParameters.parameters and if it matches the correct type.
					local mandatory = false
					forEachOrderedElement(tParameters.parameters, function(idx2, att2, typ2)
						if idx2 == idx then
							mandatory = true
							forEachOrderedElement(att2, function(idx3, att3, typ3)
								if typ3 ~= att.value then
									mandatory = false
								end
							end)
						end
					end)
					if mandatory == false then
						mandatoryTableArgument(tParameters.parameters, idx, att.value)
					end
				end
	    	end
	    end
	end)
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
