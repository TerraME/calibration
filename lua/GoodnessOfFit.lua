
--@header Goodness-of-fit metrics.

local function pixelByPixelContinuous(cs1, cs2, attribute1, attribute2)
	local counter = 0
	local dif = 0

	local mtype = type(cs1:sample()[attribute1])
	verify(mtype == "number", "Attribute '"..attribute1.."' should a number, got "..mtype..".")

	mtype = type(cs2:sample()[attribute2])
	verify(mtype == "number", "Attribute '"..attribute2.."' should a number, got "..mtype..".")

	forEachCellPair(cs1, cs2, function(cell1, cell2)
		dif = dif + (math.abs(cell1[attribute1] - cell2[attribute2]))
		counter = counter + 1
	end)

	return (1 - dif / counter)
end

local function pixelByPixelDiscrete(cs1, cs2, attribute1, attribute2)
	local counter = 0
	local equal = 0

	local mtype = type(cs1:sample()[attribute1])
	verify(mtype == "number" or mtype == "string", "Attribute '"..attribute1.."' should number or string, got "..mtype..".")

	mtype = type(cs2:sample()[attribute2])
	verify(mtype == "number" or mtype == "string", "Attribute '"..attribute2.."' should number or string, got "..mtype..".")

	forEachCellPair(cs1, cs2, function(cell1, cell2)
		if cell1[attribute1] == cell2[attribute2] then
			equal = equal + 1
		end

		counter = counter + 1
	end)

	return equal / counter
end

