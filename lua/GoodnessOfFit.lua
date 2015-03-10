
--@header Goodness-of-fit metrics.

--- Compares two continuous CelluarSpace pixel by pixel and returns
-- a number with the average precision between the values in each cell of both CelluarSpace.
-- This precision is either 1 or 0, it's 1 if both values are equal and 0 if they aren't.
-- If both maps are equal, the final result will be 1.
-- If it's continuous:
-- The difference is calculated by subtracting the value of a cell in the first cellular space,
-- with the value of the same cell in the second cellular space. 
-- And the precision of each cell is (1 - difference).
-- The final result is the sum of the precisions divided by the number of cells
-- If it's discrete:
-- This precision is either 1 or 0, it's 1 if both values are equal and 0 if they aren't equal.
-- The final result is the sum of the precisions divided by the number of cells in the CelluarSpace.
-- in the CelluarSpace.
-- @arg cs1 First Cellular Space.
-- @arg cs2 Second Cellular Space.
-- @arg attribute1 attribute from the first cellular space that should be compared.
-- @arg attribute2 attribute from the second cellular space that should be compared.
-- @arg continuous boolean that indicates if the model is continuous. 
-- (default: false, discrete model)
-- @usage pixelByPixel(cs1, cs2, "attribute1", "attribute2")
function pixelByPixel(cs1, cs2, attribute1, attribute2, continuous)
	mandatoryArgument(1, "CellularSpace", cs1)
	mandatoryArgument(2, "CellularSpace", cs2)
	verify(#cs1 == #cs2, "Number of cells in both cellular spaces must be equal")
	mandatoryArgument(3, "string", attribute1)
	mandatoryArgument(4, "string", attribute2)
	verify(cs1.cells[1][attribute1] ~= nil, "Attribute "..attribute1.." was not found in the CellularSpace.")
	verify(cs2.cells[1][attribute2] ~= nil, "Attribute "..attribute2.." was not found in the CellularSpace.")
	local counter = 0
	local dif = 0
	local equal = 0
	if continuous == true then
		forEachCellPair(cs1, cs2, function(cell1, cell2) 
			verify(type(cell1[attribute1]) == "number", "cell1["..attribute1.."] is not a number")

			verify(type(cell2[attribute2]) == "number", "cell2["..attribute2.."] is not a number")

	    	dif = dif + (math.abs(cell1[attribute1] - cell2[attribute2]))
			counter = counter + 1
		end)
		return (1 - dif / counter)
	else
		forEachCellPair(cs1, cs2, function(cell1, cell2)
			verify(type(cell1[attribute1]) == "number" or type(cell1[attribute1]) == "string", "cell1["..attribute1.."] must be a number or string")
			verify(type(cell2[attribute2]) == "number" or type(cell2[attribute2]) == "string", "cell2["..attribute2.."] must be a number or string")
    		
    		if cell1[attribute1] == cell2[attribute2] then
				equal = equal + 1		
			end

			counter = counter + 1
		end)
		return equal / counter
	end
end

local discreteSquareBySquare = function(dim, cs1, cs2, attribute) 
-- function that returns the fitness of a particular dimxdim Costanza square.
	local squareTotalFit = 0
	local squareDif = 0
	local squareFit = 0
	local squareTotalFit = 0
	local forCounter = 0
	local t1, t2
	for i = cs1.minRow, ((cs1.maxRow - dim) + 1) do -- for each line
		for j = cs1.minCol, ((cs1.maxCol - dim) + 1) do -- for each column
			forCounter = forCounter + 1 -- counter for the total number of squares
			t1 = Trajectory{ 
			-- select all elements belonging to the dim x dim  square  in cs1,
			-- starting from the element in colum j and line x.
				target = cs1,
				select = function(cell) return (cell.x < dim + j) 
				and (cell.y < dim + i) and (cell.x >= j) and (cell.y >=  i) end
			}
			t2 = Trajectory{ 
			-- select all elements belonging to the dim x dim  square  in cs1,
			-- starting from the element in colum j and line x.
				target = cs2,
				select = function(cell) return (cell.x < dim + j) 
				and (cell.y < dim + i) and (cell.x >= j) and (cell.y >=  i ) end
			}
			local counter1 = {}
			local counter2 = {}
			forEachCell(t1, function(cell1)  
			-- calculate the number of times each value is present in current square
					local value1 = cell1[attribute]
		    		if counter1[value1] == nil then
						counter1[value1] = 1
					else
						counter1[value1] = counter1[value1] + 1
					end

					if counter2[value1] == nil then
						counter2[value1] = 0
					end
			end)

			forEachCell(t2, function(cell2) 
					local value2 = cell2[attribute]
		    		if counter2[value2] == nil then
							counter2[value2] = 1
					else
						counter2[value2] = counter2[value2] + 1
					end

					if counter1[value2] == nil then
						counter1[value2] = 0
					end
			end)

			local dif = 0
			forEachElement(counter1, function(idx, value)
			-- calculate the difference in the amount of times each value appears in each square.
				dif = math.abs(value - counter2[idx]) + dif
			end)

			squareDif = dif / (dim * dim * 2)
			squareFit = 1 - squareDif -- calculate a particular  dimxdim square fitness
			squareTotalFit = squareTotalFit + squareFit 
			-- calculates the fitness of all dimxdim squares
		end
	end

	return squareTotalFit / forCounter
	-- returns the fitness of all the squares divided by the number of squares.
end

--- Compares two discrete CelluarSpace according to the calibration method described in Costanza's
-- paper and returns a number with the average precision between the values of both CelluarSpace.
-- The precision is calculated by comparing the CelluarSpace using the pixelByPixel
-- function, each time considering a square ixi as a single pixel in the function, with overlaping 
-- squares and ignoring pixels that does not fit the ixi square.
-- The final result is the sum of the precisions, for ixi from 1x1 until (maxCol)x(maxRow), 
-- divided by (maxCol * maxRow). If both maps are equal, the final result will be 1.
-- @arg cs1 First Cellular Space.
-- @arg cs2 Second Cellular Space.
-- @arg attribute An attribute present in both cellular space, which values should be compared
-- @usage discreteCostanzaMultiLevel(cs1, cs2, "attribute")
discreteCostanzaMultiLevel = function(cs1, cs2, attribute)
	mandatoryArgument(1, "CellularSpace", cs1)
	mandatoryArgument(2, "CellularSpace", cs2)
	verify(#cs1 == #cs2, "Number of cells in both cellular spaces must be equal")
	mandatoryArgument(3, "string", attribute)
	local k = 0.1 -- value that determinate weigth for each square calibration
	local exp = 1
	local fitnessSum = pixelByPixel(cs1, cs2, attribute, attribute)
	-- fitnessSum is the Sum of all the fitness from each square ixi,
	-- it is being initialized as the fitness of the 1x1 square.
	local largerSquare = 0
	local minSquare = 0
	if cs1.maxRow > cs1.maxCol then
		largerSquare = cs1.maxRow
	else
		largerSquare = cs1.maxCol
	end

	if cs1.minRow < cs1.minCol then
		minSquare = cs1.minRow
	else
		minSquare = cs1.minCol
	end

	for i = 2, (largerSquare - minSquare + 1) do
	-- increase the square size and calculate fitness for each square.
	fitnessSum = fitnessSum + discreteSquareBySquare(i, cs1, cs2, attribute) * math.exp( - k * (i - 1))
	exp = exp + math.exp( - k * (i - 1))
	end

	local fitness = fitnessSum / exp 
	-- fitness = (fitness of all ixi squares)/ (number of ixi squares)
	return fitness
end

local newDiscreteSquareBySquare = function(dim, cs1, cs2, attribute)
 -- function that returns the fitness of a particular dimxdim Costanza square.
	local squareTotalFit = 0
	local squareDif = 0
	local squareFit = 0
	local squareTotalFit = 0
	local forCounter = 0
	local t1, t2
	for i = cs1.minRow, cs1.maxRow, dim do -- for each line
		for j = cs1.minCol, cs1.maxCol, dim do -- for each column
			forCounter = forCounter + 1
			t1 = Trajectory{ -- select all elements belonging to the dim x dim  square  in cs1,
			-- starting from the element in colum j and line x.
				target = cs1,
				select = function(cell) return (cell.x < dim + j)
				 and (cell.y < dim + i) and (cell.x >= j) and (cell.y >=  i) end
			}
			t2 = Trajectory{ 
			-- select all elements belonging to the dim x dim  square  in cs1, 
			-- starting from the element in colum j and line x.
				target = cs2,
				select = function(cell) return (cell.x < dim + j)
				 and (cell.y < dim + i) and (cell.x >= j) and (cell.y >=  i ) end
			}
			local counter1 = {}
			local counter2 = {}
			local eachCellCounter = 0
			forEachCell(t1, function(cell1) 
					local value1 = cell1[attribute]
					eachCellCounter = eachCellCounter + 1
		    		if counter1[value1] == nil then
						counter1[value1] = 1
					else
						counter1[value1] = counter1[value1] + 1
					end

					if counter2[value1] == nil then
						counter2[value1] = 0
					end
			end)

			forEachCell(t2, function(cell2) 
					local value2 = cell2[attribute]
					eachCellCounter = eachCellCounter + 1
		    		if counter2[value2] == nil then
							counter2[value2] = 1
					else
						counter2[value2] = counter2[value2] + 1
					end

					if counter1[value2] == nil then
						counter1[value2] = 0
					end
			end)

			local dif = 0
			forEachElement(counter1, function(idx, value)
				dif = math.abs(value - counter2[idx]) + dif
			end)

			squareDif = dif / (eachCellCounter)
			squareFit = 1 - squareDif -- calculate a particular  dimxdim square fitness
			squareTotalFit = squareTotalFit + squareFit -- calculates the fitness of all dimxdim squares
		end
	end

	return squareTotalFit / forCounter 
	-- returns the fitness of all the squares divided by the number of squares.
end

--- Compares two discrete CelluarSpace according to the calibration method described in Costanza's
-- paper and returns a number with the average precision between the values of both CelluarSpace.
-- The precision is calculated by comparing the CelluarSpace using the pixelByPixel 
-- function, each time considering a square ixi as a single pixel in the function,
-- without overlaping squares and not ignoring pixels that does not fit the ixi square.
-- The final result is the sum of the precisions, for ixi from 1x1 until (maxCol)x(maxRow),
-- divided by (maxCol * maxRow). If both maps are equal, the final result will be 1.
-- @arg cs1 First Cellular Space.
-- @arg cs2 Second Cellular Space.
-- @arg attribute An attribute present in both cellular space, which values should be compared
-- @usage newDiscreteCostanzaMultiLevel(cs1, cs2, "attribute")
newDiscreteCostanzaMultiLevel = function(cs1, cs2, attribute)
	mandatoryArgument(1, "CellularSpace", cs1)
	mandatoryArgument(2, "CellularSpace", cs2)
	verify(#cs1 == #cs2, "Number of cells in both cellular spaces must be equal")
	mandatoryArgument(3, "string", attribute)
	local k = 0.1 -- value that determinate weigth for each square calibration
	local exp = 1 -- that will be used in the final fitness calibration
	local fitnessSum = pixelByPixel(cs1, cs2, attribute, attribute) 
	-- fitnessSum is the Sum of all the fitness from each square ixi , it is being initialized as 
	-- the fitness of the 1x1 square.
	local largerSquare = 0
	local minSquare = 0
	if cs1.maxRow > cs1.maxCol then
		largerSquare = cs1.maxRow
	else
		largerSquare = cs1.maxCol
	end

	if cs1.minRow < cs1.minCol then
		minSquare = cs1.minRow
	else
		minSquare = cs1.minCol
	end

	for i = 2, (largerSquare - minSquare + 1) do 
			-- increase the square size and calculate fitness for each square.
			fitnessSum = fitnessSum + newDiscreteSquareBySquare(i, cs1, cs2, attribute) * math.exp( - k * (i - 1))
		exp = exp + math.exp( - k * (i - 1))
	end

	local fitness = fitnessSum / exp
	return fitness
end


local continuousSquareBySquare = function(dim, cs1, cs2, attribute)
 -- function that returns the fitness of a particular dimxdim Costanza square.
	local squareTotalFit = 0
	local squareDif = 0
	local squareFit = 0
	local squareTotalFit = 0
	local forCounter = 0
	local t1, t2
	for i = cs1.minRow, ((cs1.maxRow - dim) + 1) do -- for each line
		for j = cs1.minCol, ((cs1.maxCol - dim) + 1) do -- for each column
			forCounter = forCounter + 1
			t1 = Trajectory{ 
			-- select all elements belonging to the dim x dim  square  in cs1,
			-- starting from the element in colum j and line x.
				target = cs1,
				select = function(cell) return (cell.x < dim + j)
				 and (cell.y < dim + i) and (cell.x >= j) and (cell.y >=  i) end
			}
			t2 = Trajectory{
			-- select all elements belonging to the dim x dim  square  in cs1,
			-- starting from the element in colum j and line x.
				target = cs2,
				select = function(cell) return (cell.x < dim + j)
				 and (cell.y < dim + i) and (cell.x >= j) and (cell.y >=  i ) end
			}
			local counter1 = 0
			local counter2 = 0
			forEachCell(t1, function(cell1) 
					local value1 = cell1[attribute]
		    		counter1 = counter1 + value1
			end)

			forEachCell(t2, function(cell2) 
					local value2 = cell2[attribute]
		    		counter2 = counter2 + value2
			end)

			local dif = 0
			dif = math.abs(counter1 - counter2)
			squareDif = dif / (dim * dim)
			squareFit = 1 - squareDif -- calculate a particular  dimxdim square fitness
			squareTotalFit = squareTotalFit + squareFit 
			-- calculates the fitness of all dimxdim squares
		end
	end

	return squareTotalFit / forCounter
	-- returns the fitness of all the squares divided by the number of squares.
end

--- Compares two discrete CelluarSpace according to the calibration method described in Costanza's
-- paper and returns a number with the average precision between the values of both CelluarSpace.
-- The difference is calculated by comparing the CelluarSpace using the pixelByPixel
-- function, each time considering a square ixi as a single pixel in the function.
-- The precision of each square is (1 - difference).
-- The final result is the sum of the differences, for ixi from 1x1 until (maxCol)x(maxRow), 
-- divided by (maxCol * maxRow). If both maps are equal, the final result will be 1.
-- @arg cs1 First Cellular Space.
-- @arg cs2 Second Cellular Space.
-- @arg attribute An attribute present in both cellular space, which values should be compared.
-- @usage continuousCostanzaMultiLevel(cs1, cs2, "attribute")
continuousCostanzaMultiLevel = function(cs1, cs2, attribute)
	mandatoryArgument(1, "CellularSpace", cs1)
	mandatoryArgument(2, "CellularSpace", cs2)
	mandatoryArgument(3, "string", attribute)
	verify(#cs1 == #cs2, "Number of cells in both cellular spaces must be equal")
	local k = 0.1 -- value that determinate weigth for each square calibration
	local exp = 1
	local fitnessSum = pixelByPixel(cs1, cs2, attribute, attribute, continuous) 
	-- fitnessSum is the Sum of all the fitness from each square ixi ,
	-- it is being initialized as the fitnisess of the 1x1 square.
	local largerSquare = 0
	local minSquare = 0
	if cs1.maxRow > cs1.maxCol then
		largerSquare = cs1.maxRow
	else
		largerSquare = cs1.maxCol
	end

	if cs1.minRow < cs1.minCol then
		minSquare = cs1.minRow
	else
		minSquare = cs1.minCol
	end

	for i = 2, (largerSquare - minSquare + 1) do 
	-- increase the square size and calculate fitness for each square.
	fitnessSum = fitnessSum + continuousSquareBySquare(i, cs1, cs2, attribute) * math.exp( - k * (i - 1))
	exp = exp + math.exp( - k * (i - 1))
	end
	
	local fitness = fitnessSum / exp
	return fitness
end