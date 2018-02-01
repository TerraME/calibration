return{
	pixelByPixel = function(unitTest)
		local cell = Cell{a = 0.8, b = 0.7}
		local cs = CellularSpace{xdim = 10, instance = cell}
		local error_func = function()
			pixelByPixel()
		end

		unitTest:assertError(error_func, tableArgumentMsg())

		error_func = function()
			pixelByPixel{target = 2}
		end

		unitTest:assertError(error_func, "Argument 'target' must be a CellularSpace or a table with two CellularSpaces.")

		error_func = function()
			pixelByPixel{target = cs}
		end

		unitTest:assertError(error_func, "Argument 'select' must be a string or a table with two strings.")

		error_func = function()
			pixelByPixel{target = cs, select = "a"}
		end

		unitTest:assertError(error_func, "When using a single CellularSpace, the selected attributes must be different.")

		error_func = function()
			pixelByPixel{target = {2, cs}}
		end

		unitTest:assertError(error_func, "First element of 'target' should be a CellularSpace, got number.")

		error_func = function()
			pixelByPixel{target = {cs, 2}}
		end

		unitTest:assertError(error_func, "Second element of 'target' should be a CellularSpace, got number.")

		error_func = function()
			pixelByPixel{target = {2}}
		end

		unitTest:assertError(error_func, "Argument 'target' must be a CellularSpace or a table with two CellularSpaces.")

		error_func = function()
			pixelByPixel{target = cs, select = {2, "a"}}
		end

		unitTest:assertError(error_func, "First element of 'select' should be a string, got number.")

		error_func = function()
			pixelByPixel{target = cs, select = {"a", 2}}
		end

		unitTest:assertError(error_func, "Second element of 'select' should be a string, got number.")
		error_func = function()
			pixelByPixel{target = cs, select = {2}}
		end

		unitTest:assertError(error_func, "Argument 'select' must be a string or a table with two strings.")

		error_func = function()
			pixelByPixel{target = cs, select = {2}}
		end

		unitTest:assertError(error_func, "Argument 'select' must be a string or a table with two strings.")

		error_func = function()
			pixelByPixel{target = cs, select = 2}
		end

		unitTest:assertError(error_func, "Argument 'select' must be a string or a table with two strings.")
	end,
	multiLevel = function(unitTest)
		local cell = Cell{a = 0.8, b = 0.7}
		local cs = CellularSpace{xdim = 10, instance = cell}
		local error_func = function()
			multiLevel()
		end

		unitTest:assertError(error_func, tableArgumentMsg())

		error_func = function()
			multiLevel{target = 2}
		end

		unitTest:assertError(error_func, "Argument 'target' must be a CellularSpace or a table with two CellularSpaces.")

		error_func = function()
			multiLevel{target = cs}
		end

		unitTest:assertError(error_func, "Argument 'select' must be a string or a table with two strings.")

		error_func = function()
			multiLevel{target = cs, select = "a"}
		end

		unitTest:assertError(error_func, "When using a single CellularSpace, the selected attributes must be different.")

		error_func = function()
			multiLevel{target = {2, cs}}
		end

		unitTest:assertError(error_func, "First element of 'target' should be a CellularSpace, got number.")

		error_func = function()
			multiLevel{target = {cs, 2}}
		end

		unitTest:assertError(error_func, "Second element of 'target' should be a CellularSpace, got number.")

		error_func = function()
			multiLevel{target = {2}}
		end

		unitTest:assertError(error_func, "Argument 'target' must be a CellularSpace or a table with two CellularSpaces.")

		error_func = function()
			multiLevel{target = cs, select = {2, "a"}}
		end

		unitTest:assertError(error_func, "First element of 'select' should be a string, got number.")

		error_func = function()
			multiLevel{target = cs, select = {"a", 2}}
		end

		unitTest:assertError(error_func, "Second element of 'select' should be a string, got number.")
		error_func = function()
			multiLevel{target = cs, select = {2}}
		end

		unitTest:assertError(error_func, "Argument 'select' must be a string or a table with two strings.")

		error_func = function()
			multiLevel{target = cs, select = {2}}
		end

		unitTest:assertError(error_func, "Argument 'select' must be a string or a table with two strings.")

		error_func = function()
			multiLevel{target = cs, select = 2}
		end

		unitTest:assertError(error_func, "Argument 'select' must be a string or a table with two strings.")

		error_func = function()
			multiLevel{target = cs, select = {"a", "b"}, k = false}
		end

		unitTest:assertError(error_func, incompatibleTypeMsg("k", "number", false))
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
