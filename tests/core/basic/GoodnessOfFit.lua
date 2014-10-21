

return{
	continuousPixelByPixel = function(unitTest)
		local cell = Cell{a = 0.8, b = 0.7}

		local cs = CellularSpace{xdim = 10, instance = cell}

		local result = pixelByPixel(cs, cs, "a", "b")

		unitTest:assert_equal(result, 0.1, 0.0001)
	end,
	discretePixelByPixelString = function(unitTest)
		local cell = Cell{a = "forest", b = "forest"}

		local cs = CellularSpace{xdim = 10, instance = cell}

		t = Trajectory{
			target = cs,
			select = function(cell) return cell.x > 4 end
		}

		forEachCell(t, function(cell) cell.b = "deforested" end)

		local result = pixelByPixelString(cs, cs, "a", "b")

		unitTest:assert_equal(result, 0.5)
	end,


	discreteCostanzaMultiLevel = function(unitTest)

		cs = CellularSpace{
        	 database = "Costanza.map"
		}
 
		-- print(#cs)

		cs2 = CellularSpace{
     	    database = "Costanza2.map"
		}
		local result = discreteCostanzaMultiLevel = function(cs1, cs2, "unknown attribute name")
		unitTest:assert_equal(result, 0.84) -- 0.84 is the Total Fitness in Costanza Paper Example.

		end, 

	continuousCostanzaMultiLeve = function(unitTest)

		cs = CellularSpace{
        	 database = "Costanza.map"
		}
 
		-- print(#cs)

		cs2 = CellularSpace{
     	    database = "Costanza2.map"
		}
		local result = discreteCostanzaMultiLevel = function(cs1, cs2, "unknown attribute name")
		-- unitTest:assert_equal(result, "unknown value" )

		end
	}
