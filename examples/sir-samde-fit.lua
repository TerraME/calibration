-- @example Infection example using SaMDE, simulates an infection spreading inside a school.
-- @image sir-samde-fit.bmp

import("sysdyn") -- investigate why SAMDE enters in a loop when we import sysdyn package
import("calibration")

--import("sysdyn") -- investigate why SAMDE enters in a loop when we import sysdyn package after calibration

random = Random{seed = 1232}

local fluData = {3, 7, 25, 72, 222, 282, 256, 233, 189, 123, 70, 25, 11, 4}

local fluSimulation = SAMDE{
	model = SIR,
	maxGen = 50,
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
		local dif = 0

		forEachOrderedElement(model.finalInfected, function(idx, att)
			dif = dif + math.abs(att - fluData[idx]) ^ 2
		end)

		return dif
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

data = {data = fluData, infected = instance.finalInfected}

chart = Chart{
	data = data,
	select = {"data", "infected"},
	label = {"Data", "Best simulation"},
	title = "Infected"
}

