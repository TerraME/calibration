local factorialRecursive
-- function used in execute() to test the model with all the possible combinations of parameters.
-- Params: Table with all the parameters and it's ranges or values indexed by number.
-- In the example: Params[1] = {x, -100, 100, (...)}
-- (It also contains some extra information such as the step increase 
-- or if that parameter varies according to a min/max range.)
-- a: the parameter that the function is currently variating. In the Example: [a] = [1] => x, [a] = [2]=> y.
-- Variables: The value that a parameter is being tested. Example: Variables = {x = -100, y = 1}
-- resultTable Table returned by multipleRuns as result
factorialRecursive  = function(self, Params, a, variables, resultTable)
	if Params[a].ranged == true then -- if the parameter uses a range of values
		for parameter = Params[a].min,  Params[a].max, Params[a].step do	-- Testing the parameter with each value in it's range.
			variables[Params[a].id] = parameter -- giving the variables table the current parameter and value being tested.
			local mVariables = {} -- copy of the variables table to be used in the model.
			forEachOrderedElement(variables, function(idx, attribute, atype)
				mVariables[idx] = attribute
			end)

			if a == #Params then -- if all parameters have already been given a value to be tested.
				local m = self.model(mVariables) --testing the model with it's current parameter values.
				m:execute(self.finalTime)
				resultTable.simulations[#resultTable.simulations + 1] = ""..#resultTable.simulations + 1..""
				forEachOrderedElement(variables, function ( idx2, att2, typ2)
					resultTable[idx2][#resultTable[idx2]+1] = att2
				end)
			else  -- else, go to the next parameter to test it with it's range of values.
				resultTable = factorialRecursive(self, Params, a+1, variables, resultTable)
			end
		end

	else -- if the parameter uses a table of multiple values
		forEachOrderedElement(Params[a].elements, function (idx, attribute, atype) 
			-- Testing the parameter with each value in it's table.
			variables[Params[a].id] = attribute
			local mVariables = {} -- copy of the variables table to be used in the model.
			forEachOrderedElement(variables, function(idx2, attribute2, atype2)
				mVariables[idx2] = attribute2
			end)

			if a == #Params then -- if all parameters have already been given a value to be tested.
				local m = self.model(mVariables) --testing the model with it's current parameter values.
				m:execute(self.finalTime)
				resultTable.simulations[#resultTable.simulations + 1] = ""..#resultTable.simulations + 1..""
				forEachOrderedElement(variables, function ( idx2, att2, typ2)
					resultTable[idx2][#resultTable[idx2]+1] = att2
				end)
			else  -- else, go to the next parameter to test it with each of it possible values.
				resultTable = factorialRecursive(self, Params,a + 1, variables, resultTable)
			end
		end)
	end
	return resultTable
end

--@header Model Calibration functions.
MultipleRuns_ = {

	type_ = "MultipleRuns",
	get = function(self, result, number)
		local getTable = {}
		forEachOrderedElement(result, function(idx, att, type)
			getTable[idx] = result[idx][number]
		end)
		return getTable
	end,

	--- Executes and test the model depending on the choosen strategy, 
	-- MultipleRuns returns an object with type MultipleRuns and a set of tables:
	-- simulations: the name of the simulations executed. It should be "simulation_*", depending on the strategy used.
	-- For repeat and sample, * should be 1, 2, ..., quantity. For selected, * should be the idx of the element in the table of tables. 
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

	-- @usage  c = MultipleRuns{
	-- 		...
	--	}
	--
	-- result = c:execute()
	execute = function(self)
		local resultTable = {simulations = {}} 
		local Params = {} 
		if self.strategy ~= "repeated" then
			-- The possible values for each parameter is being put in a table indexed by numbers.
			-- example:
			-- Params = {{id = "x", min =  1, max = 10, elements = nil, ranged = true, step = 2},
			-- {id = "y", min = nil, max = nil, elements = {1, 3, 5}, ranged = false, steps = 1}}

			forEachOrderedElement(self.parameters, function (idx, attribute, atype)
				local range = true
				local steps = 1
				local parameterElements
				if self.parameters[idx].step ~= nil then
					steps = self.parameters[idx].step
				end
				if self.parameters[idx].min == nil or self.parameters[idx].max == nil then
					range = false
					parameterElements = attribute
				end
				Params[#Params+1] = {id = idx, min = self.parameters[idx].min, 
				max = self.parameters[idx].max, elements = parameterElements, ranged = range, step = steps}
			end)
		end

		local variables = {}	
		local data = {factorial = "fac", repeated = "rep", sample = "samp", selected = "sec"}
		switch(data, self.strategy):caseof{
    		fac = function()
    			forEachOrderedElement(self.parameters, function(idx, attribute, atype)
    				resultTable[idx] = {}
				end)
    			resultTable = factorialRecursive(self, Params, 1, variables, resultTable)
    		end,

    		rep = function()
    			local m = self.model(self.parameters)
    			for i = 1, self.quantity do
    					m:execute(self.finalTime)
    					resultTable.simulations[#resultTable.simulations + 1] = ""..#resultTable.simulations + 1..""
						forEachOrderedElement(self.parameters, function ( idx2, att2, typ2)
							if resultTable[idx2] == nil then
								resultTable[idx2] = {}
							end
							resultTable[idx2][#resultTable[idx2]+1] = att2
						end)
				end
    		end,

    		samp = function()
    			math.randomseed(os.time())
    			for i=1, self.quantity do
    				local sampleParams = {}
    				local sampleValue
    				forEachOrderedElement(Params, function(idx2, att2, typ2)
    					if att2[ranged] == true then
    						sampleValue = math.random(att2[min], att2[max])
    						sampleParams[att2[id]] = sampleValue
    					else
    						sampleValue = att2[elements][math.random(1, #att2[elements])]
    						sampleParams[att2[id]] =  sampleValue
    					end
    				end)

    				local m = self.model(sampleParams)
    				m:execute(self.finalTime)
    				resultTable.simulations[#resultTable.simulations + 1] = ""..#resultTable.simulations + 1..""
					forEachOrderedElement(sampleParams, function ( idx2, att2, typ2)
						if resultTable[idx2] == nil then
							resultTable[idx2] = {}
						end
						
						resultTable[idx2][#resultTable[idx2]+1] = att2
					end)
    			end
    		end,

    		sec = function()
    			forEachOrderedElement(self.parameters, function (idx, att, atype)
    				local m = self.model(self.parameters[idx])
    				m:execute(self.finalTime)
    				resultTable.simulations[#resultTable.simulations + 1] = ""..#resultTable.simulations + 1..""
					forEachOrderedElement(self.parameters[idx], function ( idx2, att2, typ2)
						if resultTable[idx2] == nil then
							resultTable[idx2] = {}
						end
						resultTable[idx2][#resultTable[idx2]+1] = att2
					end)
    			end)
    		end
		}
		return resultTable
	end}

metaTableMultipleRuns_ = {
	__index = MultipleRuns_
}

---Type 
function MultipleRuns(data)
	setmetatable(data, metaTableMultipleRuns_)
	mandatoryTableArgument(data, "model", "function")
	mandatoryTableArgument(data, "parameters", "table")
	return data
end
