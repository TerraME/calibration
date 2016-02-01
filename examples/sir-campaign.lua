-- @example A Susceptible-Infected-Recovered (SIR) model with a public campaign. The
-- campaign asks the population to stop leaving home, which reduces the number of
-- contacts by half. It is activated whenever there are more than 1000
-- infected individuous in the population.
-- @image sir-campaign.bmp

SIR = Model{
	contacts = 6,
	infections = 0.25,
	duration = 2,
	policy = 1000,
	finalTime = 30,
	susceptible = 9998,
	infected = 2,
	recovered = 0,
	init = function(model)

		Chart{
			target = model,
			select = {"susceptible", "infected", "recovered"}
		}

		model.maxInfected = model.infected
		model:notify()

		model.timer = Timer{
			Event{action = function()
				model.recovered = model.recovered + model.infected / model.duration
		
				local new_infected

				if model.infected >= model.policy then
					new_infected = model.infected * (model.contacts / 2) * model.infections * model.susceptible / 10000
				else
					new_infected = model.infected * model.contacts * model.infections * model.susceptible / 10000
				end

				if new_infected > model.susceptible then
					new_infected = model.susceptible
				end
				model.infected = model.infected - model.infected / model.duration + new_infected
				model.susceptible = 10000 - model.infected - model.recovered
				model:notify()

				if model.maxInfected < model.infected then
					model.maxInfected = model.infected
				end
			end}
		}
	end
}

import("calibration")
mChart = Chart
Chart = function() end

local m = MultipleRuns{
	model = SIR,
	strategy = "factorial", -- #ADDISSUE# 
							-- IF WE CHANGE THIS TO SELECTED IT DOESNT WORK
							-- It should stop with an error
	parameters = {
		policy = Choice{min = 100, max = 4000, step = 10},
	},
	max = function(model)
		return model.maxInfected
	end,
	susceptible = function(model)
		return model.susceptible
	end

}

-- ... here
Chart = mChart

-- the code below could be encapsulated into a TerraME function
-- think about that.

cell = Cell{
	max = m.max[1],
	susceptible = m.susceptible[1],
	policy = m.policy[1]
}

c = Chart{
	target = cell,
	xAxis = "policy",
}

cell:notify()

for i = 2, #m.max do
	cell.max = m.max[i]
	cell.susceptible = m.susceptible[i]
	cell.policy = m.policy[i]

	cell:notify()
end

