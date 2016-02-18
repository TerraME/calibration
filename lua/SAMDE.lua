-------------------------------------------------------------
----                 Algorithm SaMDE                     ----
----           Implement by: Rodolfo A. Lopes            ----
----    Adapted for TerraME by Antonio G. O. Junior      ----
-------------------------------------------------------------
local rand = Random()
local NUMEST = 4
local PARAMETERS = 3
local evaluate = function(ind, dim, model, paramList, fit, singleParameters)
	local solution = {}
	for i = 1, dim do
		solution[paramList[i]] = ind[i]
	end

	forEachOrderedElement(singleParameters, function (idx, att, typ)		
		solution[idx] = att
	end) 

	local m = model(solution)
	m:execute()
	local err = fit(m)
	return err
end

local initPop = function(popTam, varMatrix, dim, paramList, paramInfo)
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
				value = minVar + (rand:number() * (maxVar - minVar))
				if paramInfo[j].step then
					local step = paramInfo[j].stepValue
					value = value - ((value-lim[1]) % step)
				end

			else
				value = varMatrix[j][rand:integer(1,#varMatrix[j])]
			end

			table.insert(ind, value)
		end

		for j = (dim + 1), (dim + NUMEST * PARAMETERS) do
			local value = rand:number()
			table.insert(ind, value)
		end

		table.insert(popInit, ind)
	end

	return popInit
end

local g3Rand = function(i,popTam)
	local rands = {}
	local a,b,c
	repeat
		a = rand:integer(1, popTam)
	until a ~= i
	repeat
		b = rand:integer(1, popTam)
	until ( (a ~= b) and (b ~= i))
	repeat
		c = rand:integer(1, popTam)
	until ( (a ~= c) and (b ~= c) and (c ~= i))
	table.insert(rands, a)
	table.insert(rands, b)
	table.insert(rands, c)
	return rands
end

local g4Rand = function(i, popTam)
	local rands = {}
	local a, b , c, d
	repeat
		a = rand:integer(1, popTam)
	until a ~= i
	repeat
		b = rand:integer(1, popTam)
	until ( (a ~= b) and (b ~= i))
	repeat
		c = rand:integer(1, popTam)
	until ( (a ~= c) and (b ~= c) and (c ~= i))
	repeat
		d = rand:integer(1, popTam)
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

local copyParameters = function(tab,dim)
	local result = {}
	for i = dim + 1, #tab do
		table.insert(result, tab[i])
	end

	return result
end

local repareP = function(parameter)
	local p = parameter
	if( p < 0) then
		p = - p
	elseif ( p > 1) then
		p = 2 * 1 - p
	end

	return p
end

local oobTrea = function(xi, varMatrix, k, step, stepValue)
	local lim = varMatrix[k]
	local minVar = lim[1]
	local maxVar = lim[2]
	local x = xi
	if step == nil then
		local stepValue = 0
		local step = false
	end

	if(x < minVar) then
		if(rand:number() < 0.5) then
			x = minVar
		elseif step == true then
			x = (2 * minVar - x)
			x = x - ((x - minVar) % stepValue)
		else
			x = 2 * minVar - x;
		end
	end

	if(x > maxVar) then
		if(rand:number() < 0.5) then
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
local fP = function(idx, group)
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
			if rand:number() < 0.5 then
				local result = aproxGroup(rand:number(), varMatrix, k)
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
normalize = function(x, varMatrix, i, paramListInfo)
	local interval = varMatrix[i]
	local total
	local value
	local newValue
	if paramListInfo[i].group == false then
		total = interval[2] - interval[1]
		value = x - interval[1]
		if total == 0 then
			total = 1
		end

		newValue = ((value * 100) / total) / 100
	else
		newValue = paramListInfo[i].proportion[x]
	end
	
	return newValue
end

local distance = function(x, y, varMatrix, i, paramListInfo)
	local dist = normalize(x, varMatrix, i, paramListInfo) - normalize(y, varMatrix, i, paramListInfo)
	dist = math.abs(dist)
	return dist
end

local maxVector = function(vector, dim)
	local valueMax = vector[1]
	for i = 2, dim do
		if(vector[i] > valueMax) then
			valueMax = vector[i]
		end
	end

	return valueMax
end

local maxDiversity = function(pop, dim, maxPopulation, varMatrix, paramListInfo)
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

-- Function used by SAMDE type that implements the SaMDE genetic algorithm
-- to calibrate a model according to a fit function,
-- it returns a table with {fit = the best fitness value, instance = the instance of the best model,
-- generations = number of generations it took to the genetic algorithm reach this model}.
local SAMDECalibrate = function(modelParameters, model, fit, maximize, size, maxGen, threshold)
	local varMatrix = {}
	local paramList = {}
	local dim = 0
	local paramListInfo = {}
	local singleParameters = {}
	forEachOrderedElement(modelParameters, function (idx, attribute, atype)
		if atype == "Choice" then
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
		else
			singleParameters[idx] = attribute
		end
	end)

	if size == nil then
		size = #paramList * 10
	end

	local pop = {}
	local costPop = {}
	local maxPopulation = size
	pop = initPop(maxPopulation, varMatrix, dim, paramList, paramListInfo)
	local bestCost = evaluate(pop[1], dim, model, paramList, fit, singleParameters)
	local bestInd = copy(pop[1])
	table.insert(costPop, bestCost)
	for i = 2, maxPopulation do
		local fitness = evaluate(pop[i], dim, model, paramList, fit, singleParameters)
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
			local F = 0.7 + (rand:number() * 0.3)
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
			
			local _rand = rand:number()
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
			local index = rand:integer(1, dim)
			local ui = {}
			for k = 1, dim do
				if( rand:number() <= params[crPos] or k == index or winV == 3) then
					local ui2
					if paramListInfo[k].group == true then
						local prop = paramListInfo[k].proportion
						if( winV == 0) then -- rand\1
							ui2 = prop[solution1[k]] + params[fPos] * (prop[solution2[k]] - prop[solution3[k]])
						elseif (winV == 1) then -- best\1
							ui2 = prop[bestInd[k]] + params[fPos] * (prop[solution1[k]] - prop[solution2[k]])
						elseif (winV == 2) then -- rand\2
							ui2 = prop[solution1[k]] + params[fPos] * (prop[solution2[k]] - prop[solution3[k]]) + params[fPos] * (prop[solution3[k]] - prop[solution4[k]])
						elseif (winV == 3) then -- current-to-rand
							ui2 = prop[indexInd[k]] + params[fPos] * (prop[solution1[k]] - prop[indexInd[k]]) + params[fPos] * (prop[solution2[k]] - prop[solution3[k]])
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
				if( rand:number() <= params[crPos] ) then
					table.insert(ui, params[k])
				else
					table.insert(ui, indexInd[dim + k])
				end
			end

			local score = evaluate(ui, dim, model, paramList, fit, singleParameters)
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
				if bestCost >= threshold then
					thresholdStop = true
				end
			else
				if bestCost <= threshold then
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
	forEachOrderedElement(singleParameters, function ( idx, att, typ)
		bestVariablesChoice[idx] = att
	end)
	
	local bestInstance = model(bestVariablesChoice)
	bestInstance:execute()

	local finalTable = {fit = bestCost, instance = bestInstance, generations = generation}
	return finalTable
end

-- ========= SAMDE Type implemente by Antonio Gomes de Oliveira Junior =====
-- Function to be used by Calibration to check
-- if all possibilites of models can be instantiated before
-- starting to test the model.
-- @arg tModel A Paramater with the model to be instantiated.
-- @arg tParameters A table of parameters, from a MultipleRuns or Calibration type.
local function checkParameters(tModel, tParameters)
	mandatoryArgument(1, "Model", tModel)
	mandatoryTableArgument(tParameters, "parameters", "table")
	-- Tests all model parameters possibilities in Multiple Runs/Calibration to see if they are in the accepted
	-- range of values according to a Model.
	forEachElement(tModel(), function(idx, att, mtype)
		if mtype ~= "function" then
	    	if idx ~= "init" and idx ~= "seed" then
				local Param = tParameters.parameters[idx]
				if mtype == "Choice" then
					if type(Param) == "Choice" then
						-- if parameter in Multiple Runs/Calibration is a range of values
			    		if Param.min ~= nil or Param.max ~= nil or Param.step ~= nil then 
			    			checkParametersRange(tModel, idx, Param)
				    	else
				    	-- if parameter Multiple Runs/Calibration is a grop of values
				    		 checkParametersSet(tModel, idx, Param)
				    	end

				   	elseif type(Param) == "table" then
				   		customError("The parameter must be of type Choice, a table of Choices or a single value.")
				   	end

				elseif mtype == "Mandatory" then
					--Check if mandatory argument exists in tParameters.parameters and if it matches the correct type.
					local mandatory = false
					local mandArg = tParameters.parameters[idx]
					if type(mandArg) ~= nil then
						if type(mandArg) == "table" then
							mandatory = true
							forEachOrderedElement(mandArg, function(idx3, att3, typ3)
								if typ3 ~= att.value then
									mandatory = false
								end
							end)
						elseif type(mandArg) == att.value then
								mandatory = true
						elseif type(mandArg) == "Choice" then
							if mandArg.max ~= nil or mandArg.min ~= nil then
								if "number" == att.value then 
									mandatory = true
								end
							else
								mandatory = true
								forEachOrderedElement(mandArg.values, function(idx3, att3, typ3)
									if typ3 ~= att.value then
										mandatory = false
									end
								end)
							end
						end
					end

					if mandatory == false then
						mandatoryTableArgument(tParameters.parameters, idx, att.value)
					end

					-- forEachOrderedElement(tParameters.parameters, function(idx2, att2, typ2)
					-- 	if idx2 == idx then
					-- 		mandatory = true
					-- 		forEachOrderedElement(att2, function(idx3, att3, typ3)
					-- 			if typ3 ~= att.value then
					-- 				mandatory = false
					-- 			end
					-- 		end)
					-- 	end
					-- end)
				elseif mtype == "table" then
					forEachOrderedElement(att, function(idxt, attt, typt)
						if tParameters.parameters[idx] ~= nil then
							Param = tParameters.parameters[idx][idxt]
						end
						
						if type(Param) == "Choice" then
							-- if parameter in Multiple Runs/Calibration is a range of values
				    		if Param.min ~= nil or Param.max ~= nil or Param.step ~= nil then
				    			checkParametersRange(tModel, idxt, Param, idx)
					    	else
					    	-- if parameter Multiple Runs/Calibration is a grop of values
					    		 checkParametersSet(tModel, idxt, Param, idx)
					    	end

					   	elseif type(Param) == "table" and type(attt) == "Choice" then
					   		customError("The parameter must be of type Choice, a table of Choices or a single value.")
					   	end
					end)
				end
			end
	    end
	end)
end

SAMDE_ = {
	type_ = "SAMDE",
}

metaTableSAMDE_ = {
	__index = SAMDE_
}

--- Type to calibrate a model using genetic algorithm. It returns a SAMDE type with the
-- fittest individual (a Model), its fit value, and the number of generations taken by the genetic algorithm 
-- to reach the result.
-- SaMDE paper is available at: 
-- ( https://onedrive.live.com/redir?resid=50A40B914086BD50!4054&authkey=!ACNH3WpLEBuIOME&ithint=file%2cpdf ).
-- @output fit The best fitness result returned by the SAMDE Algorithm.
-- @output instance The instance of the model with the best fitness.
-- @output generation The number of generations created by the generit algorithm until it stopped.
-- @arg data.model A Model.
-- @arg data.parameters A table with the possible parameter values. They can be
-- values or Choices. All Choices will be calibrated.
-- @arg data.fit A user-defined function that gets a model instance as argument and 
-- returns a numeric value of that particular model fitness,
-- this value will be minimized or maximized by SAMDE according to the maximize parameter. 
-- @arg data.size The maximum population size in each generation.
-- @arg data.maxGen The maximum number of generations. If the simulation reaches this value,
-- it stops and returns the Model that has the fittest result? TODO.
-- @arg data.threshold If the fitness of a model reaches this value, SAMDE stops and
-- returns such model.
-- @arg data.maximize An optional paramaters that determines if the fit will be maximized (true)
-- or minimized (false, default value).
-- @usage
-- import("calibration")
-- local MyModel = Model{
--   x = Choice{min = -100, max = 100},
--   y = Choice{min = 1, max = 10},
--   finalTime = 1,
--   init = function(self)
--     self.timer = Timer{
--       Event{action = function()
--         self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
--       end}
--   }
--   end
-- }
-- c = SAMDE{
--     model = MyModel,
--     parameters = {x = Choice{min = -100, max = 100}, y = Choice {min = 1, max = 10}, finalTime = 1},
--     fit = function(model)
--         return model.value
--     end
-- }
function SAMDE(data)
	mandatoryTableArgument(data, "model", "Model")
	mandatoryTableArgument(data, "parameters", "table")
	if data.fit == nil or type(data.fit) ~= "function" then
		customError("Function 'fit' was not implemented.")
	end

	verifyUnnecessaryArguments(data, {"model", "parameters", "maximize", "fit", "maxGen", "size", "threshold"})
	checkParameters(data.model, data)
	local best = {fit, instance, generations}
	if data.maximize == nil then
		data.maximize = false
	end

	best = SAMDECalibrate(data.parameters, data.model, data.fit, data.maximize, data.size, data.maxGen, data.threshold)
	forEachOrderedElement(best, function(idx, att, type)
		data[idx] = att
	end)
	setmetatable(data, metaTableSAMDE_)
	return data
end

