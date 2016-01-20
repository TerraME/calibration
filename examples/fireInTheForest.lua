import("ca")
import("calibration")
local treesSum = 0
local counter = 0

--- Template for Cellular Automata Model.
-- @arg data.dim A number with the x and y sizes of space.
-- @arg data.map A table with some parameters to visualize
-- the CellularSpace.
-- @tabular map
-- Map  & Description \
-- "select" & A string with the name of the attribute to be visualized. \
-- "value" &  A table with the possible values of the cellular automata. \
-- "color" & A table with the colors for the respective values.
-- @arg data.init A function that describes how a Cell will be initialized.
-- @arg data.changes A function that describes how each Cell is updated.
-- @usage import("ca")
--
-- Anneal = CellularAutomataModel{
--     finalTime = 30,
--     dim = 80,
--     init = function(cell)
--         if Random():number() > 0.5 then
--             cell.state = "L"
--         else
--             cell.state = "R"
--         end
--     end,
--     changes = function(cell)
--         local alive = countNeighbors(cell, "L")
--
--         if cell.state == "L" then alive = alive + 1 end
--
--         if alive <= 3 then
--             cell.state = "R"
--         elseif alive >= 6 then
--             cell.state = "L"
--         elseif alive == 4 then
--             cell.state = "L"
--         elseif alive == 5 then
--             cell.state = "R"
--         end
--     end,
--     map = {
--         select = "state",
--         value = {"L", "R"},
--         color = {"black", "white"}
--     }
-- }
--
-- Anneal:execute()
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


-- A Model to simulate fire in the forest.
-- @arg data.finalTime A number with the final time of the simulation.
-- @arg data.dim A number with the x and y size of space.
-- @arg data.empty The percentage of empty cells in the beginning of the
-- simulation. It must be a value between 0 and 1, with default 0.1.
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

local fireForest = MultipleRuns{
	model = FireCalibration,
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
		return trees
	end
}

print(treesSum/counter)
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
print ("end")
print(results.fit
	
-- 1762.6
-- end
-- 0.35382580034567