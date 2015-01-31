-- TO DO: Test each of the SAMDE functions
local MyModel
MyModel = Model{
	x = choice{ min = 1, max = 10},
	y = choice{ min = 1, max = 10},
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
	end
}

local varMatrix = {{1,10},{1,10}}
local dim = 2
local paramList = {"x","y"}
local finalTime = 1
local fit
fit = function(model)
	return model.value
end

return{

	evaluate = function(unitTest)
		unitTest:assert_equal(evaluate({1,1}, dim, MyModel, paramList, finalTime, fit), 4)
	end,

	initPop = function(unitTest)
		local pop = {}
		local maxPopulation = 1
		pop = initPop(maxPopulation, varMatrix, dim)
		local result = true
		for i=1, dim do
			if not(pop[1][i] > varMatrix[i][1] and pop[1][i] < varMatrix[i][2]) then
				result = false
			end
		end
		
		for i = dim + 1, dim + 12 do
			if not(pop[1][i] < 1 and pop[1][i] > 0) then
				result = false
			end
		end
		unitTest:assert(result)
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
