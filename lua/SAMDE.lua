------------------------------------------------------------- --SKIP
----                 Algorithm SaMDE                     ---- --SKIP
----           Implement by: Rodolfo A. Lopes            ---- --SKIP
----    Adapted for TerraME by Antonio G. O. Junior      ---- --SKIP
------------------------------------------------------------- --SKIP
local rand = Random() --SKIP
local NUMEST = 4 --SKIP
local PARAMETERS = 3 --SKIP
local evaluate = function(ind, dim, model, paramList, fit, singleParameters) --SKIP
	local solution = {} --SKIP
	for i = 1, dim do --SKIP
		solution[paramList[i]] = ind[i] --SKIP
	end --SKIP

	forEachOrderedElement(singleParameters, function (idx, att, _)		 --SKIP
		solution[idx] = att --SKIP
	end)  --SKIP

	local m = model(solution) --SKIP
	m:run() --SKIP
	local err = fit(m) --SKIP
	return err --SKIP
end --SKIP

local initPop = function(popTam, dim, paramList, parameters) --SKIP
	-- print("initializing population ..."); --SKIP
	local popInit = {} --SKIP
	for _ = 1, popTam do --SKIP
		local ind = {} --SKIP
		for j = 1, dim do --SKIP
			local value --SKIP
			value = parameters[paramList[j]]:sample() --SKIP
			table.insert(ind, value) --SKIP
		end --SKIP

		for _ = (dim + 1), (dim + NUMEST * PARAMETERS) do --SKIP
			local value = rand:number() --SKIP
			table.insert(ind, value) --SKIP
		end --SKIP

		table.insert(popInit, ind) --SKIP
	end --SKIP

	return popInit --SKIP
end --SKIP

local g3Rand = function(i,popTam) --SKIP
	local rands = {} --SKIP
	local a,b,c --SKIP
	repeat --SKIP
		a = rand:integer(1, popTam) --SKIP
	until a ~= i --SKIP
	repeat --SKIP
		b = rand:integer(1, popTam) --SKIP
	until ( (a ~= b) and (b ~= i)) --SKIP
	repeat --SKIP
		c = rand:integer(1, popTam) --SKIP
	until ( (a ~= c) and (b ~= c) and (c ~= i)) --SKIP
	table.insert(rands, a) --SKIP
	table.insert(rands, b) --SKIP
	table.insert(rands, c) --SKIP
	return rands --SKIP
end --SKIP

local g4Rand = function(i, popTam) --SKIP
	local rands = {} --SKIP
	local a, b , c, d --SKIP
	repeat --SKIP
		a = rand:integer(1, popTam) --SKIP
	until a ~= i --SKIP
	repeat --SKIP
		b = rand:integer(1, popTam) --SKIP
	until ( (a ~= b) and (b ~= i)) --SKIP
	repeat --SKIP
		c = rand:integer(1, popTam) --SKIP
	until ( (a ~= c) and (b ~= c) and (c ~= i)) --SKIP
	repeat --SKIP
		d = rand:integer(1, popTam) --SKIP
	until ( (a ~= d) and (b ~= d) and (c ~= d) and (d ~= i)) --SKIP
	table.insert(rands, a) --SKIP
	table.insert(rands, b) --SKIP
	table.insert(rands, c) --SKIP
	table.insert(rands, d) --SKIP
	return rands --SKIP
end --SKIP

local function copy(tab) --SKIP
	local result = {} --SKIP
	for i = 1, #tab do --SKIP
		table.insert(result, tab[i]) --SKIP
	end --SKIP

	return result --SKIP
end --SKIP

local copyParameters = function(tab,dim) --SKIP
	local result = {} --SKIP
	for i = dim + 1, #tab do --SKIP
		table.insert(result, tab[i]) --SKIP
	end --SKIP

	return result --SKIP
end --SKIP

local repareP = function(parameter) --SKIP
	local p = parameter --SKIP
	if( p < 0) then --SKIP
		p = - p --SKIP
	elseif ( p > 1) then --SKIP
		p = 2 * 1 - p --SKIP
	end --SKIP

	return p --SKIP
end --SKIP

