
return{
	pixelBypixel = function(unitTest)
		
		local error_func = function()
			pixelByPixel()
		end

		-- TODO: para mensagens de erro, ver terrame/base/lua/Package.lua
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#1' expected CellularSpace, got nil.")
		-- TODO: completar com outros testes
	end,
	multiLevel = function(unitTest)
		-- TODO: completar com outros testes

	end
	-- colocar o multiLevelDemand
}
