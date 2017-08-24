return{
	SAMDE = function(unitTest)
		local MyModel = Model{
			x = Choice{min = -100, max = 100},
			finalTime = 1,
			init = function(self)
				self.t = Timer{
					Event{action = function()
						self.value = 2 * self.x ^2 - 3 * self.x + 4
					end}
				}
			end
		}
		local error_func = function()
			c = SAMDE{
				parameters = {finalTime = 1, x = Choice{min = -100, max = 100}},
				size = 30,
				maxGen = 100,
				threshold = 1,
				fit = function(model)
					return model.value
				end
			}
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg("model"))
		error_func = function()
			c = SAMDE{
				model = MyModel,
				size = 30,
				maxGen = 100,
				threshold = 1,
				fit = function(model)
					return model.value
				end
			}
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg("parameters"))
		error_func = function()
			local c = SAMDE{
				model = MyModel,
				size = 30,
				maxGen = 100,
				threshold = 1,
				parameters = {finalTime = 1, x = Choice{min = -100, max = 100}},
			}
			c:fit(model, parameters)
		end

		unitTest:assertError(error_func, "Function 'fit' was not implemented.")
		local warning_func = function()
			local c = SAMDE{
				model = MyModel,
				size = 30,
				maxGen = 100,
				threshold = 1,
				fit = function(model)
					return model.value
				end,
				parameters = {finalTime = 1, x = Choice{min = -100, max = 100}},
				extraParameter = {"Unnecessary"}
			}
		end

		unitTest:assertWarning(warning_func, "Argument 'extraParameter' is unnecessary. Do you mean 'parameters'?")
	end
}

