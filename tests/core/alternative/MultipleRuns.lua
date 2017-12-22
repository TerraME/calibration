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
local MyModel4 = Model{
	parameters3 = {
		x = 1,
		y = 2,
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
			m = MultipleRuns{
				folderName = "!@#$$#$%??",
				showProgress = false,
				model = MyModel,
				parameters = {scenario1 ={x = 2, y = 5}},
			}
		end

		unitTest:assertError(error_func, "Directory name '!@#$$#$%??' cannot contain character '?'.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				showProgress = false,
				parameters = {scenario1 ={x = 2, y = 5, p = "extra"}},
			}
		end

		unitTest:assertError(error_func, "p is unnecessary.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				showProgress = false,
				parameters = {x = Choice{1, 2},
				y =Choice{1,5},
				p = "extra"},
			}
		end

		unitTest:assertError(error_func, "p is unnecessary.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				showProgress = false,
				parameters = {x = Choice{-100, 2}, y = Choice{1, 5}},
			}
		end

		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				showProgress = false,
				parameters = {scenario1 ={x = 2, y = 5}},
				value = function(model)
					return model.value
				end
			}
		end

		unitTest:assertError(error_func, "It is not possible to use function 'value' as output because this name is already an output value of the model.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				showProgress = false,
			}
		end

		unitTest:assertError(error_func, "Argument 'parameters' is mandatory.")
		error_func = function()
			m = MultipleRuns{
				showProgress = false,
				parameters = {scenario1 = {x = 2, y = 5, seed = 1001}},
			}
		end

		unitTest:assertError(error_func, "Argument 'model' is mandatory.")

		error_func = function()
			m = MultipleRuns{
				model = MyModel2,
				showProgress = false,
				strategy = "factorial",
				parameters = {x = Choice{min = 1, max = 5},  y = Choice{1, 2}}
			}
		end

		unitTest:assertError(error_func, "Argument 'x.step' is mandatory.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				showProgress = false,
				strategy = "sample",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = 5},
			}
		end

		unitTest:assertError(error_func, "Argument 'quantity' is mandatory.")
		error_func = function()
				m = MultipleRuns{
				model = MyModel,
				showProgress = false,
				strategy = "factorial",
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10}},
			}
		end

		unitTest:assertError(error_func, "Argument 'y.step' is mandatory.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				showProgress = false,
				parameters = {x = {-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10, step = 1}},
			}
		end

		unitTest:assertError(error_func, "The parameter must be of type Choice, a table of Choices or a single value.")

		error_func = function()
			MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				showProgress = false,
				parameters = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10, step = 1}},
				test = "test",
			}
		end

		unitTest:assertError(error_func, "Argument 'test' is not a valid argument of MultipleRuns.")

		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "factorial",
				showProgress = false,
				parameters = {x = Choice{-100, -1, 0, 1, 2, 99}, y = Choice{min = 1, max = 10, step = 1}},
			}
		end

		unitTest:assertError(error_func, "Argument 'x' should belong to Choice{-100, -1, 0, 1, 2, 100}, got 99 in position 6.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel2,
				strategy = "factorial",
				showProgress = false,
				parameters = {x = Choice{1,2,3}},
			}
		end

		unitTest:assertError(error_func, "Argument 'y' is mandatory.")
			error_func = function()
			m = MultipleRuns{
				model = MyModel2,
				strategy = "factorial",
				showProgress = false,
				parameters = {x = Choice{min = 1, max = 5},  y = Choice{1, 2}},
			}
		end

		unitTest:assertError(error_func, "Argument 'x.step' is mandatory.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "selected",
				showProgress = false,
				parameters = {x = -100, y = 10}
			}
		end

		unitTest:assertError(error_func, "Parameters used in strategy 'selected' must be in a table of scenarios.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "selected",
				showProgress = false,
				parameters = {scenario1 = {x = Choice{-100, -1, 0, 1, 2, 100}, y = Choice{min = 1, max = 10, step = 1}}}
			}
		end

		unitTest:assertError(error_func, "Parameters used in strategy 'selected' cannot be 'Choice'.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				strategy = "selected",
				showProgress = false,
				parameters = {
					scenario1 = {x = Choice{2,3,4}, y = 5},
					scenario2 = {x = 1, y = 3}
				},
				additionalF = function(_)
					return "test"
				end
			}
		end

		unitTest:assertError(error_func, "Parameters used in strategy 'selected' cannot be 'Choice'.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel3,
				strategy = "selected",
				parameters = {
					scenario1 = {parameters3 = {x = Choice{2,3}, y = 5}},
					scenario2 = {parameters3 = {x = 1, y = 3}}
				},
				additionalF = function(_)
					return "test"
				end
			}
		end

		unitTest:assertError(error_func, "Parameters used in strategy 'selected' cannot be 'Choice'.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel3,
				strategy = "selected",
				parameters = {
					parameters3 = {x = Choice{1,2,3}, y = 5}
				},
				additionalF = function(_)
					return "test"
				end
			}
		end

		unitTest:assertError(error_func, "Parameters used in strategy 'selected' cannot be 'Choice'.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel3,
				strategy = "selected",
				parameters = {
					parameters3 = {x = 2, y = 5}
				},
				additionalF = function(_)
					return "test"
				end
			}
		end

		unitTest:assertError(error_func, "Parameters used in strategy 'selected' must be in a table of scenarios.")
				error_func = function()
			m = MultipleRuns{
				model = MyModel4,
				strategy = "selected",
				parameters = {
					parameters3 = {x = 2, y = 5}
				},
				additionalF = function(_)
					return "test"
				end
			}
		end

		unitTest:assertError(error_func, "Parameters used in strategy 'selected' must be in a table of scenarios.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel3,
				strategy = "factorial",
				parameters = {
					parameters3 = {x = {0,1,2}, y = 5}
				},
				additionalF = function(_)
					return "test"
				end
			}
		end

		unitTest:assertError(error_func, "The parameter must be of type Choice, a table of Choices or a single value.")
		error_func = function()
			m = MultipleRuns{
				model = MyModel,
				parameters = {
					x = Choice{-1, 0, 1},
					y = Choice{1, 2, 3},
				},
				init = 5
			}
		end
		unitTest:assertError(error_func, "Incompatible types. Argument 'init' expected function, got number.")
		error_func = function()
			MultipleRuns{
				model = MyModel,
				showProgress = false,
				parameters = {
					x = Choice{-1, 0, 1},
					y = Choice{1, 2, 3},
				},
				repetition = 3
			}
		end
		unitTest:assertWarning(error_func, "Parameter 'repetition' is unnecessary for a non-random model.")
	end
}
