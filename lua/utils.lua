-- @header Useful functions that are used by MultipleRuns and SAMDE. It contains
-- basic functions to work with Models, such as checking parameters and creating
-- random instances of a given Model.

--- Verify if a given parameter for a Model using min and max (and possibly range) 
-- values is a valid subset for a given Model parameter.
-- @arg model A Model to be instantiated.
-- @arg idx  The name of the parameter to be verified in the Model.
-- @arg Param A table with the values to be verified.
-- @arg tableName Optional parameter to be used if the paramater 'idx' is inside another table,
-- it's the parameter's table name.
-- @usage import("calibration")
--
-- myModel = Model{
--     y = Choice{min = 1, max = 100, step = 1},
--     finalTime = 1,
--     init = function(self)
--         self.timer = Timer{
--             -- ...
--         }
--     end
-- }
--
-- local parameters = {y = Choice{min = 20, max = 40}}
-- ok, err =  pcall(function()
--     checkParametersRange(myModel, "y", parameters.y)
-- end)
--
-- print(err) -- Error: Argument 'y.step' is mandatory.
function checkParametersRange(model, idx, Param, tableName)
	local values
	if tableName ~= nil then
		values = model:getParameters()[tableName][idx]
	else
		values = model:getParameters()[idx]
	end

	--test if the range of values in the Calibration/Multiple Runs type are inside the accepted model range of values.
	if values.min == nil and values.max == nil then
		customError("Parameter "..idx.." should not be a range of values")
	end

	if Param.min == nil or Param.max == nil then
		customError("Parameter "..idx.." must have min and max values")
	end

	if values.min ~= nil then
		if values.min > Param.min then
			customError("Parameter "..idx.." min is out of the model range.")
		end
	end

	if values.max ~= nil then
		if values.max < Param.max then
			customError("Parameter "..idx.." max is out of the model range.")
		end
	end

	if values.step ~= nil then
		if Param.step == nil then
			customError("Argument '"..idx..".step' is mandatory.")
		elseif Param.step % values.step ~= 0 then
			customError("Parameter "..idx.." step is out of the model range.")
		end

		if values.min ~= nil then
			if (Param.min - values.min) % values.step ~= 0 then
				customError("Parameter "..idx.." min is out of the model range.")
			end
		end		
	end
end

--- Verify if a given parameter for a Model 
-- value is a valid subset for a given Model parameter.
-- @arg model A model to be instantiated.
-- @arg idx  The name of the parameter to be checked in the parameters table.
-- @arg idx2  The numerical index, of the parameter value to be checked, in the choosen parameter Choice table.
-- @arg value The value to be checked.
-- @arg tableName Optional parameter to be used if the paramater 'idx' is inside another table,
-- it's the parameter's table name.
-- @usage import("calibration")
--
-- myModel = Model{
--     x = Choice{-100, -1, 0, 1, 2, 100},
--     finalTime = 1,
--     init = function(self)
--         self.timer = Timer{
--             -- ...
--         }
--     end
-- }
--
-- local parameters = {x = Choice{-100, 5, 2}}
-- ok, err =  pcall(function()
--     checkParameterSingle(myModel, "x", 2, 5)
-- end)
--
-- print(err) -- Error: Parameter 5 in #2 is out of the model x range.
function checkParameterSingle(model, idx, idx2, value, tableName)
	local mParam
	if tableName ~= nil then
		mParam = model:getParameters()[tableName][idx]
	else
		mParam = model:getParameters()[idx]
	end

	--test if a value inside the accepted model range of values
	if mParam.min ~= nil then
		if value < mParam.min then
			customError("Parameter "..value.." in #"..idx2.." is smaller than "..idx.." min value")
		end

		if mParam.step ~= nil then
			if (value - mParam.min) % mParam.step ~= 0 then
				customError("Parameter "..value.." in #"..idx2.." is out of "..idx.." range")
			end
		end
	end

	if mParam.max ~= nil then
		if value > mParam.max then
			customError("Parameter "..value.." in #"..idx2.." is bigger than "..idx.." max value")
		end
	end

	if mParam.values ~= nil then
		if belong(value, mParam.values) == false then
			customError("Parameter "..value.." in #"..idx2.." is out of the model "..idx.." range.")
		end
	end
end

--- Verify if a given parameter for a Model using a table of
-- values is a valid subset for a given Model parameter.
-- @arg model A model to be instantiated.
-- @arg idx  The index of the parameter to be checked in the parameters table.
-- @arg parameters A table with the group of parameter values to be checked.
-- @arg tableName Optional parameter to be used if the paramater 'idx' is inside another table,
-- it's the parameter's table name.
-- @usage
-- import("calibration")
--
-- myModel = Model{
--     x = Choice{-100, -1, 0, 1, 2, 100},
--     finalTime = 1,
--     init = function(self)
--         self.timer = Timer{
--             -- ...
--         }
--     end
-- }
--
-- local parameters = {x = Choice{-100, 1, 3}}
-- ok, err =  pcall(function()
--    checkParametersSet(myModel, "x", parameters.x)
-- end)
--
-- print(err) -- Error: Parameter 3 in #3 is out of the model x range.
function checkParametersSet(model, idx, parameters, tableName) 
	-- test if the group of values in the Calibration/Multiple Runs type are inside the accepted model range of values
	forEachOrderedElement(parameters.values, function(idx2, att2, type2)
		checkParameterSingle(model, idx, idx2, att2, tableName)
	end)
