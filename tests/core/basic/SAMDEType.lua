local MyModelSamde = Model{
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
local c2 = SAMDE{
	model = MyModelSamde,
	parameters = {x = Choice{min = 1, max = 10}, y = Choice{min = 1, max = 10}},
	size = 30,
	maxGen = 100,
	threshold = 1,
	fit = function(model)
		return model.value
end}
local c3 = SAMDE{
	model = MyModelSamde,
	parameters = {x = Choice{min = 1, max = 10}, y = Choice{min = 1, max = 10}},
	size = 30,
	maxGen = 100,
	threshold = 100,
	maximize = true,
	fit = function(model)
		return model.value
end}
local c4 = SAMDE{
	model = MyModelSamde,
	parameters = {x = Choice{min = 1, max = 10, step = 1}, y = Choice{min = 1, max = 10, step = 0.3}},
	size = 30,
	maxGen = 100,
	threshold = 1,
	fit = function(model)
		return model.value
end}
return{
SAMDE = function(unitTest)
unitTest:assertEquals(c2.fit, 4)
unitTest:assertEquals(c2.instance.x, 1)
unitTest:assertEquals(c2.instance.y, 1)
--The maximun value possible is 184, but ssince the threshold is 100,
--the SaMDE function will stop as soon as it gets a value higher than 100.
unitTest:assertEquals(c3.fit, 142, 42)
unitTest:assertEquals(c3.instance.x, 6, 4)
unitTest:assertEquals(c3.instance.y, 6, 4)
unitTest:assertEquals(c4.fit, 4)
unitTest:assertEquals(c4.instance.x, 1)
unitTest:assertEquals(c4.instance.y, 1)
end}
