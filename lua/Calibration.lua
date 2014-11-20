Calibration_ = {
	type_ = "Calibration",
	execute = function (self)
		for _, parameter  in ipairs(self.parameters) do
			for i = parameter[0], parameter[1] do
				self.model:execute(i)
				if i == -100 then
					min = self.model.value
					best_x = -100 
				else
					if self.model.value< min then
						min = self.model.value
						best_x = i
					end
				end
			end
		end
		return min
	end
}

metaTableCalibration_ = {
	__index = Calibration_,
	__tostring = tostringTerraME
}

function Calibration(data)
	setmetatable(data, metaTableCalibration_)
	return data
end