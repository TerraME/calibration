local factorialRecursive
-- function used in execute() to test the model with all the possible combinations of parameters.
-- Params: Table with all the parameters and it's ranges or values indexed by number.
-- In the example: Params[1] = {x, -100, 100, (...)}
-- (It also contains some extra information such as the step increase 
-- or if that parameter varies according to a min/max range.)
-- best: The smallest fitness of the model tested.
-- a: the parameter that the function is currently variating. In the Example: [a] = [1] => x, [a] = [2]=> y.
-- Variables: The value that a parameter is being tested. Example: Variables = {x = -100, y = 1}
factorialRecursive  = function(self, Params, a, variables)
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
				print(self.output(m))
			else  -- else, go to the next parameter to test it with it's range of values.
				factorialRecursive(self, Params, a+1, variables)
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
				print(self.output(m))

			else  -- else, go to the next parameter to test it with each of it possible values.
				factorialRecursive(self, Params,a + 1, variables)
			end
		end)
	end
end

--@header Model Calibration functions.
MultipleRuns_ = {

	type_ = "MultipleRuns",
	output = function(self)
		customError("Function 'fit' was not implemented.")
	end,
	execute = function(self)
		local startParams = {} 
			-- A table with the first possible values for the parameters to be tested.
		forEachOrderedElement(self.parameters, function(idx, attribute, atype)
			if self.parameters[idx].min ~= nil then
    			startParams[idx] = self.parameters[idx].min
    		else
    			startParams[idx] = self.parameters[idx][0]
    		end
		end)

		local Params = {} 
		-- The possible values for each parameter is being put in a table indexed by numbers.
		forEachOrderedElement(self.parameters, function (idx, attribute, atype)
			local range = true
			local steps = 1
			if self.parameters[idx].step ~= nil then
				steps = self.parameters[idx].step
			end
			if self.parameters[idx].min == nil or self.parameters[idx].max == nil then
				range = false
			end
			Params[#Params+1] = {id = idx, min = self.parameters[idx].min, 
			max = self.parameters[idx].max, elements = attribute, ranged = range, step = steps}
		end)
		local variables = {}	
		local data = {factorial = "fac", repeated = "rep"}
		switch(data, self.strategy):caseof{
    		fac = function()
    			factorialRecursive(self, Params, 1, variables) 

    		end,
    		rep = function() print("rep") end
		}
	end

	
}

metaTableMultipleRuns_ = {
	__index = MultipleRuns_
}

---Type 
function MultipleRuns(data)
	setmetatable(data, metaTableMultipleRuns_)
	mandatoryTableArgument(data, "model", "function")
	mandatoryTableArgument(data, "parameters", "table")
	mandatoryTableArgument(data, "finalTime", "number")
	return data
end
