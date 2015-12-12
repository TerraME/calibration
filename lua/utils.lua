--- Function to be used by Multiple Runs and SAMDE, to test if a Choice type
-- range of possible values is valid to be used as a given Model parameter.
-- @arg values A table with the group of values to be cheked.
-- @arg idx  The index of the parameter to be checked in the parameters table.
-- @arg Param The table containing the valid set of parameters in a model.
-- @usage -- DONTRUN
-- checkParametersRange(myModel, MultipleRunsParameters)
function checkParametersRange(values, idx, Param)
	--test if the range of values in the Calibration/Multiple Runs type are inside the accepted model range of values.
	if values.min == nil and values.max == nil then
		customError("Parameter "..idx.." should not be a range of values")
	end

	if Param.min == nil or Param.max == nil then
		customError("Parameter "..idx.." must have min and max values")
	end

	if values.min ~= nil then
		if values.min > Param.min then
			customError("Parameter "..idx.." min is out of the model range.")
		end
	end

	if values.max ~= nil then
		if values.max < Param.max then
			customError("Parameter "..idx.." max is out of the model range.")
		end
	end

	if values.step ~= nil then
		if Param.step == nil then
			customError("Argument '"..idx..".step' is mandatory.")
		elseif Param.step % values.step ~= 0 then
			customError("Parameter "..idx.." step is out of the model range.")
		end

		if values.min ~= nil then
			if (Param.min - values.min) % values.step ~= 0 then
				customError("Parameter "..idx.." min is out of the model range.")
			end
		end		
	end
end

--- Function to be used by Multiple Runs and SAMDE to test if a
-- value is valid to be used as a given Model parameter.
-- @arg values A table with the group of values to be cheked.
-- @arg idx  The index of the parameter to be checked in the parameters table.
-- @arg Param The table containing the valid set of parameters in a model.
-- @usage -- DONTRUN
-- checkParametersSingle(myModel, MultipleRunsParameters)
function checkParameterSingle(mParam, idx, idx2, value)
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

--- Function to be used by Multiple Runs and SAMDE,
-- to test if a Choice type table of possible values is valid to be used as a given Model parameter.
-- @arg values A table with the group of values to be cheked.
-- @arg idx  The index of the parameter to be checked in the parameters table.
-- @arg Param The table containing the valid set of parameters in a model.
-- @usage -- DONTRUN
-- checkParametersSet(myModel, MultipleRunsParameters)
function checkParametersSet(values, idx, Param) 
	-- test if the group of values in the Calibration/Multiple Runs type are inside the accepted model range of values
	forEachOrderedElement(Param.values, function(idx2, att2, type2)
		checkParameterSingle(values, idx, idx2, att2)
	end)
end

--- Function to create a copy of a given parameter, returns the copy.
-- @arg mtable The parameter to be copied.
-- @usage
-- import("calibration")
-- local original = {param = 42}
-- local copy = clone(original) 
function clone(mtable)
    mandatoryArgument(1, "table", mtable)

    local result = {}

    forEachElement(mtable, function(idx, value, mtype)
        if mtype == "table" then
            result[idx] = clone(value)
        else
            result[idx] = value
        end
    end)

    return result
end

