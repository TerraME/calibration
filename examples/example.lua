-- @example Basic example for testing Calibration type, 
-- using a simple equation and variating it's x and y parameters.
local MyModel = Model{
	x = choice{-100, -1, 0, 1, 2, 100},
	y = choice{ min = 1, max = 10},
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
	end}

c = Calibration{
	model = MyModel,
	finalTime = 1,
	parameters = {x ={-100, -1, 0, 1, 2, 100}, y = { min = 1, max = 10}},
	fit = function(model)
		return model.value
	end}

local MyModelSamde = Model{
	x = choice{ min = 1, max = 10},
	y = choice{ min = 1, max = 10},
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
	end}

local c2 = Calibration{
	model = MyModelSamde,
	finalTime = 1,
	parameters = {x ={ min = 1, max = 10}, y = { min = 1, max = 10}},
	SAMDE = true,
	fit = function(model)
		return model.value
	end}

local result = c:execute()
local result2 = c2:execute()
print("1st Example Result: \n")
c:printResults(result)
print("2st Example Result: (SAMDE)\n")
c2:printResults(result2)