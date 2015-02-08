return{
MultipleRuns = function(unitTest)
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

	r = m:execute()
	print(type(r))
	unitTest:assert(true)
end}
