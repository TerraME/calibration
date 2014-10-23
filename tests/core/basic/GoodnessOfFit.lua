

return{
	continuousPixelByPixel = function(unitTest)
		local cell = Cell{a = 0.8, b = 0.7}

		local cs = CellularSpace{xdim = 10, instance = cell}

		local result = continuousPixelByPixel(cs, cs, "a", "b")

		unitTest:assert_equal(result, 0.1, 0.0001)
	end,

	discretePixelByPixelString = function(unitTest)
		local cell = Cell{a = "forest", b = "forest"}

		local cs = CellularSpace{xdim = 10, instance = cell}

		local t = Trajectory{
			target = cs,
			select = function(cell) return cell.x > 4 end
		}

		forEachCell(t, function(cell) cell.b = "deforested" end)

		local result = discretePixelByPixelString(cs, cs, "a", "b")

		unitTest:assert_equal(result, 0.5)
	end,


	discreteCostanzaMultiLevel = function(unitTest)

		local cs = CellularSpace{
        		database = file("Costanza.map", "calibration"),
        		attrname = "Costanza"
		}
 
		-- print(#cs)

		local cs2 = CellularSpace{
     	    		database = file("Costanza2.map", "calibration"),
     	    		attrname = "Costanza"
		}

		local result = discreteCostanzaMultiLevel(cs, cs2, "Costanza")
		unitTest:assert_equal(result, 0.84) -- 0.84 is the Total Fitness in Costanza Paper Example.

	end, 

	continuousCostanzaMultiLevel = function(unitTest)

		local cs = CellularSpace{
        		database = file("Costanza.map", "calibration"),
        		attrname = "Costanza"
		}
 
		-- print(#cs)

		local cs2 = CellularSpace{
     	    	database = file("Costanza2.map", "calibration"),
     	    	attrname = "Costanza"
		}
		local result = continuousCostanzaMultiLevel(cs, cs2, "Costanza")
		-- unitTest:assert_equal(result, "unknown value" )

	end
	}
