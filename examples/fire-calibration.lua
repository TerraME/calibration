-- @example Fire in the forest example using  multiple runs repeateated strategy.
if not isLoaded("ca") then
   import("ca")
end
import("calibration")
i = 0

local m = MultipleRuns{
	model = Fire,
	hideGraphs = true,
	strategy = "repeated", 
	repeats = 10,
	parameters = {
		empty = 0.3,
		dim = 30
	},
	forest = function(model)
		print(i) 
		i = i + 1
		return model.cs:forest()
	end
}
local sum = 0
forEachElement(m.forest, function(idx, value)
	sum = sum + value
end)

print("Average forest in the end of "..m.repeats.." simulations: "..sum / m.repeats)

