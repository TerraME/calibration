
-- TO DO: Test each of the SAMDE functions
local MyModel
MyModel = Model{
	x = 1,
	y = 0,
	setup = function(self)
		self.t = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
	end
}

return{

	evaluate = function(unitTest)
		unitTest:assert(true)
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
