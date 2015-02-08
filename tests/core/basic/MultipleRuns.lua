local MyModel = Model{
	x = choice{-100, -1, 0, 1, 2, 100},
	y = choice{ min = 1, max = 10, step = 1},
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
	finalTime = 1,
	parameters = {
		x = {-100, -1, 0, 1, 2, 100},
		y = { min = 1, max = 10, step = 1}
	 },
	output = function(model)
		return model.value
	end}

local r = m:execute()

return{
execute = function(unitTest)
		unitTest:assert(true)
end,
get = function (unitTest)
	unitTest:assert_equal(m:get(r,1).x, -100)
		unitTest:assert_equal(m:get(r,1).y, 1)
end,
MultipleRuns = function(unitTest)
	unitTest:assert(true)
end}
