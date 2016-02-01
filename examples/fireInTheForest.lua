if not isLoaded("ca") then
   import("ca")
end

import("calibration")
local treesSum = 0
local counter = 0

function CellularAutomataModelCalibration(data)
	mandatoryTableArgument(data, "changes", "function")
	mandatoryTableArgument(data, "dim", "number")
	optionalTableArgument(data, "init", "function")
	optionalTableArgument(data, "space", "function")
	optionalTableArgument(data, "neighborhood", "string")

	local init = data.init
	data.init = nil

	local changes = data.changes
	data.changes = nil

	local space = data.space
	data.space = nil

	data.init = function(instance)
		instance.cell = Cell{
			init = init,
			changes = changes
		}

		if space then
			instance.cs = space(instance)
			instance.cs.changes = function(self)
				forEachCell(self, function(cell)
					changes(cell)
				end)
			end
		else
			instance.cs = CellularSpace{
				xdim = instance.dim,
				instance = instance.cell
			}

			instance.cs:createNeighborhood{strategy = data.neighborhood}
		end

		instance.timer = Timer{
            Event{priority = "high", action = function (ev)
				instance.cs:synchronize()
				instance.cs:changes(ev)
            end},    
			Event{start = 0, priority = "low", action = function()
				instance.cs:notify()
				instance:notify()
			end}
		}
	end

	return Model(data)
end

local FireCalibration = CellularAutomataModelCalibration{
	finalTime = 100,
	empty = Choice{min = 0, max = 1, default = 0.1},
	dim = 60,
	space = function(model)
		local cell = Cell{
			init = function(cell)
				if Random():number() > model.empty then
					cell.state = "forest"
				else
					cell.state = "empty"
				end
			end
		}

		local cs = CellularSpace{
			xdim = model.dim,
			instance = cell
		}

		cs:sample().state = "burning"
		cs:createNeighborhood{strategy = "vonneumann"}

		cs.burned = function()
			return #Trajectory{target = cs, select = function(cell)
				return cell.state == "burned"
			end}
		end

		cs.forest = function()
			return #Trajectory{target = cs, select = function(cell)
				return cell.state == "forest"
			end}
		end

		return cs
	end,
	changes = function(cell)
		if cell.past.state == "burning" then
			cell.state = "burned"
		elseif cell.past.state == "forest" then
			local burning = countNeighbors(cell, "burning")
			if burning > 0 then
				cell.state = "burning"
			end
		end
	end
}

local results = SAMDE{
	model = FireCalibration,
	parameters = {empty = Choice{min = 0, max = 1}},
	size = 30,
	maxGen = 10,
	fit = function(model)
		local trees = 0
		local total = 0
		forEachCell(model.cs, function(cell)
			total = total + 1
			if cell.state == "forest" then
				trees = trees + 1
			end
		end)
		return (1 - trees/(total - model.empty))
end}

print(results.fit)
print ("end")	