--- Compares two CelluarSpaces using a pixel by pixel strategy.
-- It returns a number with the average difference of the values in each cell of both CelluarSpaces.
-- When the attributes are discrete, the difference between two cells will be zero when they have
-- the same value or one if not.  If all the values are equal, the output will be one.
-- If they are completely different, it will be zero.
-- When the attributes are continuous, the difference between
-- the two values will be used. In this case, the returned value is the average of all
-- differences.
-- @arg data.target A base::CellularSpace or a table with two CellularSpaces.
-- @arg data.select A vector of strings with the names of the attributes to be compared.
-- They must follow the same order of data.target: the first attribute is related to the
-- first CellularSpace and so for the second one. When the target is a single CellularSpace,
-- the two attributes must belong to it.
-- It can also be a single string, when comparing the same attribute name in both CellularSpaces.
-- @arg data.discrete A boolean value indicating whether the values are discrete. The default value
-- is false, meaning that the atributes are continuous.
-- @usage import("calibration")
--
-- cell = Cell{a = 0.8, b = 0.7}
-- cs = CellularSpace{xdim = 10, instance = cell}
--
-- result = pixelByPixel{
--     target = cs,
--     select = {"a", "b"}
-- }
--
-- print(result)
function pixelByPixel(data)
	verifyNamedTable(data)

	defaultTableValue(data, "discrete", false)

	if type(data.target) == "CellularSpace" then
		data.target = {data.target, data.target}
	elseif type(data.target) == "table" and #data.target == 2 then
		local mtype = type(data.target[1])
		verify(mtype == "CellularSpace", "First element of 'target' should be a CellularSpace, got "..mtype..".")

		mtype = type(data.target[2])
		verify(mtype == "CellularSpace", "Second element of 'target' should be a CellularSpace, got "..mtype..".")
	else
		customError("Argument 'target' must be a CellularSpace or a table with two CellularSpaces.")
	end

	if type(data.select) == "string" then
		data.select = {data.select, data.select}
	elseif type(data.select) == "table" and #data.select == 2 then
		local mtype = type(data.select[1])
		verify(mtype == "string", "First element of 'select' should be a string, got "..mtype..".")

		mtype = type(data.select[2])
		verify(mtype == "string", "Second element of 'select' should be a string, got "..mtype..".")
	else
		customError("Argument 'select' must be a string or a table with two strings.")
	end

	local cs1 = data.target[1]
	local cs2 = data.target[2]
	local attribute1 = data.select[1]
	local attribute2 = data.select[2]

	if cs1 == cs2 and attribute1 == attribute2 then
		customError("When using a single CellularSpace, the selected attributes must be different.")
	end

	verify(#cs1 == #cs2, "Number of cells in both CellularSpaces must be equal.")
	verify(cs1:sample()[attribute1] ~= nil, "Attribute '"..attribute1.."' does not exist in the first CellularSpace.")
	verify(cs2:sample()[attribute2] ~= nil, "Attribute '"..attribute2.."' does not exist in the second CellularSpace.")

	if data.discrete then
		return pixelByPixelDiscrete(cs1, cs2, attribute1, attribute2)
	else
		return pixelByPixelContinuous(cs1, cs2, attribute1, attribute2)
	end
end

local newDiscreteSquareBySquare = function(step, cs1, cs2, attribute)
	-- function that returns the fitness of a particular dimxdim Costanza square.
	local squareTotalFit = 0
	local forCounter = 0
	local t1, t2
	-- These variable are adjustments so the function works on
	-- cellular spaces with different formats and starting points.
	local yMax =cs1.yMax
	local xMax =cs1.xMax
	local lastRow = (yMax - step + cs1.yMin)
	local lastCol = (xMax - step + cs1.xMin)
	local stepx = step
	local stepy = step
	if step > xMax then
		lastCol = 0
		stepx = step - (step - xMax)
	end

	if step > yMax then
		lastRow = 0
		stepy = step - (step - yMax)
		if stepx == step - 1 then
			return -1
		end
	end

	for i = cs1.yMin, lastRow do -- for each line
		for j = cs1.xMin, lastCol do -- for each column
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

			local squareDif
			local squareFit
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
	local yMax =cs1.yMax
	local xMax =cs1.xMax
	local lastRow = (yMax - step + cs1.yMin)
	local lastCol = (xMax - step + cs1.xMin)
	local stepx = step
	local stepy = step
	if step > xMax then
		lastCol = 0
		stepx = step - (step - xMax)
	end

	if step > yMax then
		lastRow = 0
		stepy = step - (step - yMax)
		if stepx == step - 1 then
			return -1
		end
	end

	for i = cs1.yMin, lastRow do -- for each line
		for j = cs1.xMin, lastCol do -- for each column
			forCounter = forCounter + 1
			t1 = Trajectory{ -- select all elements belonging to the dim x dim square in cs1,
			-- starting from the element in colum j and line x.
				target = cs1,
				select = function(cell)
					return (cell.x <= stepx + j) and (cell.y <= stepy + i) and (cell.x >= j) and (cell.y >= i)
				end
			}
			t2 = Trajectory{
			-- select all elements belonging to the dim x dim square in cs1,
			-- starting from the element in colum j and line x.
				target = cs2,
				select = function(cell)
					return (cell.x <= stepx + j) and (cell.y <= stepy + i) and (cell.x >= j) and (cell.y >= i)
				end
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

			local dif
			local squareDif
			local squareFit
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
-- @arg data.cs1 First Cellular Space.
-- @arg data.cs2 Second Cellular Space.
-- @arg data.attribute An attribute present in both cellular space, which values should be compared.
-- @arg data.continuous Boolean that indicates if the model to be calibrated is continuous.
-- @arg data.graphics Boolean argument that indicates whether or not to draw a Chart with each square fitness.
-- (Default = False, discrete model).
-- @usage
-- import("calibration")
-- cs = CellularSpace{
--     file = filePath("Costanza.pgm", "calibration"),
--     attrname = "Costanza"
-- }
--
-- cs2 = CellularSpace{
--     file = filePath("Costanza2.pgm", "calibration"),
--     attrname = "Costanza"
-- }
--
-- multiLevel{cs1 = cs, cs2 = cs2, attribute = "Costanza", continuous = false, graphics = true}
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
	local largerSquare
	if data.cs1.yMax > data.cs1.xMax then
	-- Determines of the size of the smallest square possible containig all the map elements.
		largerSquare = data.cs1.yMax
	else
		largerSquare = data.cs1.xMax
	end

	local continuous = data.continuous
	local discrete = not data.continuous

	if not discrete then discrete = nil end

	local fitnessSum = pixelByPixel{
		target = {data.cs1, data.cs2},
		select = {data.attribute, data.attribute},
		discrete = discrete
	}

	local fitSquareTable = {}
	local resolutionTable = {}
	table.insert(fitSquareTable, fitnessSum)
	table.insert(resolutionTable, 0)
	if continuous then
		for i = 1, (largerSquare) do
		-- increase the square size and calculate fitness for each square.
			local fitSquare = continuousSquareBySquare(i, data.cs1, data.cs2, data.attribute)
			if fitSquare ~= -1 then
				table.insert(fitSquareTable, fitSquare)
				table.insert(resolutionTable, i)
				fitnessSum = fitnessSum + (fitSquare * math.exp(-k * 2 ^ (i - 1)))
				exp = exp + math.exp(-k * 2 ^ (i - 1))
			end
		end
	else
		for i = 1, (largerSquare) do
			-- increase the square size and calculate fitness for each square.
			local fitSquare = newDiscreteSquareBySquare(i, data.cs1, data.cs2, data.attribute)
			if fitSquare ~= -1 then
				table.insert(fitSquareTable, fitSquare)
				table.insert(resolutionTable, i)
				fitnessSum = fitnessSum + (fitSquare * math.exp(-k * 2 ^ (i - 1)))
				exp = exp + math.exp(-k * 2 ^ (i - 1))
			end
		end
	end

	local fitness = fitnessSum / exp
	local df = DataFrame{fit = fitSquareTable, resolution = resolutionTable}
	return fitness, df
end

--- Calculates the summation of the difference of squares between two tables of a table.
-- @arg data A named table formed by other tables.
-- @arg attribute1 The attribute corresponding to the first table in table data.
-- @arg attribute2 The attribute corresponding to the second table in table data.
-- @usage import("calibration")
-- data = {a = {1, 2, 3, 4, 5}, b = {5, 4, 3, 2, 1}}
-- sumOfSquares(data, "a", "b")
function sumOfSquares(data, attribute1, attribute2)
	mandatoryArgument(1, "table", data)
	mandatoryArgument(2, "string", attribute1)
	mandatoryArgument(3, "string", attribute2)
	mandatoryTableArgument(data, attribute1, "table")
	mandatoryTableArgument(data, attribute2, "table")
	if #data[attribute1] ~= #data[attribute2] then
		customError("Tables '"..attribute1.."' and '"..attribute2.."' must have the same size, got "..#data[attribute1].." ('"..attribute1.."') and "..#data[attribute2].." ('"..attribute2.."').")
	end

	local sum = 0
	for i = 1, #data[attribute1] do
		sum = sum + (data[attribute1][i] - data[attribute2][i]) ^ 2
	end

	return sum
end

