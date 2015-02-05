local factorialRecursive
-- function used in execute() to test the model with all the possible combinations of parameters.
-- Params: Table with all the parameters and it's ranges or values indexed by number.
-- In the example: Params[1] = {x, -100, 100, (...)}
-- (It also contains some extra information such as the step increase 
-- or if that parameter varies according to a min/max range.)
-- best: The smallest fitness of the model tested.
-- a: the parameter that the function is currently variating. In the Example: [a] = [1] => x, [a] = [2]=> y.
-- Variables: The value that a parameter is being tested. Example: Variables = {x = -100, y = 1}
factorialRecursive  = function(self, Params, best, a, variables)
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
				

			else  -- else, go to the next parameter to test it with it's range of values.
				best = factorialRecursive(self, Params, best, a+1, variables)
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
				local candidate = self.fit(m)
				if candidate < best.bestCost then
					best.bestCost = candidate
					best.bestVariables = mVariables
				end

			else  -- else, go to the next parameter to test it with each of it possible values.
				best = factorialRecursive(self, Params, best, a + 1, variables)
			end
		end)
	end
	return best
end

--@header Model Calibration functions.
MultipleRuns_ = {
	type_ = "MultipleRuns",
	
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
