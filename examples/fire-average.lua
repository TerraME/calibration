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
		empty = Choice{min = 0.2, max = 1, step = 0.1},--0.4,
		dim = 30
	},
	forest = function(model)
		return model.cs:state().forest or 0
	end,
	summary = function(result)
        local sum = 0
        local max = -math.huge
        local min = math.huge

        forEachElement(result.forest, function(_, value)
            sum = sum + value

            if max < value then
                max = value
            end

            if min > value then
                min = value
            end
        end)

        return {
            average = sum / #result.forest,
            max = max,
            min = min
        }
    end
}

local sum = 0
forEachElement(m.output, function(_, value)
	sum = sum + value.forest
end)

average = sum / #m.output

print("Average forest in the end of "..#m.output.." simulations: "..average)

m.summary["expected"] = {}
forEachElement(m.summary, function(_, result)
	table.insert(m.summary.expected, result.dim * result.dim * (1-result.empty))
end)

Chart{
    target = m.summary,
    select = {"average", "expected"},
    xAxis = "empty",
	color = {"red", "green"}
}
