local MyModel = Model{
	x = Choice{-100, -1, 0, 1, 2, 100},
	y = Choice{ min = 1, max = 10},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
	end}

local c = Calibration{
	model = MyModel,
	parameters = {x ={-100, -1, 0, 1, 2, 100}, y = { min = 1, max = 10}},
	fit = function(model)
		return model.value
	end}

local MyModelSamde = Model{
	x = Choice{ min = 1, max = 10},
	y = Choice{ min = 1, max = 10},
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
	parameters = {x ={ min = 1, max = 10}, y = { min = 1, max = 10}},
	SAMDE = true,
	fit = function(model)
		return model.value
	end}

local result = c:execute()
local result2 = c2:execute()
return{
Calibration = function(unitTest)
unitTest:assertEquals(result.bestCost, 4)
unitTest:assertEquals(result.bestVariables.x, 1)
unitTest:assertEquals(result.bestVariables.y, 1)
unitTest:assertEquals(result2.bestCost, 4)
unitTest:assertEquals(result2.bestVariables.x, 1)
unitTest:assertEquals(result2.bestVariables.y, 1)
end, 

fit = function(unitTest)
		unitTest:assert(true)
end,

printResults = function(unitTest)
	unitTest:assertEquals(result.bestCost, 4)
	unitTest:assertEquals(result.bestVariables.x, 1)
	unitTest:assertEquals(result.bestVariables.y, 1)
end,

execute = function(unitTest)
		unitTest:assert(true)
end}
