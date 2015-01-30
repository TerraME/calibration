
-- TO DO: Test each of the SAMDE functions
local MyModel
MyModel = Model{
	x = choice{-100, -1, 0, 1, 2, 100},
	y = choice{ min = 1, max = 10},
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
	end
}

return{

	evaluate = function(unitTest)
		local fit = function(model)
			return model.value
		end	
		unitTest:assert_equal(evaluate({1,1}, 2, MyModel, {"x","y"}, 1, fit), 4)
	end,
	initPop = function(unitTest)
		unitTest:assert(true)
	end,
	g3Rand = function(unitTest)
		unitTest:assert(true)
	end,
	g4Rand = function(unitTest)
		unitTest:assert(true)
	end,
	copy = function(unitTest)
		unitTest:assert(true)
	end,
	copyParameters = function(unitTest)
		unitTest:assert(true)
	end,
	repareP = function(unitTest)
		unitTest:assert(true)
	end,
	oobTrea = function(unitTest)
		unitTest:assert(true)
	end,
	distancia = function(unitTest)
		unitTest:assert(true)
	end,
	normaliza = function(unitTest)
		unitTest:assert(true)
	end,
	maxVector = function(unitTest)
		unitTest:assert(true)
	end,
	maxDiversity = function(unitTest)
		unitTest:assert(true)
	end,
	SAMDE_ = function(unitTest)
		unitTest:assert(true)
	end,
	calibration = function(unitTest)
		unitTest:assert(true)
	end
	}
