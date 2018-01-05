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
	end,
	sumOfSquares = function(unitTest)
		local data = {
			x1 = {1, 2, 3, 4, 5},
			x2 = {5, 4, 3, 2, 1},
			x3 = {1, 2, 3},
			x4 = "x4"
		}

		local error_func = function()
			sumOfSquares(nil, "x1", "x2")
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg("#1"))
		error_func = function()
			sumOfSquares(data, nil, "x2")
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg("#2"))
		error_func = function()
			sumOfSquares(data, "x1")
		end

		unitTest:assertError(error_func, mandatoryArgumentMsg("#3"))
		error_func = function()
			sumOfSquares(data, "x1", "x3")
		end

		unitTest:assertError(error_func, "Tables 'x1' and 'x3' must have the same size, got 5 ('x1') and 3 ('x3').")
		error_func = function()
			sumOfSquares(data, "x3", "x2")
		end

		unitTest:assertError(error_func, "Tables 'x3' and 'x2' must have the same size, got 3 ('x3') and 5 ('x2').")
	end
}
