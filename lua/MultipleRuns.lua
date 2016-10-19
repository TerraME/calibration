local dir
-- checkParameters auxiliar function.
local function checkMultipleRunsStrategyRules(tModel, tParameters, Param, idx, idxt)

	if type(Param) == "Choice" then
		if tParameters.strategy == "selected" then
			customError("Parameters used in selected strategy cannot be a 'Choice'")
		end
	elseif tParameters.strategy == "selected" then
		if idxt == nil then
   			forEachOrderedElement(tParameters.parameters, function(scenario, sParam, sType)
	   			if sType ~= "table" then
	   				customError("Parameters used in selected strategy must be in a table of scenarios")
	   			end

	   			if type(sParam[idx])  == "Choice" then
	   				customError("Parameters used in selected strategy cannot be a 'Choice'")
	   			end
	   		end)
	   	else
			forEachOrderedElement(tParameters.parameters, function(scenario, sParam, sType)
	   			if type(sParam[idx]) ~= "table" then
	   				customError("Parameters used in selected strategy must be in a table of scenarios")
	   			end

	   			if type(sParam[idx][idxt]) == "Choice" then
	   				customError("Parameters used in selected strategy cannot be a 'Choice'")
	   			end
	   		end)
	   	end
   	end
end

-- Function to be used by Multiple Runs to check
-- if all possibilites of models can be instantiated before
-- starting to test the model.
-- @arg tModel A Paramater with the model to be instantiated.
-- @arg tParameters A table of parameters, from a MultipleRuns or Calibration type.
local function checkParameters(tModel, tParameters)
	mandatoryArgument(1, "Model", tModel)
	mandatoryTableArgument(tParameters, "parameters", "table")
	-- Tests all model parameters possibilities in Multiple Runs/Calibration to see if they are in the accepted
	-- range of values according to a Model.
	local modelParametersSet = {}
	forEachElement(tModel:getParameters(), function(idx, att, mtype)
		modelParametersSet[idx] = true
		if mtype ~= "function" then
	    	if idx ~= "init" and idx ~= "seed" then
				local Param = tParameters.parameters[idx]
				-- check if all parameters fit the choosen strategy rules before
				-- checking if it obeys the model rules.
				if mtype ~= "table" then
					checkMultipleRunsStrategyRules(tModel, tParameters, Param, idx)
				end

				if mtype == "Choice" then
					if type(Param) == "Choice" then				
						-- if parameter in Multiple Runs/Calibration is a range of values
			    		if Param.min ~= nil or Param.max ~= nil or Param.step ~= nil then 
			    			checkParametersRange(tModel, idx, Param)	
				    	else
				    	-- if parameter Multiple Runs/Calibration is a grop of values
				    		 checkParametersSet(tModel, idx, Param)
				    	end

				   	elseif tParameters.strategy == "selected" then
				   		forEachOrderedElement(tParameters.parameters, function(scenario, sParam, sType)
				   			checkParameterSingle(tModel, idx, 1, sParam[idx]) 
				   		end) 
				   	elseif type(Param) == "table" then
				   		customError("The parameter must be of type Choice, a table of Choices or a single value.")
				   	end

				elseif mtype == "Mandatory" then
					--Check if mandatory argument exists in tParameters.parameters and if it matches the correct type.
					local mandatory = false
					local mandArg = tParameters.parameters[idx]
					if type(mandArg) ~= nil then
						if type(mandArg) == "table" then
							mandatory = true
							forEachOrderedElement(mandArg, function(idx3, att3, typ3)
								if typ3 ~= att.value then
									mandatory = false
								end
							end)
						elseif type(mandArg) == att.value then
								mandatory = true
						elseif type(mandArg) == "Choice" then
							if mandArg.max ~= nil or mandArg.min ~= nil then
								if "number" == att.value then 
									mandatory = true
								end
							else
								mandatory = true
								forEachOrderedElement(mandArg.values, function(idx3, att3, typ3)
									if typ3 ~= att.value then
										mandatory = false
									end
								end)
							end
						end
					end

					if mandatory == false then
						mandatoryTableArgument(tParameters.parameters, idx, att.value)
					end

				elseif mtype == "table" then
					forEachOrderedElement(att, function(idxt, attt, typt)
						if tParameters.parameters[idx] ~= nil then
							Param = tParameters.parameters[idx][idxt]
						end

						-- check if all parameters fit the choosen strategy rules before
						-- checking if it obeys the model rules.
						checkMultipleRunsStrategyRules(tModel, tParameters, Param, idx, idxt)	
						if type(Param) == "Choice" then
							-- if parameter in Multiple Runs/Calibration is a range of values
				    		if Param.min ~= nil or Param.max ~= nil or Param.step ~= nil then
				    			checkParametersRange(tModel, idxt, Param, idx)
					    	else
					    	-- if parameter Multiple Runs/Calibration is a grop of values
					    		 checkParametersSet(tModel, idxt, Param,idx)
					    	end

					   	elseif tParameters.strategy == "selected" then
					   		forEachOrderedElement(tParameters.parameters, function(scenario, sParam, sType)
					   			checkParameterSingle(tModel, idxt, 1, sParam[idx][idxt], idx)
					   		end)
					   	elseif type(Param) == "table" and type(attt) == "Choice" then
					   		customError("The parameter must be of type Choice, a table of Choices or a single value.")
					   	end
					end)
				else
					if type(Param) == "table" then
				   		customError("The parameter must be of type Choice, a table of Choices or a single value.")
				   	end
				end
			end
	    end
	end)
