local MyModel = Model{
	x = Choice{-100, -1, 0, 1, 2, 100},
	y = Choice{ min = 1, max = 10, step = 1},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
	end
}
local error_func
return{
	randomModel = function(unitTest)
		error_func = function()
			randomModel("test", {x = Choice{1,2,3}, y = Choice{3,4,5}})
		end

		unitTest:assertError(error_func,  "Incompatible types. Argument '#1' expected Model, got string.")
		error_func = function()
			randomModel(MyModel, "test")
		end
		unitTest:assertError(error_func, "Incompatible types. Argument '#1' expected table, got string.")
	end
}
