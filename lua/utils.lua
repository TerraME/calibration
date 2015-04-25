local TestRangedvalues = function(att, Param, idx)
	--test if the range of values in the Calibration/Multiple Runs type are inside the accepted model range of values.
	if att.min == nil and att.max == nil then
		customError("Parameter "..idx.." should not be a range of values")
	end

	if Param.min == nil or Param.max == nil then
		customError("Parameter "..idx.." must have min and max values")
	end

	if att.min ~= nil then
		if att.min > Param.min then
			customError("Parameter "..idx.." min is out of the model range.")
		end
	end

	if att.max ~= nil then
		if att.max < Param.max then
			customError("Parameter "..idx.." max is out of the model range.")
		end
	end

	if att.step ~= nil then
		if Param.step == nil then
			customError("Argument '"..idx..".step' is mandatory.")
		elseif Param.step % att.step ~= 0 then
			customError("Parameter "..idx.." step is out of the model range.")
		end

		if att.min ~= nil then
			if (Param.min - att.min) % att.step ~= 0 then
				customError("Parameter "..idx.." min is out of the model range.")
			end
		end		
	end
end

local testSingleValue = function(mParam, idx, idx2, value)
	--test if a value inside the accepted model range of values
	if mParam.min ~= nil then
		if value < mParam.min then
			customError("Parameter "..value.." in #"..idx2.." is smaller than "..idx.." min value")
		end

		if mParam.step ~= nil then
			if (value - mParam.min) % mParam.step ~= 0 then
				customError("Parameter "..value.." in #"..idx2.." is out of "..idx.." range")
			end
		end
	end

	if mParam.max ~= nil then
		if value > mParam.max then
			customError("Parameter "..value.." in #"..idx2.." is bigger than "..idx.." max value")
		end
	end

	if mParam.values ~= nil then
		if belong(value, mParam.values) == false then
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

---Function to be used by Multiple Runs and Calibration to check
-- if all possibilites of models can be instantiated before
-- starting to test the model.
-- @arg tModel A Paramater with the model to be instantiated.
-- @arg tParameters A table of parameters, from a MultipleRuns or Calibration type.
-- Multiple Runs or Calibration instance. 
-- @usage checkParameters(myModel, MultipleRunsParameters)
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

				   			testSingleValue(att, idx, 1, sParam[idx])
				   		end)
				   	elseif tParameters.strategy == "repeated" then
				   		testSingleValue(att, idx, 0, tParameters.parameters[idx])	
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
				elseif mtype == "table" then
					forEachOrderedElement(att, function( idxt, attt, typt)
						if tParameters.strategy ~= "selected" then
							Param = tParameters.parameters[idx][idxt]
						end
						if type(Param) == "Choice" then
							if tParameters.strategy == "selected" or tParameters.strategy == "repeated" then
								customError("Parameters used in repeated or selected strategy cannot be a 'Choice'")
							end
							
							-- if parameter in Multiple Runs/Calibration is a range of values
				    		if Param.min ~= nil  or Param.max ~= nil or Param.step ~= nil then 
				    			TestRangedvalues(attt, Param, idxt)	
					    	else
					    	-- if parameter Multiple Runs/Calibration is a grop of values
					    		 testGroupOfValues(attt, Param, idxt)
					    	end

					   	elseif tParameters.strategy == "selected" then
					   		forEachOrderedElement(tParameters.parameters, function(scenario, sParam, sType)
					   			if sType == "Choice" then
					   				customError("Parameters used in repeated or selected strategy cannot be a 'Choice'")
					   			end

					   			testSingleValue(attt, idxt, 1, sParam[idx][idxt])
					   		end)
					   	elseif tParameters.strategy == "repeated" then
					   		testSingleValue(attt, idxt, 0, tParameters.parameters[idx][idxt])	
					   	end
					end)
				end
	    	end
	    end
	end)
end

local parametersOrganizer
-- The possible values for each parameter is being put in a table indexed by numbers.
-- example:
-- Params = {{id = "x", min =  1, max = 10, elements = nil, ranged = true, step = 2},
-- {id = "y", min = nil, max = nil, elements = {1, 3, 5}, ranged = false, steps = 1}}
parametersOrganizer = function(mainTable, idx, attribute, atype, Params)
	if type(attribute) == "number" then
		print(attribute)
		print(idx)
		print(atype)
	end
	local range = true
	local steps = 1
	local parameterElements = {}
	if idx ~= "finalTime" and idx ~= "seed" then
		if attribute.min == nil or attribute.max == nil then
			range = false
			if atype == "Choice" then
				forEachOrderedElement(attribute.values, function (idv, atv, tpv)
					parameterElements[#parameterElements + 1] = attribute.values[idv]
				end) 
			else
				parameterElements = attribute
			end

		else
			if attribute.step == nil then
				mandatoryTableArgument(attribute, idx..".step", "Choice")
			end

			steps = attribute.step
		end

		Params[#Params + 1] = {id = idx, min = attribute.min, 
		max = attribute.max, elements = parameterElements, ranged = range, step = steps, table = mainTable}
	end
end

---Function that  that returns a randommodel instance from a set of parameters.
-- Each parameter that has a choice needs to be instantiated with a random value from the available choices.
-- The other parameters need to be instantiated with their exact values.
-- This function can be used by SaMDE as well as by MultipleRuns.
-- @arg tModel A Paramater with the model to be instantiated.
-- @arg tParameters A table of parameters.
-- @arg seed Optional seed to be used by randomModel.
-- Multiple Runs or Calibration instance .
-- @usage randomModel(myModel, MultipleRunsParameters)
function randomModel(tModel, tParameters, seed)
	mandatoryArgument(1, "Model", tModel)
	mandatoryArgument(1, "table", tParameters)
	local Params = {}
	local sampleParams = {}
	local mainTable = nil
	forEachOrderedElement(tParameters, function (idx, attribute, atype)
		if atype ~= "number" then
			if Params[idx] == nil then
				Params[idx] = {}
			end

			if atype ~= "table" then
				parametersOrganizer(mainTable, idx, attribute, atype, Params)
			else
				forEachOrderedElement(attribute, function(idx2, att2, typ2)
					if Params[idx][idx2] == nil then
						Params[idx][idx2] = {}
					end
					parametersOrganizer(idx, idx2, att2, typ2, Params)
				end)
			end
		else
			sampleParams[idx] = attribute
		end
	end)
	if seed == nil then
		math.randomseed(os.time())
	else
		math.randomseed(seed)
	end

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