local oobTrea = function(xi, varMatrix, k, step, stepValue) --SKIP
	local lim = varMatrix[k] --SKIP
	local minVar = lim[1] --SKIP
	local maxVar = lim[2] --SKIP
	local x = xi --SKIP
	if step == nil then --SKIP
		stepValue = 0 --SKIP
		step = false --SKIP
	end --SKIP

	if(x < minVar) then --SKIP
		if(rand:number() < 0.5) then --SKIP
			x = minVar --SKIP
		elseif step == true then --SKIP
			x = (2 * minVar - x) --SKIP
			x = x - ((x - minVar) % stepValue) --SKIP
		else --SKIP
			x = 2 * minVar - x; --SKIP
		end --SKIP
	end --SKIP

	if(x > maxVar) then --SKIP
		if(rand:number() < 0.5) then --SKIP
			x = maxVar --SKIP
		elseif step == true then --SKIP
			x = (2 * maxVar - x) --SKIP
			x = x - ((x - minVar) % stepValue) --SKIP
		else --SKIP
			x = 2 * maxVar - x --SKIP
		end --SKIP
	end --SKIP

	return x --SKIP
end --SKIP

-- Find Proportion function --SKIP
local fP = function(idx, group) --SKIP
	local size = #group --SKIP
	if size > 1 then --SKIP
		return (idx / size) --SKIP
	else --SKIP
		return 1 --SKIP
	end --SKIP
end --SKIP

