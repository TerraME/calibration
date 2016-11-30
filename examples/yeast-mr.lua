-- @example Basic example for testing MultipleRuns using Yeast model.
-- It computes the difference from the simulations output to data given
-- different values of growth rate.
-- @image yeast-mr.bmp

import("sysdyn")
import("calibration")

data = {
	[0] = 9.6,
	[1] = 29.0,
	[2] = 71.1,
	[3] = 174.6,
	[4] = 350.7,
	[5] = 513.3,
	[6] = 594.4,
	[7] = 640.8,
	[8] = 655.9,
	[9] = 661.8
}

mr = MultipleRuns{
	model = Yeast,
	parameters = {rate = Choice{min = 0, max = 3, step = 0.1}},
	rms = function(model)
		local result = 0
		local diff

		forEachElement(model.finalCells, function(pos, cell)
				diff  = cell - data[pos]
				result = result + diff * diff
		end)

		return result
	end
}

chart = Chart{
	data = mr,
	select = "rms",
	xAxis = "rate"
}

