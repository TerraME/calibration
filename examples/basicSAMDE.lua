-- @example Basic example for testing SAMDE type, 
-- using a simple equation and variating it's x and y parameters.
if not isLoaded("calibration") then
	import("calibration")
end

local MyModelSamde = Model{
	x = Choice{min = 1, max = 10},
	y = Choice{min = 1, max = 10},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
	end
}
local c2 = SAMDE{
	model = MyModelSamde,
	size = 30,
	maxGen = 100,
	threshold = 1,
	parameters = {x = Choice{min = 1, max = 10}, y = Choice{min = 1, max = 10}},
	fit = function(model)
		model:execute()
		return model.value
	end
}
print("Example Result: (SAMDE)\n")
print("Type result: "..type(c2))
print("Best Cost: "..c2.fit)
forEachOrderedElement(c2.parameters, function(idx, att, type)
	print("Best "..idx..": "..c2.instance[idx])
end)
print("")