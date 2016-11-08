-- @example Basic example for testing Calibration type, 
-- using factorial strategy.
if not isLoaded("calibration") then
	import("calibration")
end

local MyModel = Model{
	x = Choice{-100, -1, 0, 1, 2, 100},
	y = Choice{min = 1, max = 10, step = 1},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
	}
	end}


local m = MultipleRuns{
	model = MyModel,
	strategy = "factorial",
	parameters = {
		x = Choice{-100, -1, 0, 1, 2, 100},
		y = Choice{min = 1, max = 10, step = 1},
		finalTime = 1
	 }
}
