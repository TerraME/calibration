-- @example Fire in the forest example using  multiple runs repeateated strategy.
if not isLoaded("ca") then
   import("ca")
end

Random{seed = 70374981}
import("calibration")

local m = MultipleRuns{
	model = Fire,
	repetition = 30,
	parameters = {
		--empty = 0.4,
		empty = Choice{min = 0.2, max = 0.9, step = 0.1},--0.4,
		dim = 30
	},
	summary = function(df)
        local sum = 0
        max = -math.huge
        min = math.huge

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
            average = sum / m.repetition,
            max = max,
            min = min
        }
    end,
	forest = function(model)
		return model.cs:state().forest or 0
	end
}

chart = Chart{
    target = m.summaryOutput,
    select = "average",
    xAxis = "empty"
}

local sum = 0
forEachElement(m.output, function(_, value)
	sum = sum + value.forest
end)

average = sum / m.repetition

print("Average forest in the end of "..m.repetition.." simulations: "..average)

