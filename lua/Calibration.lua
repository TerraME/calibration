

--@header Model Calibration functions.
Calibration_ = {
	type_ = "Calibration",
	--- Returns the fitness of a model, function must be implemented by the user.
	-- @arg model Model fo calibration.
	-- @usage c:fit(model, parameter)
	fit = function(model)
		customError("Function 'fit' was not implemented.")
	end,
	--- Prints the Calibration results on the console.
	-- @arg results Result of a Calibration type execution.
	-- @usage c = Calibration{
	--     -- ...
	-- }
	--
	-- result = c:execute()
	-- c:printResults(result)
	printResults = function(self, results)
		print("Best Cost: "..results.bestCost)
		forEachOrderedElement(self.parameters, function(idx, att, type)
			print("Best "..idx..": "..results.bestVariables[idx])
		end)
		print("")
	end,
	--- Executes and test the fitness of the model, 
	-- and then returns the table: {bestCost = (Smallest Fitness Value), bestVariables = {x = (bestXValue),...,z = (bestZValue)}}.
	-- If the variable: "parameters" contains a parameter with a table with min and max
	-- it tests the model for each of the values between self.parameters.min and self.parameters.max,
	-- If the variable: "parameters" contains a parameter with a table of multiple values,
	-- it tests the model with all the possible combinations of these values.
	-- @usage c = Calibration{
	--     -- ...
	-- }
	--
	-- result = c:execute()
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

		local m = self.model(startParams) -- test the model with it's first possible values
		m:execute()
		local best = {bestCost = self.fit(m), bestVariables = startParams}
		local variables = {}
		-- If the SAMDE variable is set to true, use the SAMDE genetic algorithm to find the best fitness value
		local samdeValues = {}
		local samdeParam = {}
		local SamdeParamQuant = 0
		forEachOrderedElement(self.parameters, function (idx, attribute, atype)
			table.insert(samdeParam, idx)
			table.insert(samdeValues, {self.parameters[idx].min, self.parameters[idx].max})
			SamdeParamQuant = SamdeParamQuant + 1
		end)
		best = SAMDE(samdeValues, SamdeParamQuant, self.model, samdeParam, self.fit)
		return best -- returns the smallest fitness
	end}

metaTableCalibration_ = {
	__index = Calibration_
}

--- Type to calibrate a model, returns a calibration type with it's functions.
-- @arg data a Table containing: A model constructor, with the model that will be calibrated,
-- and a table with (min, max, step) of the range in which the model will be calibrated 
-- or a table with multiple values to be tested.
-- @usage c = Calibration{
--     model = MyModel,
--     parameters = {x = {min = 1, max = 10, step = 2}},
--     fit = function(model, parameter)
--         -- ...
--     end
-- }
-- 
--c = Calibration{
--     model = MyModel,
--     parameters = {x = {1, 3, 4, 7}},
--     fit = function(model, parameter)
--         -- ...
--     end
-- }
function Calibration(data)
	setmetatable(data, metaTableCalibration_)
	mandatoryTableArgument(data, "model", "Model")
	mandatoryTableArgument(data, "parameters", "table")
	return data
end

