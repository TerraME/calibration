
return{
	pixelBypixel = function(unitTest)
		local cell = Cell{a = 0.8, b = 0.7}

		local cs = CellularSpace{xdim = 10, instance = cell}

		local result = pixelByPixel(cs, cs, "a", "b")

		unitTest:assert_equal(result, 0.1)
	end,
	pixelBypixelString = function(unitTest)
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


	multiLevel = function(unitTest)

	end
}
