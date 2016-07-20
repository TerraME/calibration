-- @example Daisy world example using multiple Runs factorial strategy.
-- Based on the Model described in Wood, A. J., G. J. Ackland, J. G. Dyke, H. T. P. Williams, and T. M. Lenton (2008), 
-- Daisyworld: A review, Rev. Geophys., 46.
import("sysdyn")
import("calibration")

local m = MultipleRuns{
	model = Daisyworld,
	hideGraphs = true,
	parameters = {
		sunLuminosity = Choice{min = 0.4, max = 1.6, step = 0.01},
	},
	output = {"blackArea", "whiteArea", "emptyArea"}
}

c = Chart{
	data = m,
	select = {"blackArea", "whiteArea", "emptyArea"},
	xAxis = "sunLuminosity"
}

