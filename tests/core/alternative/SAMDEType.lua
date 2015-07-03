return{
	SAMDE = function(unitTest)
		local MyModel = Model{
			x = 1,
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
				parameters = {finalTime = 1, x ={min = -100, max = 100}},
				fit = function(model)
					return model.value
				end
			}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("model"))	

		error_func = function()
			c = SAMDE{
				model = MyModel,
				fit = function(model)
					return model.value
				end
			}
		end
		unitTest:assertError(error_func, mandatoryArgumentMsg("parameters"))	

		error_func = function()
			local c = SAMDE{
				model = MyModel,
				parameters = {finalTime = 1, x = {min = -100, max = 100}},
			}
			c:fit(model, parameters)
		end
		unitTest:assertError(error_func, "Function 'fit' was not implemented.")	
	end
}

