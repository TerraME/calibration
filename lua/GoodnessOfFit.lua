
--@header Goodness-of-fit metrics.

--- Compares two CelluarSpace pixel by pixel and returns
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
-- @arg continuous boolean that indicates if the model is continuous
-- (default: false, discrete model).
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

local newDiscreteSquareBySquare = function(step, cs1, cs2, attribute)
 -- function that returns the fitness of a particular dimxdim Costanza square.
	local squareTotalFit = 0
	local forCounter = 0
	local t1, t2
	-- These variable are adjustments so the function works on
	-- cellular spaces with different formats and starting points.
	local maxRow =cs1.maxRow
	local maxCol =cs1.maxCol
	local dim = step + 1
	local lastRow = (maxRow - step + cs1.minRow)
	local lastCol = (maxCol - step + cs1.minCol)
	local stepx = step
	local stepy = step
	if step > maxCol then
		lastCol = 0
		stepx = step - (step - maxCol)
	end

	if step > maxRow then
		lastRow = 0
		stepy = step - (step - maxRow)
		if stepx == step - 1 then
			return -1
		end
	end

	for i = cs1.minRow, lastRow do -- for each line
		for j = cs1.minCol, lastCol do -- for each column
			forCounter = forCounter + 1
			t1 = Trajectory{ -- select all elements belonging to the dim x dim square in cs1,
			-- starting from the element in colum j and line x.
				target = cs1,
				select = function(cell) return (cell.x <= stepx + j)
				 and (cell.y <= stepy + i) and (cell.x >= j) and (cell.y >= i) end
			}
			t2 = Trajectory{ 
			-- select all elements belonging to the dim x dim square in cs1, 
			-- starting from the element in colum j and line x.
				target = cs2,
				select = function(cell) return (cell.x <= stepx + j)
				 and (cell.y <= stepy + i) and (cell.x >= j) and (cell.y >= i ) end
			}
			local counter1 = {}
			local counter2 = {}
			local sizet = 0
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
					if counter2[value2] == nil then
							counter2[value2] = 1
					else
						counter2[value2] = counter2[value2] + 1
					end

					if counter1[value2] == nil then
						counter1[value2] = 0
					end
			end)

			local squareDif = 0
			local squareFit = 0
			local dif = 0
			forEachElement(counter1, function(idx, value)
				dif = math.abs(value - counter2[idx]) + dif
			end)

			squareDif = dif / (2 * eachCellCounter)
			squareFit = 1 - squareDif -- calculate a particular dimxdim square fitness
			squareTotalFit = squareTotalFit + squareFit -- calculates the fitness of all dimxdim squares
		end
	end

	return squareTotalFit / forCounter 
	-- returns the fitness of all the squares divided by the number of squares.
end

