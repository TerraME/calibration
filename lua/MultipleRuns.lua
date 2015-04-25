local parametersOrganizer
-- The possible values for each parameter is being put in a table indexed by numbers.
-- example:
-- Params = {{id = "x", min =  1, max = 10, elements = nil, ranged = true, step = 2},
-- {id = "y", min = nil, max = nil, elements = {1, 3, 5}, ranged = false, steps = 1}}
parametersOrganizer = function(data, mainTable, idx, attribute, atype, Params)
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

local factorialRecursive
-- function used in execute() to test the model with all the possible combinations of parameters.
-- Params: Table with all the parameters and it's ranges or values indexed by number.
-- Example: Params = {{id = "x", min =  1, max = 10, elements = nil, ranged = true, step = 2},
-- {id = "y", min = nil, max = nil, elements = {1, 3, 5}, ranged = false, steps = 1}}
-- a: the parameter that the function is currently variating. In the Example: [a] = [1] => x, [a] = [2]=> y.
-- Variables: The value that a parameter is being tested. Example: Variables = {x = -100, y = 1}
-- resultTable Table returned by multipleRuns as result
factorialRecursive  = function(data, Params, a, variables, resultTable, addFunctions)
	if Params[a].ranged == true then -- if the parameter uses a range of values
		for parameter = Params[a].min, Params[a].max, Params[a].step do	-- Testing the parameter with each value in it's range.
			-- Giving the variables table the current parameter and value being tested.
			if Params[a].table == nil then
				variables[Params[a].id] = parameter 
			else
				if variables[Params[a].table] == nil then
					variables[Params[a].table] = {}
				end
				variables[Params[a].table][Params[a].id] = parameter
			end

			local mVariables = {} -- copy of the variables table to be used in the model.
			forEachOrderedElement(variables, function(idx, attribute, atype)
				mVariables[idx] = attribute
			end)

			if a == #Params then -- if all parameters have already been given a value to be tested.
				local m = data.model(mVariables) --testing the model with it's current parameter values.
				m:execute()
				if addFunctions ~= nil then
					local returnValueF
					forEachOrderedElement(addFunctions, function(idxF, attF, typF)
						returnValueF = data[idxF](m)
						if resultTable[idxF] == nil then
							resultTable[idxF] = {}
						end
						resultTable[idxF][#resultTable[idxF] + 1] = returnValueF
					end)
				end

				local stringSimulations = ""
				forEachOrderedElement(variables, function ( idx2, att2, typ2)
					if typ2 ~= "table" then
						resultTable[idx2][#resultTable[idx2] + 1] = att2
						stringSimulations = stringSimulations..idx2.."_"..att2.."_"
					else
						forEachOrderedElement(att2, function( idx3, att3, typ3)
							resultTable[idx2][idx3][#resultTable[idx2][idx3] + 1] = att3
							stringSimulations = stringSimulations..idx2.."_"..idx3.."_"..att3.."_"
						end)
					end
				end)
				local currentDir = currentDir()
				mkDir(stringSimulations)
				chDir(stringSimulations)
				if output ~= nil then
					data.output(m)
				end
				chDir(currentDir)
				resultTable.simulations[#resultTable.simulations + 1] = stringSimulations
			else  -- else, go to the next parameter to test it with it's range of values.
				resultTable = factorialRecursive(data, Params, a + 1, variables, resultTable, addFunctions)
			end
		end

	else -- if the parameter uses a table of multiple values
		forEachOrderedElement(Params[a].elements, function (idx, attribute, atype) 
			-- Testing the parameter with each value in it's table.
			-- Giving the variables table the current parameter and value being tested.
			if Params[a].table == nil then
				variables[Params[a].id] = attribute 
			else
				if variables[Params[a].table] == nil then
					variables[Params[a].table] = {}
				end
				variables[Params[a].table][Params[a].id] = attribute
			end
			local mVariables = {} -- copy of the variables table to be used in the model.
			forEachOrderedElement(variables, function(idx2, attribute2, atype2)
				mVariables[idx2] = attribute2
			end)

			if a == #Params then -- if all parameters have already been given a value to be tested.
				local m = data.model(mVariables) --testing the model with it's current parameter values.
				m:execute()
				if addFunctions ~= nil then
					local returnValueF
					forEachOrderedElement(addFunctions, function(idxF, attF, typF)
						returnValueF = attF(m)
						if resultTable.idxF == nil then
							resultTable.idxF = {}
						end
						resultTable.idxF[#resultTable.idxF + 1] = returnValueF
					end)
				end

				local stringSimulations = ""
				forEachOrderedElement(variables, function ( idx2, att2, typ2)
					resultTable[idx2][#resultTable[idx2] + 1] = att2
					stringSimulations = stringSimulations..idx2.."_"..att2.."_"
				end)
				local currentDir = currentDir ()
				mkDir(stringSimulations)
				chDir(stringSimulations)
				if output ~= nil then
					data.output(m)
				end
				chDir(currentDir)
				resultTable.simulations[#resultTable.simulations + 1] = stringSimulations
			else  -- else, go to the next parameter to test it with each of it possible values.
				resultTable = factorialRecursive(data, Params, a + 1, variables, resultTable, addFunctions)
			end
		end)
	end

	return resultTable
end

--@header Model Calibration functions.
MultipleRuns_ = {
	type_ = "MultipleRuns",
	--- Optional function defined by the user,
	-- that is executed each time the model runs.
	-- @arg data The data of the MultipleRuns object.
	-- @arg model The instance of the Model that was executed.
	-- @usage m = multipleRuns = {...
	-- output = function(model)
	-- 	return model.value
	-- end}
	-- r = m:execute()
	output = function(data, model)
		return nil
	end,
	--- Function that returns the result of the Multiple Runs Instance.
	-- @arg data The data of the MultipleRuns object.
	-- @arg number The number of the desired execution.
	-- @usage m = multipleRuns = {...}
	-- r = m:execute()
	-- m:get(r,1).x == -100
	get = function(data, number)
		mandatoryArgument(1, "number", number)
		local getTable = {}
		forEachOrderedElement(data, function(idx, att, typ)
			if type(data[idx]) == "table" then
				getTable[idx] = data[idx][number]
			end
		end)
		return getTable
	end,

	--- Function that saves the result of the Multiple Runs instance in a .csv file.
	-- @arg data The data of the MultipleRuns object.
	-- @arg separator The choosen separator to be used in the .csv file.
	-- @usage m = multipleRuns = {...}
	-- r = m:execute()
	-- m:saveCSV(";")
	saveCSV = function(data, separator)
		mandatoryArgument(1, "string", separator)
		local CSVTable = {}
		forEachOrderedElement(data, function(idx, att, typ)
			if typ == "table" and idx ~= "parameters" then
				local counter = 0
				forEachOrderedElement(att, function(idx2, att2, typ2)
					counter = counter + 1
					if CSVTable[counter] == nil then
						CSVTable[counter] = {}
					end
					CSVTable[counter][idx] = idx2
				end)
			end
		end)
		CSVwrite(CSVTable, "result.csv", separator)
	end
}
metaTableMultipleRuns_ = {
	__index = MultipleRuns_
}

---Type to repeatly execute a model according to a choosen strategy,
-- Returns an object with type MultipleRuns and a set of tables:
-- simulations: the name of the simulations executed. It should be "simulation_*", 
-- depending on the strategy used.
-- For repeat and sample, * should be 1, 2, ..., quantity. 
-- For selected, * should be the idx of the element in the table of tables. 
-- For Factorial, * should be a combination of the name and value of the parameters:
-- "parameter1_value1_parameter_2_value_2...parameter_n_value_n".
-- One extra table for each parameter used in the argument "parameters",
-- with the parameter value used for the respective simulation.
-- In this sense, the model below:
-- r = MultipleRuns{
--    model = MyModel,
--    parameters = {water = 10, rain = 20},
--    quantity = 10,
--   finalTime = 10
-- }
-- should return a table with the values:
-- r.simulations == {"1", "2", "...", "10"}
-- r.water = {10, 10, 10, ..., 10}
-- r.rain = {20, 20, 20, ... 20}
-- type(r) == "MultipleRuns"
--
-- Is an example of a Multiple Runs type.
-- @arg data a Table containing: A model constructor, with the model that will be calibrated;
-- A table with the parameters to be tested; An optional quantity variable; 
-- An optional user defined output function.
-- @usage c = MultipleRuns{
--     model = MyModel,
--	quantity = 5,
--	parameters = {
--		x = {-100, -1, 0, 1, 2, 100},
--		y = { min = 1, max = 10, step = 1}
--	 },
--	output = function(model)
--		return model.value
--	end}
-- }
function MultipleRuns(data)
		mandatoryTableArgument(data, "model", "Model")
		mandatoryTableArgument(data, "parameters", "table")
		local resultTable = {simulations = {}} 
		local Params = {} 
		-- addFunctions: Parameter that organizes the additional functions choosen to be executed after the model.
		local addFunctions = {}
		forEachOrderedElement(data, function(idx, att, typ)
			if type(att) == "function" and idx ~= "output" then
				addFunctions[idx] = att
			else
				local checkingArgument = {}
				checkingArgument[idx] = idx
				checkUnnecessaryArguments(checkingArgument, {"model", "strategy", "parameters", "quantity", "output"})
			end
		end)
		checkParameters(data.model, data)
		-- Organizing the parameters table of multiple runs into a simpler table,
		-- indexed by number with the characteristics of each parameter.
		if data.strategy ~= "repeated" and data.strategy ~= "selected" then
			local mainTable = nil
			forEachOrderedElement(data.parameters, function (idx, attribute, atype)
				if Params[idx] == nil then
					Params[idx] = {}
				end
				if atype ~= "table" then
					parametersOrganizer(data, mainTable, idx, attribute, atype, Params)
				else
					forEachOrderedElement(attribute, function(idx2, att2, typ2)
						if Params[idx][idx2] == nil then
							Params[idx][idx2] = {}
						end
						parametersOrganizer(data, idx, idx2, att2, typ2, Params)
					end)
				end
			end)
		end

		local variables = {}	
		switch(data, "strategy"):caseof{
    	-- Prepares the variables and executes the model according to each strategy.
    		factorial = function()
    			forEachOrderedElement(data.parameters, function(idx, attribute, atype)
    				resultTable[idx] = {}
    				if atype == "table" then
    					forEachOrderedElement(attribute, function(idx2, _, _)
    						resultTable[idx][idx2] = {}
    					end)
    				end
				end)
    			resultTable = factorialRecursive(data, Params, 1, variables, resultTable, addFunctions)
    		end,
    		repeated = function()
    			mandatoryTableArgument(data, "quantity", "number")
    			if data.parameters.seed ~= nil or data.model.seed ~= nil then
    				customError("Models using repeated strategy cannot use seed or all results will be the same.")
    			end	

    			local m = data.model(data.parameters)
    			for i = 1, data.quantity do
    					m:execute()
    					if addFunctions ~= nil then
	    					local returnValueF
							forEachOrderedElement(addFunctions, function(idxF, attF, typF)
								if resultTable.idxF == nil then
									resultTable.idxF = {}
								end
								returnValueF = attF(m)
								resultTable.idxF[#resultTable.idxF + 1] = returnValueF 
							end)
	    				end
 
    					resultTable.simulations[#resultTable.simulations + 1] = ""..(#resultTable.simulations + 1)..""
						local currentDir = currentDir ()
						mkDir(""..(#resultTable.simulations).."")
						chDir(""..(#resultTable.simulations).."")
						if output ~= nil then
							data.output(m)
						end
						chDir(currentDir)
						forEachOrderedElement(data.parameters, function ( idx2, att2, typ2)
							if resultTable[idx2] == nil then
								resultTable[idx2] = {}
							end
							resultTable[idx2][#resultTable[idx2]+1] = att2
						end)
				end
    		end,
    		sample = function()
    			mandatoryTableArgument(data, "quantity", "number")
    			for i = 1, data.quantity do
    				local sampleParams = {}
    				local sampleValue
    				for i = 1, #Params do
    					if Params[i].ranged == true then
    						sampleValue = math.random(Params[i].min, Params[i].max)
    					else
    						sampleValue = Params[i].elements[math.random(1, #Params[i].elements)]
    					end
    					if Params[i].table == nil then
							sampleParams[Params[i].id] = sampleValue
						else
							if sampleParams[Params[i].table] == nil then
								sampleParams[Params[i].table] = {}
							end
							sampleParams[Params[i].table][Params[i].id] = sampleValue
						end
    				end


    				local m = data.model(sampleParams)
    				m:execute()
    				if addFunctions ~= nil then
	    				local returnValueF
						forEachOrderedElement(addFunctions, function(idxF, attF, typF)
							returnValueF = attF(m)
							if resultTable.idxF == nil then
								resultTable.idxF = {}
							end
							resultTable.idxF[#resultTable.idxF + 1] = returnValueF 
						end)
					end
    				
    				resultTable.simulations[#resultTable.simulations + 1] = ""..(#resultTable.simulations + 1)..""
					local currentDir = currentDir ()
					mkDir(""..(#resultTable.simulations).."")
					chDir(""..(#resultTable.simulations).."")
					if output ~= nil then
						data.output(m)
					end
					chDir(currentDir)
					forEachOrderedElement(sampleParams, function (idx2, att2, typ2)
						if resultTable[idx2] == nil then
							resultTable[idx2] = {}
						end

						resultTable[idx2][#resultTable[idx2] + 1] = att2
					end)
    			end
    		end,
    		selected = function()
    			forEachOrderedElement(data.parameters, function(idx, att, atype)
    				if atype ~= "table" then
    					incompatibleTypeMsg(idx, "table", att)
    				end

    				local m = data.model(att)
    				m:execute()
    				if addFunctions ~= nil then
	    				local returnValueF
						forEachOrderedElement(addFunctions, function(idxF, attF, typF)
							returnValueF = attF(m)
							if resultTable.idxF == nil then
								resultTable.idxF = {}
							end
							resultTable.idxF[#resultTable.idxF + 1] = returnValueF 
						end)
					end

    				resultTable.simulations[#resultTable.simulations + 1] = ""..(idx)..""
    				local currentDir = currentDir ()
					mkDir(""..(idx).."")
					chDir(""..(idx).."")
					if output ~= nil then
						data.output(m)
					end
					chDir(currentDir)
					forEachOrderedElement(data.parameters[idx], function(idx2, att2, typ2)
						if resultTable[idx2] == nil then
							resultTable[idx2] = {}
						end
						resultTable[idx2][#resultTable[idx2] + 1] = att2
					end)
    			end)
    		end
		}

	setmetatable(data, metaTableMultipleRuns_)
	forEachOrderedElement(resultTable, function(idx, att, type)
		data[idx] = att
	end)
	return data
end

