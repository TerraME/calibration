
return{
	pixelByPixel = function(unitTest)
		local cell = Cell{a = 0.8, b = 0.7}
		local cs = CellularSpace{xdim = 10, instance = cell}
		local result = pixelByPixel(cs, cs, "a", "b", true)
		unitTest:assertEquals(result, 0.9, 0.0001)
		local cell2 = Cell{a = "forest", b = "forest"}
		local cs2 = CellularSpace{xdim = 10, instance = cell2}
		local t = Trajectory{
			target = cs2,
			select = function(cellCs2) return cellCs2.x > 4 end
		}
		forEachCell(t, function(cellT) cellT.b = "deforested" end)
		local result2 = pixelByPixel(cs2, cs2, "a", "b")
		unitTest:assertEquals(result2, 0.5)
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
		local result = multiLevel{cs1 = cs, cs2 = cs2, attribute = "costanza"}
		local result5 = multiLevel{cs1 = sugar, cs2 = sugar2, attribute = "maxsugar"}
		local result9 = multiLevel{cs1 = sugar3, cs2 = sugar4, attribute = "maxsugar"}
		-- Continuous Tests:
		local result2 = multiLevel{cs1 = cs, cs2 = cs2, attribute = "costanza", continuous = true}
		local result6 = multiLevel{cs1 = sugar, cs2 = sugar2, attribute = "maxsugar", continuous = true}
		local result10 = multiLevel{cs1 = sugar3, cs2 = sugar4, attribute = "maxsugar", continuous = true}
		unitTest:assertEquals(result, 0.84, 0.01) -- 0.84 is the Total Fitness in Costanza Paper Example.
		unitTest:assertEquals(result2, 0.91, 0.01)
		unitTest:assertEquals(result5, 0.66, 0.01)
		unitTest:assertEquals(result6, 0.62, 0.01)
		unitTest:assertEquals(result9, 1, 0.01)
		unitTest:assertEquals(result10, 1, 0.01)
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
