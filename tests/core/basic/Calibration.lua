require("calibration")
return{
Calibration = function(unitTest)

local MyModel = Model{
	x = 1,
	setup = function(self)
		self.t = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4
			end}
		}
	end
}


local c = Calibration{
	model = MyModel,
	finalTime = 1,
	parameters = {x ={ min = -100, max = 100}},
	fit = function(model)
		return model.value
	end
}

local result = c:execute()

unitTest:assert_equal(result, 3)

end, 
fit = function(unitTest)
		unitTest:assert(true)
	end,

execute = function(unitTest)
		unitTest:assert(true)
	end
}

