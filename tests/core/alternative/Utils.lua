
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
			local m = randomModel("test", {x = Choice{1, 2, 3}, y = Choice{3, 4, 5}})
			m:run()
		end

		unitTest:assertError(error_func,  "Incompatible types. Argument '#1' expected Model, got string.")
		error_func = function()
			local m = randomModel(MyModel, "test")
			m:run()
		end

		unitTest:assertError(error_func, "Incompatible types. Argument '#1' expected table, got string.")
	end,
	checkParametersSet = function(unitTest)
		error_func = function()
			local parameters = {x = Choice{-100, 1, 3}}
			checkParametersSet(MyModel, "x", parameters.x)
		end
		unitTest:assertError(error_func, "Argument 'x' should belong to Choice{-100, -1, 0, 1, 2, 100}, got 3 in position 3.")
	end,
	checkParametersRange = function(unitTest)
		error_func = function()
			local parameters = {y = Choice{min = 2, max = 11, step =1}}
			checkParametersRange(MyModel, "y", parameters.y)
		end

		unitTest:assertError(error_func, "Argument 'y.max' should be less than or equal to 10, got 11.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				parameters = {x = Choice{min=1, max=10, step=1}, y = 5},
			}
		end

		unitTest:assertError(error_func, "Argument 'x' should not be a range of values.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				parameters = {x = 1, y = Choice{min = 5, step = 1}},
			}
		end

		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{min = 2, max = 5, step = 1}, y = Choice{min = 2, max = 5, step = 1}}
			}
		end

		unitTest:assertError(error_func, "Argument 'x' should not be a range of values.")
			error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1}}
			}
		end

		unitTest:assertError(error_func, "Argument 'y' must have 'min' and 'max' values.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 0, max = 10, step = 1}}
			}
		end

		unitTest:assertError(error_func, "Argument 'y.min' should be greater than or equal to 1, got 0.")
			error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 11, step = 1}}
			}
		end

		unitTest:assertError(error_func, "Argument 'y.max' should be less than or equal to 10, got 11.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10, step = 0.5}}
			}
		end

		unitTest:assertError(error_func, "Argument 'y.step' should be within range of Choice{min = 1, max = 10, step = 1}, got 0.5.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1.5, max = 9.5, step = 1}}
			}
		end

		unitTest:assertError(error_func, "Argument 'y.min' should be within range of Choice{min = 1, max = 10, step = 1}, got 1.5.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{1, 100}}
			}
		end

		unitTest:assertError(error_func, "Argument 'y' should be less than or equal to 10, got 100 in position 2.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel2,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10, step = 1}}
			}
		end

		unitTest:assertError(error_func, "Argument 'x' should be greater than or equal to 1, got -100 in position 1.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{1, 1.5}}
			}
		end

		unitTest:assertError(error_func, "Argument 'y' should be within range of Choice{min = 1, max = 10, step = 1}, got 1.5 in position 2.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{2.5, 3}}
			}
		end

		unitTest:assertError(error_func, "Argument 'y' should be within range of Choice{min = 1, max = 10, step = 1}, got 2.5 in position 1.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10}}
			}
		end

		unitTest:assertError(error_func,  "Argument 'y.step' is mandatory.")
	end,
	checkParameterSingle = function(unitTest)
		-- parameters = {x = Choice{-100, 2}}
		error_func = function()
			checkParameterSingle(MyModel, "x", 2, 5)
		end
		unitTest:assertError(error_func, "Argument 'x' should belong to Choice{-100, -1, 0, 1, 2, 100}, got 5 in position 2.")
	end,
	cloneValues = function(unitTest)
		error_func = function()
			cloneValues(nil)
		end
		unitTest:assertError(error_func, "Argument '#1' is mandatory.")
	end
}
