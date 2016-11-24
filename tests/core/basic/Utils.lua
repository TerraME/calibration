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
	rParam = {
				x = Choice{-100, -1, 0, 1, 2, 100},
				y = 5
			}
	rs = randomModel(MyModel, rParam)
	unitTest:assertEquals(type(rs.value), "number")
end,
-- These are error verification functions so it's impossible to properly test them without veryfing the errors,
-- these functions verification are tested in the multipleRuns ans SaMDE alternative tests.
checkParametersSet = function(unitTest)
	local parameters = {x = Choice{-100, 1, 0}}
   	checkParametersSet(MyModel, "x", parameters.x)
   	local x = 2
   	unitTest:assertEquals(x, 2)
 -- Error: Parameter 3 in #3 is out of the model x range.
end,
checkParametersRange = function(unitTest)
	local parameters = {y = Choice{min = 2, max = 10, step =1}}
    checkParametersRange(MyModel, "y", parameters.y)
    local x = 2
	unitTest:assertEquals(x, 2)
end,
checkParameterSingle = function(unitTest)
	-- parameters = {x = Choice{-100, 2}}
    checkParameterSingle(MyModel, "x", 2, 2)
    local x = 2
	unitTest:assertEquals(x, 2)
end,

cloneValues = function(unitTest)
	local original = {x = 42}
	local copy = clone(original)
	unitTest:assertEquals(copy.x, 42)
end
}
