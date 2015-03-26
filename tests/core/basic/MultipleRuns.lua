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
		y = {min = 1, max = 10, step = 1},
		finalTime = 1
	 },
	additionalF = function(model)
		return "test"
	end,
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
	seed = 1001,
	parameters = {
		x = {-100, -1, 0, 1, 2, 100},
		y = {min = 1, max = 10, step = 1},
		seed = 1001
	 },
	quantity = 5,
	output = function(model)
		return model.value
	end}

return{
output = function(unitTest)
	unitTest:assert(true)
end,

get = function (unitTest)

	unitTest:assert_equal(m:get(1).x, -100)
	unitTest:assert_equal(m:get(1).y, 1)
	unitTest:assert_equal(m:get(1).simulations, "x_-100_y_1_")
end,

MultipleRuns = function(unitTest)
	unitTest:assert_equal(m:get(1).x, -100)
	unitTest:assert_equal(m:get(1).y, 1)
	unitTest:assert_equal(m:get(1).simulations, "x_-100_y_1_")
	unitTest:assert_equal(m2:get(1).x, 2)
	unitTest:assert_equal(m2:get(1).y, 5)
	unitTest:assert_equal(m2:get(2).x, 1)
	unitTest:assert_equal(m2:get(2).y, 3)
	unitTest:assert_equal(m2:get(1).simulations, "scenario1")
	unitTest:assert(m3:get(1).x == 2 and m3:get(2).x == 2 and m3:get(3).x == 2)
	unitTest:assert(m3:get(1).y == 5 and m3:get(2).y == 5 and m3:get(3).y == 5)
	unitTest:assert_equal(m3:get(1).simulations, "1")
	unitTest:assert(m4:get(5).simulations == "5")
	unitTest:assert_equal(m4:get(1).simulations, "1")
	unitTest:assert_equal(m:get(1).additionalF, "test")
end}
