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
local MyModel2 = Model{
	x = Choice{min = 1, max = 10},
	y = Mandatory("Choice"),
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
		
		unitTest:assert_error(error_func, "Models using repeated strategy cannot use seed or all results will be the same.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10}},
			output = function(model)
				return model.value
			end}
		end

		unitTest:assert_error(error_func, "Argument 'y.step' is mandatory.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10, step = 1}},
			test = "test",
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assert_error(error_func, "Argument 'test' is unnecessary.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{min = 2, max = 5, step = 1}, y = Choice{min = 2, max = 5, step = 1}},
			output = function(model)
				return model.value
			end}
		end

		unitTest:assert_error(error_func, "Parameter x should not be a range of values")
			error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1}},
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assert_error(error_func, "Parameter y must have min and max values")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 0, max = 10, step = 1}},
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assert_error(error_func, "Parameter y min is out of the model range.")
			error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 11, step = 1}},
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assert_error(error_func, "Parameter y max is out of the model range.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10, step = 0.5}},
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assert_error(error_func, "Parameter y step is out of the model range.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 0, max = 10, step = 1}},
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assert_error(error_func, "Parameter y min is out of the model range.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1.5, max = 9.5, step = 1}},
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assert_error(error_func, "Parameter y min is out of the model range.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 11, step = 1}},
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assert_error(error_func, "Parameter y max is out of the model range.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10, step = 1}},
			output = function(model)
				return model.value
			end}
			m4:get("a")
			
		end
		
		unitTest:assert_error(error_func, "Incompatible types. Argument '#1' expected number, got string.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10, step = 1}},
			output = function(model)
				return model.value
			end}
			m4:saveCSV(1)
		end
		
		unitTest:assert_error(error_func, "Incompatible types. Argument '#1' expected string, got number.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 99}, y = Choice{min = 1, max = 10, step = 1}},
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assert_error(error_func, "Parameter 99 in #6 is out of the model x range.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel2,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10, step = 1}},
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assert_error(error_func, "Parameter -100 in #1 is smaller than x min value")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{1, 100}},
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assert_error(error_func, "Parameter 100 in #2 is bigger than y max value")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{1, 1.5}},
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assert_error(error_func, "Parameter 1.5 in #2 is out of y range")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{2.5, 3}},
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assert_error(error_func, "Parameter 2.5 in #1 is out of y range")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel2,
			strategy = "factorial",
			parameters = {x = Choice{1,2,3}},
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assert_error(error_func, "Argument 'y' is mandatory.")
			error_func = function()
			local m4 = MultipleRuns{
			model = MyModel2,
			strategy = "factorial",
			parameters = {x = Choice{min = 1, max = 5},  y = Choice{1, 2}},
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assert_error(error_func, "Argument 'x.step' is mandatory.")
	end

}
