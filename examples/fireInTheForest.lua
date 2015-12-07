import("ca")
import("calibration")
local treesSum = 0
local counter = 0
local map = Map
local chart = Chart
Map = function() end
Chart = Map
local fireForest = MultipleRuns{
	model = Fire,
	strategy = "repeated",
	parameters = {empty = 0.5},
	quantity = 5,
	output = function(model)
		local trees = 0
		forEachCell(model.cs, function(cell)
			if cell.state == "forest" then
				trees = trees + 1
			end
		end)
		counter = counter + 1
		treesSum = (trees + treesSum)
		print(trees)
		return trees
	end
}
Map = map
Chart = chart
print(treesSum/counter)