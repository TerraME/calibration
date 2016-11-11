
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
			local original = {x = 42}
			local copy = clone(original)
			if copy ~= original then
				customError("Values are different.")
			end
		end
		unitTest:assertError(error_func, "Values are different.")
	end
}
