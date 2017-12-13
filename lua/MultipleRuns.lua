-- checkParameters auxiliar function.
local function checkMultipleRunsStrategyRules(origParameters, Param, idx, idxt)
	if type(Param) == "Choice" then
		if origParameters.strategy == "selected" then
			customError("Parameters used in strategy 'selected' cannot be 'Choice'.")
		end
	elseif origParameters.strategy == "selected" then
		if idxt == nil then
			forEachOrderedElement(origParameters.parameters, function(_, sParam, sType)
				if sType ~= "table" then
					customError("Parameters used in strategy 'selected' must be in a table of scenarios.")
				end

				if type(sParam[idx]) == "Choice" then
					customError("Parameters used in strategy 'selected' cannot be 'Choice'.")
				end
			end)
		else
			forEachOrderedElement(origParameters.parameters, function(_, sParam)
				if type(sParam[idx]) ~= "table" then
					customError("Parameters used in strategy 'selected' must be in a table of scenarios.")
				end

				if type(sParam[idx][idxt]) == "Choice" then
					customError("Parameters used in strategy 'selected' cannot be 'Choice'.")
				end
			end)
		end
	end
end

-- Function to be used by Multiple Runs to check
-- if all possibilites of models can be instantiated before
-- starting to test the model.
-- @arg origModel A Paramater with the model to be instantiated.
-- @arg origParameters A table of parameters, from a MultipleRuns or Calibration type.
local function checkParameters(origModel, origParameters)
	mandatoryArgument(1, "Model", origModel)
	mandatoryTableArgument(origParameters, "parameters", "table")
	-- Tests all model parameters possibilities in Multiple Runs/Calibration to see if they are in the accepted
	-- range of values according to a Model.
	local modelParametersSet = {}
	forEachElement(origModel:getParameters(), function(idx, att, mtype)
		modelParametersSet[idx] = true
		if mtype == "function" then return end
		if idx == "init" then return end

		local Param = origParameters.parameters[idx]
		-- check if all parameters fit the choosen strategy rules before
		-- checking if it obeys the model rules.
		if mtype ~= "table" then
			checkMultipleRunsStrategyRules(origParameters, Param, idx)
		end

		if mtype == "Choice" then
			if type(Param) == "Choice" then
				-- if parameter in Multiple Runs/Calibration is a range of values
				if Param.min ~= nil or Param.max ~= nil or Param.step ~= nil then
					checkParametersRange(origModel, idx, Param)
				else
					-- if parameter Multiple Runs/Calibration is a grop of values
					 checkParametersSet(origModel, idx, Param)
				end

			elseif origParameters.strategy == "selected" then
				forEachOrderedElement(origParameters.parameters, function(_, sParam)
					checkParameterSingle(origModel, idx, 1, sParam[idx])
				end)
			elseif type(Param) == "table" then
				customError("The parameter must be of type Choice, a table of Choices or a single value.")
			end
		elseif mtype == "Mandatory" then
			--Check if mandatory argument exists in origParameters.parameters and if it matches the correct type.
			local mandatory = false
			local mandArg = origParameters.parameters[idx]
			if type(mandArg) ~= nil then
				if type(mandArg) == att.value then
						mandatory = true
				elseif type(mandArg) == "Choice" then
					if mandArg.max ~= nil or mandArg.min ~= nil then
						if "number" == att.value then
							mandatory = true
						end
					else
						mandatory = true
						forEachOrderedElement(mandArg.values, function(_, _, typ3)
							if typ3 ~= att.value then
								mandatory = false -- SKIP
							end
						end)
					end
				end
			end

			if mandatory == false then
				mandatoryTableArgument(origParameters.parameters, idx, att.value)
			end
		elseif mtype == "table" then
			forEachOrderedElement(att, function(idxt, attt)
				if origParameters.parameters[idx] ~= nil then
					Param = origParameters.parameters[idx][idxt]
				end

				-- check if all parameters fit the choosen strategy rules before
				-- checking if it obeys the model rules.
				checkMultipleRunsStrategyRules(origParameters, Param, idx, idxt)
				if type(Param) == "Choice" then
					-- if parameter in Multiple Runs/Calibration is a range of values
					if Param.min ~= nil or Param.max ~= nil or Param.step ~= nil then
						checkParametersRange(origModel, idxt, Param, idx)
					else
					-- if parameter Multiple Runs/Calibration is a grop of values
						 checkParametersSet(origModel, idxt, Param,idx)
					end

				elseif origParameters.strategy == "selected" then
					forEachOrderedElement(origParameters.parameters, function(_, sParam)
						checkParameterSingle(origModel, idxt, 1, sParam[idx][idxt], idx)
					end)
				elseif type(Param) == "table" and type(attt) == "Choice" then
					customError("The parameter must be of type Choice, a table of Choices or a single value.")
				end
			end)
		end
	end)

	if origParameters.strategy ~= "selected" then
		forEachOrderedElement(origParameters.parameters, function(idx)
			if modelParametersSet[idx] == nil then
				customError(idx.." is unnecessary.")
			end
		end)
	else
		forEachOrderedElement(origParameters.parameters, function(_, att)
			forEachOrderedElement(att, function(idx)
				if modelParametersSet[idx] == nil then
					customError(idx.." is unnecessary.")
				end
			end)
		end)
	end