---Function to be used by Multiple Runs and Calibration to check
-- if all possibilites of models can be instantiated before
-- starting to test the model.
-- @arg tModel A Paramater with the model to be instantiated.
-- @arg tParameters A table of parameters, from a MultipleRuns or Calibration type.
-- @usage -- DONTRUN
-- checkParameters(myModel, MultipleRunsParameters)
function checkParameters(tModel, tParameters)
	mandatoryTableArgument(tParameters, "model", "Model")
	mandatoryTableArgument(tParameters, "parameters", "table")
	-- Tests all model parameters possibilities in Multiple Runs/Calibration to see if they are in the accepted
	-- range of values according to a Model.
	forEachElement(tModel(), function(idx, att, mtype)
		if mtype ~= "function" then
	    	if idx ~= "init" and idx ~= "seed" then
				local Param = tParameters.parameters[idx]
				if mtype == "Choice" then
					if type(Param) == "Choice" then
						if tParameters.strategy == "selected" or tParameters.strategy == "repeated" then
							customError("Parameters used in repeated or selected strategy cannot be a 'Choice'")
						end
						
						-- if parameter in Multiple Runs/Calibration is a range of values
			    		if Param.min ~= nil or Param.max ~= nil or Param.step ~= nil then 
			    			checkParametersRange(att, idx, Param)	
				    	else
				    	-- if parameter Multiple Runs/Calibration is a grop of values
				    		 checkParametersSet(att, idx, Param)
				    	end

				   	elseif tParameters.strategy == "selected" then
				   		forEachOrderedElement(tParameters.parameters, function(scenario, sParam, sType)
				   			if sType ~= "table" then
				   				customError("Parameters used in selected strategy must be in a table of scenarios")
				   			end

				   			if type(sParam[idx])  == "Choice" then
				   				customError("Parameters used in repeated or selected strategy cannot be a 'Choice'")
				   			end

				   			checkParameterSingle(att, idx, 1, sParam[idx]) 
				   		end)
				   	elseif tParameters.strategy == "repeated" then
				   		checkParameterSingle(att, idx, 0, tParameters.parameters[idx]) 
				   	elseif type(Param) == "table" then
				   		customError("The parameter must be of type Choice, a table of Choices or a single value.")
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
					forEachOrderedElement(att, function(idxt, attt, typt)
						if tParameters.parameters[idx] ~= nil then
							Param = tParameters.parameters[idx][idxt]
						end
						
						if type(Param) == "Choice" then
							if tParameters.strategy == "selected" or tParameters.strategy == "repeated" then
								customError("Parameters used in repeated or selected strategy cannot be a 'Choice'")
							end
							
							-- if parameter in Multiple Runs/Calibration is a range of values
				    		if Param.min ~= nil or Param.max ~= nil or Param.step ~= nil then
				    			checkParametersRange(attt, idxt, Param)
					    	else
					    	-- if parameter Multiple Runs/Calibration is a grop of values
					    		 checkParametersSet(attt, idxt, Param)
					    	end

					   	elseif tParameters.strategy == "selected" then
					   		forEachOrderedElement(tParameters.parameters, function(scenario, sParam, sType)
					   			if type(sParam[idx]) ~= "table" then
					   				customError("Parameters used in selected strategy must be in a table of scenarios")
					   			end

					   			if type(sParam[idx][idxt]) == "Choice" then
					   				customError("Parameters used in repeated or selected strategy cannot be a 'Choice'")
					   			end

					   			checkParameterSingle(attt, idxt, 1, sParam[idx][idxt])
					   		end)
					   	elseif tParameters.strategy == "repeated" then
					   		checkParameterSingle(attt, idxt, 0, tParameters.parameters[idx][idxt])
					   	elseif type(Param) == "table" and type(attt) == "Choice" then
					   		customError("The parameter must be of type Choice, a table of Choices or a single value.")
					   	end
					end)
				end
			end
	    end
	end)
end

--- Function that returns a random model instance from a set of parameters.
-- Each Choice argument will be instantiated with a random value from the available choices.
-- The other arguments will be instantiated with their exact values.
-- This function can be used by SaMDE as well as by MultipleRuns.
-- @arg tModel The Model to be instantiated.
-- @arg tParameters A table of possible parameters for the model.
-- Multiple Runs or Calibration instance .
-- @usage
-- import("calibration")
-- local myModel = Model{
-- 	x = Choice{-100, -1, 0, 1, 2, 100},
-- 	y = Choice{min = 1, max = 10, step = 1},
-- 	finalTime = 1,
-- 	init = function(self)
-- 		self.timer = Timer{
-- 			Event{action = function()
-- 				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
-- 			end}
-- 	}
-- 	end
-- }
-- local parameters = {x = Choice{-100,- 1, 0, 1, 2, 100}, y = Choice{min = 1, max = 8, step = 1}}
-- randomModel(myModel, parameters)
function randomModel(tModel, tParameters)
	mandatoryArgument(1, "Model", tModel)
	mandatoryArgument(1, "table", tParameters)
	local Params = {}
	local sampleParams = {}
	forEachOrderedElement(tParameters, function (idx, attribute, atype)
		if atype == "Choice" then
			sampleParams[idx] = attribute:sample()
		elseif atype == "table" then
			if sampleParams[idx] == nil then
				sampleParams[idx] = {}
			end

			forEachOrderedElement(attribute, function(idx2, att2, typ2)
				if typ2 == "Choice" then
					sampleParams[idx][idx2] = att2:sample()
				else
					sampleParams[idx][idx2] = att2
				end
			end)
		else
			sampleParams[idx] = attribute
		end
	end)
	local m = tModel(sampleParams)
	m:execute()
	return m
end

