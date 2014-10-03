

pixelByPixel = function(cs1, cs2, attribute1, attribute2)
	-- cs1 tem attribute1 cs1.cells[1][attribute1] ~= nil
	-- attributes string
	-- cs2 tem attribute2

	if type(cs1) ~= "CellularSpace" then
		incompatibleTypeError("#1", "CellularSpace", cs1)
	end

	-- TODO: outras verificacoes

	-- TODO: calcula as diferencas pixel a pixel

	-- TODO: retorna a media
end


multiLevel = function(cs1, cs2, attribute)
	-- cs1 tem attribute1
	-- cs2 tem attribute2

end

multiLevelDemand = function(cs1, cs2, attribute, demand)
	-- cs1 tem attribute1
	-- cs2 tem attribute2
	-- demand > 0

end