end

local function testAddFunctions(resultTable, addFunctions, data, m, summaryResult)
	forEachElement(m, function(attr, value, typ)
		if addFunctions[attr] ~= nil then
			customError("It is not possible to use function '"..attr.."' as output because this name is already an output value of the model.")
		end

		if typ == "number" then
			if not resultTable[attr] then
				resultTable[attr] = {}
			end

			local foundOnParameters = false
			if data.strategy == "selected" then
				forEachOrderedElement(data.parameters, function (_, pat, pty)
					if pty == "table" then
						if pat[attr] then
							foundOnParameters = true
							return
						end
					end
				end)
			end

			if not data.parameters[attr] and not foundOnParameters or data.strategy == "sample" then
				table.insert(resultTable[attr], value)
			end
		end
	end)

	if addFunctions == nil then return end

	forEachOrderedElement(addFunctions, function(idxF)
		if resultTable[idxF] == nil then
			resultTable[idxF] = {}
		end

		local returnValueF = data[idxF](m)
		table.insert(resultTable[idxF], returnValueF)
		if data.summary then
			if not summaryResult[idxF] then
				summaryResult[idxF] = {}
			end
			table.insert(summaryResult[idxF], returnValueF)
		end
	end)
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
			forEachOrderedElement(attribute.values, function (idv)
				table.insert(parameterElements, attribute.values[idv])
			end)
		else
			if attribute.step == nil then
				mandatoryTableArgument(attribute, idx..".step", "Choice")
			end

			steps = attribute.step
		end

		table.insert(params, {
			id = idx,
			min = attribute.min,
			max = attribute.max,
			elements = parameterElements,
			ranged = range,
			step = steps,
			table = mainTable
		})
	else
		table.insert(parameterElements, attribute)
		table.insert(params, {
			id = idx,
			elements = parameterElements,
			ranged = false,
			step = 1,
			table = mainTable
		})
	end
end

-- function used in run() to count all the possible combinations of parameters.
-- params: Table with all the parameters and it's ranges or values indexed by number.
-- Example: params = {{id = "x", min = 1, max = 10, elements = nil, ranged = true, step = 2},
-- {id = "y", min = nil, max = nil, elements = {1, 3, 5}, ranged = false, steps = 1}}
-- i: the parameter that the function is currently variating. In the Example: [i] = [1] => x, [i] = [2]=> y.
-- Variables: The value that a parameter is being tested. Example: Variables = {x = -100, y = 1}
-- resultTable Table returned by multipleRuns as result
local function countSimulations(params, i)
	local count = 0
	if params[i].ranged then -- if the parameter uses a range of values
		for _ = params[i].min, (params[i].max + sessionInfo().round), params[i].step do
			if i == #params then
				count = count + 1
			else
				count = count + countSimulations(params, i + 1)
			end
		end
	else -- if the parameter uses a table of multiple values
		forEachOrderedElement(params[i].elements, function ()
			if i == #params then
				count = count + 1
			else
				count = count + countSimulations(params, i + 1)
			end
		end)
	end

	return count
