local MyModel = Model{
	x = Choice{-100, -1, 0, 1, 2, 100},
	y = Choice{ min = 1, max = 10, step = 1},
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
		x = {-100, -1, 0, 1, 2, 100},
		y = { min = 1, max = 10, step = 1}
	 },
	output = function(model)
		return model.value
	end}

local m2 = MultipleRuns{
	model = MyModel,
	strategy = "selected",
	parameters = {
		scenario1 = {x = 2, y = 5},
		scenario2 = {x = 1, y = 3}
	 },
	output = function(model)
		return model.value
	end}

local m3 = MultipleRuns{
	model = MyModel,
	strategy = "repeated",
	parameters = {x = 2, y = 5},
	quantity = 3,
	output = function(model)
		return model.value
	end}

local m4 = MultipleRuns{
	model = MyModel,
	strategy = "sample",
	parameters = {
		x = {-100, -1, 0, 1, 2, 100},
		y = { min = 1, max = 10, step = 1}
	 },
	quantity = 5,
	output = function(model)
		return model.value
	end}


local r = m:execute()
local r2 = m2:execute()
local r3 = m3:execute()
local r4 = m4:execute()

return{
execute = function(unitTest)
		unitTest:assert(true)
end,

output = function(unitTest)
	unitTest:assert(true)
end,

get = function (unitTest)
	unitTest:assert_equal(m:get(r, 1).x, -100)
	unitTest:assert_equal(m:get(r, 1).y, 1)
	unitTest:assert_equal(m2:get(r2, 1).x, 2)
	unitTest:assert_equal(m2:get(r2, 1).y, 5)
	unitTest:assert_equal(m2:get(r2, 2).x, 1)
	unitTest:assert_equal(m2:get(r2, 2).y, 3)
	unitTest:assert(m3:get(r3, 1).x == 2 and m3:get(r3, 2).x == 2 and m3:get(r3, 3).x == 2)
	unitTest:assert(m3:get(r3, 1).y == 5 and m3:get(r3, 2).y == 5 and m3:get(r3, 3).y == 5)
	unitTest:assert(m4:get(r4, 5).simulations == "5")
end,

MultipleRuns = function(unitTest)
	unitTest:assert(true)
end}
