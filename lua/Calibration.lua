local recursiva = function(self, startParams, Params, best, a, variables)
	print("a:"..a)
	for c = a, #Params do
		print("test")
		for parameter = Params[a]["min"],  Params[a]["max"] do
			variables[Params[a]["id"]] = parameter
			if c == #Params then
				local m = self.model(variables)
				execute(self.finalTime)
				local candidate = self.fit(m)
				if candidate < best then
					best = candidate
				end

				return best
			else 
					best = recursiva(self , startParams, Params, best, a+1, variables)
			end
		end

		return best
	end
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
		local startParams = {}
		forEachOrderedElement(self.parameters, function(idx, attribute, atype)
    		startParams[idx] = self.parameters[idx]["min"]
		end)
		print(startParams["x"])
		local Params = {}
		forEachOrderedElement(self.parameters, function (idx, attribute, atype)
			Params[#Params+1] = {id = idx, min = self.parameters[idx]["min"], max = self.parameters[idx]["max"] }
		end)
		print("#1:"..#Params)
		local m = self.model(startParams)
		m:execute(self.finalTime)
		local best = self.fit(m)
		local variables = {}
		best = recursiva(self, startParams, Params, best, 1, variables)
		return best
	end
}

metaTableCalibration_ = {
	__index = Calibration_
}
 
-- @arg model A model constructor, containing the model that will be calibrated.
-- @arg parameters A table with the range of values in which the model will be calibrated.
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
