-- @example Calibration of a SIR model using a single point. The best fit is reached when the
-- simulation produces the same maximum number of infected in the same time instant.
-- Note that the other parts of the curves are not so good.
-- @image sir-samde-point.bmp

import("sysdyn") -- investigate why SAMDE enters in a loop when we import sysdyn package
import("calibration")

random = Random{seed = 1232}

local fluData = {3, 7, 25, 72, 222, 282, 256, 233, 189, 123, 70, 25, 11, 4}

local fluSimulation = SAMDE{
	model = SIR,
	maxGen = 10,
	hideGraphs = true,
	parameters = {
		contacts = Choice{min = 2, max = 50},
		probability = Choice{min = 0, max = 1},
		duration = Choice{min = 1, max = 20},
		finalTime = 13,
		susceptible = 763,
		infected = 3
	},
	fit = function(model)
		local pos

		forEachOrderedElement(model.finalInfected, function(idx, att)
			if att == model.maxInfected then
				pos = idx
			end
		end)

		return math.abs(282 - model.maxInfected) + math.abs(pos - 6) * 50
	end
}

print("Difference between data and best simulation: "..fluSimulation.fit)
local modelF = fluSimulation.instance

print("Parameters of best simulatoin:")
print("duration:    "..modelF.duration)
print("contacts:    "..modelF.contacts)
print("probability: "..modelF.probability)

-- Repeating best simulation

instance = SIR{
	duration    = modelF.duration,
	contacts    = modelF.contacts,
	probability = modelF.probability,
	susceptible = 763,
	infected    = 3,
	finalTime   = modelF.finalTime
}

instance:run()

data = {data = fluData, infected = instance.finalInfected}

chart = Chart{
	data = data,
	select = {"data", "infected"},
	label = {"Data", "Best simulation"},
	title = "Infected"
}