-- PLEASE DO NOT FORGET TO ADAPT THIS TO SELECT LATER
	if tParameters.strategy ~= "selected" then
		forEachOrderedElement(tParameters.parameters, function (idx, att, mtype)
			if modelParametersSet[idx] == nil then
				customError(idx.." is unnecessary.")
			end
		end)
	end
end

local function testAddFunctions(resultTable, addFunctions, data, m)
	if addFunctions ~= nil then
		local returnValueF
		forEachOrderedElement(addFunctions, function(idxF, attF, typF)
			if resultTable[idxF] == nil then
				resultTable[idxF] = {}
			end
			if m[idxF] == nil and data.outputVariables[idxF] then
				customError('Output value "'..idxF..'" is not present in the model.')
			end

			returnValueF = data[idxF](m)

			resultTable[idxF][#resultTable[idxF] + 1] = returnValueF
		end)
	end
end

-- The possible values for each parameter is being put in a table indexed by numbers.
-- example:
-- params = {{id = "x", min = 1, max = 10, elements = nil, ranged = true, step = 2},
-- {id = "y", min = nil, max = nil, elements = {1, 3, 5}, ranged = false, steps = 1}}
local function parametersOrganizer(mainTable, idx, attribute, atype, params)
	local range = true
	local steps = 1
	local parameterElements = {}
	if atype == "Choice" then
		if attribute.min == nil or attribute.max == nil then
			range = false
			forEachOrderedElement(attribute.values, function (idv, atv, tpv)
				parameterElements[#parameterElements + 1] = attribute.values[idv]
			end) 
		else
			if attribute.step == nil then
				mandatoryTableArgument(attribute, idx..".step", "Choice")
			end

			steps = attribute.step
		end

		params[#params + 1] = {id = idx, min = attribute.min, 
		max = attribute.max, elements = parameterElements, ranged = range, step = steps, table = mainTable}
	else
		table.insert(parameterElements, attribute)
		table.insert(params, {id = idx, min = nil, max = nil, elements = parameterElements, ranged = false, step = 1, table = mainTable})
	end
end

local factorialRecursive
-- function used in run() to test the model with all the possible combinations of parameters.
-- params: Table with all the parameters and it's ranges or values indexed by number.
-- Example: params = {{id = "x", min = 1, max = 10, elements = nil, ranged = true, step = 2},
-- {id = "y", min = nil, max = nil, elements = {1, 3, 5}, ranged = false, steps = 1}}
-- a: the parameter that the function is currently variating. In the Example: [a] = [1] => x, [a] = [2]=> y.
-- Variables: The value that a parameter is being tested. Example: Variables = {x = -100, y = 1}
-- resultTable Table returned by multipleRuns as result
factorialRecursive = function(data, params, a, variables, resultTable, addFunctions, s, repetition, repeated)
	if params[a].ranged == true then -- if the parameter uses a range of values
		local correctionValue = params[a].step / 100

		for parameter = params[a].min, (params[a].max + correctionValue), params[a].step do	-- Testing the parameter with each value in it's range.
			if parameter > params[a].max then
				parameter = params[a].max
			end

			-- Giving the variables table the current parameter and value being tested.
			if params[a].table == nil then
				variables[params[a].id] = parameter 
			else
				if variables[params[a].table] == nil then
					variables[params[a].table] = {}
				end

				variables[params[a].table][params[a].id] = parameter
			end

			local mVariables = {} -- copy of the variables table to be used in the model.
			forEachOrderedElement(variables, function(idx, attribute, atype)
				mVariables[idx] = attribute
			end)

			if a == #params then -- if all parameters have already been given a value to be tested.
				local m = data.model(mVariables) --testing the model with it's current parameter values.
				m:run()
				local stringSimulations = ""
				if repeated == true then
					stringSimulations = repetition.."_execution_"
				end

				forEachOrderedElement(variables, function (idx2, att2, typ2)
					if typ2 ~= "table" then
						resultTable[idx2][#resultTable[idx2] + 1] = att2
						stringSimulations = stringSimulations..idx2.."_"..att2.."_"
					else
						forEachOrderedElement(att2, function(idx3, att3, typ3)
							resultTable[idx2][idx3][#resultTable[idx2][idx3] + 1] = att3
							stringSimulations = stringSimulations..idx2.."_"..idx3.."_"..att3.."_"
						end)
					end
				end)
				local testDir = currentDir()
				if data.folderName then
					dir = Directory(stringSimulations)
					dir:create()
					Directory(testDir..s..stringSimulations):setCurrentDir()
				end

				testAddFunctions(resultTable, addFunctions, data, m)
				Directory(testDir):setCurrentDir()
				resultTable.simulations[#resultTable.simulations + 1] = stringSimulations
			else -- else, go to the next parameter to test it with it's range of values.
				resultTable = factorialRecursive(data, params, a + 1, variables, resultTable, addFunctions, s, repetition, repeated)
			end
		end

	else -- if the parameter uses a table of multiple values
		forEachOrderedElement(params[a].elements, function (idx, attribute, atype) 
			-- Testing the parameter with each value in it's table.
			-- Giving the variables table the current parameter and value being tested.
			if params[a].table == nil then
				variables[params[a].id] = attribute 
			else
				if variables[params[a].table] == nil then
					variables[params[a].table] = {}
				end
				variables[params[a].table][params[a].id] = attribute
			end
			
			local mVariables = {} -- copy of the variables table to be used in the model.
			forEachOrderedElement(variables, function(idx2, attribute2, atype2)
				mVariables[idx2] = attribute2
			end)

			if a == #params then -- if all parameters have already been given a value to be tested.
				local m = data.model(mVariables) --testing the model with it's current parameter values.
				m:run()
				local stringSimulations = ""
				if repeated == true then
					stringSimulations = repetition.."_execution_"
				end

				forEachOrderedElement(variables, function (idx2, att2, typ2)
					if typ2 ~= "table" then
						resultTable[idx2][#resultTable[idx2] + 1] = att2
						stringSimulations = stringSimulations..idx2.."_"..att2.."_"
					else
						forEachOrderedElement(att2, function(idx3, att3, typ3)
							resultTable[idx2][idx3][#resultTable[idx2][idx3] + 1] = att3
							stringSimulations = stringSimulations..idx2.."_"..idx3.."_"..att3.."_"
						end)
					end
				end)
				local testDir = currentDir()
				if folderName then
					dir = Directory(stringSimulations)
					dir:create()
					Directory(testDir..s..stringSimulations):setCurrentDir()
				end

				testAddFunctions(resultTable, addFunctions, data, m)
				Directory(testDir):setCurrentDir()
				resultTable.simulations[#resultTable.simulations + 1] = stringSimulations 
			else -- else, go to the next parameter to test it with each of it possible values.
				resultTable = factorialRecursive(data, params, a + 1, variables, resultTable, addFunctions, s, repetition, repeated)
			end
		end)
	end

	return resultTable
end

MultipleRuns_ = {
	type_ = "MultipleRuns",
	--- Function that returns the result of a given MultipleRuns instance.
	-- @arg number Index of the desired execution in the MultipleRuns.simulations returned.
	-- @usage
	-- import("calibration")
	-- MyModel = Model{
	-- x = Choice{-100, -1, 0, 1, 2, 100},
	--   finalTime = 1,
	--   init = function(self)
	--     self.timer = Timer{
	--       Event{action = function()
	--         self.value = x
	--       end}
	--     }
	--   end
	-- }
	-- m = MultipleRuns{
	--  model = MyModel,
	--  strategy = "sample",
	--  parameters = {x = Choice{-100, -1, 0, 1,2,100}},
	--  quantity = 3,
	--  additionlOutputFunction = function(model)
	--    print(model.x)
	--  end}
	-- -- Get the X value in the first execution
	-- result = m:get(1).x
	get = function(self, number)
		mandatoryArgument(1, "number", number)
		local getTable = {}

		forEachOrderedElement(self, function(idx, att, typ)
			if typ == "table" then
				if self[idx][number] ~= nil then		
					getTable[idx] = self[idx][number]
				else
					forEachOrderedElement(att, function(idx2, att2, typ2)
						if typ2 == "table" then
							if getTable[idx] == nil then
								getTable[idx] = {}
							end

							getTable[idx][idx2] = self[idx][idx2][number]
						end
					end)
				end
			end
		end)

		return getTable
	end,
	--- Save the results of MultipleRuns to a CSV file.
	-- Each line represents the values in a different simulation.
	-- The columns are each of the parameters passed to MultipleRuns
	-- and the return values of all additional functions and parameters in the output table.
	-- @arg name The name of the CSV file.
	-- @arg separator The chosen separator to be used in the CSV file.
	-- @usage
	-- import("calibration")
	-- MyModel = Model{
	--     x = Choice{-100, -1, 0, 1, 2, 100},
	--     finalTime = 1,
	--     init = function(self)
	--         self.timer = Timer{
	--             Event{action = function()
	--                 self.value = x
	--             end}
	--         }
	--      end
	-- }
	--
	-- m = MultipleRuns{
	--      model = MyModel,
	--      parameters = {x = 2},
	--      repetition = 3,
	--  }
	--
	-- -- Saves MultipleRuns results:
	-- m:saveCSV("myCSVFile", ";")
	saveCSV = function(self, name, separator)
		mandatoryArgument(2, "string", separator)
		mandatoryArgument(1, "string", name)
		local CSVTable = {}

		forEachOrderedElement(self, function(idx, att, typ)
			if typ == "table" and idx ~= "parameters" then
				local counter = 0
				forEachOrderedElement(att, function(idx2, att2, typ2)
					counter = counter + 1
					if CSVTable[counter] == nil then
						CSVTable[counter] = {}
					end

					CSVTable[counter][idx] = att2
				end)
			end
		end)
		local csvFile = File(name..".csv")
		csvFile:write(CSVTable, separator)
	end
}

metaTableMultipleRuns_ = {
	__index = MultipleRuns_
}

--- The Multiple Runs type has various model execution strategies, that can be used by the modeler
-- to compare the results of a model and analyze it's behavior in different scenarios.
-- It returns a MultipleRuns table with the results.
-- @output simulations A table of folder names, a folder is created for each model instance to save the output functions result. Its indexed by execution order.
-- @output parameters A table with parameters used to instantiate the model in this simulation. Also indexed by execution order.
-- @output output A table with the return value of an additional function, and the final values in each model execution for all parameters in the output table. A different table is created for each of the additional functions and parameters in the output table, its name depend on the user defined functions.
-- @usage
-- -- Complete Example:
-- import("calibration")
-- local MyModel = Model{
--     x = Choice{-100, -1, 0, 1, 2, 100},
--     y = Choice{min = 1, max = 10, step = 1},
--     finalTime = 1,
--     init = function(self)
--         self.timer = Timer{
--             Event{action = function()
--                 self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
--             end}
--         }
--     end
-- }
--
-- c = MultipleRuns{
--     model = MyModel,
--     strategy = "sample",
--     quantity = 5,
--     parameters = {
--         x = Choice{-100, -1, 0, 1, 2, 100},
--         y = Choice{min = 1, max = 10, step = 1},
--         finalTime = 1
--     },
--     additionalOutputfunction = function(model)
--         return model.value
--     end,
--     additionalFunction = function(model)
--         return model.value/2
--     end
-- }
--
-- -- Repeated Example:
-- local RainModel = Model{
--     water = Choice{min = 0, max = 100},
--     rain = Choice{min = 0, max = 20},
--     finalTime = 2,
--     init = function(self)
--         self.timer = Timer{
--             Event{action = function()
--                 self.water = self.water + (self.rain - 150)
--             end}
--         }
--     end
-- }
--
-- -- Factorial Example. It will run the model 2*66 times to test all the possibilities
-- -- for the parameters repetition times.
-- MultipleRuns{
--     model = RainModel,
--     strategy = "factorial",
--     parameters = {
--         water = Choice{min = 10, max = 20, step = 1},
--         rain = Choice{min = 10, max = 20, step = 2},
--         finalTime = 1
--     },
--     repetition = 2
-- }
--
-- r = MultipleRuns{
--     model = RainModel,
--     parameters = {water = 10, rain = 20, finalTime = 1},
--     repetition = 10,
--     showProgress = true
-- }
--
-- -- This should run the model 10 times with the same parameters.
-- -- Sample Example:
-- MultipleRuns{
--     model = RainModel,
--     strategy = "sample",
--     parameters = {
--         water = Choice{min = 10, max = 20, step = 1},
--         rain = Choice{min = 10, max = 20, step = 2},
--         finalTime = 10,
--     },
--     quantity = 5
-- }
--
-- -- This should run the model 5 times selecting random values from the defined parameters
-- -- (if they are choice, otherwise use the only available value).
-- -- Selected Example:
-- x = MultipleRuns{
--     model = RainModel,
--     strategy = "selected",
--     parameters = {
--         scenario1 = {water = 10, rain = 20, finalTime = 10},
--         scenario2 = {water = 5, rain = 10, finalTime = 10}
--     }
-- }
-- -- This should run the model two times with the same parameters defined in the vector of parameters.
-- @arg data.repetition repetition of runs that must be executed with the same parameters.
-- The default value is 1.
-- @arg data.quantity number of samples to be created in sample strategy execution.
-- @arg data.model The Model to be instantiated and executed several times.
-- @arg data.parameters A table with the parameters to be tested. These parameters must be a subset
-- of the parameters of the Model with a subset of the available values.
-- They may have any name the modeler chooses.
-- @arg data.output An optional user defined table of model attributes.
-- The values of these attributes, for each of the model executions, are returned in a table in the result of MultipleRuns.
-- @arg data.folderName Name or file path of the folder where the simulations output will be saved.
-- Whenever the Model saves one or more files along its simulation, it is necessary to use this
-- argument to guarantee that the files of each simulation will be saved in a different directory.
-- @arg data.hideGraphs If true, then disableGraphics() will disable all charts and observers during models execution.
-- @arg data.showProgress If true, a message is printed on screen to show the models executions progress on repeated strategy,
-- (Default is false).
-- @arg data.strategy Strategy to be used when testing the model. See the table below:
-- @arg data.... Additional functions can be defined by the user. Such functions are
-- executed each time a simulation of a Model ends and get as parameter the model instance
-- itself. MultipleRuns will get the returning value of these function calls and
-- put it into a vector of results available in the returning value of MultpleRuns.
-- @tabular strategy
-- Strategy  & Description & Mandatory arguments & Optional arguments \
-- "factorial" & Simulate the Model with all combinations of the argument parameters. 
-- & parameters, model & repetition, output, hideGraphs, quantity, folderName, showProgress, ... \
-- "sample" & Run the model with a random combination of the possible parameters & parameters,
-- repetition, model & output, folderName, hideGraphs, quantity, showProgress, ... \
-- "selected" & This should test the Model with a given set of parameters values. In this case,
-- the argument parameters must be a named table, where each position is another table describing
-- the parameters to be used in such simulation. &
-- model, parameters & output, folderName, hideGraphs, repetition, showProgress, quantity, ... 
function MultipleRuns(data)
	mandatoryTableArgument(data, "model", "Model")
	mandatoryTableArgument(data, "parameters", "table")
	if type(data.output) == 'string' then
		data.output = {data.output}
	end

	optionalTableArgument(data, "output", "table")
	optionalTableArgument(data, "strategy", "string")
	defaultTableValue(data,  "repetition", 1)
	optionalTableArgument(data, "folderName", "string")
	optionalTableArgument(data, "quantity", "number")
	defaultTableValue(data, "hideGraphs", false)
	defaultTableValue(data, "showProgress", false)

	if data.strategy == nil then
		local choiceStrg = false

		forEachOrderedElement(data.parameters, function (idx, att, typ)
			if typ == "table" then
				forEachOrderedElement(att, function (idx2, att2, typ2)

					if typ2 == "Choice" then
						choiceStr = true
					end
				end)
			else
				if typ == "Choice" then
					choiceStrg = true
				end
			end
		end)

		if choiceStrg == true then
			if data.quantity ~= nil then
				data.strategy = "sample"
			else
				data.strategy = "factorial"
			end
		else
			data.strategy = "selected"
		end
	end		

	local resultTable = {simulations = {}} 
	-- addFunctions: Parameter that organizes the additional functions choosen to be executed after the model.
	local addFunctions = {}
	data.outputVariables = {}

	if data.output ~= nil then
		forEachOrderedElement(data.output, function(idx, att, typ)
			if data[att] ~= nil then
				customError("Values in output parameters or additional functions should not be repeated or have the same name.")
			end

			if data.strategy ~= "selected" then
				if data.parameters[att] ~= nil then
					customError("MultipleRuns already saves the output of all parameters inputed for testing, it's not necessary to select them in the 'output' table.")
				end

			else
				forEachOrderedElement(data.parameters, function (pid, pat, pty)
					if pty == "table" then
						if pat[att] ~= nil then
							customError("MultipleRuns already saves the output of all parameters inputed for testing, it's not necessary to select them in the 'output' table.")
						end
					end
				end)
			end

			data[att] = function(model)
				return model[att]
			end

			data.outputVariables[att] = true
		end)
	end
	

	forEachOrderedElement(data, function(idx, att, typ)
		if type(att) == "function" then
			if addFunctions[idx] ~= nil then
				customError("Values in output parameters or additional functions should not be repeated or have the same name.")
			end
			
			addFunctions[idx] = att 
		else
			local checkingArgument = {}
			checkingArgument[idx] = idx
			verifyUnnecessaryArguments(checkingArgument, {
				"model", "output", "strategy", "parameters", "repetition", "folderName", "hideGraphs", "showProgress", "repeat", "quantity", "outputVariables"})
		end
	end)

	checkParameters(data.model, data)
	data.output = nil

	--If hideGraphs is true, hide Map and Chart graphs during models execution
	local copyChart
	local copyMap
	if data.hideGraphs == true then
		disableGraphics()
	end

	local params = {} 
	-- Organizing the parameters table of multiple runs into a simpler table,
	-- indexed by number with the characteristics of each parameter.
	if data.strategy ~= "selected" then
		local mainTable = nil
		forEachOrderedElement(data.parameters, function(idx, attribute, atype)
			if atype ~= "table" then
				parametersOrganizer(mainTable, idx, attribute, atype, params)
			else
				forEachOrderedElement(attribute, function(idx2, att2, typ2)
					parametersOrganizer(idx, idx2, att2, typ2, params) 
				end)
			end
		end)
	end

	-- Setting the folder for the tests results to be saved:
	local s = package.config:sub(1, 1) 
	local firstDir = currentDir()
	local folderDir = currentDir()
	local folder = data.folderName

	if folder ~= nil then
		dir = Directory(folder) 
		local mkDirValue, mkDirError = dir:create()
		if not mkDirValue then
			if mkDirError ~= "File exists" then
				Directory(firstDir):setCurrentDir()
				customError('Folder "'..folder..'": '..mkDirError)
			end
		end

		Directory(folder):setCurrentDir()
		folderDir = currentDir()
		Directory(firstDir):setCurrentDir()
	end

	local variables = {}	
	switch(data, "strategy"):caseof{
		-- Prepares the variables and executes the model according to each strategy.
		factorial = function()

			forEachOrderedElement(data.parameters, function(idx, attribute, atype)
				resultTable[idx] = {}
				if atype == "table" then
					forEachOrderedElement(attribute, function(idx2)
						resultTable[idx][idx2] = {}
					end)
				end
			end)
			local repeated = false
			if data.repetition > 1 then
				repeated = true
			end


			if data.folderName then
				Directory(folderDir):setCurrentDir()
			end

			for i = 1, data.repetition do
				resultTable = factorialRecursive(data, params, 1, variables, resultTable, addFunctions, s, i, repeated)
			end

			if data.folderName then
				Directory(firstDir):setCurrentDir()
			end
		end,
		sample = function()
			mandatoryTableArgument(data, "quantity", "number")
			local repetition
			repetition = data.repetition

			if data.folderName then
				Directory(folderDir):setCurrentDir()
			end

			for case = 1, repetition do
				local stringSimulations = ""
				if repetition > 1 then
					stringSimulations = case.."_execution_"
				end
				for i = 1, data.quantity do
					local sampleparams = {}
					local m = randomModel(data.model, data.parameters)
					resultTable.simulations[#resultTable.simulations + 1] = stringSimulations..""..(#resultTable.simulations + 1 - (#resultTable.simulations*(case - 1)))..""

					if data.folderName then
						dir = Directory(stringSimulations..""..(#resultTable.simulations + 1 - (#resultTable.simulations*(case - 1))).."") 
						dir:create()
						Directory(folderDir..s..stringSimulations..""..(#resultTable.simulations + 1 - (#resultTable.simulations*(case - 1)))..""):setCurrentDir()
					end

					testAddFunctions(resultTable, addFunctions, data, m)

					if data.folderName then
						Directory(folderDir):setCurrentDir()
					end

					forEachOrderedElement(data.parameters, function(idx2, att2, typ2)
						if typ2 ~= "table" then
							sampleparams[idx2] = m.idx2
						else
							if sampleparams[idx2] == nil then
								sampleparams[idx2] = {}
							end

							forEachOrderedElement(att2, function(idx3, att3, typ3)
								sampleparams[idx2][idx3] = m[idx2].idx3
							end)
						end
					end)

					forEachOrderedElement(sampleparams, function (idx2, att2, typ2)
						if resultTable[idx2] == nil then 
							resultTable[idx2] = {}
						end

						resultTable[idx2][#resultTable[idx2] + 1] = att2 
					end)
				end
			end

			Directory(firstDir):setCurrentDir()
		end,
		selected = function()
			if data.folderName then
				Directory(folderDir):setCurrentDir()
			end

			local repetition 
			repetition = data.repetition


			local models = {}
			forEachOrderedElement(data.parameters, function(idx, att, atype)
					models[idx] = data.model(att)
			end)

			for case = 1, repetition do
				local stringSimulations = ""
				if repetition > 1 then
					stringSimulations = case.."_execution_"
				end
				forEachOrderedElement(models, function(idx, att, atype)
					local m = models[idx]
					m:run()
					resultTable.simulations[#resultTable.simulations + 1] = stringSimulations..""..(idx)..""

					if data.folderName then
						dir = Directory(stringSimulations..""..(idx).."")
						dir:create() 
						Directory(folderDir..s..stringSimulations..""..(idx)..""):setCurrentDir()
					end

					testAddFunctions(resultTable, addFunctions, data, m)

					if data.folderName then
						Directory(folderDir):setCurrentDir()
					end

					forEachOrderedElement(data.parameters[idx], function(idx2, att2, typ2)
						if resultTable[idx2] == nil then 
							resultTable[idx2] = {}
						end

						resultTable[idx2][#resultTable[idx2] + 1] = att2 
					end)
				end)
			end
			Directory(firstDir):setCurrentDir()
		end
	}
	setmetatable(data, metaTableMultipleRuns_)
	forEachOrderedElement(resultTable, function(idx, att, type)
		data[idx] = att
	end)

	Directory(firstDir):setCurrentDir()
	if data.hideGraphs == true then
		enableGraphics()
	end

	data.outputVariables = nil
	return data
end