end

local function redirectPrint(log, f)
	local oldPrint = print
	print = function(...)
		local line = {}
		for _, v in ipairs({...}) do
			table.insert(line, v) -- SKIP
		end

		table.insert(log, table.concat(line, "\t")) -- SKIP
	end

	f()

	print = oldPrint
end

local function freeModel(model)
	forEachElement(model, function(member)
		model[member] = nil
	end)
end

-- function used in run() to test the model with all the possible combinations of parameters.
-- params: Table with all the parameters and it's ranges or values indexed by number.
-- Example: params = {{id = "x", min = 1, max = 10, elements = nil, ranged = true, step = 2},
-- {id = "y", min = nil, max = nil, elements = {1, 3, 5}, ranged = false, steps = 1}}
-- a: the parameter that the function is currently variating. In the Example: [a] = [1] => x, [a] = [2]=> y.
-- Variables: The value that a parameter is being tested. Example: Variables = {x = -100, y = 1}
-- resultTable Table returned by multipleRuns as result
local function factorialRecursive(data, params, a, variables, resultTable, addFunctions, s, repeated, numSimulation, maxSimulations, elapsedTimes, initialTime, summaryTable, firstDir, folderDir)
	if params[a].ranged then -- if the parameter uses a range of values
		for parameter = params[a].min, (params[a].max + sessionInfo().round), params[a].step do -- Testing the parameter with each value in it's range.
			-- Giving the variables table the current parameter and value being tested.
			if params[a].table == nil then
				variables[params[a].id] = parameter
			else
				if variables[params[a].table] == nil then
					variables[params[a].table] = {}
				end

				variables[params[a].table][params[a].id] = parameter
			end

			if a == #params then -- if all parameters have already been given a value to be tested.
				if data.summary then
					forEachOrderedElement(variables, function(variable, value, typ)
						if not summaryTable[variable] then
							summaryTable[variable] = {}
						end
						if typ ~= "table" then
							table.insert(summaryTable[variable], value)
						else
							table.insert(summaryTable[variable], clone(value))
						end
					end)
				end

				local summaryResult = {repetition = data.repetition} -- table to store the results from each output function
				for case = 1, data.repetition do
					numSimulation = numSimulation + 1
					local iterationTime = sessionInfo().time -- time to compute a single interation (bigger than simulation time)
					local mVariables = {} -- copy of the variables table to be used in the model.
					forEachOrderedElement(variables, function(idx, attribute)
						mVariables[idx] = attribute
					end)

					local stringSimulations = ""
					if repeated == true then
						stringSimulations = case.."_execution_"
					end

					forEachOrderedElement(variables, function (idx2, att2, typ2)
						if typ2 ~= "table" then
							table.insert(resultTable[idx2], att2)
							stringSimulations = stringSimulations..idx2.."_"..att2.."_"
						else
							forEachOrderedElement(att2, function(idx3, att3)
								table.insert(resultTable[idx2][idx3], att3)
								stringSimulations = stringSimulations..idx2.."_"..idx3.."_"..att3.."_"
							end)
						end
					end)

					local testDir = folderDir
					firstDir:setCurrentDir()
					local simulationTime = sessionInfo().time
					local log = {}
					local m
					redirectPrint(log, function()
						m = data.model(mVariables)
					end)

					testDir:setCurrentDir()
					if data.folderName then
						local dir = Directory(stringSimulations)
						dir:create() -- SKIP
						Directory(testDir..s..stringSimulations):setCurrentDir() -- SKIP
					end

					if data.showProgress then
						local title = m:title()
						if repeated then
							title = table.concat({title, string.format("repetition %d/%d", case, data.repetition)}, ", ")
						end

						print(string.format("Running simulation %d/%d (%s)", numSimulation, maxSimulations, title)) -- SKIP
						redirectPrint(log, function()
							m:run() -- SKIP
						end)

						simulationTime = round(sessionInfo().time - simulationTime) -- SKIP
						print(string.format("Simulation finished in %s", timeToString(simulationTime))) -- SKIP
						iterationTime = sessionInfo().time - iterationTime -- SKIP
						table.insert(elapsedTimes, iterationTime) -- SKIP
						local elapsedReal = 0
						for _, t in pairs(elapsedTimes) do
							elapsedReal = elapsedReal + t -- SKIP
						end

						local elapsedMean = elapsedReal / #elapsedTimes
						local estimatedTime = elapsedReal + (maxSimulations - numSimulation) * elapsedMean
						local timeLeft = math.max(round(initialTime + estimatedTime - os.time()), 0)
						local timeString = os.date("%H:%M", round(initialTime + estimatedTime))
						print(string.format("Estimated time to finish all simulations: %s (%s)", timeString, timeToString(timeLeft))) -- SKIP
					else
						redirectPrint(log, function()
							m:run()
						end)

					end

					local logfile = File("output.log")
					logfile:writeLine(table.concat(log, "\n"))
					logfile:close()
					clean()
					testAddFunctions(resultTable, addFunctions, data, m, summaryResult)
					testDir:setCurrentDir()
					table.insert(resultTable.simulations, stringSimulations)
					if data.free then
						freeModel(m)
						m = nil
						collectgarbage()
					end
				end

				if data.summary and type(data.summary) == "function" then
					local retSummary = data.summary(summaryResult)
					verifyNamedTable(retSummary)
					forEachElement(retSummary, function(key, value) -- insert the result from each function to summaryTable
						if not summaryTable[key] then
							summaryTable[key] = {}
						end

						table.insert(summaryTable[key], value)
					end)
				end
			else -- else, go to the next parameter to test it with it's range of values.
				resultTable, numSimulation, elapsedTimes, summaryTable = factorialRecursive(data, params, a + 1, variables, resultTable, addFunctions, s, repeated, numSimulation, maxSimulations, elapsedTimes, initialTime, summaryTable, firstDir, folderDir)
			end
		end
	else -- if the parameter uses a table of multiple values
		forEachOrderedElement(params[a].elements, function (_, attribute)
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

			if a == #params then -- if all parameters have already been given a value to be tested.
				if data.summary then
					forEachOrderedElement(variables, function(variable, value, typ)
						if not summaryTable[variable] then
							summaryTable[variable] = {}
						end
						if typ ~= "table" then
							table.insert(summaryTable[variable], value)
						else
							table.insert(summaryTable[variable], clone(value))
						end
					end)
				end
				local summaryResult = {repetition = data.repetition} -- table to store the results from each output function
				for case = 1, data.repetition do
					numSimulation = numSimulation + 1
					local iterationTime = sessionInfo().time -- time to compute a single interation (bigger than simulation time)
					local mVariables = {} -- copy of the variables table to be used in the model.
					forEachOrderedElement(variables, function(idx2, attribute2)
						mVariables[idx2] = attribute2
					end)

					local stringSimulations = ""
					if repeated == true then
						stringSimulations = case.."_execution_"
					end

					forEachOrderedElement(variables, function(idx2, att2, typ2)
						if typ2 ~= "table" then
							table.insert(resultTable[idx2], att2)
							stringSimulations = stringSimulations..idx2.."_"..att2.."_"
						else
							forEachOrderedElement(att2, function(idx3, att3, _)
								table.insert(resultTable[idx2][idx3], att3)
								stringSimulations = stringSimulations..idx2.."_"..idx3.."_"..att3.."_"
							end)
						end
					end)

					local testDir = folderDir
					firstDir:setCurrentDir()
					local simulationTime = sessionInfo().time
					local log = {}
					local m
					redirectPrint(log, function()
						m = data.model(mVariables)
					end)

					testDir:setCurrentDir()
					if data.folderName then
						local dir = Directory(stringSimulations)
						dir:create()
						Directory(testDir..s..stringSimulations):setCurrentDir()
					end

					if data.showProgress then
						local title = m:title()
						if repeated then
							title = table.concat({title, string.format("repetition %d/%d", case, data.repetition)}, ", ")
						end

						print(string.format("Running simulation %d/%d (%s)", numSimulation, maxSimulations, title)) -- SKIP
						redirectPrint(log, function()
							m:run() -- SKIP
						end)

						simulationTime = round(sessionInfo().time - simulationTime) -- SKIP
						print(string.format("Simulation finished in %s", timeToString(simulationTime))) -- SKIP
						iterationTime = sessionInfo().time - iterationTime -- SKIP
						table.insert(elapsedTimes, iterationTime) -- SKIP
						local elapsedReal = 0
						for _, t in pairs(elapsedTimes) do
							elapsedReal = elapsedReal + t -- SKIP
						end

						local elapsedMean = elapsedReal / #elapsedTimes
						local estimatedTime = elapsedReal + (maxSimulations - numSimulation) * elapsedMean
						local timeLeft = math.max(round(initialTime + estimatedTime - os.time()), 0)
						local timeString = os.date("%H:%M", round(initialTime + estimatedTime))
						print(string.format("Estimated time to finish all simulations: %s (%s)", timeString, timeToString(timeLeft))) -- SKIP
					else
						redirectPrint(log, function()
							m:run()
						end)
					end

					local logfile = File("output.log")
					logfile:writeLine(table.concat(log, "\n"))
					logfile:close()
					clean()
					testAddFunctions(resultTable, addFunctions, data, m, summaryResult)
					testDir:setCurrentDir()
					table.insert(resultTable.simulations, stringSimulations)
					if data.free then
						freeModel(m)
						m = nil
						collectgarbage()
					end
				end

				if data.summary then
					local retSummary = data.summary(summaryResult)
					verifyNamedTable(retSummary)
					forEachElement(retSummary, function(key, value) -- insert the result from each function to summaryTable
						if not summaryTable[key] then
							summaryTable[key] = {}
						end

						table.insert(summaryTable[key], value)
					end)
				end
			else -- else, go to the next parameter to test it with each of it possible values.
				resultTable, numSimulation, elapsedTimes, summaryTable = factorialRecursive(data, params, a + 1, variables, resultTable, addFunctions, s, repeated, numSimulation, maxSimulations, elapsedTimes, initialTime, summaryTable, firstDir, folderDir) -- SKIP
			end
		end)
	end
	return resultTable, numSimulation, elapsedTimes, summaryTable
