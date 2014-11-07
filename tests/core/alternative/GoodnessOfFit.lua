return{
	continuousPixelByPixel = function(unitTest)
		local cell = Cell{a = 0.8, b = 0.7}
		local cs = CellularSpace{xdim = 10, instance = cell}
		local error_func = function()
			continuousPixelByPixel()
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(1))	
		local error_func = function()
			continuousPixelByPixel(cs)
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(2))
		error_func = function()
			continuousPixelByPixel(cs, cs)
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(3))
		error_func = function()
			continuousPixelByPixel(cs, cs, "a")
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(4))
		error_func = function()
			continuousPixelByPixel(cs,cs,"c","b")
		end

		unitTest:assert_error(error_func, "Attribute c was not found in the CellularSpace.")
		local error_func = function()
			continuousPixelByPixel(cs,cs,"a","c")
		end

		unitTest:assert_error(error_func, "Attribute c was not found in the CellularSpace.")
	end,
	discretePixelByPixelString = function(unitTest)
		local cell = Cell{a = 0.8, b = 0.7}
		local cs = CellularSpace{xdim = 10, instance = cell}
		local error_func = function()
			discretePixelByPixelString()
		end

		-- for error messages see terrame/base/lua/Package.lua
		unitTest:assert_error(error_func, mandatoryArgumentMsg(1))
		local error_func = function()
			discretePixelByPixelString(cs)
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(2))
		error_func = function()
			discretePixelByPixelString(cs, cs)
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(3))
		error_func = function()
			discretePixelByPixelString(cs,cs,"a")
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(4))
		error_func = function()
			discretePixelByPixelString(cs,cs,"c","b")
		end

		unitTest:assert_error(error_func, "Attribute c was not found in the CellularSpace.")
		local error_func = function()
			discretePixelByPixelString(cs,cs,"a","c")
		end

		unitTest:assert_error(error_func, "Attribute c was not found in the CellularSpace.")
		-- TODO: completar com outros testes
	end,
	discreteCostanzaMultiLevel = function(unitTest)
		local cell = Cell{a = 0.8, b = 0.7}
		local cs = CellularSpace{xdim = 10, instance = cell}
		local error_func = function()
			discreteCostanzaMultiLevel()
		end
		
		unitTest:assert_error(error_func, mandatoryArgumentMsg(1))
		error_func = function()
			discreteCostanzaMultiLevel(cs)
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(2))
		error_func = function()
			discreteCostanzaMultiLevel(cs,cs)
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(3))
	end,
	multiLevelDemand = function(unitTest)	
		local cell = Cell{a = 0.8, b = 0.7}
		local cs = CellularSpace{xdim = 10, instance = cell}
		local error_func = function()
			multiLevelDemand()
		end
		
		unitTest:assert_error(error_func, mandatoryArgumentMsg(1))
		error_func = function()
			multiLevelDemand(cs)
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(2))
		error_func = function()
			multiLevelDemand(cs,cs)
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(3))
		error_func = function()
			multiLevelDemand(cs,cs, "a")
		end
	
		unitTest:assert_error(error_func, mandatoryArgumentMsg(4))
		error_func = function()
			multiLevelDemand(cs,cs, "a", 0)
		end

		unitTest:assert_error(error_func, "Demand should be bigger than 0.")
	end
}