local aproxGroup  --SKIP
aproxGroup = function(proportion, varMatrix, k) --SKIP
	local group = varMatrix[k] --SKIP
	local max = group[#group] --SKIP
	local min = group[1] --SKIP
	local size = #group --SKIP
	local share = 1 / size --SKIP
	local i = 1 --SKIP
	if size == 1 then --SKIP
		return group[1] --SKIP

	else --SKIP
		if proportion < 0 or proportion > 1 then --SKIP
			if rand:number() < 0.5 then --SKIP
				local result = aproxGroup(rand:number(), varMatrix, k) --SKIP
				return result --SKIP
			else --SKIP
				if proportion < 0 then --SKIP
					return min --SKIP
				else --SKIP
					return max --SKIP
				end --SKIP
			end --SKIP
		end --SKIP

		while proportion > share * i do --SKIP
			i = i + 1 --SKIP
		end --SKIP

		if proportion - (share * (i - 1)) > share / 2 and i ~= size then --SKIP
			return group[i + 1] --SKIP
		else --SKIP
			return group[i] --SKIP
		end --SKIP
	end --SKIP
end --SKIP

local normalize --SKIP
normalize = function(x, varMatrix, i, paramListInfo) --SKIP
	local interval = varMatrix[i] --SKIP
	local total --SKIP
	local value --SKIP
	local newValue --SKIP
	if paramListInfo[i].group == false then --SKIP
		total = interval[2] - interval[1] --SKIP
		value = x - interval[1] --SKIP
		if total == 0 then --SKIP
			total = 1 --SKIP
		end --SKIP

		newValue = ((value * 100) / total) / 100 --SKIP
	else --SKIP
		newValue = paramListInfo[i].proportion[x] --SKIP
	end --SKIP
	 --SKIP
	return newValue --SKIP
end --SKIP

local distance = function(x, y, varMatrix, i, paramListInfo) --SKIP
	local dist = normalize(x, varMatrix, i, paramListInfo) - normalize(y, varMatrix, i, paramListInfo) --SKIP
	dist = math.abs(dist) --SKIP
	return dist --SKIP
end --SKIP

local maxVector = function(vector, dim) --SKIP
	local valueMax = vector[1] --SKIP
	for i = 2, dim do --SKIP
		if(vector[i] > valueMax) then --SKIP
			valueMax = vector[i] --SKIP
		end --SKIP
	end --SKIP

	return valueMax --SKIP
end --SKIP

local maxDiversity = function(pop, dim, maxPopulation, varMatrix, paramListInfo) --SKIP
	local varMax = {} --SKIP
	local varMin = {} --SKIP
	local vector = pop[1] --SKIP
	for i = 1, dim do --SKIP
		table.insert(varMax, vector[i]) --SKIP
		table.insert(varMin, vector[i]) --SKIP
	end --SKIP

	for i = 2, maxPopulation do --SKIP
		vector = pop[i] --SKIP
		for j = 1, dim do --SKIP
			if(vector[j] > varMax[j]) then --SKIP
				varMax[j] = vector[j] --SKIP
			end --SKIP

			if(vector[j] < varMin[j]) then --SKIP
				varMin[j] = vector[j] --SKIP
			end --SKIP
		end --SKIP
	end --SKIP

	local dist = {} --SKIP
	for i = 1, dim do --SKIP
		local value = distance(varMax[i], varMin[i], varMatrix, i, paramListInfo) --SKIP
		table.insert(dist, value) --SKIP
	end --SKIP

	local valueMax = maxVector(dist, dim) --SKIP
	return valueMax --SKIP
end --SKIP

-- Function used by SAMDE type that implements the SaMDE genetic algorithm --SKIP
-- to calibrate a model according to a fit function, --SKIP
-- it returns a table with {fit = the best fitness value, instance = the instance of the best model, --SKIP
-- generations = number of generations it took to the genetic algorithm reach this model}. --SKIP
local SAMDECalibrate = function(modelParameters, model, fit, maximize, size, maxGen, threshold) --SKIP
	local varMatrix = {} --SKIP
	local paramList = {} --SKIP
	local dim = 0 --SKIP
	local paramListInfo = {} --SKIP
	local singleParameters = {} --SKIP
	forEachOrderedElement(modelParameters, function (idx, attribute, atype) --SKIP
		if atype == "Choice" then --SKIP
			table.insert(paramList, idx) --SKIP
			table.insert(paramListInfo, {}) --SKIP
			if attribute.min ~= nil then --SKIP
				paramListInfo[#paramListInfo].group = false --SKIP
				if attribute.step ~= nil then --SKIP
					paramListInfo[#paramListInfo].step = true --SKIP
					paramListInfo[#paramListInfo].stepValue = attribute.step --SKIP
				else  --SKIP
					paramListInfo[#paramListInfo].step = false --SKIP
				end --SKIP

				if attribute.max ~=nil then --SKIP
					table.insert(varMatrix, {attribute.min, attribute.max}) --SKIP
				else --SKIP
					table.insert(varMatrix, {attribute.min, math.huge()}) --SKIP
				end --SKIP

			elseif attribute.max ~= nil then --SKIP
					paramListInfo[#paramListInfo].group = false --SKIP
					if attribute.step ~= nil then --SKIP
						paramListInfo[#paramListInfo].step = true --SKIP
						paramListInfo[#paramListInfo].stepValue = attribute.step --SKIP
					else  --SKIP
						paramListInfo[#paramListInfo].step = false --SKIP
					end --SKIP

					table.insert(varMatrix, { -1*math.huge(), attribute.max}) --SKIP
			else --SKIP
				paramListInfo[#paramListInfo].step = false --SKIP
				paramListInfo[#paramListInfo].group = true --SKIP
				paramListInfo[#paramListInfo].proportion = {} --SKIP
				table.insert(varMatrix, attribute.values) --SKIP
				forEachOrderedElement(attribute.values, function(idx2, att2, _) --SKIP
					paramListInfo[#paramListInfo].proportion[att2] = fP(idx2, attribute.values) --SKIP
				end) --SKIP
			end --SKIP

			dim = dim + 1 --SKIP
		else --SKIP
			singleParameters[idx] = attribute --SKIP
		end --SKIP
	end) --SKIP

	if size == nil then --SKIP
		size = #paramList * 10 --SKIP
	end --SKIP

	local pop --SKIP
	local costPop = {} --SKIP
	local maxPopulation = size --SKIP
	pop = initPop(maxPopulation, dim, paramList, modelParameters) --SKIP
	local bestCost = evaluate(pop[1], dim, model, paramList, fit, singleParameters) --SKIP
	local bestInd = copy(pop[1]) --SKIP
	table.insert(costPop, bestCost) --SKIP
	for i = 2, maxPopulation do --SKIP
		local fitness = evaluate(pop[i], dim, model, paramList, fit, singleParameters) --SKIP
		table.insert(costPop, fitness) --SKIP
		if maximize == true then --SKIP
			if(fitness > bestCost) then --SKIP
				bestCost = fitness --SKIP
				bestInd = copy(pop[i]) --SKIP
			end --SKIP
		else --SKIP
			if(fitness < bestCost) then --SKIP
				bestCost = fitness --SKIP
				bestInd = copy(pop[i]) --SKIP
			end --SKIP
		end --SKIP
	end --SKIP

	local thresholdStop = false --SKIP
	local generationStop = false --SKIP
	local generation = 1 --SKIP
	-- print("evolution population ..."); --SKIP
	while( (bestCost > 0.001) and (maxDiversity(pop, dim, maxPopulation, varMatrix, paramListInfo) > 0.001) and generationStop == false and thresholdStop == false) do --SKIP
		 --SKIP
		local popAux = {} --SKIP
		for j = 1, maxPopulation do --SKIP
			local params = copyParameters(pop[j], dim) --SKIP
			local F = 0.7 + (rand:number() * 0.3) --SKIP
			local rands = g3Rand(j, maxPopulation) --SKIP
			local solution1, solution2, solution3 --SKIP
			solution1 = pop[rands[1]] --SKIP
			solution2 = pop[rands[2]] --SKIP
			solution3 = pop[rands[3]] --SKIP
			for k = 1, NUMEST do --SKIP
				params[k] = repareP(solution1[dim + k] + F * (solution2[dim + k] - solution3[dim + k])) --SKIP
			end --SKIP
			 --SKIP
			local sumV = 0.0 --SKIP
			for k = 1, NUMEST do --SKIP
				sumV = sumV + params[k] --SKIP
			end --SKIP
			 --SKIP
			local _rand = rand:number() --SKIP
			local p = 0 --SKIP
			local winV = 0 --SKIP
			for k = 1, NUMEST do --SKIP
				p = p + (params[k] / sumV) --SKIP
				if(_rand > p) then --SKIP
					winV = winV + 1 --SKIP
				end --SKIP
			end --SKIP
			 --SKIP
			local fPos = 1 + NUMEST + 2 * winV --SKIP
			params[fPos] = repareP(solution1[dim + fPos] + F * (solution2[dim + fPos] - solution3[dim + fPos])) --SKIP
			local crPos = fPos + 1; --SKIP
			params[crPos] = repareP(solution1[dim + crPos] + F * (solution2[dim + crPos] - solution3[dim + crPos])) --SKIP
			local rand4 = g4Rand(j, maxPopulation) --SKIP
			local solution4 --SKIP
			solution1 = pop[rand4[1]] --SKIP
			solution2 = pop[rand4[2]] --SKIP
			solution3 = pop[rand4[3]] --SKIP
			solution4 = pop[rand4[4]] --SKIP
			local indexInd = pop[j] --SKIP
			local index = rand:integer(1, dim) --SKIP
			local ui = {} --SKIP
			for k = 1, dim do --SKIP
				if( rand:number() <= params[crPos] or k == index or winV == 3) then --SKIP
					local ui2 --SKIP
					if paramListInfo[k].group == true then --SKIP
						local prop = paramListInfo[k].proportion --SKIP
						if( winV == 0) then -- rand\1 --SKIP
							ui2 = prop[solution1[k]] + params[fPos] * (prop[solution2[k]] - prop[solution3[k]]) --SKIP
						elseif (winV == 1) then -- best\1 --SKIP
							ui2 = prop[bestInd[k]] + params[fPos] * (prop[solution1[k]] - prop[solution2[k]]) --SKIP
						elseif (winV == 2) then -- rand\2 --SKIP
							ui2 = prop[solution1[k]] + params[fPos] * (prop[solution2[k]] - prop[solution3[k]]) + params[fPos] * (prop[solution3[k]] - prop[solution4[k]]) --SKIP
						elseif (winV == 3) then -- current-to-rand --SKIP
							ui2 = prop[indexInd[k]] + params[fPos] * (prop[solution1[k]] - prop[indexInd[k]]) + params[fPos] * (prop[solution2[k]] - prop[solution3[k]]) --SKIP
						end --SKIP
					else --SKIP
						if( winV == 0) then -- rand\1 --SKIP
							ui2 = oobTrea(solution1[k] + params[fPos] * (solution2[k] - solution3[k]), varMatrix, k) --SKIP
						elseif (winV == 1) then -- best\1 --SKIP
							ui2 = oobTrea(bestInd[k] + params[fPos] * (solution1[k] - solution2[k]), varMatrix, k) --SKIP
						elseif (winV == 2) then -- rand\2 --SKIP
							ui2 = oobTrea(solution1[k] + params[fPos] * (solution2[k] - solution3[k]) + params[fPos] * (solution3[k] - solution4[k]), varMatrix, k) --SKIP
						elseif (winV == 3) then -- current-to-rand --SKIP
							ui2 = oobTrea(indexInd[k] + params[fPos] * (solution1[k] - indexInd[k]) + params[fPos] * (solution2[k] - solution3[k]), varMatrix, k) --SKIP
						end --SKIP
					end --SKIP

					if paramListInfo[k].step == true then --SKIP
						local ui3 --SKIP
						local step = paramListInfo[k].stepValue --SKIP
						local uiErr = ((ui2 - varMatrix[k][1]) % step) --SKIP
						if uiErr < (step / 2) then --SKIP
							ui3 = oobTrea((ui2 - uiErr), varMatrix, k, true, step) --SKIP
						else --SKIP
							ui3 = oobTrea((ui2 - uiErr) + step, varMatrix, k, true, step) --SKIP
						end --SKIP

						table.insert(ui, ui3) --SKIP
					elseif paramListInfo[k].group == true then --SKIP
						local ui3 = aproxGroup(ui2, varMatrix, k) --SKIP
						table.insert(ui, ui3) --SKIP
					else --SKIP
						table.insert(ui, ui2) --SKIP
					end --SKIP

				else --SKIP
					table.insert(ui,indexInd[k]) --SKIP
				end --SKIP
			end --SKIP
			 --SKIP
			for k = 1, (NUMEST * PARAMETERS) do --SKIP
				if( rand:number() <= params[crPos] ) then --SKIP
					table.insert(ui, params[k]) --SKIP
				else --SKIP
					table.insert(ui, indexInd[dim + k]) --SKIP
				end --SKIP
			end --SKIP

			local score = evaluate(ui, dim, model, paramList, fit, singleParameters) --SKIP
			if maximize == true then --SKIP
				if(score > costPop[j]) then --SKIP
					table.insert(popAux,copy(ui)) --SKIP
					costPop[j] = score --SKIP
					if(score > bestCost) then --SKIP
						bestCost = score --SKIP
						bestInd = copy(ui) --SKIP
					end --SKIP

				else --SKIP
					table.insert(popAux, pop[j]) --SKIP
				end --SKIP

			else --SKIP
				if(score < costPop[j]) then --SKIP
					table.insert(popAux,copy(ui)) --SKIP
					costPop[j] = score --SKIP
					if(score < bestCost) then --SKIP
						bestCost = score --SKIP
						bestInd = copy(ui) --SKIP
					end --SKIP

				else --SKIP
					table.insert(popAux, pop[j]) --SKIP
				end	 --SKIP
			end --SKIP
		end --SKIP
		 --SKIP
		-- print("best: " .. bestCost); --SKIP
		for j = 1, maxPopulation do --SKIP
			pop[j] = copy(popAux[j]) --SKIP
		end --SKIP
		 --SKIP
		if threshold ~= nil then  --SKIP
			if maximize == true then --SKIP
				if bestCost >= threshold then --SKIP
					thresholdStop = true --SKIP
				end --SKIP
			else --SKIP
				if bestCost <= threshold then --SKIP
					thresholdStop = true --SKIP
				end --SKIP
			end --SKIP
		end --SKIP

		generation = generation + 1 --SKIP
		if maxGen ~= nil then --SKIP
			if generation > maxGen then --SKIP
				generationStop = true --SKIP
			end --SKIP
		end --SKIP
	end --SKIP

	local bestVariablesChoice = {} --SKIP
	for i=1, dim do --SKIP
		bestVariablesChoice[paramList[i]] = bestInd[i] --SKIP
	end --SKIP
	forEachOrderedElement(singleParameters, function (idx, att) --SKIP
		bestVariablesChoice[idx] = att --SKIP
	end) --SKIP
	 --SKIP
	local bestInstance = model(bestVariablesChoice) --SKIP
	bestInstance:run() --SKIP

	local finalTable = {fit = bestCost, instance = bestInstance, generations = generation} --SKIP
	return finalTable --SKIP
end --SKIP

-- ========= SAMDE Type implemente by Antonio Gomes de Oliveira Junior ===== --SKIP
-- Function to be used by Calibration to check --SKIP
-- if all possibilites of models can be instantiated before --SKIP
-- starting to test the model. --SKIP
-- @arg tModel A Paramater with the model to be instantiated. --SKIP
-- @arg tParameters A table of parameters, from a MultipleRuns or Calibration type. --SKIP
local function checkParameters(tModel, tParameters) --SKIP
	mandatoryArgument(1, "Model", tModel) --SKIP
	mandatoryTableArgument(tParameters, "parameters", "table") --SKIP
	-- Tests all model parameters possibilities in Multiple Runs/Calibration to see if they are in the accepted --SKIP
	-- range of values according to a Model. --SKIP
	forEachElement(tModel:getParameters(), function(idx, att, mtype) --SKIP
		if mtype ~= "function" then --SKIP
	    	if idx ~= "init" and idx ~= "seed" then --SKIP
				local Param = tParameters.parameters[idx] --SKIP
				if mtype == "Choice" then --SKIP
					if type(Param) == "Choice" then --SKIP
						-- if parameter in Multiple Runs/Calibration is a range of values --SKIP
			    		if Param.min ~= nil or Param.max ~= nil or Param.step ~= nil then  --SKIP
			    			checkParametersRange(tModel, idx, Param) --SKIP
				    	else --SKIP
				    	-- if parameter Multiple Runs/Calibration is a grop of values --SKIP
				    		 checkParametersSet(tModel, idx, Param) --SKIP
				    	end --SKIP

				   	elseif type(Param) == "table" then --SKIP
				   		customError("The parameter must be of type Choice, a table of Choices or a single value.") --SKIP
				   	end --SKIP

				elseif mtype == "Mandatory" then --SKIP
					--Check if mandatory argument exists in tParameters.parameters and if it matches the correct type. --SKIP
					local mandatory = false --SKIP
					local mandArg = tParameters.parameters[idx] --SKIP
					if type(mandArg) ~= nil then --SKIP
						if type(mandArg) == "table" then --SKIP
							mandatory = true --SKIP
							forEachOrderedElement(mandArg, function(_, _, typ3) --SKIP
								if typ3 ~= att.value then --SKIP
									mandatory = false --SKIP
								end --SKIP
							end) --SKIP
						elseif type(mandArg) == att.value then --SKIP
								mandatory = true --SKIP
						elseif type(mandArg) == "Choice" then --SKIP
							if mandArg.max ~= nil or mandArg.min ~= nil then --SKIP
								if "number" == att.value then  --SKIP
									mandatory = true --SKIP
								end --SKIP
							else --SKIP
								mandatory = true --SKIP
								forEachOrderedElement(mandArg.values, function(_, _, typ3) --SKIP
									if typ3 ~= att.value then --SKIP
										mandatory = false --SKIP
									end --SKIP
								end) --SKIP
							end --SKIP
						end --SKIP
					end --SKIP

					if mandatory == false then --SKIP
						mandatoryTableArgument(tParameters.parameters, idx, att.value) --SKIP
					end --SKIP

					-- forEachOrderedElement(tParameters.parameters, function(idx2, att2, typ2) --SKIP
					-- 	if idx2 == idx then --SKIP
					-- 		mandatory = true --SKIP
					-- 		forEachOrderedElement(att2, function(idx3, att3, typ3) --SKIP
					-- 			if typ3 ~= att.value then --SKIP
					-- 				mandatory = false --SKIP
					-- 			end --SKIP
					-- 		end) --SKIP
					-- 	end --SKIP
					-- end) --SKIP
				elseif mtype == "table" then --SKIP
					forEachOrderedElement(att, function(idxt, attt) --SKIP
						if tParameters.parameters[idx] ~= nil then --SKIP
							Param = tParameters.parameters[idx][idxt] --SKIP
						end --SKIP
						 --SKIP
						if type(Param) == "Choice" then --SKIP
							-- if parameter in Multiple Runs/Calibration is a range of values --SKIP
				    		if Param.min ~= nil or Param.max ~= nil or Param.step ~= nil then --SKIP
				    			checkParametersRange(tModel, idxt, Param, idx) --SKIP
					    	else --SKIP
					    	-- if parameter Multiple Runs/Calibration is a grop of values --SKIP
					    		 checkParametersSet(tModel, idxt, Param, idx) --SKIP
					    	end --SKIP

					   	elseif type(Param) == "table" and type(attt) == "Choice" then --SKIP
					   		customError("The parameter must be of type Choice, a table of Choices or a single value.") --SKIP
					   	end --SKIP
					end) --SKIP
				end --SKIP
			end --SKIP
	    end --SKIP
	end) --SKIP
end --SKIP

SAMDE_ = { --SKIP
	type_ = "SAMDE", --SKIP
} --SKIP

metaTableSAMDE_ = { --SKIP
	__index = SAMDE_ --SKIP
} --SKIP

--- Type to calibrate a model using genetic algorithm. It returns a SAMDE type with the --SKIP
-- fittest individual (a Model), its fit value, and the number of generations taken by the genetic algorithm  --SKIP
-- to reach the result. --SKIP
-- SaMDE paper is available at:  --SKIP
-- ( https://onedrive.live.com/redir?resid=50A40B914086BD50!4054&authkey=!ACNH3WpLEBuIOME&ithint=file%2cpdf ). --SKIP
-- @output fit The best fitness result returned by the SAMDE Algorithm. --SKIP
-- @output instance The instance of the model with the best fitness. --SKIP
-- @output generation The number of generations created by the generit algorithm until it stopped. --SKIP
-- @arg data.model A Model. --SKIP
-- @arg data.parameters A table with the possible parameter values. They can be --SKIP
-- values or Choices. All Choices will be calibrated. --SKIP
-- @arg data.fit A user-defined function that gets a model instance as argument and  --SKIP
-- returns a numeric value of that particular model fitness, --SKIP
-- this value will be minimized or maximized by SAMDE according to the maximize parameter.  --SKIP
-- @arg data.size The maximum population size in each generation. --SKIP
-- @arg data.maxGen The maximum number of generations. If the simulation reaches this value, --SKIP
-- it stops and returns the Model that has the fittest result? TODO. --SKIP
-- @arg data.threshold If the fitness of a model reaches this value, SAMDE stops and --SKIP
-- returns such model. --SKIP
-- @arg data.maximize An optional paramaters that determines if the fit will be maximized (true) --SKIP
-- or minimized (false, default value). --SKIP
-- @usage --SKIP
-- import("calibration") --SKIP
-- local MyModel = Model{ --SKIP
--   x = Choice{min = -100, max = 100}, --SKIP
--   y = Choice{min = 1, max = 10}, --SKIP
--   finalTime = 1, --SKIP
--   init = function(self) --SKIP
--     self.timer = Timer{ --SKIP
--       Event{action = function() --SKIP
--         self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y --SKIP
--       end} --SKIP
--   } --SKIP
--   end --SKIP
-- } --SKIP
-- c = SAMDE{ --SKIP
--     model = MyModel, --SKIP
--     parameters = {x = Choice{min = -100, max = 100}, y = Choice {min = 1, max = 10}, finalTime = 1}, --SKIP
--     fit = function(model) --SKIP
--         return model.value --SKIP
--     end --SKIP
-- } --SKIP
function SAMDE(data) --SKIP
	mandatoryTableArgument(data, "model", "Model") --SKIP
	mandatoryTableArgument(data, "parameters", "table") --SKIP
	if data.fit == nil or type(data.fit) ~= "function" then --SKIP
		customError("Function 'fit' was not implemented.") --SKIP
	end --SKIP

	verifyUnnecessaryArguments(data, {"model", "parameters", "maximize", "fit", "maxGen", "size", "threshold", "hideGraphs"}) --SKIP
	if data.hideGraphs == nil then --SKIP
		data.hideGraphs = true  --SKIP
	end --SKIP

	if data.hideGraphs == true then --SKIP
		disableGraphics()  --SKIP
	end --SKIP

	checkParameters(data.model, data) --SKIP
	if data.maximize == nil then --SKIP
		data.maximize = false --SKIP
	end --SKIP
	-- best = {fit, instance, generations} --SKIP
	local best = SAMDECalibrate(data.parameters, data.model, data.fit, data.maximize, data.size, data.maxGen, data.threshold) --SKIP
	forEachOrderedElement(best, function(idx, att) --SKIP
		data[idx] = att --SKIP
	end) --SKIP
	if data.hideGraphs == true then --SKIP
		enableGraphics()  --SKIP
	end --SKIP
	setmetatable(data, metaTableSAMDE_) --SKIP
	return data --SKIP
end --SKIP

