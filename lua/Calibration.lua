local rangeRecursive 
-- function used in execute to test the model with all the possible combinations of parameters.
-- Params: Table with all the parameters and it's ranges indexed by number. In the example: Params[1] = {x, -100, 100}
-- best: The smallest fitness of the model tested.
-- a: the parameter that the function is currently variating. In the Example: 1 => x, 2=> y.
-- Variables: The value that a parameter is being tested. Example: Variables = {x = -100, y = 1}
rangeRecursive = function(self, Params, best, a, variables)
		for parameter = Params[a]["min"],  Params[a]["max"] do	-- Testing the parameter in it's range.
			variables[Params[a]["id"]] = parameter -- giving the variables table the current parameter and value being tested.
			local mVariables = {} -- copy of the variables table to be used in the model.
			forEachOrderedElement(variables, function(idx, attribute, atype)
				mVariables[idx] = attribute
			end)

			if a == #Params then -- if all parameters have already been given a value to be tested.
				local m = self.model(mVariables) --testing the model with it's current parameter values.
				m:execute(self.finalTime)
				local candidate = self.fit(m)
				if candidate < best then
					best = candidate
				end

			else  -- else, go to the next parameter to test it with it's range of values.
				best = rangeRecursive(self, Params, best, a+1, variables)
			end
		end

		return best
end

local elementsRecursive 
elementsRecursive = function(self, Params, best, a, variables)
	forEachOrderedElement(Params[a]["elements"], function (idx, attribute, atype)
		variables[Params[a]["id"]] = attribute
		local mVariables = {} -- copy of the variables table to be used in the model.
		forEachOrderedElement(variables, function(idx2, attribute2, atype2)
			mVariables[idx2] = attribute2
		end)

		if a == #Params then
			local m = self.model(mVariables) --testing the model with it's current parameter values.
				m:execute(self.finalTime)
				local candidate = self.fit(m)
				if candidate < best then
					best = candidate
				end

			else  -- else, go to the next parameter to test it with it's range of values.
				best = elementsRecursive(self, Params, best, a+1, variables)
		end
	end)
	return best
end
--@header Model Calibration functions.

Calibration_ = {
	type_ = "Calibration",
	--- Returns the fitness of a model, fucntion must be implemented by the user
	-- @arg model Model fo calibration
	-- @arg parameter A Table with the parameters of the model.
	-- @usage c:fit(model, parameter)
	fit = function(model, parameter)
		customError("Function 'fit' was not implemented.")
	end,
	--- Executes and test the fitness of the model
	-- for each of the values between self.parameters.min and self.parameters.max,
	-- and then returns the parameter which generated the smaller fitness value.
	-- @usage c:execute()
	execute = function(self)
		local rangedParameters = true
		forEachOrderedElement(self.parameters, function (idx, attribute, atype)
			if self.parameters[idx]["max"] == nil or self.parameters[idx]["min"]  == nil then
				rangedParameters = false
			end
		end)

		if rangedParameters == true then
			local startParams = {}
			forEachOrderedElement(self.parameters, function(idx, attribute, atype)
    			startParams[idx] = self.parameters[idx]["min"]
			end)

			local Params = {}
			forEachOrderedElement(self.parameters, function (idx, attribute, atype)
				Params[#Params+1] = {id = idx, min = self.parameters[idx]["min"], max = self.parameters[idx]["max"] }
			end)

			local m = self.model(startParams)
			m:execute(self.finalTime)
			local best = self.fit(m)
			local variables = {}
			best = rangeRecursive(self, Params, best, 1, variables)
			return best
		else
			local startParams = {}
			forEachOrderedElement(self.parameters, function(idx, attribute, atype)
    			startParams[idx] = self.parameters[idx][1]
			end)

			local Params = {}
			forEachOrderedElement(self.parameters, function (idx, attribute, atype)
				Params[#Params+1] = {id = idx, elements = attribute}
			end)

			local m = self.model(startParams)
			m:execute(self.finalTime)
			local best = self.fit(m)
			local variables = {}
			best = elementsRecursive(self, Params, best, 1, variables)
			
			return best
			
		end
	end
}

metaTableCalibration_ = {
	__index = Calibration_
}

---Type to calibrate a model. It tests all the possibilities of parameters combinations
-- and returns the smallest fitness value possible of the model according to the user defined fit function.
-- @arg data a Table containing: A model constructor, with the model that will be calibrated,
-- and a table with the range of values in which the model will be calibrated.
-- @usage Calibration{
--     model = MyModel,
--     parameters = {min = 1, max = 10},
--     fit = function(model, parameter)
--     		...	
--     end
-- }
--
function Calibration(data)
	setmetatable(data, metaTableCalibration_)
	mandatoryTableArgument(data, "model", "function")
	mandatoryTableArgument(data, "parameters", "table")
	mandatoryTableArgument(data, "finalTime", "number")
	return data
end
