return{
	pixelByPixel = function(unitTest)
		local cell = Cell{a = 0.8, b = 0.7}
		local cs = CellularSpace{xdim = 10, instance = cell}
		local error_func = function()
			pixelByPixel()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))	
		error_func = function()
			pixelByPixel(cs)
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(2))
		error_func = function()
			pixelByPixel(cs, cs)
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(3))
		error_func = function()
			pixelByPixel(cs, cs, "a")
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(4))
		error_func = function()
			pixelByPixel(cs,cs,"c","b")
		end

		unitTest:assertError(error_func, "Attribute c was not found in the first CellularSpace.")
		error_func = function()
			pixelByPixel(cs,cs,"a","c")
		end

		unitTest:assertError(error_func, "Attribute c was not found in the second CellularSpace.")
	end,
	multiLevel = function(unitTest)
		local cell = Cell{a = 0.8, b = 0.7}
		local cs = CellularSpace{xdim = 10, instance = cell}
		local error_func = function()
			multiLevel()
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg(1))
		error_func = function()
			multiLevel{}
		end
		
		unitTest:assertError(error_func, mandatoryArgumentMsg("cs1"))
		error_func = function()
			multiLevel{cs1 = cs}
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg("cs2"))
		error_func = function()
			multiLevel{cs1 = cs, cs2 = cs}
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg("attribute"))
	end
}
