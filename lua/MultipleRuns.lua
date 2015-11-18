local function testAddFunctions(resultTable, addFunctions, data, m)
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
end

-- The possible values for each parameter is being put in a table indexed by numbers.
-- example:
-- Params = {{id = "x", min =  1, max = 10, elements = nil, ranged = true, step = 2},
-- {id = "y", min = nil, max = nil, elements = {1, 3, 5}, ranged = false, steps = 1}}
local function parametersOrganizer(mainTable, idx, attribute, atype, Params)
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

		Params[#Params + 1] = {id = idx, min = attribute.min, 
		max = attribute.max, elements = parameterElements, ranged = range, step = steps, table = mainTable}
	else
		table.insert(parameterElements, attribute)
		table.insert(Params, {id = idx, min = nil, max = nil, elements = parameterElements, ranged = false, step = 1, table = mainTable})
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
factorialRecursive  = function(data, Params, a, variables, resultTable, addFunctions, s)
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
				

				local stringSimulations = ""
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
				mkDir(stringSimulations)
				chDir(testDir..s..stringSimulations)
				testAddFunctions(resultTable, addFunctions, data, m)
				chDir(testDir)
				resultTable.simulations[#resultTable.simulations + 1] = stringSimulations
			else  -- else, go to the next parameter to test it with it's range of values.
				resultTable = factorialRecursive(data, Params, a + 1, variables, resultTable, addFunctions, s)
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
				local stringSimulations = ""
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
				mkDir(stringSimulations)
				chDir(testDir..s..stringSimulations)
				testAddFunctions(resultTable, addFunctions, data, m)
				chDir(testDir)
				resultTable.simulations[#resultTable.simulations + 1] = stringSimulations 
			else  -- else, go to the next parameter to test it with each of it possible values.
				resultTable = factorialRecursive(data, Params, a + 1, variables, resultTable, addFunctions, s)
			end
		end)
	end

	return resultTable
end

MultipleRuns_ = {
	type_ = "MultipleRuns",
	--- Optional function defined by the user,
	-- that is executed each time the model runs.
	-- @arg data The data of the MultipleRuns object.
	-- @arg model The instance of the Model that was executed.
	-- @usage -- DONTRUN
	-- m = multipleRuns = {...
	-- output = function(model)
	-- 	return model.value
	-- end}
	output = function(data, model)
		return nil
	end,
	--- Function that returns the result of the Multiple Runs Instance.
	-- @arg data The data of the MultipleRuns object.
	-- @arg number The number of the desired execution.
	-- @usage -- DONTRUN
	-- m = multipleRuns = {...}
	-- m:get(1).x == -100
	get = function(data, number)
		mandatoryArgument(1, "number", number)
		local getTable = {}
		forEachOrderedElement(data, function(idx, att, typ)
			if typ == "table" then
				if data[idx][number] ~= nil then		
					getTable[idx] = data[idx][number]
				else
					forEachOrderedElement(att, function(idx2, att2, typ2)
						if typ2 == "table" then
							if getTable[idx] == nil then
								getTable[idx] = {}
							end

							getTable[idx][idx2] = data[idx][idx2][number]
						end
					end)
				end
			end
		end)
		return getTable
	end,
	--- Function that saves the result of the Multiple Runs instance in a .csv file.
	-- @arg data The data of the MultipleRuns object.
	-- @arg name The name of the .csv file.
	-- @arg separator The choosen separator to be used in the .csv file.
	-- @usage -- DONTRUN
	-- m = multipleRuns = {...}
	-- m:saveCSV("myCSVFile", ";")
	saveCSV = function(data, name, separator)
		mandatoryArgument(2, "string", separator)
		mandatoryArgument(1, "string", name)
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
		CSVwrite(CSVTable, name..".csv", separator)
	end
}
metaTableMultipleRuns_ = {
	__index = MultipleRuns_
}

---Type to test a model with different strategies, returns a MultipleRuns varibles with the results.
-- MultipleRuns should return an object with type MultipleRuns and the tables:
-- ".simulations": with a name for each test executed and
-- one extra table for each parameter used in the argument "parameters", with that parameter value in each test.
-- @tabular Strategy
-- Strategy  & Description \
-- "Factorial" & Test all possibilities of the model parameters combinations. 
-- The parameter "quantity" is optional and the default value is 1.\
-- "Repeated" & Test the model with defined parameters quantity times.\
-- "Sample" & This should test the model quantity times, each time with a random combination of the possible parameters.\
-- "Selected" & This should test the model in each of the selected combinations of parameters. 
-- @usage
--		-- Complete Example:
-- 		import("calibration")
-- 		c = MultipleRuns{
-- 			model = MyModel,
-- 			strategy = "sample",
-- 			quantity = 5,
-- 			folderName = "Tests",
-- 			folderPath = currentDir(),
-- 			parameters = {
-- 				x = Choice{-100, -1, 0, 1, 2, 100},
-- 				y = Choice{min = 1, max = 10, step = 1},
-- 				finalTime = 1
-- 		 	},
-- 			output = function(model)
-- 				return model.value
-- 			end,
--			additionalFunction = function(model)
--				return model.value/2
--			end
-- 		}
--		
-- 		-- Factorial Example:
--	
-- 		MultipleRuns{
-- 			model = MyModel,
-- 			strategy = "factorial",
-- 			parameters = {
-- 		    	water = Choice{min = 10, max = 20, step = 1},
-- 		   		rain = Choice{min = 10, max = 20, step = 2},
-- 				finalTime = 1
-- 			},
-- 			quantity = 2
-- 		}
-- 		-- This should run the model 2*66 times to test all the possibilities for the parameters quantity times.
--		
-- 		-- Repeated Example:
--		
-- 		r = MultipleRuns{
-- 		    model = MyModel,
--			strategy = "repeated",
-- 		    parameters = Choice{water = 10, rain = 20, finalTime = 1},
-- 		    quantity = 10,
-- 		}
-- 		-- This should run the model 10 times with the same parameters.
--
--		-- Sample Example:
--
-- 		MultipleRuns{
-- 		    model = MyModel,
--			strategy  = "sample",
-- 		    parameters = {
-- 		        water = Choice{min = 10, max = 20, step = 1},
-- 		        rain = Choice{min = 10, max = 20, step = 2},
--				finalTime = 10,
-- 		    },
-- 		    quantity = 5
-- 		}
-- 		-- This should run the model 5 times selecting random values from the defined parameters
--		-- (if they are choice, otherwise use the only available value).
--
--		-- Selected Example:
--
-- 		x = MultipleRuns{
-- 		    model = MyModel,
--			strategy = "selected",
-- 		    parameters = {
-- 		        scenario1 = {water = 10, rain = 20, finalTime = 10},
-- 		        scenario2 = {water = 5, rain = 10, finalTime = 10}
-- 		    }
-- 		}
-- 		-- This should run the model 2 times with the same parameters defined in the vector of parameters.
-- @arg data A table containing the described values.
-- @arg data.quantity Quantity of repeated runs for repeated, factorial and sample strategy.
-- @arg data.model A model.
-- @arg data.parameters A table with the parameters to be tested; An optional quantity variable.
-- @arg data.output An optional user defined output function.
-- @arg data.folderName Name of the folder where the tests will be saved.
-- @arg data.folderPath Path of the folder where the tests will be saved.
-- @arg data.strategy Strategy to be used when testing the model.
function MultipleRuns(data)
	mandatoryTableArgument(data, "model", "Model")
	mandatoryTableArgument(data, "parameters", "table")
	local resultTable = {simulations = {}} 
	-- addFunctions: Parameter that organizes the additional functions choosen to be executed after the model.
	local addFunctions = {}
	forEachOrderedElement(data, function(idx, att, typ)
		if type(att) == "function" then
			addFunctions[idx] = att 
		else
			local checkingArgument = {}
			checkingArgument[idx] = idx
			verifyUnnecessaryArguments(checkingArgument, {"model", "strategy", "parameters", "quantity", "folderName", "folderPath"})
		end
	end)

	checkParameters(data.model, data)
	local Params = {} 
	-- Organizing the parameters table of multiple runs into a simpler table,
	-- indexed by number with the characteristics of each parameter.
	if data.strategy ~= "repeated" and data.strategy ~= "selected" then
		local mainTable = nil
		forEachOrderedElement(data.parameters, function(idx, attribute, atype)
			if atype ~= "table" then
				parametersOrganizer(mainTable, idx, attribute, atype, Params)
			else
				forEachOrderedElement(attribute, function(idx2, att2, typ2)
					parametersOrganizer(idx, idx2, att2, typ2, Params) 
				end)
			end
		end)
	end

	-- Setting the folder for the tests results to be saved:

	local firstDir  = currentDir()
	local folderDir =  firstDir 

	if data.folderPath ~= nil then
		if not chDir(data.folderPath) then
			chDir(firstDir)
			customError("Invalid folder path")
		end

		folderDir = currentDir()
	end

	local folder = data.folderName
	if folder == nil then
		folder = "MultipleRunsTests"
		mkDir(folder)
	else
		if type(folder) ~= "string" or not mkDir(folder) then
			chDir(firstDir)
			customError("Invalid folder name")
		end
	end

	--set the folder for test results to be saved.
	local s = package.config:sub(1, 1)
	chDir(folderDir..s..folder) 
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
			if data.quantity == nil then
				data.quantity = 1
			end

			local factorialResultTable = {}
			for i = 1, data.quantity do
				if data.quantity > 1 then
					mkDir("factorial_quantity"..i)
					chDir(currentDir()..s.."factorial_quantity"..i)
				end

				factorialResultTable[i] = resultTable 
				factorialResultTable[i] = factorialRecursive(data, Params, 1, variables, factorialResultTable[i], addFunctions, s, i)
			end

			if data.quantity > 1 then
				resultTable = factorialResultTable
			else
				resultTable = factorialResultTable[1]
			end

			factorialResultTable = nil
		end,
		repeated = function()
			local m = data.model(data.parameters)
			for i = 1, data.quantity do
					m:execute() 
					resultTable.simulations[#resultTable.simulations + 1] = ""..(#resultTable.simulations + 1)..""
					local testDir = currentDir()
					mkDir(""..(#resultTable.simulations).."") 
					chDir(testDir..s..""..(#resultTable.simulations).."") 
					testAddFunctions(resultTable, addFunctions, data, m)
					chDir(testDir)
					forEachOrderedElement(data.parameters, function ( idx2, att2, typ2)
						if resultTable[idx2] == nil then
							resultTable[idx2] = {}
						end

						resultTable[idx2][#resultTable[idx2] + 1] = att2
					end)
			end
		end,
		sample = function()
			for i = 1, data.quantity do
				local sampleParams = {}
				local m = randomModel(data.model, data.parameters)
				resultTable.simulations[#resultTable.simulations + 1] = ""..(#resultTable.simulations + 1).."" 
				local testDir = currentDir()
				mkDir(""..(#resultTable.simulations).."") 
				chDir(testDir..s..""..(#resultTable.simulations).."") 
				testAddFunctions(resultTable, addFunctions, data, m)
				chDir(testDir)
				forEachOrderedElement(data.parameters, function(idx2, att2, typ2)
					if typ2 ~= "table" then
						sampleParams[idx2] = m.idx2
					else
						if sampleParams[idx2] == nil then
							sampleParams[idx2] = {}
						end

						forEachOrderedElement(att2, function(idx3, att3, typ3)
							sampleParams[idx2][idx3] = m[idx2].idx3
						end)
					end
				end)
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
				local m = data.model(att)
				m:execute()
				resultTable.simulations[#resultTable.simulations + 1] = ""..(idx).."" 
				local testDir = currentDir()
				mkDir(""..(idx).."") 
				chDir(testDir..s..""..(idx).."") 
				testAddFunctions(resultTable, addFunctions, data, m)
				chDir(testDir) 
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

	chDir(firstDir) 
	return data
end

