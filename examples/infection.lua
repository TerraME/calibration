import("calibration")
local infection = Model{
	contacts = Mandatory("number"),
	contagion = Choice{min = 0, max = 1},
	infected = Mandatory("number"),
	susceptible = Mandatory("number"),
	recovered = 0, 
	days = Mandatory("number"),
	finalTime = 100,
	counter = 0,
	init = function(self)
		self.total = self.infected + self.susceptible + self.recovered
		self.alpha = self.contagion * self.contacts / self.total
		self.beta = 1/self.days
		local results = {inf = self.infected}
		Chart{
		target = results,
		    select = {"inf"}
		}
		results:notify(0)
		self.timer = Timer{
			Event{action = function()
				self.susceptible = self.susceptible - self.alpha * self.infected * self.susceptible 
				self.infected = self.infected + self.alpha * self.infected * self.susceptible - self.beta * self.infected
				self.recovered = self.recovered + self.beta * self.infected
				print(self.infected)
				results.inf = self.infected
				self.counter = self.counter + 1
				results:notify(self.counter)
			end}
	}
	end
}

model = infection{contacts = 20, contagion = 0.1, infected = 3, susceptible = 1000, days = 4}
model:execute()