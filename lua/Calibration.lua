Calibration_ = {
	type_ = "Calibration",
	--- Returns the fitness of a model, fucntion must be implemented by the user
	-- @param model Model fo calibration
	-- @param parameter A Table with the parameters of the model.
	-- @usage c:fit(model, parameter)
	fit = function(model, parameter)
		customError("Function 'fit' was not implemented.")
	end,
	--- Executes and test the fitness of the model
	-- for each of the values between self.parameters.min and self.parameters.max,
	-- and then returns the parameter which generated the smaller fitness value.
	-- @usage c:execute()
	execute = function(self)
		startParams = {}
		forEachOrderedElement(self.parameters, function(idx, attribute, atype)
    		startParams[idx] = self.parameters[idx]["min"]
		end)
		local m = self.model(startParams)
		m:execute(self.finalTime)
		local best = self.fit(m)
		for parameter = self.parameters.x.min, self.parameters.x.max do
			m = self.model{x = parameter}
			m:execute(self.finalTime)
			local candidate = self.fit(m)

			if candidate < best then
				best = candidate
			end
		end
		return best
	end
}

metaTableCalibration_ = {
	__index = Calibration_
}
 
-- @param model A model constructor, containing the model that will be calibrated.
-- @param parameters A table with the range of values in which the model will be calibrated.
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