end

--- Function to create a copy of a given parameter, returns the copy.
-- @arg mtable The parameter to be copied.
-- @usage
-- import("calibration")
-- local original = {param = 42}
-- local copy = clone(original) 
function clone(mtable)
    mandatoryArgument(1, "table", mtable)

    local result = {}

    forEachElement(mtable, function(idx, value, mtype)
        if mtype == "table" then
            result[idx] = clone(value)
        else
            result[idx] = value
        end
    end)

    return result
end

--- Function that returns a random model instance from a set of parameters.
-- Each Choice argument will be instantiated with a random value from the available choices.
-- The other arguments will be instantiated with their exact values.
-- This function can be used by SaMDE as well as by MultipleRuns.
-- @arg tModel The Model to be instantiated.
-- @arg tParameters A table of possible parameters for the model.
-- Multiple Runs or Calibration instance .
-- @usage
-- import("calibration")
-- local myModel = Model{
--   x = Choice{-100, -1, 0, 1, 2, 100},
--   y = Choice{min = 1, max = 10, step = 1},
--   finalTime = 1,
--   init = function(self)
--     self.timer = Timer{
--       Event{action = function()
--         self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
--       end}
--   }
--   end
-- }
-- local parameters = {x = Choice{-100,- 1, 0, 1, 2, 100}, y = Choice{min = 1, max = 8, step = 1}}
-- randomModel(myModel, parameters)
function randomModel(tModel, tParameters)
	mandatoryArgument(1, "Model", tModel)
	mandatoryArgument(1, "table", tParameters)
	local Params = {}
	local sampleParams = {}
	forEachOrderedElement(tParameters, function (idx, attribute, atype)
		if atype == "Choice" then
			sampleParams[idx] = attribute:sample()
		elseif atype == "table" then
			if sampleParams[idx] == nil then
				sampleParams[idx] = {}
			end

			forEachOrderedElement(attribute, function(idx2, att2, typ2)
				if typ2 == "Choice" then
					sampleParams[idx][idx2] = att2:sample()
				else
					sampleParams[idx][idx2] = att2
				end
			end)
		else
			sampleParams[idx] = attribute
		end
	end)
	local m = tModel(sampleParams)
	m:run()
	return m
end

--- Function that test the model and saves a results table with the model input and output
-- for OFAT Sensitivity Analysis
function OFATSensitivity(data, testParameters, tableName, separator)
	mandatoryArgument(1, "table", data)
	mandatoryArgument(2, "table", testParameters)
	if tableName == nil then
		tableName = "results"
		separator = ";"
	else
		mandatoryArgument(4, "string", separator)
	end

	if data.strategy == nil then
		data.strategy = "factorial"
	end

	forEachOrderedElement(testParameters, function(parameter, att, typ)
		rangePoints = {}
		if att.min ~= nil or att.max ~= nil then
			mandatoryTableArgument(att, "min", "number")
			mandatoryTableArgument(att, "max", "number")
			mandatoryTableArgument(att, "points", "number")
			rangePoints[1] = att.min
			for i = 2, (att.points - 1) do
			    rangePoints[i] = att.min + math.floor( i * (att.max - att.min) / (att.points))  
			end

			rangePoints[att.points] = att.max
		elseif att.values ~= nil then
			mandatoryTableArgument(att, "values", "table")  
			if att.points ~= nil then
				for i = 1, att.points do
					rangePoints[i] = att:sample()
				end
			else
				rangePoints = att.values
			end
		else
			customError("testParameter["..parameter.."] does not have a 'max'/'min' range or a table of 'values'")
		end

		referenceParameter = data.parameters[parameter]
		data.parameters[parameter] = Choice(rangePoints)
	    sensivityTest = MultipleRuns(data)
	    sensivityTest:saveCSV(tableName.."["..parameter.."]", separator)
	    data.parameters[parameter] = rangePoints
	end)

	
end

-- @example Basic example for testing SAMDE type
-- using a SysDyn model.
-- import("calibration")
-- import("ca")
-- abm = Wolfram
-- testParameters = {"rule"}
-- minRule = 0
-- maxRule = 255
-- repetitions = 2
-- points = 9
-- rangePoints = {}
-- rangePoints[0] = minRule
-- for i = 1, points do
--     rangePoints[i] = minRule + math.floor( i * (maxRule - minRule) / (points + 1))  
-- end
-- rangePoints[points+1] = maxRule
-- forEachOrderedElement(testParameters, function(parameter, att, typ)
--     sensivityTest = MultipleRuns{
--         folderName = tmpDir(),
--         quantity = 2,
--         model = abm,
--         -- hideGraphs = true,
--         -- If this is true, observers are turned off but model does not work. I think this is a bug in terrame disableGraphs().
--         parameters = {parameter = Choice(rangePoints)},
--         strategy = "factorial",
--         output = function ( model )
--             counter = 0
--             forEachOrderedElement(model.cs.cells, function(id, at, ty)
--                 if at.state == "alive" then
--                     counter = counter + 1
--                 end
--             end)
--             return counter
--         end
--     }
-- end)

-- sensivityTest:saveCSV("results", ";")

