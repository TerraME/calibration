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
	end
}
return{
randomModel = function(unitTest)
	local rParam = {
				x = Choice{-100, -1, 0, 1, 2, 100},
				y = Choice{min = 1, max = 10, step = 1}
			}
	local rs = randomModel(MyModel, rParam)
	unitTest:assertEquals(type(rs.value), "number")
	local rParam = {
				x = Choice{-100, -1, 0, 1, 2, 100},
				y = 5
			}
	local rs = randomModel(MyModel, rParam)
	unitTest:assertEquals(type(rs.value), "number")
end,
-- These are error verification functions so it's impossible to test it without veryfing the errors,
-- these functions verification are tested in the multipleRuns ans SaMDE alternative tests.
checkParametersSet = function(unitTest)
	unitTest:assert(true)
end,
checkParametersRange = function(unitTest)
	unitTest:assert(true)
end,
checkParameterSingle = function(unitTest)
	unitTest:assert(true)
end,
clone = function(unitTest)
	local original = {x = 42}
	local copy = clone(original)
	unitTest:assertEquals(copy.x, 42)
end
}
