
return{
	pixelBypixel = function(unitTest)
		
		local error_func = function()
			pixelByPixel()
		end

		-- TODO: para mensagens de erro, ver terrame/base/lua/Package.lua
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected CellularSpace, got nil.")
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#2' expected CellularSpace, got nil.")
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#3' expected String, got nil.")
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#4' expected String, got nil.")
		unitTest:assert_error(error_func, "#3 is not a valid cell attribute of #1.")
		unitTest:assert_error(error_func, "#4 is not a valid cell attribute of #2.")
		-- TODO: completar com outros testes
	end,
	multiLevel = function(unitTest)
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected CellularSpace, got nil.")
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#2' expected CellularSpace, got nil.")
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#3' expected String, got nil.")
		-- TODO: completar com outros testes

	end
	multiLevelDemand = function(unitTest)			
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected CellularSpace, got nil.")
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#2' expected CellularSpace, got nil.")
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#3' expected String, got nil.")
		unitTest:assert_error(error_func, "Demand should be bigger than 0.")

	end
	-- colocar o multiLevelDemand
}
