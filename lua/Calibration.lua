Calibration_ = {
	type_ = "Calibration",
	fit = function(self)
		customError("Function 'fit' was not implemented.")
	end,
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

function Calibration(data)
	setmetatable(data, metaTableCalibration_)
	mandatoryArgument(1, "table", data.parameters)
	return data
end