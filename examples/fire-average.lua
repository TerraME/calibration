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
        -- chamado apos as 30 repeticoes para uma determinada configuracao de parametros
        -- 30 resultados de 0.2
        -- 30 resultados de 0.3
        -- ...
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
            average = sum / result.repetition, -- should result carry .repetition or it should be get in #result.forest instead?
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

Chart{
    target = m.summary,
    select = "average",
    xAxis = "empty"
}
