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
	end}
local error_func
return{
	MultipleRuns = function(unitTest)
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "repeated",
			parameters = {x = 2, y = 5, seed = 1001},
			quantity = 3,
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assert_error(error_func, "Models using repeated strategy cannot use random seed.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = {min = 2, max = 5}, y = 5},
			output = function(model)
				return model.value
			end}
		end
		unitTest:assert_error(error_func, "Argument 'x.step' is mandatory.")
	end

}
