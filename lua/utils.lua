local TestRangedvalues = function(att, Param, idx)
	--test if the range of values in the Calibration/Multiple Runs type are inside the accepted model range of values.
	if att.min == nil and att.max == nil then
	 print("3")
		customError("Parameter "..idx.." should not be a range of values")
		 print("4")
	end

	if Param.min == nil or Param.max == nil then
	 print("7")
		customError("Parameter "..idx.." must have min and max values") print("8")
	end

	if att.min ~= nil then
	 print("11")
		if att.min > Param.min then
		 print("12")
			customError("Parameter "..idx.." min is out of the model range.")
			 print("13")
		end
	end

	if att.max ~= nil then
	 print("17")
		if att.max < Param.max then
		 print("18")
			customError("Parameter "..idx.." max is out of the model range.")
			 print("19")
		end
	end

	if att.step ~= nil then
	 print("23")
		if Param.step == nil then
		 print("24")
			customError("Argument '"..idx..".step' is mandatory.")
			 print("25")
		elseif Param.step % att.step ~= 0 then
			 print("27")
			customError("Parameter "..idx.." step is out of the model range.")
		end

		if att.min ~= nil then
		 print("30")
			if (Param.min - att.min) % att.step ~= 0 then
			 print("31")
				customError("Parameter "..idx.." min is out of the model range.")
				 print("32")
			end
		end		
	end
end

local testSingleValue = function(mParam, idx, idx2, value)
	--test if a value inside the accepted model range of values
	if mParam.min ~= nil then
	 print("40")
		if value < mParam.min then
		 print("41")
			customError("Parameter "..value.." in #"..idx2.." is smaller than "..idx.." min value")
			 print("42")
		end

		if mParam.step ~= nil then
		 print("45")
			if (value - mParam.min) % mParam.step ~= 0 then
			 print("46")
				customError("Parameter "..value.." in #"..idx2.." is out of "..idx.." range")
				 print("47")
			end
		end
	end

	if mParam.max ~= nil then
	 print("52")
		if value > mParam.max then
		 print("53")
			customError("Parameter "..value.." in #"..idx2.." is bigger than "..idx.." max value")
			 print("54")
		end
	end

	if mParam.values ~= nil then
	 print("58")
		if belong(value, mParam.values) == false then
		 print("59")
			customError("Parameter "..value.." in #"..idx2.." is out of the model "..idx.." range.")
			 print("60")
		end
	end
end

