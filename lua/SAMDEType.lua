SAMDE_ = {
	type_ = "SAMDE",
	--- Returns the fitness of a model, function must be implemented by the user.
	-- @arg model Model fo calibration.
	-- @usage c:fit(model, parameter)
	fit = function(model)
		customError("Function 'fit' was not implemented.")
	end,
	--- Executes and test the fitness of the model, 
	-- and then returns the table: {fit = (Smallest Fitness Value), bestVariables = {x = (bestXValue),...,z = (bestZValue)}}.
	-- If the variable: "parameters" contains a parameter with a table with min and max
	-- it tests the model for each of the values between self.parameters.min and self.parameters.max,
	-- If the variable: "parameters" contains a parameter with a table of multiple values,
	-- it tests the model with all the possible combinations of these values.
	-- @usage  c = SAMDE{
	-- 		...
	--	}
	--
	-- result = c:execute()
	execute = function(self)
			local startParams = {} 
			-- A table with the first possible values for the parameters to be tested.
			forEachOrderedElement(self.parameters, function(idx, attribute, atype)
				if attribute.min ~= nil then
    				startParams[idx] = attribute.min
    			else
    				startParams[idx] = attribute[1]
    			end
			end)
			local m = self.model(startParams) -- test the model with it's first possible values
			m:execute()
			local best = {fit = self.fit(m), instance = m, generations = 1}
			local variables = {}
			local samdeValues = {}
			local samdeParam = {}
			local SamdeParamQuant = 0
			forEachOrderedElement(self.parameters, function (idx, attribute, atype)
				table.insert(samdeParam, idx)
				if attribute.min and attribute.max ~=nil then
					table.insert(samdeValues, {attribute.min, attribute.max})
				else
					local bigger = attribute[1]
					local smaller = attribute[1]
					forEachOrderedElement(attribute, function(idx2, att2, atyp2)
						if att2 > bigger then
							bigger = att2
						elseif att2 < smaller then
							smaller = att2
						end
					end)
					table.insert(samdeValues, {smaller, bigger})
				end

				SamdeParamQuant = SamdeParamQuant + 1
			end)
			best = SAMDECalibrate(samdeValues, SamdeParamQuant, self.model, samdeParam, self.fit)
			return best -- returns the smallest fitness
	end}

metaTableSAMDE_ = {
	__index = SAMDE_
}

---Type to calibrate a model, returns a SAMDE type with the fittest individual,
-- the fit value and the number of generations.
-- @arg data a Table containing: A model constructor, with the model that will be calibrated,
-- and a table with (min, max, step) of the range in which the model will be calibrated 
-- or a table with multiple values to be tested.
-- @usage c = SAMDE{
--     model = MyModel,
--     parameters = {x = {min = 1, max = 10, step = 2}},
--     fit = function(model, parameter)
--     		...	
--     end
-- }
-- 
--c = SAMDE{
--     model = MyModel,
--     parameters = { x = {1, 3, 4, 7}},
--     fit = function(model, parameter)
--     		...	
--     end
-- }
function SAMDE(data)
	setmetatable(data, metaTableSAMDE_)
	mandatoryTableArgument(data, "model", "Model")
	mandatoryTableArgument(data, "parameters", "table")
	return data
end

