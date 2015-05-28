local MyModel = Model{
	x = Choice{-100, -1, 0, 1, 2, 100},
	y = Choice{min = 1, max = 10, step = 1},
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
local MyModel3 = Model{
	parameters3 = {
		x = Choice{-100, -1, 0, 1, 2, 100},
		y = Choice{min = 1, max = 10, step = 1}
	},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.parameters3.x ^2 - 3 * self.parameters3.x + 4 + self.parameters3.y
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
		
		unitTest:assertError(error_func, "Models using repeated strategy cannot use seed or all results will be the same.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "repeated",
			quantity = 3,
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assertError(error_func, "Argument 'parameters' is mandatory.")
		error_func = function()
			local m4 = MultipleRuns{
			strategy = "repeated",
			parameters = {x = 2, y = 5, seed = 1001},
			quantity = 3,
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assertError(error_func,  "Argument 'model' is mandatory.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10}},
			output = function(model)
				return model.value
			end}
		end

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
		
		unitTest:assertError(error_func, "Incompatible types. Argument '#1' expected number, got string.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10, step = 1}},
			output = function(model)
				return model.value
			end}
			m4:saveCSV("nome", 1)
		end
		
		unitTest:assertError(error_func, "Incompatible types. Argument '#2' expected string, got number.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10, step = 1}},
			output = function(model)
				return model.value
			end}
			m4:saveCSV(1, ",")
		end
		
		unitTest:assertError(error_func, "Incompatible types. Argument '#1' expected string, got number.")
		error_func = function()
			local m4 = MultipleRuns{
			model = MyModel2,
			strategy = "factorial",
			parameters = {x = Choice{min = 1, max = 5},  y = Choice{1, 2}},
			output = function(model)
				return model.value
			end}
		end
		
		unitTest:assertError(error_func, "Argument 'x.step' is mandatory.")
	end
}
