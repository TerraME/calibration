-- @example Fire in the forest example using  multiple runs repeateated strategy.

if not isLoaded("ca") then
   import("ca")
end

import("calibration")

local m = MultipleRuns{
	model = Fire,
	hideGraphs = true,
	repeats = 30,
	showProgress = true,
	parameters = {
		empty = 0.3,
		dim = 30
	},
	forest = function(model)
		return model.cs:forest()
	end
}

local sum = 0
forEachElement(m.forest, function(idx, value)
	sum = sum + value
end)

average = sum / m.repeats

print("Average forest in the end of "..m.repeats.." simulations: "..average)

