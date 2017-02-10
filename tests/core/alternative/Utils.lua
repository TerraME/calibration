
-- Creating Models
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

local error_func
return{
	randomModel = function(unitTest)
		error_func = function()
			randomModel("test", {x = Choice{1, 2, 3}, y = Choice{3, 4, 5}})
		end

		unitTest:assertError(error_func,  "Incompatible types. Argument '#1' expected Model, got string.")
		error_func = function()
			randomModel(MyModel, "test")
		end

		unitTest:assertError(error_func, "Incompatible types. Argument '#1' expected table, got string.")
	end,
	checkParametersSet = function(unitTest)
		error_func = function()
			local parameters = {x = Choice{-100, 1, 3}}
			checkParametersSet(MyModel, "x", parameters.x)
		end
		unitTest:assertError(error_func, "Parameter 3 in #3 is out of the model x range.")
	end,
	checkParametersRange = function(unitTest)
		error_func = function()
			local parameters = {y = Choice{min = 2, max = 11, step =1}}
			checkParametersRange(MyModel, "y", parameters.y)
		end

		unitTest:assertError(error_func, "Parameter y max is out of the model range.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				parameters = {x = Choice{min=1, max=10, step=1}, y = 5},
				repetition = 3,
				output = {"value"}
			}
		end

		unitTest:assertError(error_func, "Parameter x should not be a range of values")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				parameters = {x = 1, y = Choice{min = 5, step = 1}},
				repetition = 3,
				output = {"value"}
			}
		end

		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{min = 2, max = 5, step = 1}, y = Choice{min = 2, max = 5, step = 1}},
				output = {"value"}
			}
		end

		unitTest:assertError(error_func, "Parameter x should not be a range of values")
			error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1}},
				output = {"value"}
			}
		end

		unitTest:assertError(error_func, "Parameter y must have min and max values")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 0, max = 10, step = 1}},
				output = {"value"}
			}
		end

		unitTest:assertError(error_func, "Parameter y min is out of the model range.")
			error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 11, step = 1}},
				output = {"value"}
			}
		end

		unitTest:assertError(error_func, "Parameter y max is out of the model range.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10, step = 0.5}},
				output = {"value"}
			}
		end

		unitTest:assertError(error_func, "Parameter y step is out of the model range.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1.5, max = 9.5, step = 1}},
				output = {"value"}
			}
		end

		unitTest:assertError(error_func, "Parameter y min is out of the model range.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{1, 100}},
				output = {"value"}
			}
		end

		unitTest:assertError(error_func, "Parameter 100 in #2 is bigger than y max value")
		error_func = function()
			m = MultipleRuns{
				model = MyModel2,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10, step = 1}},
				output = {"value"}
			}
		end

		unitTest:assertError(error_func, "Parameter -100 in #1 is smaller than x min value")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{1, 1.5}},
				output = {"value"}
			}
		end

		unitTest:assertError(error_func, "Parameter 1.5 in #2 is out of y range")
			error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{2.5, 3}},
				output = {"value"}
			}
		end

		unitTest:assertError(error_func, "Parameter 2.5 in #1 is out of y range")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10}},
				output = {"value"}
			}
		end

		unitTest:assertError(error_func,  "Argument 'y.step' is mandatory.")
	end,
	checkParameterSingle = function(unitTest)
		-- parameters = {x = Choice{-100, 2}}
		error_func = function()
			checkParameterSingle(MyModel, "x", 2, 5)
		end
		unitTest:assertError(error_func, "Parameter 5 in #2 is out of the model x range.")
	end,
	cloneValues = function(unitTest)
		error_func = function()
			cloneValues(nil)
		end
		unitTest:assertError(error_func, "Argument '#1' is mandatory.")
	end
}
