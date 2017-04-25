-- @example Fire in the forest example using  multiple runs repeateated strategy.
if not isLoaded("ca") then
   import("ca")
end

Random{seed = 70374981}
import("calibration")

local m = MultipleRuns{
	model = Fire,
	repetition = 30,
	showProgress = true,
	parameters = {scenario = {
		empty = 0.4,
		--empty = Choice{min = 0.2, max = 0.9, step = 0.1},--0.4,
		dim = 30
	}},
	forest = function(model)
		return model.cs:state().forest or 0
	end,
	summary = function(self, df)
		local sum = 0
        local max = -math.huge
        local min = math.huge

        forEachElement(df, function(_, dfAtt)
        	local value = dfAtt.forest
            sum = sum + value

            if max < value then
                max = value
            end

            if min > value then
                min = value
            end
        end)

        return {
            average = sum / self.repetition,
            max = max,
            min = min
        }
	end
}

local sum = 0
forEachElement(m.output, function(_, value)
	sum = sum + value.forest
end)

average = sum / m.repetition

print("Average forest in the end of "..m.repetition.." simulations: "..average)

