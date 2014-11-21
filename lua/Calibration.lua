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
		for parameter = self.parameters.min, self.parameters.max do
			if parameter == self.parameters.min then
				best = self.fit(parameter)
			else
				if self.fit(parameter) < best then
					best = self.fit(parameter)
				end
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
	mandatoryArgument(1, "function", data.model)
	mandatoryArgument(2, "table", data.parameters)
	return data
end