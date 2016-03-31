
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
			select = function(cell2) return cell2.x > 4 end
		}
		forEachCell(t, function(cell2) cell2.b = "deforested" end)
		local result2 = pixelByPixel(cs2, cs2, "a", "b")
		unitTest:assertEquals(result2, 0.5)
	end,
	multiLevel = function(unitTest)
		local cs = CellularSpace{
			database = filePath("Costanza.map", "calibration"),
			attrname = "value",
			attrname = "Costanza"
		}
		local cs2 = CellularSpace{
				database = filePath("Costanza2.map", "calibration"),
				attrname = "Costanza"
		}
		local cs12 = CellularSpace{
			database = filePath("Costanza1-2.map", "calibration"),
			attrname = "Costanza"
		}
		local cs22 = CellularSpace{
			database = filePath("Costanza2-2.map", "calibration"),
			attrname = "Costanza"
		}
		local cs13 = CellularSpace{
			database = filePath("Costanza1-3.map", "calibration"),
			attrname = "Costanza"
		}
		local cs23 = CellularSpace{
			database = filePath("Costanza2-3.map", "calibration"),
			attrname = "Costanza"
		}
		local sugar = CellularSpace{
			database = filePath("sugarScape.csv", "calibration"),
			sep      = ";"
		}
		local sugar2 = CellularSpace{
			database = filePath("sugarScape2.csv", "calibration"),
			sep      = ";"
		}
		local sugar3 = CellularSpace{
			database = filePath("sugarScape3.csv", "calibration")
		}
		local sugar4 = CellularSpace{
			database = filePath("sugarScape4.csv", "calibration")
		}
		-- Discrete Tests:
		local result = multiLevel{cs1 = cs, cs2 = cs2, attribute = "Costanza"}
		local result3 = multiLevel{cs1 = cs12, cs2 = cs22, attribute = "Costanza"}
		local result5 = multiLevel{cs1 = sugar, cs2 = sugar2, attribute = "maxsugar"}
		local result7 = multiLevel{cs1 = cs13, cs2 = cs23, attribute = "Costanza"}
		local result9 = multiLevel{cs1 = sugar3, cs2 = sugar4, attribute = "maxsugar"}
		-- Continuous Tests:
		local result2 = multiLevel{cs1 = cs, cs2 = cs2, attribute = "Costanza", continuous = true}
		local result4 = multiLevel{cs1 = cs12, cs2 = cs22, attribute = "Costanza", continuous = true}
		local result6 = multiLevel{cs1 = sugar, cs2 = sugar2, attribute = "maxsugar", continuous = true}
		local result8 = multiLevel{cs1 = cs13, cs2 = cs23, attribute = "Costanza", continuous = true}
		local result10 = multiLevel{cs1 = sugar3, cs2 = sugar4, attribute = "maxsugar", continuous = true}
		unitTest:assertEquals(result, 0.84, 0.01) -- 0.84 is the Total Fitness in Costanza Paper Example.
		unitTest:assertEquals(result2, 0.91, 0.01) 
		unitTest:assertEquals(result3, 0.83, 0.01) 
		unitTest:assertEquals(result4, 0.91, 0.01)
		unitTest:assertEquals(result5, 0.66, 0.01)
		unitTest:assertEquals(result6, 0.62, 0.01)
		unitTest:assertEquals(result7, 1, 0.01)
		unitTest:assertEquals(result8, 1, 0.01)
		unitTest:assertEquals(result9, 1, 0.01)
		unitTest:assertEquals(result10, 1, 0.01)

	end
}

