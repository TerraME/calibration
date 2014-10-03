
return{
	pixelBypixel = function(unitTest)
		
		local error_func = function()
			pixelByPixel()
		end

		-- TODO: para mensagens de erro, ver terrame/base/lua/Package.lua
		unitTest:assert_error(error_func, "Incompatible types. ...#1 should be a CellularSpace")

		-- TODO: completar com outros testes
	end,
	multiLevel = function(unitTest)
		-- TODO: completar com outros testes

	end
	-- colocar o multiLevelDemand
}