local continuousSquareBySquare = function(step, cs1, cs2, attribute)
 -- function that returns the fitness of a particular dimxdim Costanza square.
	local squareTotalFit = 0
	local forCounter = 0
	local t1, t2
	-- These variable are adjustments so the function works on
	-- cellular spaces with different formats and starting points.
	local maxRow =cs1.maxRow
	local maxCol =cs1.maxCol
	local lastRow = (maxRow - step + cs1.minRow)
	local lastCol = (maxCol - step + cs1.minCol)
	local stepx = step
	local stepy = step
	if step > maxCol then
		lastCol = 0
		stepx = step - (step - maxCol)
	end

	if step > maxRow then
		lastRow = 0
		stepy = step - (step - maxRow)
		if stepx == step - 1 then
			return -1
		end
	end

	for i = cs1.minRow, lastRow do -- for each line
		for j = cs1.minCol, lastCol do -- for each column
			forCounter = forCounter + 1	
			t1 = Trajectory{ -- select all elements belonging to the dim x dim square in cs1,
			-- starting from the element in colum j and line x.
				target = cs1,
				select = function(cell) return (cell.x <= stepx + j)
				 and (cell.y <= stepy + i) and (cell.x >= j) and (cell.y >= i) end
			}
			t2 = Trajectory{ 
			-- select all elements belonging to the dim x dim square in cs1, 
			-- starting from the element in colum j and line x.
				target = cs2,
				select = function(cell) return (cell.x <= stepx + j)
				 and (cell.y <= stepy + i) and (cell.x >= j) and (cell.y >= i ) end
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
			local squareDif = 0
			local squareFit = 0
			dif = math.abs(counter1 - counter2)
			squareDif = dif / (counter2 + counter1)
			squareFit = 1 - squareDif -- calculate a particular dimxdim square fitness
			squareTotalFit = squareTotalFit + squareFit -- calculates the fitness of all dimxdim squares

		end
	end

	return squareTotalFit / forCounter 
	-- returns the fitness of all the squares divided by the number of squares.
end

--- Compares two CelluarSpace according to the calibration method described in Costanza's
-- paper and returns a number with the average precision between the values of both CelluarSpace.
-- If discrete:
-- The precision is calculated by comparing the CelluarSpace using the pixelByPixel 
-- function, each time considering a square ixi as a single pixel in the function,
-- without overlaping squares and not ignoring pixels that does not fit the ixi square.
-- The final result is the sum of the precisions, for ixi from 1x1 until (maxCol)x(maxRow),
-- divided by (maxCol * maxRow). If both maps are equal, the final result will be 1.
-- If continuous:
-- The difference is calculated by comparing the CelluarSpace using the pixelByPixel
-- function, each time considering a square ixi as a single pixel in the function.
-- The precision of each square is (1 - difference).
-- The final result is the sum of the precisions, for ixi from 1x1 until (maxCol)x(maxRow), 
-- divided by (maxCol * maxRow). If both maps are equal, the final result will be 1.
-- @arg data A table with the described values.
-- @arg data.cs1 First Cellular Space.
-- @arg data.cs2 Second Cellular Space.
-- @arg data.attribute An attribute present in both cellular space, which values should be compared.
-- @arg data.continuous Boolean that indicates if the model to be calibrated is continuous.
-- @arg data.graphics Boolean argument that indicates whether or not to draw a Chart with each square fitness.
-- (Default = False, discrete model).
-- @usage multiLevel{cs1, cs2, "attribute"}
multiLevel = function(data)
	mandatoryArgument(1, "table", data)
	mandatoryTableArgument(data, "cs1", "CellularSpace")
	mandatoryTableArgument(data, "cs2", "CellularSpace")
	mandatoryTableArgument(data, "attribute", "string")
	verify(#data.cs1 == #data.cs2, "Number of cells in both cellular spaces must be equal")

	local k = 0.1 -- value that determinate weigth for each square calibration
	local exp = 1 -- that will be used in the final fitness calibration
	-- fitnessSum is the Sum of all the fitness from each square ixi , it is being initialized as 
	-- the fitness of the 1x1 square.
	local largerSquare = 0
	local minSquare = 0
	if data.cs1.maxRow > data.cs1.maxCol then
	-- Determines of the size of the smallest square possible containig all the map elements.
		largerSquare = data.cs1.maxRow
	else
		largerSquare = data.cs1.maxCol
	end

	if data.cs1.minRow < data.cs1.minCol then
	--Determines if the model starts at [0] or [1].
		minSquare = data.cs1.minRow
	else
		minSquare = data.cs1.minCol
	end

	local fitnessSum = pixelByPixel(data.cs1, data.cs2, data.attribute, data.attribute, data.continuous)
	local fitChart = {sqrFit = fitnessSum}
	if data.graphics == true then
		Chart{
			title = "MultiLevel Results",
			target = fitChart,
		 	select = {"sqrFit"}
		}
		fitChart:notify(0)
	end

	if data.continuous == true then
		for i = 1, (largerSquare) do 
		-- increase the square size and calculate fitness for each square.
			local fitSquare = continuousSquareBySquare(i, data.cs1, data.cs2, data.attribute)
			if fitSquare ~= -1 then
				if data.graphics == true then
					fitChart.sqrFit = fitSquare
					fitChart:notify(i)
				end

				fitnessSum = fitnessSum + (fitSquare * math.exp(-k * math.pow(2 , i - 1)))
				exp = exp + math.exp(-k * math.pow(2 , i - 1))
			end
		end

	else
		for i = 1, (largerSquare) do 
			-- increase the square size and calculate fitness for each square.
			local fitSquare = newDiscreteSquareBySquare(i, data.cs1, data.cs2, data.attribute) 
			if fitSquare ~= -1 then
				if data.graphics == true then
					fitChart.sqrFit = fitSquare
					fitChart:notify(i)
				end

				fitnessSum = fitnessSum + (fitSquare * math.exp(-k * math.pow(2 , i - 1)))
				exp = exp + math.exp(-k * math.pow(2 , i - 1))
			end
		end
	end

	local fitness = fitnessSum / exp
	return fitness
end
