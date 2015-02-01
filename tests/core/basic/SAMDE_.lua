-- TO DO: Test each of the SAMDE functions
local MyModel
MyModel = Model{
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

local varMatrix = {{1,10},{1,10}}
local dim = 2
local paramList = {"x","y"}
local finalTime = 1
local fit
fit = function(model)
	return model.value
end

return{
	normaliza = function(unitTest)
		unitTest:assert(true)
	end,
	
	calibration = function(unitTest)
		local c2 = Calibration{
		model = MyModel,
		finalTime = 1,
		parameters = {x ={ min = 1, max = 10}, y = { min = 1, max = 10}},
		SAMDE = true,
		fit = function(model)
			return model.value
		end
		}
		
		unitTest:assert_equal(c2:execute(), 4)

	end
	}
