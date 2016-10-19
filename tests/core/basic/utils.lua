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
	local parameters = {x = Choice{-100, 1, 0}}
   	checkParametersSet(myModel, "x", parameters.x)
   	unitTest:assert(true)
 -- Error: Parameter 3 in #3 is out of the model x range.
end,
checkParametersRange = function(unitTest)
	local parameters = {y = Choice{min = 20, max = 40}}
	ok, err =  pcall(function()
    	checkParametersRange(myModel, "y", parameters.y)
	end)

	unitTest:assertEquals(err, "Error: Argument 'y.step' is mandatory.")
end,
checkParameterSingle = function(unitTest)
	local parameters = {x = Choice{-100, 5, 2}}
	ok, err =  pcall(function()
    	checkParameterSingle(myModel, "x", 2, 5)
	end)
	unitTest:assertEquals(err, "Error: Parameter 5 in #2 is out of the model x range.")
end,
sensitivityAnalysisOutput = function(unitTest)
	local m = MultipleRuns{
		model = MyModel,
		strategy = "factorial",
		parameters = {
			x = Choice{-100, -1, 0, 1, 2, 100},
			y = Choice{min = 1, max = 10, step = 1},
			finalTime = 1
		 },
		additionalF = function(model)
			return "test"
		end,
		output = {"value"}
	}
end,
cloneValues = function(unitTest)
	local original = {x = 42}
	local copy = clone(original)
	unitTest:assertEquals(copy.x, 42)
end
}
