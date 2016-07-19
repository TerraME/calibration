-- @example Fire in the forest example using  multiple runs repeateated strategy.

if not isLoaded("ca") then
   import("ca")
end

import("calibration")

local m = MultipleRuns{
	model = Fire,
	hideGraphs = true,
	repetition = 30,
	showProgress = true,
	parameters = {scenario = {
		empty = 0.3,
		dim = 30
	}},
	forest = function(model)
		return model.cs:forest()
	end
}

local sum = 0
forEachElement(m.forest, function(idx, value)
	sum = sum + value
end)

average = sum / m.repetition

print("Average forest in the end of "..m.repetition.." simulations: "..average)

