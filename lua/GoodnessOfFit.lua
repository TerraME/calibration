
--Documentation for TERRAME 130 was used as referssence.

pixelByPixel = function(cs1, cs2, attribute1, attribute2)
	-- cs1 tem attribute1 cs1.cells[1][attribute1] ~= nil
	-- attributes string
	-- cs2 tem attribute2

	if cs1 == nil then
		 mandatoryArgumentError("#1")
	elseif type(cs1) ~= "CellularSpace" then
		incompatibleTypeError("#1", "CellularSpace", cs1)
	end
	
	if cs2 == nil then
		 mandatoryArgumentError("#2")

	elseif type(cs2) ~= "CellularSpace" then
		incompatibleTypeError("#2", "CellularSpace", cs2)	
	end
	
	if attribute1 == nil then
		 mandatoryArgumentError("#3")

	elseif type(attribute1) ~= "string" then
		incompatibleTypeError("#3", "String", attribute1)
	end
	
	if attribute2 == nil then
		 mandatoryArgumentError("#4")
	elseif type(attribute2) ~= "string" then
		incompatibleTypeError("#4", "String", attribute2)
	end

	if cs1.cells[1][attribute1] == nil then
		customError("Attribute "..attribute1.." was not found in the CellularSpace.")
	
	end
	if cs2.cells[1][attribute2] == nil then
		customError("Attribute "..attribute2.." was not found in the CellularSpace.")
	
	end
	
	local counter = 0
	local dif = 0

	forEachCellPair(cs1, cs2, function(cell1, cell2) 
    	dif = dif + (cell1[attribute1] - cell2[attribute2])
		counter = counter + 1
	end)
	
	return dif/counter
	

	-- TODO: outras verificacoes

	-- TODO: calcula as diferencas pixel a pixel

	-- TODO: retorna a media
end

pixelByPixelString = function(cs1, cs2, attribute1, attribute2)
	-- cs1 tem attribute1 cs1.cells[1][attribute1] ~= nil
	-- attributes string
	-- cs2 tem attribute2

	
	
	if cs1 == nil then
		 mandatoryArgumentError("#1")

	elseif type(cs1) ~= "CellularSpace" then
		incompatibleTypeError("#1", "CellularSpace", cs1)
	end
	
	if cs2 == nil then
		 mandatoryArgumentError("#2")

	elseif type(cs2) ~= "CellularSpace" then
		incompatibleTypeError("#2", "CellularSpace", cs2)	
	end
	
	if attribute1 == nil then
		 mandatoryArgumentError("#3")

	elseif type(attribute1) ~= "string" then
		incompatibleTypeError("#3", "string", attribute1)
	end
	
	if attribute2 == nil then
		 mandatoryArgumentError("#4")
	elseif type(attribute2) ~= "string" then
		incompatibleTypeError("#4", "string", attribute2)
	end

	if cs1.cells[1][attribute1] == nil then
		customError("Attribute "..attribute1.." was not found in the CellularSpace.")
	
	end
	if cs2.cells[1][attribute2] == nil then
		customError("Attribute "..attribute2.." was not found in the CellularSpace.")
	
	end
	
	
	local counter = 0
	local equal = 0

	forEachCellPair(cs1, cs2, function(cell1, cell2) 
    		if cell1[attribute1] == cell2[attribute2] then
			equal = equal + 1		
		end
		counter = counter + 1
	end)
	
	return equal/counter
end

multiLevel = function(cs1, cs2, attribute)
	if cs1 == nil then
		 mandatoryArgumentError("#1")
	elseif type(cs1) ~= "CellularSpace" then
		incompatibleTypeError("#1", "CellularSpace", cs1)
	end
	
	if cs2 == nil then
		 mandatoryArgumentError("#2")
	elseif type(cs2) ~= "CellularSpace" then
		incompatibleTypeError("#2", "CellularSpace", cs2)	
	end
	
	if attribute == nil then
		 mandatoryArgumentError("#3")
	elseif type(attribute) ~= "string" then
		incompatibleTypeError("#3", "string", attribute1)
	end
	-- cs1 tem attribute1
	-- cs2 tem attribute2
end

multiLevelDemand = function(cs1, cs2, attribute, demand)
	-- cs1 tem attribute1
	-- cs2 tem attribute2
	-- demand > 0

	if cs1 == nil then
		 mandatoryArgumentError("#1")
	elseif type(cs1) ~= "CellularSpace" then
		incompatibleTypeError("#1", "CellularSpace", cs1)
	end
	
	if cs2 == nil then
		 mandatoryArgumentError("#2")
	elseif type(cs2) ~= "CellularSpace" then
		incompatibleTypeError("#2", "CellularSpace", cs2)	
	end
	
	if attribute == nil then
		 mandatoryArgumentError("#3")
	elseif type(attribute) ~= "string" then
		incompatibleTypeError("#3", "string", attribute1)
	end
	
	if demand == nil then
		mandatoryArgumentError("#4")
	elseif type(demand) ~= "number" then
		incompatibleTypeError("#4", "number", demand)
		 
	elseif demand <= 0 then
		customError("Demand should be bigger than 0.")		
	end
end

