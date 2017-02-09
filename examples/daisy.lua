-- @example Daisyworld example using multiple Runs factorial strategy.
-- It simulates Daisyworld using different sun luminosities to investigate
-- the final distribution of black, white, and empty areas.
-- Based on the Model described in Wood, A. J., G. J. Ackland, J. G. Dyke, H. T. P. Williams, and T. M. Lenton (2008),
-- Daisyworld: A review, Rev. Geophys., 46.
-- @image daisy.bmp

import("sysdyn")
import("calibration")

local m = MultipleRuns{
	model = Daisyworld,
	parameters = {
		sunLuminosity = Choice{min = 0.4, max = 1.6, step = 0.01},
	},
	output = {"blackArea", "whiteArea", "emptyArea"}
}

chart = Chart{
	data = m,
	select = {"blackArea", "whiteArea", "emptyArea"},
	xAxis = "sunLuminosity"
}

