-- @example An example of a bad calibration. It uses a SIR model and calibrates it with real data using
-- only the difference between the maximum number of infected as error.
-- The calibration is perfect, but the time when the maximum is reached is completely different.
-- The data available shows the maximum in time 6, but the fittest configuration of the model reaches
-- the maximum only in the end of the simulation.
-- @image sir-samde-max-infected.bmp

import("sysdyn") -- investigate why SAMDE enters in a loop when we import sysdyn package
import("calibration")

random = Random{seed = 1232}

local fluData = {3, 7, 25, 72, 222, 282, 256, 233, 189, 123, 70, 25, 11, 4}

local fluSimulation = SAMDE{
	model = SIR,
	maxGen = 10,
	hideGraphs = true,
	parameters = {
		contacts = Choice{min = 2, max = 50, step = 1},
		probability = Choice{min = 0, max = 1},
		duration = Choice{min = 1, max = 20},
		finalTime = 13,
		susceptible = 763,
		infected = 3
	},
	fit = function(model)
		return math.abs(282 - model.maxInfected)
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

--print(vardump(instance.chart:getData())) -- verify this - it seems to be a bug

data = DataFrame{data = fluData, infected = instance.finalInfected}

chart = Chart{
	target = data,
	select = {"data", "infected"},
	label = {"Data", "Best simulation"},
	title = "Infected"
}

