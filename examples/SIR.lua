-- @example Multiple simulations of a Susceptible-Infected-Recovered (SIR) model with a public campaign.
-- The campaign asks the population to stop leaving home, which reduces the number of
-- contacts by half. The example shows the outcomes given different thresholds to start the campaign.

import("calibration")
import("sysdyn")

runs = MultipleRuns{
	model = SIR,
	parameters = {
		maximum = Choice{min = 100, max = 4000, step = 10}
	},
	output = {"maxInfected", "susceptible"}
}

Chart{
	data = runs,
	select = {"maxInfected", "susceptible"},
	xAxis = "maximum"
}

