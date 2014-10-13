return{
	pixelByPixel = function(unitTest)

		local cell = Cell{a = 0.8, b = 0.7}

		local cs = CellularSpace{xdim = 10, instance = cell}

		
		
		local error_func = function()
			pixelByPixel()
		end


		-- TODO: para mensagens de erro, ver terrame/base/lua/Package.lua
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")
		
		local error_func = function()
			pixelByPixel(cs)
		end

		unitTest:assert_error(error_func, "Error: Parameter '#2' is mandatory.")

		error_func = function()
			pixelByPixel(cs, cs)
		end
		unitTest:assert_error(error_func, "Error: Parameter '#3' is mandatory.")

		error_func = function()
			pixelByPixel(cs,cs,"a")
		end
		unitTest:assert_error(error_func, "Error: Parameter '#4' is mandatory.")

		error_func = function()
			pixelByPixel(cs,cs,"c","b")
		end
		unitTest:assert_error(error_func, "#3 is not a valid cell attribute of #1.")

		local error_func = function()
			pixelByPixel(cs,cs,"a","c")
		end
		unitTest:assert_error(error_func, "#4 is not a valid cell attribute of #2.")
		-- TODO: completar com outros testes
	end,
	pixelByPixelString = function(unitTest)
	
		local cell = Cell{a = 0.8, b = 0.7}

		local cs = CellularSpace{xdim = 10, instance = cell}
		
		local error_func = function()
			pixelByPixelString()
		end

		-- TODO: para mensagens de erro, ver terrame/base/lua/Package.lua
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")
		
		local error_func = function()
			pixelByPixelString(cs)
		end

		unitTest:assert_error(error_func, "Error: Parameter '#2' is mandatory.")

		error_func = function()
			pixelByPixelString(cs, cs)
		end
		unitTest:assert_error(error_func, "Error: Parameter '#3' is mandatory.")

		error_func = function()
			pixelByPixelString(cs,cs,"a")
		end
		unitTest:assert_error(error_func, "Error: Parameter '#4' is mandatory.")


		error_func = function()
			pixelByPixelString(cs,cs,"c","b")
		end
		unitTest:assert_error(error_func, "#3 is not a valid cell attribute of #1.")

		local error_func = function()
			pixelByPixelString(cs,cs,"a","c")
		end
		unitTest:assert_error(error_func, "#4 is not a valid cell attribute of #2.")
		-- TODO: completar com outros testes
	end,
	multiLevel = function(unitTest)

		local cell = Cell{a = 0.8, b = 0.7}

		local cs = CellularSpace{xdim = 10, instance = cell}
		
		local error_func = function()
			multiLevel()
		end
		
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")

		error_func = function()
			multiLevel(cs)
		end

		unitTest:assert_error(error_func, "Error: Parameter '#2' is mandatory.")

		error_func = function()
			multiLevel(cs,cs)
		end

		unitTest:assert_error(error_func, "Error: Parameter '#3' is mandatory.")
		-- TODO: completar com outros testes

	end,
	multiLevelDemand = function(unitTest)	

		local cell = Cell{a = 0.8, b = 0.7}

		local cs = CellularSpace{xdim = 10, instance = cell}
		
		local error_func = function()
			multiLevelDemand()
		end
		
		unitTest:assert_error(error_func, "Error: Parameter '#1' is mandatory.")

		error_func = function()
			multiLevelDemand(cs)
		end

		unitTest:assert_error(error_func, "Error: Parameter '#2' is mandatory.")

		error_func = function()
			multiLevelDemand(cs,cs)
		end

		unitTest:assert_error(error_func, "Error: Parameter '#3' is mandatory.")

		error_func = function()
			multiLevelDemand(cs,cs, 0)
		end

		unitTest:assert_error(error_func, "Demand should be bigger than 0.")

	end
	-- colocar o multiLevelDemand
}
