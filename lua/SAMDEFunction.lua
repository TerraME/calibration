-------------------------------------------------------------
----                 Algorithm SaMDE                     ----
----           Implement by: Rodolfo A. Lopes            ----
---		 Adapted for TerraME by Antonio G. O. Junior	 ----
-------------------------------------------------------------
GLOBAL_RANDOM_SEED = os.time()
NUMEST = 4
PARAMETERS = 3
local function evaluate(ind, dim, model, paramList, fit, finalTime)
	local solution = {}
	for i = 1, dim do
		solution[paramList[i]] = ind[i]
	end
	solution["finalTime"] = finalTime
	local m = model(solution)
	m:execute()
	local err = fit(m)
	return err
end

local function initPop(popTam, varMatrix, dim, paramList, paramInfo)
	math.randomseed(GLOBAL_RANDOM_SEED)
	-- print("initializing population ...");
	local popInit = {}
	for i = 1, popTam do
		local ind = {}
		for j = 1, dim do
			local value
			if paramInfo[j].group == false then
				local lim = varMatrix[j]
				local minVar = lim[1]
				local maxVar = lim[2]
				value = minVar + (math.random() * (maxVar - minVar))
			else
				value = varMatrix[j][math.random(1,#varMatrix[j])]
			end

			table.insert(ind, value)
		end

		for j = (dim + 1), (dim + NUMEST * PARAMETERS) do
			local value = math.random()
			table.insert(ind, value)
		end

		table.insert(popInit, ind)
	end

	return popInit
end

local function g3Rand(i,popTam)
	local rands = {}
	local a,b,c
	repeat
		a = math.random(1, popTam)
	until a ~= i
	repeat
		b = math.random(1, popTam)
	until ( (a ~= b) and (b ~= i))
	repeat
		c = math.random(1, popTam)
	until ( (a ~= c) and (b ~= c) and (c ~= i))
	table.insert(rands, a)
	table.insert(rands, b)
	table.insert(rands, c)
	return rands
end

local function g4Rand(i, popTam)
	local rands = {}
	local a, b , c, d
	repeat
		a = math.random(1, popTam)
	until a ~= i
	repeat
		b = math.random(1, popTam)
	until ( (a ~= b) and (b ~= i))
	repeat
		c = math.random(1, popTam)
	until ( (a ~= c) and (b ~= c) and (c ~= i))
	repeat
		d = math.random(1, popTam)
	until ( (a ~= d) and (b ~= d) and (c ~= d) and (d ~= i))
	table.insert(rands, a)
	table.insert(rands, b)
	table.insert(rands, c)
	table.insert(rands, d)
	return rands
end

local function copy(tab)
	local result = {}
	for i = 1, #tab do
		table.insert(result, tab[i])
	end

	return result
end

local function copyParameters(tab,dim)
	local result = {}
	for i = dim + 1, #tab do
		table.insert(result, tab[i])
	end

	return result
end

local function repareP(parameter)
	local p = parameter
	if( p < 0) then
		p = - p
	elseif ( p > 1) then
		p = 2 * 1 - p
	end

	return p
end

local function oobTrea(xi, varMatrix, k, step, stepValue)
	local lim = varMatrix[k]
	local minVar = lim[1]
	local maxVar = lim[2]
	local x = xi
	if step == nil then
		local stepValue = 0
		local step = false
	end

	if(x < minVar) then
		if(math.random() < 0.5) then
			x = minVar
		elseif step == true then
			x = (2 * minVar - x)
			x = x - ((x - minVar) % stepValue)
		else
			x = 2 * minVar - x;
		end
	end

	if(x > maxVar) then
		if(math.random() < 0.5) then
			x = maxVar
		elseif step == true then
			x = (2 * maxVar - x)
			x = x - ((x - minVar) % stepValue)
		else
			x = 2 * maxVar - x
		end
	end

	return x
end

-- Find Proportion function
local function fP(idx, group)
	local size = #group
	if size > 1 then
		return (idx / size)
	else
		return 1
	end
end

local aproxGroup 
aproxGroup = function(proportion, varMatrix, k)
	local group = varMatrix[k]
	local max = group[#group]
	local min = group[1]
	local size = #group
	local share = 1 / size
	local i = 1
	if size == 1 then
		return group[1]
	else
		if proportion < 0 or proportion > 1 then
			if math.random() < 0.5 then
				local result = aproxGroup(math.random(), varMatrix, k)
				return result
			else
				if proportion < 0 then
					return min
				else
					return max
				end
			end
		end

		while proportion > share * i do
			i = i + 1
		end

		if proportion - (share * (i - 1)) > share / 2 and i ~= size then
			return group[i + 1]
		else
			return group[i]
		end
	end
end

local normalize
function normalize(x, varMatrix, i, paramListInfo)
	local interval = varMatrix[i]
	local total
	local value
	if paramListInfo[i].group == false then
		total = interval[2] - interval[1]
		value = x - interval[1]
	else
		total = interval[#interval] - interval[1]
		value = x - interval[1]
	end

	local newValue = ((value * 100) / total) / 100
	return newValue
end

local function distance(x, y, varMatrix, i, paramListInfo)
	local dist = normalize(x, varMatrix, i, paramListInfo) - normalize(y, varMatrix, i, paramListInfo)
	dist = math.abs(dist)
	return dist
end

local function maxVector(vector, dim)
	local valueMax = vector[1]
	for i = 2, dim do
		if(vector[i] > valueMax) then
			valueMax = vector[i]
		end
	end

	return valueMax
end

local function maxDiversity(pop, dim, maxPopulation, varMatrix, paramListInfo)
	local varMax = {}
	local varMin = {}
	local vector = pop[1]
	for i = 1, dim do
		table.insert(varMax, vector[i])
		table.insert(varMin, vector[i])
	end

	for i = 2, maxPopulation do
		local vector = pop[i]
		for j = 1, dim do
			if(vector[j] > varMax[j]) then
				varMax[j] = vector[j]
			end

			if(vector[j] < varMin[j]) then
				varMin[j] = vector[j]
			end
		end
	end

	local dist = {}
	for i = 1, dim do
		local value = distance(varMax[i], varMin[i], varMatrix, i, paramListInfo)
		table.insert(dist, value)
	end

	local valueMax = maxVector(dist, dim)
	return valueMax
end

--- Function used by SAMDE type that implements the SaMDE genetic algorithm
-- to calibrate a model according to a fit function,
-- it returns a table with {fit = the best fitness value, instance = the instance of the best model,
-- generations = number of generations it took to the genetic algorithm reach this model}.
-- @arg modelParameters Table containing the model parameters.
-- @arg model model The model that will be calibrated by the function.
-- @arg finalTime finalTime to be used in the model.
-- @arg fit fit() A function that receive a model as a parameter and determines the fitness value of such model.
-- @arg maximize maximize An optional paramaters that determines if the models fitness values must be
-- maximized instead of minimized, default is false.
-- @arg size size Determines the size of the populations used in the SaMDE algorithm
-- (recommended size: (10*dim)).
-- @arg maxGen maxGen If a model generation reach this value, the function stops.
-- @arg threshold threshold If a model fitness reach this value, the function stops.
-- @usage 
-- local fit = function(model, parameters)
--		local m = model(parameters)
--		m:execute()
-- 		return m.result
-- end
--
-- local best = SAMDECalibrate({x = Choice{min = 1, max = 10, step = 2}, finalTime = 1}, MyModel, 1, fit(), false, 30, 100, 0)
function SAMDECalibrate(modelParameters, model, finalTime, fit, maximize, size, maxGen, threshold)
	local varMatrix = {}
	local paramList = {}
	local dim = 0
	local paramListInfo = {}
	forEachOrderedElement(modelParameters, function (idx, attribute, atype)
		if idx ~= "finalTime" then
			table.insert(paramList, idx)
			table.insert(paramListInfo, {})
			if attribute.min ~= nil then
				paramListInfo[#paramListInfo].group = false
				if attribute.step ~= nil then
					paramListInfo[#paramListInfo].step = true
					paramListInfo[#paramListInfo].stepValue = attribute.step
				else 
					paramListInfo[#paramListInfo].step = false
				end

				if attribute.max ~=nil then
					table.insert(varMatrix, {attribute.min, attribute.max})
				else
					table.insert(varMatrix, {attribute.min, math.huge()})
				end

			elseif attribute.max ~= nil then
					paramListInfo[#paramListInfo].group = false
					if attribute.step ~= nil then
						paramListInfo[#paramListInfo].step = true
						paramListInfo[#paramListInfo].stepValue = attribute.step
					else 
						paramListInfo[#paramListInfo].step = false
					end

					table.insert(varMatrix, { -1*math.huge(), attribute.max})
			else
				paramListInfo[#paramListInfo].step = false
				paramListInfo[#paramListInfo].group = true
				paramListInfo[#paramListInfo].proportion = {}
				table.insert(varMatrix, attribute.values)
				forEachOrderedElement(attribute.values, function(idx2, att2, typ2)
					paramListInfo[#paramListInfo].proportion[att2] = fP(idx2, attribute.values)
				end)
			end

		dim = dim + 1
		end
	end)
	if size == nil then
		size = #paramList * 10
	end

	local pop = {}
	local costPop = {}
	local maxPopulation = size
	pop = initPop(maxPopulation, varMatrix, dim, paramList, paramListInfo)
	local bestCost = evaluate(pop[1], dim, model, paramList, fit)
	local bestInd = copy(pop[1])
	table.insert(costPop, bestCost)
	for i = 2, maxPopulation do
		local fitness = evaluate(pop[i], dim, model, paramList, fit)
		table.insert(costPop, fitness)
		if maximize == true then
			if(fitness > bestCost) then
				bestCost = fitness
				bestInd = copy(pop[i])
			end
		else
			if(fitness < bestCost) then
				bestCost = fitness
				bestInd = copy(pop[i])
			end
		end
	end

	local thresholdStop = false
	local generationStop = false
	local generation = 1
	-- print("evolution population ...");
	while( (bestCost > 0.001) and (maxDiversity(pop, dim, maxPopulation, varMatrix, paramListInfo) > 0.001) and generationStop == false and thresholdStop == false) do
		
		local popAux = {}
		for j = 1, maxPopulation do
			local params = copyParameters(pop[j], dim)
			local F = 0.7 + (math.random() * 0.3)
			local rands = g3Rand(j, maxPopulation)
			local solution1, solution2, solution3
			solution1 = pop[rands[1]]
			solution2 = pop[rands[2]]
			solution3 = pop[rands[3]]
			for k = 1, NUMEST do
				params[k] = repareP(solution1[dim + k] + F * (solution2[dim + k] - solution3[dim + k]))
			end
			
			local sumV = 0.0
			for k = 1, NUMEST do
				sumV = sumV + params[k]
			end
			
			local _rand = math.random()
			local p = 0
			local winV = 0
			for k = 1, NUMEST do
				p = p + (params[k] / sumV)
				if(_rand > p) then
					winV = winV + 1
				end
			end
			
			local fPos = 1 + NUMEST + 2 * winV
			params[fPos] = repareP(solution1[dim + fPos] + F * (solution2[dim + fPos] - solution3[dim + fPos]))
			local crPos = fPos + 1;
			params[crPos] = repareP(solution1[dim + crPos] + F * (solution2[dim + crPos] - solution3[dim + crPos]))
			local rand4 = g4Rand(j, maxPopulation)
			local solution1, solution2, solution3, solution4
			solution1 = pop[rand4[1]]
			solution2 = pop[rand4[2]]
			solution3 = pop[rand4[3]]
			solution4 = pop[rand4[4]]
			local indexInd = pop[j]
			local index = math.random(1, dim)
			local ui = {}
			for k = 1, dim do
				if( math.random() <= params[crPos] or k == index or winV == 3) then
					local ui2
					if paramListInfo[k].group == true then
						if( winV == 0) then -- rand\1
							ui2 = oobTrea(paramListInfo[k].proportion[solution1[k]] + params[fPos] * (paramListInfo[k].proportion[solution2[k]] - paramListInfo[k].proportion[solution3[k]]), varMatrix, k)
						elseif (winV == 1) then -- best\1
							ui2 = oobTrea(bestInd[k] + params[fPos] * (paramListInfo[k].proportion[solution1[k]] - paramListInfo[k].proportion[solution2[k]]), varMatrix, k)
						elseif (winV == 2) then -- rand\2
							ui2 = oobTrea(paramListInfo[k].proportion[solution1[k]] + params[fPos] * (paramListInfo[k].proportion[solution2[k]] - paramListInfo[k].proportion[solution3[k]]) + params[fPos] * (paramListInfo[k].proportion[solution3[k]] - paramListInfo[k].proportion[solution4[k]]), varMatrix, k)
						elseif (winV == 3) then -- current-to-rand
							ui2 = oobTrea(indexInd[k] + params[fPos] * (paramListInfo[k].proportion[solution1[k]] - indexInd[k]) + params[fPos] * (paramListInfo[k].proportion[solution2[k]] - paramListInfo[k].proportion[solution3[k]]), varMatrix, k)
						end
					else
						if( winV == 0) then -- rand\1
							ui2 = oobTrea(solution1[k] + params[fPos] * (solution2[k] - solution3[k]), varMatrix, k)
						elseif (winV == 1) then -- best\1
							ui2 = oobTrea(bestInd[k] + params[fPos] * (solution1[k] - solution2[k]), varMatrix, k)
						elseif (winV == 2) then -- rand\2
							ui2 = oobTrea(solution1[k] + params[fPos] * (solution2[k] - solution3[k]) + params[fPos] * (solution3[k] - solution4[k]), varMatrix, k)
						elseif (winV == 3) then -- current-to-rand
							ui2 = oobTrea(indexInd[k] + params[fPos] * (solution1[k] - indexInd[k]) + params[fPos] * (solution2[k] - solution3[k]), varMatrix, k)
						end
					end

					if paramListInfo[k].step == true then
						local ui3
						local step = paramListInfo[k].stepValue
						local uiErr = ((ui2 - varMatrix[k][1]) % step)
						if uiErr < (step / 2) then
							ui3 = oobTrea((ui2 - uiErr), varMatrix, k, true, step)
						else
							ui3 = oobTrea((ui2 - uiErr) + step, varMatrix, k, true, step)
						end

						table.insert(ui, ui3)
					elseif paramListInfo[k].group == true then
						local ui3 = aproxGroup(ui2, varMatrix, k)
						table.insert(ui, ui3)
					else
						table.insert(ui, ui2)
					end

				else
					table.insert(ui,indexInd[k])
				end
			end
			
			for k = 1, (NUMEST * PARAMETERS) do
				if( math.random() <= params[crPos] ) then
					table.insert(ui, params[k])
				else
					table.insert(ui, indexInd[dim + k])
				end
			end

			local score = evaluate(ui, dim, model, paramList, fit, finalTime)
			if maximize == true then
				if(score > costPop[j]) then
					table.insert(popAux,copy(ui))
					costPop[j] = score
					if(score > bestCost) then
						bestCost = score
						bestInd = copy(ui)
					end

				else
					table.insert(popAux, pop[j])
				end

			else
				if(score < costPop[j]) then
					table.insert(popAux,copy(ui))
					costPop[j] = score
					if(score < bestCost) then
						bestCost = score
						bestInd = copy(ui)
					end

				else
					table.insert(popAux, pop[j])
				end	
			end
		end
		
		-- print("best: " .. bestCost);
		for j = 1, maxPopulation do
			pop[j] = copy(popAux[j])
		end
		
		if threshold ~= nil then 
			if maximize == true then
				if bestCost > threshold then
					thresholdStop = true
				end
			else
				if bestCost < threshold then
					thresholdStop = true
				end
			end
		end

		generation = generation + 1
		if maxGen ~= nil then
			if generation > maxGen then
				generationStop = true
			end
		end
	end

	local bestVariablesChoice = {}
	for i=1, dim do
		bestVariablesChoice[paramList[i]] = bestInd[i]
	end
	local bestInstance = model(bestVariablesChoice)
	bestInstance:execute()

	local finalTable = {fit = bestCost, instance = bestInstance, generations = generation}
	return finalTable
end


-- 