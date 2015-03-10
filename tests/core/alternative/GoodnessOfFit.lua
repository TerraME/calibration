return{
	pixelByPixel = function(unitTest)
		local cell = Cell{a = 0.8, b = 0.7}
		local cs = CellularSpace{xdim = 10, instance = cell}
		local error_func = function()
			pixelByPixel()
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(1))	
		local error_func = function()
			pixelByPixel(cs)
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(2))
		error_func = function()
			pixelByPixel(cs, cs)
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(3))
		error_func = function()
			pixelByPixel(cs, cs, "a")
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(4))
		error_func = function()
			pixelByPixel(cs,cs,"c","b")
		end

		unitTest:assert_error(error_func, "Attribute c was not found in the CellularSpace.")
		local error_func = function()
			pixelByPixel(cs,cs,"a","c")
		end

		unitTest:assert_error(error_func, "Attribute c was not found in the CellularSpace.")
	end,
	multiLevel = function(unitTest)
		local cell = Cell{a = 0.8, b = 0.7}
		local cs = CellularSpace{xdim = 10, instance = cell}
		local error_func = function()
			multiLevel()
		end
		
		unitTest:assert_error(error_func, mandatoryArgumentMsg(1))
		error_func = function()
			multiLevel(cs)
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(2))
		error_func = function()
			multiLevel(cs,cs)
		end

		unitTest:assert_error(error_func, mandatoryArgumentMsg(3))
	end
}
