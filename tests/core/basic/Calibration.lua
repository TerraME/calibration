require("calibration")
return{
Calibration = function(unitTest)

local MyModel = Model{
	x = 1,
	y = 0,
	setup = function(self)
		self.t = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
	end
}

local c = Calibration{
	model = MyModel,
	finalTime = 1,
	parameters = {x ={ -100, -1, 0, 1, 2, 100}, y = { min = 1, max = 10}},
	fit = function(model)
		return model.value
	end
}

local result = c:execute()

unitTest:assert_equal(result, 4)

end, 
fit = function(unitTest)
		unitTest:assert(true)
end,

execute = function(unitTest)
		unitTest:assert(true)
end
}

