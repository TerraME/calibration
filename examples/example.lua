-- @example Basic example for testing SAMDE type, 
-- using a simple equation and variating it's x and y parameters.
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
	end}

local c2 = Calibration{
	model = MyModelSamde,
	parameters = {x = {min = 1, max = 10}, y = {min = 1, max = 10}},
	fit = function(model)
		return model.value
	end}
local result2 = c2:execute()
print("Example Result: (SAMDE)\n")
c2:printResults(result2)

