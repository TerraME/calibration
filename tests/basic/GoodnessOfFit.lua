
return{
	pixelByPixel = function(unitTest)
		local cell = Cell{a = 0.8, b = 0.7}
		local cs = CellularSpace{xdim = 10, instance = cell}
		local result = pixelByPixel{
			target = cs,
			select = {"a", "b"}
		}

		unitTest:assertEquals(result, 0.9, 0.0001)
		local cell2 = Cell{a = "forest", b = "forest"}
		local cs2 = CellularSpace{xdim = 10, instance = cell2}
		local t = Trajectory{
			target = cs2,
			select = function(cellCs2) return cellCs2.x > 4 end
		}
		forEachCell(t, function(cellT) cellT.b = "deforested" end)

		local warningFunc = function()
			result = pixelByPixel{
				target = cs2,
				select = {"a", "b"},
				discrete = true,
				abc = 123
			}
		end

		unitTest:assertWarning(warningFunc, unnecessaryArgumentMsg("abc"))
		unitTest:assertEquals(result, 0.5)
	end,
	multiLevel = function(unitTest)
		local cs = CellularSpace{
			file = filePath("costanza.pgm", "calibration")}
		local cs2 = CellularSpace{
			file = filePath("costanza2.pgm", "calibration"),
			attrname = "costanza"}
		local sugar = CellularSpace{
			file = filePath("internal/sugarScape.csv", "calibration"),
			sep      = ";"
		}
		local sugar2 = CellularSpace{
			file = filePath("internal/sugarScape2.csv", "calibration"),
			sep      = ";"
		}
		local sugar3 = CellularSpace{
			file = filePath("internal/sugarScape3.csv", "calibration")
		}
		local sugar4 = CellularSpace{
			file = filePath("internal/sugarScape4.csv", "calibration")
		}

		-- Discrete Tests:
		local result = multiLevel{
			target = {cs, cs2},
			select = "costanza",
			discrete = true
		}

		unitTest:assertEquals(result, 0.865, 0.01) -- 0.84 is the Total Fitness in Costanza Paper Example.

		local warningFunc = function()
			result = multiLevel{
				target = {sugar, sugar2},
				select = "maxsugar",
				discrete = true,
				abc = 2
			}
		end

		unitTest:assertWarning(warningFunc, unnecessaryArgumentMsg("abc"))
		unitTest:assertEquals(result, 0.722, 0.01)

		result = multiLevel{
			target = {sugar3, sugar4},
			select = "maxsugar",
			discrete = true
		}

		unitTest:assertEquals(result, 1, 0.01)

		-- Continuous Tests:
		result = multiLevel{
			target = {cs, cs2},
			select = "costanza",
		}

		unitTest:assertEquals(result, 0.963, 0.01)

		result = multiLevel{
			target = {sugar, sugar2},
			select = "maxsugar"
		}

		unitTest:assertEquals(result, 0.76, 0.01)

		result = multiLevel{
			target = {sugar3, sugar4},
			select = "maxsugar"
		}

		unitTest:assertEquals(result, 1, 0.01)
	end,
	sumOfSquares = function(unitTest)
		local data = {
			x1 = {1, 2, 3, 4, 5},
			x2 = {5, 4, 3, 2, 1}
		}

		unitTest:assertEquals(sumOfSquares(data, "x1", "x2"), 40)
		unitTest:assertEquals(sumOfSquares(data, "x2", "x1"), 40)
		unitTest:assertEquals(sumOfSquares(data, "x1", "x1"), 0)
		unitTest:assertEquals(sumOfSquares(data, "x2", "x2"), 0)
	end
}
