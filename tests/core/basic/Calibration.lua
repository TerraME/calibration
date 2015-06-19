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
local c2 = Calibration{
	model = MyModelSamde,
	parameters = {x = {min = 1, max = 10}, y = { min = 1, max = 10}},
	fit = function(model)
		return model.value
end}

local result2 = c2:execute()
return{

Calibration = function(unitTest)
unitTest:assertEquals(result2.bestCost, 4)
unitTest:assertEquals(result2.bestModel.x, 1)
unitTest:assertEquals(result2.bestModel.y, 1)
end,

fit = function(unitTest)
		unitTest:assert(true)
end,
printResults = function(unitTest)
	unitTest:assertEquals(result2.bestCost, 4)
	unitTest:assertEquals(result2.bestModel.x, 1)
	unitTest:assertEquals(result2.bestModel.y, 1)
end,
execute = function(unitTest)
		unitTest:assert(true)
end}
