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

return{
randomModel = function(unitTest)
	local rParam = {
				x = {-100, -1, 0, 1, 2, 100},
				y = {min = 1, max = 10, step = 1},
				seed = 1001
			}
	local rs = randomModel(MyModel, rParam)
	unitTest:assert_equal(rs.value, 19709)
end,
printParamsTable = function(unitTest)
	unitTest:assert(true)
end,
checkParameters = function(unitTest)
	-- The tests for the checkParameter function are the same as the alternative Multiple Runs tests that use it.
	unitTest:assert(true)
end
}
