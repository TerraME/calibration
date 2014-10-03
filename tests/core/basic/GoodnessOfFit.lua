
return{
	pixelBypixel = function(unitTest)
		local cell = Cell{a = 0.8, b = 0.7}

		local cs = CellularSpace{xdim = 10, instance = cell}

		local result = pixelByPixel(cs, cs, "a", "b")

		unitTest:assert_equal(result, 0.1)
	end,
	multiLevel = function(unitTest)

	end
}
