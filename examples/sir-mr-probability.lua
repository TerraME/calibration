-- @example Investigating the probability of infection in a Susceptible-Infected-Recovered (SIR) model.
-- The example shows how susceptibles and the maximum number of infected varies according to the
-- probability of infection.
-- @image sir-probability.bmp

import("calibration")
import("sysdyn")

runs = MultipleRuns{
	model = SIR,
	parameters = {
		probability = Choice{min = 0.05, max = 0.3, step = 0.001}
	},
	--output = {"infected", "probability"} -- error!
	output = {"susceptible", "maxInfected"}
}

chart = Chart{
	data = runs,
	select = {"susceptible", "maxInfected"},
	color = {"blue", "red"},
	xAxis = "probability"
}

