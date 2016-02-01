import("calibration")
local infection = Model{
	contacts = Mandatory("number"),
	contagion = Choice{min = 0, max = 1},
	infected = Mandatory("number"),
	susceptible = Mandatory("number"),
	recovered = 0, 
	days = Mandatory("number"),
	finalTime = 13,
	counter = 1,
	chart = true,
	finalInfected = {},
	finalSusceptible = {},
	finalRecovered = {},
	init = function(self)
		self.total = self.infected + self.susceptible + self.recovered
		self.alpha = self.contagion * self.contacts / self.total
		self.beta = 1/self.days
		self.finalInfected[self.counter] = self.infected
		self.finalSusceptible[self.counter] = self.susceptible
		self.finalRecovered[self.counter] = self.recovered
		local graph
		if self.chart then
			graph = {inf = self.infected}
			Chart{
				target = graph,
		    	select = {"inf"}
			}
			graph:notify(0)
		end
	
		self.timer = Timer{
			Event{action = function()
				self.susceptible = self.susceptible - self.alpha * self.infected * self.susceptible 
				self.infected = self.infected + self.alpha * self.infected * self.susceptible - self.beta * self.infected
				self.recovered = self.recovered + self.beta * self.infected
				self.counter = self.counter + 1
				self.finalInfected[self.counter] = self.infected
				self.finalSusceptible[self.counter] = self.susceptible
				self.finalRecovered[self.counter] = self.recovered
				if self.chart then
					print(self.infected)
					graph.inf = self.infected
					graph:notify(self.counter)
				end
			end}
	}
	end
}

local fluData = {3, 7, 25, 72, 222, 282, 256, 233, 189, 123, 70, 25, 11, 4}
local fluSimulation = SAMDE{
	model = infection,
	parameters = {
		chart = false,
		contacts = Choice{min = 3, max = 50},
		contagion = Choice{min = 0, max = 1},
		infected = 3, susceptible = 763,
		days = Choice{min = 1, max = 20}
	},
	fit = function(model)
		local dif = 0
		forEachOrderedElement(model.finalInfected, function(idx, att, typ)
			dif = dif + math.pow((att - fluData[idx]), 2)
		end)
		return dif
end}
print(fluSimulation.fit)

model = infection{contacts = 20, contagion = 0.1, infected = 3, susceptible = 1000, days = 4}
model:execute()