end

MultipleRuns_ = {
	type_ = "MultipleRuns",
}

metaTableMultipleRuns_ = {
	__index = MultipleRuns_
}

--- The Multiple Runs type has various model execution strategies, that can be used by the modeler
-- to compare the results of a model and analyze it's behavior in different scenarios.
-- It returns a MultipleRuns table with the results.
-- @output simulations A table with directory names. A directory is created for each model instance to save the output functions result.
-- It is indexed by execution order.
-- @output parameters A table with parameters used to instantiate the model in this simulation. Also indexed by execution order.
-- @output output A DataFrame with the final values in each model execution. The additional functions used as arguments for MultipleRuns will also generate attributes whose name will be the function's name, and whose values will be the returning value of such function given the final state of the model as argument.
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
-- c = MultipleRuns{
--     model = MyModel,
--     strategy = "sample",
--     showProgress = false,
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
-- -- Selected Example:
-- m = MultipleRuns{
-- 	model = MyModel,
--  showProgress = false,
-- 	parameters = {
-- 		scenario1 = {x = 2, y = 5},
-- 		scenario2 = {x = 1, y = 3}
-- 	 },
-- 	output = {"value"},
-- 	additionalF = function(model)
-- 		return "test"
-- 	end
-- }
--
-- -- This should run the model 10 times with the same parameters:
-- r = MultipleRuns{
--     model = RainModel,
--     showProgress = false,
--     parameters = {repeatScenario = {water = 10, rain = 20, finalTime = 1}},
--     repetition = 10
-- }
--
-- -- Factorial Example. It will run the model 2*66 times to test all the possibilities
-- -- for the parameters repetition times.
-- MultipleRuns{
--     model = RainModel,
--     showProgress = false,
--     strategy = "factorial",
--     parameters = {
--         water = Choice{min = 10, max = 20, step = 1},
--         rain = Choice{min = 10, max = 20, step = 2},
--         finalTime = 1
--     },
--     repetition = 2
-- }
--
-- -- Sample Example:
-- MultipleRuns{
--     model = RainModel,
--     strategy = "sample",
--     showProgress = false,
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
-- @arg data.free If true, then the memory used by Model instances will be removed after their simulations. Only the observed
-- properties of the model will be stored within MultipleRuns, (Default is false).
-- @arg data.hideGraphics If true (default), then sessionInfo().graphics will disable all charts and observers during models execution.
-- @arg data.showProgress If true, a message is printed on screen to show the models executions progress on repeated strategy,
-- (Default is false).
-- @arg data.summary A function can be defined by the user to summarize results after executing all repetitions of a set of parameters.
-- This function gets as a parameter a table containing the values of each variable, the results of each simulation and results of each
-- user-defined functions.
-- @arg data.strategy Strategy to be used when testing the model. See the table below:
-- @arg data.... Additional functions can be defined by the user. Such functions are
-- executed each time a simulation of a Model ends and get as parameter the model instance
-- itself. MultipleRuns will get the returning value of these function calls and
-- put it into a vector of results available in the returning value of MultpleRuns.
-- @tabular strategy
-- Strategy & Description & Mandatory arguments & Optional arguments \
-- "factorial" & Simulate the Model with all combinations of the argument parameters.
-- & parameters, model & repetition, output, hideGraphics, quantity, folderName, free, showProgress, summary, ... \
-- "sample" & Run the model with a random combination of the possible parameters & parameters,
-- repetition, model & output, folderName, free, hideGraphics, quantity, showProgress, summary, ... \
-- "selected" & This should test the Model with a given set of parameters values. In this case,
-- the argument parameters must be a named table, where each position is another table describing
-- the parameters to be used in such simulation. &
-- model, parameters & output, folderName, free, hideGraphics, quantity, repetition, showProgress, summary, ...
function MultipleRuns(data)
	mandatoryTableArgument(data, "model", "Model")
	mandatoryTableArgument(data, "parameters", "table")

	optionalTableArgument(data, "strategy", "string")
	defaultTableValue(data, "repetition", 1)
	optionalTableArgument(data, "folderName", "string")
	optionalTableArgument(data, "quantity", "number")
	defaultTableValue(data, "hideGraphics", true)
	defaultTableValue(data, "showProgress", true)
	optionalTableArgument(data, "summary", "function")
	defaultTableValue(data, "free", false)

	if data.strategy == nil then
		local choiceStrg = false

		forEachOrderedElement(data.parameters, function (_, att, typ)
			if typ == "table" then
				forEachOrderedElement(att, function (_, _, typ2)
					if typ2 == "Choice" then
						choiceStrg = true
					end
				end)
			else
				if typ == "Choice" then
					choiceStrg = true
				end
			end
		end)

		if choiceStrg then
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
	local summaryTable = {}

	forEachOrderedElement(data, function(idx, att)
		if type(att) == "function" then
			if addFunctions[idx] ~= nil then
				customError("Values in output parameters or additional functions should not be repeated or have the same name.")
			end

			if idx ~= "summary" then
				addFunctions[idx] = att
			end
		else
			local checkingArgument = {}
			checkingArgument[idx] = idx
			verifyUnnecessaryArguments(checkingArgument, {
				"model", "strategy", "parameters", "repetition", "folderName", "hideGraphics", "showProgress", "repeat", "quantity", "outputVariables", "free"})
		end
	end)

	checkParameters(data.model, data)

	if data.hideGraphics then
		sessionInfo().graphics = false
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
		local dir = Directory(folder)
		local mkDirValue, mkDirError = dir:create()
		if not mkDirValue then
			if mkDirError ~= "File exists" then -- SKIP
				firstDir:setCurrentDir() -- SKIP
				customError('Folder "'..folder..'": '..mkDirError) -- SKIP
			end
		end

		Directory(folder):setCurrentDir()
		folderDir = currentDir()
		firstDir:setCurrentDir()
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
				folderDir:setCurrentDir()
			end

			local maxSimulations = countSimulations(params, 1) * data.repetition
			local initialTime = os.time()
			resultTable = factorialRecursive(data, params, 1, variables, resultTable, addFunctions, s, repeated, 0, maxSimulations, {}, initialTime, summaryTable, firstDir, folderDir)
			if data.folderName then
				firstDir:setCurrentDir()
			end
		end,
		sample = function()
			mandatoryTableArgument(data, "quantity", "number")
			local repetition
			repetition = data.repetition

			local maxSimulations = math.max(repetition, 1) * math.max(data.quantity, 1)
			local numSimulation = 0
			local initialTime = os.time()
			local elapsedTimes = {}
			for quantity = 1, data.quantity do
				local summaryResult = {repetition = data.repetition} -- table to store the results from each output function
				if data.summary then
					forEachOrderedElement(variables, function(variable, value)
						if not summaryTable[variable] then -- SKIP
							summaryTable[variable] = {}
						end
						table.insert(summaryTable[variable], value) -- SKIP
					end)
				end

				for case = 1, repetition do
					local stringSimulations = ""
					if repetition > 1 then
						stringSimulations = case.."_execution_"
					end

					local iterationTime = sessionInfo().time -- time to compute a single interation
					numSimulation = numSimulation + 1
					local sampleparams = {}
					table.insert(resultTable.simulations, stringSimulations..quantity)

					local simulationTime = sessionInfo().time
					firstDir:setCurrentDir()
					local log = {}
					local m
					redirectPrint(log, function()
						m = randomModel(data.model, data.parameters)
					end)

					if data.folderName then
						folderDir:setCurrentDir()
						local dir = Directory(stringSimulations..quantity)
						dir:create()
						Directory(folderDir..s..stringSimulations..quantity):setCurrentDir()
					end

					if data.showProgress then
						local title = m:title()
						if repetition > 1 then -- SKIP
							title = table.concat({title, string.format("repetition %d/%d", case, data.repetition)}, ", ")
						end

						print(string.format("Running simulation %d/%d (%s)", numSimulation, maxSimulations, title)) -- SKIP
						redirectPrint(log, function()
							m:run() -- SKIP
						end)

						simulationTime = round(sessionInfo().time - simulationTime) -- SKIP
						print(string.format("Simulation finished in %s", timeToString(simulationTime))) -- SKIP
						iterationTime = sessionInfo().time - iterationTime -- SKIP
						table.insert(elapsedTimes, iterationTime) -- SKIP
						local elapsedReal = 0
						for _, t in pairs(elapsedTimes) do
							elapsedReal = elapsedReal + t -- SKIP
						end

						local elapsedMean = elapsedReal / #elapsedTimes
						local estimatedTime = elapsedReal + (maxSimulations - numSimulation) * elapsedMean
						local timeLeft = math.max(round(initialTime + estimatedTime - os.time()), 0)
						local timeString = os.date("%H:%M", round(initialTime + estimatedTime))
						print(string.format("Estimated time to finish all simulations: %s (%s)", timeString, timeToString(timeLeft))) -- SKIP
					else
						redirectPrint(log, function()
							m:run()
						end)
					end

					local logfile = File("output.log")
					logfile:writeLine(table.concat(log, "\n"))
					logfile:close()
					clean()
					testAddFunctions(resultTable, addFunctions, data, m, summaryResult)
					forEachOrderedElement(data.parameters, function(idx2, att2, typ2)
						if typ2 ~= "table" then
							sampleparams[idx2] = m.idx2
						else
							if sampleparams[idx2] == nil then
								sampleparams[idx2] = {}
							end

							forEachOrderedElement(att2, function(idx3)
								sampleparams[idx2][idx3] = m[idx2].idx3
							end)
						end
					end)

					forEachOrderedElement(sampleparams, function(idx2, att2)
						if resultTable[idx2] == nil then
							resultTable[idx2] = {}
						end

						table.insert(resultTable[idx2], att2)
					end)

					if data.free then
						freeModel(m)
						m = nil
						collectgarbage()
					end
				end

				if data.summary then
					local retSummary = data.summary(summaryResult)
					verifyNamedTable(retSummary)
					forEachElement(retSummary, function(key, value) -- insert the result from each function to summaryTable
						if not summaryTable[key] then
							summaryTable[key] = {}
						end

						table.insert(summaryTable[key], value)
					end)
				end
			end

			if data.folderName then
				firstDir:setCurrentDir()
			end
		end,
		selected = function()
			local repetition = data.repetition
			local maxSimulations = 0
			forEachOrderedElement(data.parameters, function()
				maxSimulations = maxSimulations + 1
			end)

			maxSimulations = maxSimulations * math.max(data.repetition, 1)
			local numSimulation = 0
			local elapsedTimes = {}
			local initialTime = os.time()
			forEachOrderedElement(data.parameters, function(idx, att)
				local summaryResult = {repetition = data.repetition} -- table to store the results of all output function
				if data.summary then
					forEachOrderedElement(att, function(variable, value)
						if not summaryTable[variable] then
							summaryTable[variable] = {}
						end
						table.insert(summaryTable[variable], value)
					end)
				end

				for case = 1, repetition do
					local stringSimulations = ""
					if repetition > 1 then
						stringSimulations = case.."_execution_"
					end

					local iterationTime = sessionInfo().time -- time to compute a single interation
					numSimulation = numSimulation + 1
					table.insert(resultTable.simulations, stringSimulations..idx)
					local simulationTime = sessionInfo().time
					firstDir:setCurrentDir()
					local log = {}
					local m
					redirectPrint(log, function()
						m = data.model(clone(att))
					end)

					if data.folderName then
						folderDir:setCurrentDir()
						local dir = Directory(stringSimulations..idx)
						dir:create()
						Directory(folderDir..s..stringSimulations..idx):setCurrentDir()
					end

					if data.showProgress then
						local title = m:title()
						if repetition > 1 then -- SKIP
							title = table.concat({title, string.format("repetition %d/%d", case, data.repetition)}, ", ")
						end

						print(string.format("Running simulation %d/%d (%s)", numSimulation, maxSimulations, title)) -- SKIP
						redirectPrint(log, function()
							m:run() -- SKIP
						end)

						simulationTime = round(sessionInfo().time - simulationTime) -- SKIP
						print(string.format("Simulation finished in %s", timeToString(simulationTime))) -- SKIP
						iterationTime = sessionInfo().time - iterationTime -- SKIP
						table.insert(elapsedTimes, iterationTime) -- SKIP
						local elapsedReal = 0
						for _, t in pairs(elapsedTimes) do
							elapsedReal = elapsedReal + t -- SKIP
						end

						local elapsedMean = elapsedReal / #elapsedTimes
						local estimatedTime = elapsedReal + (maxSimulations - numSimulation) * elapsedMean
						local timeLeft = math.max(round(initialTime + estimatedTime - os.time()), 0)
						local timeString = os.date("%H:%M", round(initialTime + estimatedTime))
						print(string.format("Estimated time to finish all simulations: %s (%s)", timeString, timeToString(timeLeft))) -- SKIP
					else
						redirectPrint(log, function()
							m:run()
						end)
					end

					local logfile = File("output.log")
					logfile:writeLine(table.concat(log, "\n"))
					logfile:close()
					clean()
					testAddFunctions(resultTable, addFunctions, data, m, summaryResult)
					forEachOrderedElement(data.parameters[idx], function(idx2, att2)
						if resultTable[idx2] == nil then
							resultTable[idx2] = {}
						end

						table.insert(resultTable[idx2], att2)
					end)

					if data.free then
						freeModel(m)
						m = nil
						collectgarbage()
					end
				end

				if data.summary then
					local retSummary = data.summary(summaryResult)
					verifyNamedTable(retSummary)
					forEachElement(retSummary, function(key, value) -- insert the result from each function to summaryTable
						if not summaryTable[key] then
							summaryTable[key] = {}
						end

						table.insert(summaryTable[key], value)
					end)
				end
			end)

			if data.folderName then
				firstDir:setCurrentDir()
			end
		end
	}

	setmetatable(data, metaTableMultipleRuns_)

	local output = {}

	forEachElement(resultTable, function(idx, value)
		if #value > 0 then
			output[idx] = value
		else
			forEachElement(value, function(midx, mvalue, mmtype)
				if mmtype == "table" then
					output[idx.."_"..midx] = mvalue
				end
			end)
		end
	end)

	data.output = DataFrame(output)
	if data.summary then
		data.summary = DataFrame(summaryTable) -- transform summaryTable in a DataFrame
	end

	firstDir:setCurrentDir()

	if data.hideGraphics then
		sessionInfo().graphics = true
	end

	data.outputVariables = nil
	return data
end