local testGroupOfValues = function (att, Param, idx) 
	-- test if the group of values in the Calibration/Multiple Runs type are inside the accepted model range of values
	forEachOrderedElement(Param.values, function(idx2, att2, type2)
		testSingleValue(att, idx, idx2, att2)
		 print("68")
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
	 print("80")
	mandatoryTableArgument(tParameters, "parameters", "table")
	 print("81")
	-- Tests all model parameters possibilities in Multiple Runs/Calibration to see if they are in the accepted
	-- range of values according to a Model.
	forEachElement(tModel(), function(idx, att, mtype)
		if mtype ~= "function" then
	    	if idx ~= "init" and idx ~="finalTime" and idx ~= "seed" then
	    	 print("86")
				local Param = tParameters.parameters[idx]
				if mtype == "Choice" then
				  print("88")
					if type(Param) == "Choice" then
					 print("89")
						if tParameters.strategy == "selected" or tParameters.strategy == "repeated" then
							customError("Parameters used in repeated or selected strategy cannot be a 'Choice'")
						end
						
						-- if parameter in Multiple Runs/Calibration is a range of values
			    		if Param.min ~= nil  or Param.max ~= nil or Param.step ~= nil then
			    		 print("95")
			    			TestRangedvalues(att, Param, idx)
			    			print("96")
				    	else
				    	-- if parameter Multiple Runs/Calibration is a grop of values
				    		 testGroupOfValues(att, Param, idx)
				    		  print("99")
				    	end

				   	elseif tParameters.strategy == "selected" then
				   		forEachOrderedElement(tParameters.parameters, function(scenario, sParam, sType)
				   			if sType ~= "table" then
				   			 print("104")
				   				customError("Parameters used in selected strategy must be in a table of scenarios")
				   				 print("105")
				   			end

				   			if type(sParam[idx])  == "Choice" then
				   				customError("Parameters used in repeated or selected strategy cannot be a 'Choice'")
				   			end

				   			testSingleValue(att, idx, 1, sParam[idx])
				   			 print("108")
				   		end)
				   	elseif tParameters.strategy == "repeated" then
				   		testSingleValue(att, idx, 0, tParameters.parameters[idx])
				   		 print("111")
				   	end

				elseif mtype == "Mandatory" then
					--Check if mandatory argument exists in tParameters.parameters and if it matches the correct type.
					local mandatory = false
					forEachOrderedElement(tParameters.parameters, function(idx2, att2, typ2)
						if idx2 == idx then
							print("118")
							mandatory = true
							 print("119")
							forEachOrderedElement(att2, function(idx3, att3, typ3)
								if typ3 ~= att.value then
								 print("121")
									mandatory = false
									 print("122")
								end
							end)
						end
					end)
					if mandatory == false then
					 print("127")
						mandatoryTableArgument(tParameters.parameters, idx, att.value)
						 print("128")
					end

				elseif mtype == "table" then
					forEachOrderedElement(att, function( idxt, attt, typt)
						if tParameters.parameters[idx] ~= nil then
						 print("132")
							Param = tParameters.parameters[idx][idxt]
							 print("133")
						end
						
						if type(Param) == "Choice" then
						 print("135")
							if tParameters.strategy == "selected" or tParameters.strategy == "repeated" then
								customError("Parameters used in repeated or selected strategy cannot be a 'Choice'")
							end
							
							-- if parameter in Multiple Runs/Calibration is a range of values
				    		if Param.min ~= nil  or Param.max ~= nil or Param.step ~= nil then
				    		 print("141")
				    			TestRangedvalues(attt, Param, idxt)
				    			 print("142")
					    	else
					    	-- if parameter Multiple Runs/Calibration is a grop of values
					    		 testGroupOfValues(attt, Param, idxt)
					    		  print("145")
					    	end

					   	elseif tParameters.strategy == "selected" then
					   		forEachOrderedElement(tParameters.parameters, function(scenario, sParam, sType)
					   			if type(sParam[idx]) ~= "table" then
					   				print("150 - 1")
					   				customError("Parameters used in selected strategy must be in a table of scenarios")
					   			end

					   			if type(sParam[idx][idxt]) == "Choice" then
					   				print("150 - 2")
					   				customError("Parameters used in repeated or selected strategy cannot be a 'Choice'")
					   			end

					   			testSingleValue(attt, idxt, 1, sParam[idx][idxt])
					   			 print("154")
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
				 print("183")
			end

		else
			if attribute.step == nil then
				mandatoryTableArgument(attribute, idx..".step", "Choice")
				 print("188")
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
		if atype == "Choice" and atype ~= "table" then
			if Params[idx] == nil then
				Params[idx] = {}
			end

			if atype ~= "table" then
				parametersOrganizer(mainTable, idx, attribute, atype, Params)
			else
				forEachOrderedElement(attribute, function(idx2, att2, typ2)
					if Params[idx][idx2] == nil then
					 print("224")
						Params[idx][idx2] = {}
					end
					parametersOrganizer(idx, idx2, att2, typ2, Params)
					 print("227")
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
		else
			sampleValue = Params[i].elements[math.random(1, #Params[i].elements)]
		end

		if Params[i].step ~= nil then
			sampleValue = sampleValue - (sampleValue % Params[i].step)
		end

		if Params[i].table == nil then
			sampleParams[Params[i].id] = sampleValue
		else
			if sampleParams[Params[i].table] == nil then
			 print("255")
				sampleParams[Params[i].table] = {}
			end
			sampleParams[Params[i].table][Params[i].id] = sampleValue
			 print("258")
		end
	end

	local m = tModel(sampleParams)
	m:execute()
	return m
end
