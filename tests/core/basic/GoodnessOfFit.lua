

return{
	pixelByPixel = function(unitTest)
		local cell = Cell{a = 0.8, b = 0.7}

		local cs = CellularSpace{xdim = 10, instance = cell}

		local result = pixelByPixel(cs, cs, "a", "b", true)

		unitTest:assert_equal(result, 0.9, 0.0001)

		local cell2 = Cell{a = "forest", b = "forest"}

		local cs2 = CellularSpace{xdim = 10, instance = cell2}

		local t = Trajectory{
			target = cs2,
			select = function(cell2) return cell2.x > 4 end
		}

		forEachCell(t, function(cell2) cell2.b = "deforested" end)

		local result2 = pixelByPixel(cs2, cs2, "a", "b")

		unitTest:assert_equal(result2, 0.5)
	end,
	multiLevel = function(unitTest)
		local cs = CellularSpace{
        		database = file("Costanza.map", "calibration"),
        		attrname = "Costanza"
		}
 
		-- print(#cs)

		local cs2 = CellularSpace{
     	    		database = file("Costanza2.map", "calibration"),
     	    		attrname = "Costanza"
		}

		local result = multiLevel(cs, cs2, "Costanza")
		local result2 = multiLevel(cs, cs2, "Costanza", true)
		unitTest:assert_equal(result, 0.84) -- 0.84 is the Total Fitness in Costanza Paper Example.
		unitTest:assert_equal(result2, 0.84 )
	end
	}
