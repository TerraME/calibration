
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

local function verifyBasicArguments(data)
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
	verifyBasicArguments(data)

	verifyUnnecessaryArguments(data, {"target", "select", "discrete"})

	local cs1 = data.target[1]
	local cs2 = data.target[2]
	local attribute1 = data.select[1]
	local attribute2 = data.select[2]

	if data.discrete then
		return pixelByPixelDiscrete(cs1, cs2, attribute1, attribute2)
	else
		return pixelByPixelContinuous(cs1, cs2, attribute1, attribute2)
	end
end

local function discreteSquareBySquare(step, cs1, cs2, attribute1, attribute2, minSquare, maxSquare)
	local sumfit = 0
	local quantity = 0

	for beginX = minSquare, maxSquare - step + 1 do
		for beginY = minSquare, maxSquare - step + 1 do
			-- tables with the counts of each value in each space
			local values1 = {}
			local values2 = {}

			local cellsInTheBlock = 0

			-- trasverse the block [beginX, beginY] to [beginX + step - 1, beginY + step - 1]
			for cx = beginX, beginX + step - 1 do
				for cy = beginY, beginY + step - 1 do

					local cell1 = cs1:get(cx, cy)

					if cell1 then
						cellsInTheBlock = cellsInTheBlock + 1

						local value = cell1[attribute1]

						if not values1[value] then values1[value] = 0 end
						if not values2[value] then values2[value] = 0 end

						values1[value] = values1[value] + 1
					end

					local cell2 = cs2:get(cx, cy)

					if cell2 then
						local value = cell2[attribute2]

						if not values1[value] then values1[value] = 0 end
						if not values2[value] then values2[value] = 0 end

						values2[value] = values2[value] + 1
					end
				end
			end

			local err = 0

			forEachElement(values1, function(idx, value1)
				err = err + math.abs(values2[idx] - value1)
			end)

			if cellsInTheBlock > 0 then
				sumfit = sumfit + (1 - err / (2 * cellsInTheBlock))

				quantity = quantity + 1
			end
		end
	end

	return sumfit / quantity
end

local function continuousSquareBySquare(step, cs1, cs2, attribute1, attribute2, minSquare, maxSquare)
	local err = 0

	for beginX = minSquare, maxSquare - step + 1 do
		for beginY = minSquare, maxSquare - step + 1 do
			-- tables with the counts of each value in each space
			local values1 = 0
			local values2 = 0

			-- trasverse the block [beginX, beginY] to [beginX + step - 1, beginY + step - 1]
			for cx = beginX, beginX + step - 1 do
				for cy = beginY, beginY + step - 1 do

					local cell1 = cs1:get(cx, cy)

					if cell1 then
						values1 = values1 + cell1[attribute1]
					end

					local cell2 = cs2:get(cx, cy)

					if cell2 then
						values2 = values2 + cell2[attribute2]
					end
				end
			end

			if values1 > 0 or values2 > 0 then
				err = err + math.abs(values1 - values2) / math.max(values1, values2)
			end
		end
	end

	local fit = 1 - (err / #cs1)

	return fit
end

--- Compares two CelluarSpace according to the calibration method described in Costanza's
-- paper. It returns a number with the average precision between the values of both CelluarSpaces.
-- Source: Costanza R. Model goodness of fit: a multiple resolution procedure. Ecological modelling.
-- 1989 Sep 15;47(3-4):199-215.
-- @arg data.target A base::CellularSpace or a table with two CellularSpaces.
-- @arg data.select A vector of strings with the names of the attributes to be compared.
-- They must follow the same order of data.target: the first attribute is related to the
-- first CellularSpace and so for the second one. When the target is a single CellularSpace,
-- the two attributes must belong to it.
-- It can also be a single string, when comparing the same attribute name in both CellularSpaces.
-- @arg data.discrete A boolean value indicating whether the values are discrete. The default value
-- is false, meaning that the atributes are continuous.
-- @arg data.k Value that determines the weigth for each square calibration. The default value is 0.1.
-- @arg data.log Value indicating whether the levels should be computed using log scale: 1, 2, 4, ... until
-- the maximum length in both directions. The default value (fales) means that all levels will be computed:
-- 1, 2, 3, ... until the maximum length in both directions.
-- @usage import("calibration")
--
-- cs1 = CellularSpace{
--     file = filePath("costanza.pgm", "calibration"),
--     attrname = "costanza"
-- }
--
-- cs2 = CellularSpace{
--     file = filePath("costanza2.pgm", "calibration"),
--     attrname = "costanza"
-- }
--
-- multiLevel{
--     target = {cs1, cs2},
--     select = "costanza",
--     discrete = true
-- }
function multiLevel(data)
	verifyBasicArguments(data)

	defaultTableValue(data, "k", 0.1)
	defaultTableValue(data, "log", false)

	verifyUnnecessaryArguments(data, {"target", "select", "discrete", "k", "log"})

	local k = data.k
	local cs1 = data.target[1]
	local cs2 = data.target[2]
	local attribute1 = data.select[1]
	local attribute2 = data.select[2]

	local maxSquare = cs1.xMax - cs1.xMin + 1
	local ySize = cs1.yMax - cs1.yMin + 1
	if maxSquare <= ySize then -- <= to force the next line to be executed
		maxSquare = ySize
	end

	local minSquare = cs1.xMin
	if minSquare >= cs1.yMin then -- >= to force the next line to be executed
		minSquare = cs1.yMin
	end

	local fitnessSum = 0
	local exp = 0

	local fitSquareTable = {}
	local resolutionTable = {}
	local expTable = {}
	if data.discrete then
		local i = 1
		while i <= maxSquare do
			-- increase the square size and calculate fitness for each square.
			local fitSquare = discreteSquareBySquare(i, cs1, cs2, attribute1, attribute2, minSquare, maxSquare)
			if fitSquare ~= -1 then
				table.insert(fitSquareTable, fitSquare)
				table.insert(resolutionTable, i)
				local myexp = math.exp(-k * (i - 1))
				table.insert(expTable, myexp)
				fitnessSum = fitnessSum + (fitSquare * myexp)
				exp = exp + myexp
			end

			if data.log then
				if i == maxSquare then
					i = i + 1
				else
					i = i * 2

					if i > maxSquare then i = maxSquare end
				end
			else
				i = i + 1
			end
		end
	else
		local i = 1
		while i <= maxSquare do
			-- increase the square size and calculate fitness for each square.
			local fitSquare = continuousSquareBySquare(i, cs1, cs2, attribute1, attribute2, minSquare, maxSquare)
			if fitSquare ~= -1 then
				table.insert(fitSquareTable, fitSquare)
				table.insert(resolutionTable, i)
				local myexp = math.exp(-k * (i - 1))
				table.insert(expTable, myexp)
				fitnessSum = fitnessSum + (fitSquare * myexp)
				exp = exp + myexp
			end

			if data.log then
				if i == maxSquare then
					i = i + 1
				else
					i = i * 2

					if i > maxSquare then i = maxSquare end
				end
			else
				i = i + 1
			end
		end
	end

	local fitness = fitnessSum / exp
	local df = DataFrame{fit = fitSquareTable, resolution = resolutionTable, exp = expTable}
	return fitness, df
end

--- Calculates the sum of the difference of squares between two tables of a table.
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

