require("calibration")
return{
Calibration = function(unitTest)

local MyModel = Model{
	x = choice{-100, -1, 0, 1, 2, 100},
	y = choice{ min = 1, max = 10},
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
	end
}

local c = Calibration{
	model = MyModel,
	finalTime = 1,
	parameters = {x ={-100, -1, 0, 1, 2, 100}, y = { min = 1, max = 10}},
	fit = function(model)
		return model.value
	end
}

local MyModelSamde = Model{
	x = choice{ min = 1, max = 10},
	y = choice{ min = 1, max = 10},
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
	end
}

local c2 = Calibration{
	model = MyModelSamde,
	finalTime = 1,
	parameters = {x ={ min = 1, max = 10}, y = { min = 1, max = 10}},
	SAMDE = true,
	fit = function(model)
		return model.value
	end
}

local result = c:execute()
local result2 = c2:execute()
unitTest:assert_equal(result["bestCost"], 4)
unitTest:assert_equal(result["bestVariables"]["x"], 1)
unitTest:assert_equal(result["bestVariables"]["y"], 1)
unitTest:assert_equal(result2["bestCost"], 4)
unitTest:assert_equal(result2["bestVariables"]["x"], 1)
unitTest:assert_equal(result2["bestVariables"]["y"], 1)
end, 

fit = function(unitTest)
		unitTest:assert(true)
end,

printResults = function(unitTest)
	unitTest:assert(true)
end,

execute = function(unitTest)
		unitTest:assert(true)
end
}
