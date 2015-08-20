local myModelSamde = Model{
	x = Choice{min = 1, max = 10},
	y = Choice{min = 1, max = 10},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
end}

local discreteSamde = Model{
	x = Choice{min = 1, max = 10},
	y = Choice{min = 1, max = 10},
	z = Choice{"high", "low"},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				if self.z == "high" then
					self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
				elseif self.z == "low" then
					self.value = 2 * self.x ^2 - 3 * self.x + 4 - self.y
				end
			end}
		}
end}

local c1 = SAMDE{
	model = myModelSamde,
	parameters = {x = Choice{min = 1, max = 10, step = 1}, y = Choice{min = 1, max = 10, step = 0.3}},
	size = 30,
	maxGen = 100,
	maximize = true,
	threshold = 200,
	fit = function(model)
		return model.value
end}

local c2 = SAMDE{
	model = myModelSamde,
	parameters = {x = Choice{min = 1, max = 10}, y = Choice{min = 1, max = 10}},
	size = 30,
	maxGen = 100,
	threshold = 1,
	fit = function(model)
		return model.value
end}

local c3 = SAMDE{
	model = myModelSamde,
	parameters = {x = Choice{min = 1, max = 10}, y = Choice{min = 1, max = 10}},
	size = 30,
	maxGen = 100,
	threshold = 100,
	maximize = true,
	fit = function(model)
		return model.value
end}

local c4 = SAMDE{
	model = myModelSamde,
	parameters = {x = Choice{min = 1, max = 10, step = 1}, y = Choice{min = 1, max = 10, step = 0.3}},
	fit = function(model)
		return model.value
end}

local c5 = SAMDE{
	model = myModelSamde,
	parameters = {x = Choice{min = 1, max = 10, step = 1}, y = Choice{min = 1, max = 10, step = 0.3}},
	size = 30,
	maxGen = 100,
	threshold = 1,
	fit = function(model)
		return model.value
end}

local c5 = SAMDE{
	model = myModelSamde,
	parameters = {x = Choice{min = 1, max = 10, step = 1}, y = Choice{2,3,4,9}},
	size = 30,
	maxGen = 100,
	threshold = 1,
	fit = function(model)
		return model.value
end}

local c6 = SAMDE{
	model = myModelSamde,
	parameters = {x = Choice{1,3,5,6}, y = Choice{2,3,4,9}},
	maximize = true,
	fit = function(model)
		return model.value
end}

local c7 = SAMDE{
	model = discreteSamde,
	parameters = {x = Choice{1,3,5,6}, y = Choice{2,3,4,9}, z = Choice{"high", "low"}},
	threshold = -6,
	maxGen = 100,
	fit = function(model)
		return model.value
end}

local c8 = SAMDE{
	model = discreteSamde,
	parameters = {x = Choice{1,3,5,6}, y = Choice{2,3,4,9}, z = Choice{"high", "low"}},
	maxGen = 100,
	threshold = 67,
	maximize = true,
	fit = function(model)
		return model.value
end}

return{
	SAMDE = function(unitTest)
	unitTest:assertEquals(c1.fit, 184)
	unitTest:assertEquals(c1.instance.x, 10)
	unitTest:assertEquals(c1.instance.y, 10)
	unitTest:assertEquals(c2.fit, 4)
	unitTest:assertEquals(c2.instance.x, 1)
	unitTest:assertEquals(c2.instance.y, 1)
	--The maximun value possible is 184, but since the threshold is 100,
	--the SaMDE function will stop as soon as it gets a value higher than 100.
	unitTest:assertEquals(c3.fit, 142, 42)
	unitTest:assertEquals(c3.instance.x, 6, 4)
	unitTest:assertEquals(c3.instance.y, 6, 4)
	unitTest:assertEquals(c4.fit, 4)
	unitTest:assertEquals(c4.instance.x, 1)
	unitTest:assertEquals(c4.instance.y, 1)
	unitTest:assertEquals(c4.fit, 4)
	unitTest:assertEquals(c4.instance.x, 1)
	unitTest:assertEquals(c4.instance.y, 1)
	unitTest:assertEquals(c5.fit, 5)
	unitTest:assertEquals(c5.instance.x, 1)
	unitTest:assertEquals(c5.instance.y, 2)
	unitTest:assertEquals(c6.fit, 67)
	unitTest:assertEquals(c6.instance.x, 6)
	unitTest:assertEquals(c6.instance.y, 9)
	unitTest:assertEquals(c7.fit, -6)
	unitTest:assertEquals(c7.instance.x, 1)
	unitTest:assertEquals(c7.instance.y, 9)
	unitTest:assertEquals(c7.instance.z, "low")
	unitTest:assertEquals(c8.fit, 67)
	unitTest:assertEquals(c8.instance.x, 6)
	unitTest:assertEquals(c8.instance.y, 9)
	unitTest:assertEquals(c8.instance.z, "high")
end}
