-- @example Fire in the forest example using  multiple runs factorial strategy and summary function.

if not isLoaded("ca") then
   import("ca")
end

Random{seed = 70374981}
local m = MultipleRuns{
	model = Fire,
	repetition = 30,
	parameters = {
		--empty = 0.4,
		empty = Choice{min = 0.3, max = 0.7, step = 0.1},--0.4,
		dim = 30
	},
	summary = function(df, data, inputVariables)
        local sum = 0
        local empty = inputVariables.empty
        local max = -math.huge
        local min = math.huge

        forEachElement(df.forest, function(_, value)

            sum = sum + value

            if max < value then
                max = value
            end

            if min > value then
                min = value
            end
        end)

        return {
            empty = empty,
            average = sum / data.repetition,
            max = max,
            min = min
        }
    end,
	forest = function(model)
		return model.cs:state().forest or 0
	end
}

forEachElement(m.summaryOutput, function(_, value)
    print("Average forest in the end of "..m.repetition.." simulations: "..value.average)
end)

sOutput = {}

forEachElement(m.summaryOutput, function(idx, value)
    forEachElement(value, function(idx2, value2)
        if sOutput[idx2] == nil then
            sOutput[idx2] = {}
        end
        sOutput[idx2][idx] = value2

    end)
end)
local chartData = DataFrame(sOutput)
chart = Chart{
    target = chartData,
    select = "average",
    xAxis = "empty"
}
--print(vardump(sOutput))
--print(" -- ")
--print(vardump(chartData))




