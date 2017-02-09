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
local MyModel3 = Model{
	parameters3 = {
		x = Choice{-100, -1, 0, 1, 2, 100, 200},
		y = Choice{min = 1, max = 10, step = 1},
		z = Choice{-50, -3, 0, 1, 2, 50}
	},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.parameters3.x ^2 - 3 * self.parameters3.x + 4 + self.parameters3.y
			end}
	}
end
}
local MyModelPosition = Model{
	position = {
		x = Choice{-100, -1, 0, 1, 2, 100},
		y = Choice{min = 1, max = 10, step = 1}
	},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.position.x ^2 - 3 * self.position.x + 4 + self.position.y
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
	local mPosition = MultipleRuns{
		model = MyModelPosition,
		parameters = {
			position = {
				x = Choice{-100, -1, 0, 1, 2, 100},
				y = Choice{min = 1, max = 10, step = 1}},
			finalTime = 1
		 },
		additionalF = function(_)
			return "test"
		end,
		output = {"value"}
	}
	local mPosition2 = MultipleRuns{
		model = MyModelPosition,
		strategy = "selected",
		parameters = {
			scenario1 = {
				position = {
					x = -100,
					y = 1
				},
				finalTime = 1
			},
			scenario2 = {
				position = {
					x = 100,
					y = 2
				},
				finalTime = 1
			}
		 },
		additionalF = function(_)
			return "test"
		end,
		output = {"value"}
	}
	local m4Tab = MultipleRuns{
		model = MyModel3,
		strategy = "sample",
		parameters = {
			parameters3 = {
				x = Choice{-100, -1, 0, 1, 2, 100},
				y = Choice{min = 1, max = 10, step = 1},
				z = 1
			},
		},
		quantity = 5,
		repetition = 2,
		output = {"value"}
	}
	unitTest:assert(m4Tab:get(5).simulations == "1_execution_5")
	unitTest:assertEquals(m4Tab:get(6).simulations, "2_execution_1")
	unitTest:assertEquals(m4Tab:get(1).simulations, "1_execution_1")
	unitTest:assertEquals(mPosition2:get(1).position.x, -100)
	unitTest:assertEquals(mPosition2:get(1).position.y, 1)
	unitTest:assertEquals(mPosition:get(1).position.x, -100)
	unitTest:assertEquals(mPosition:get(1).position.y, 1)
	unitTest:assertEquals(mPosition:get(1).simulations, 'finalTime_1_position_x_-100_position_y_1_')
end,
checkParameterSingle = function(unitTest)
	-- parameters = {x = Choice{-100, 2}}
    checkParameterSingle(MyModel, "x", 2, 2)
    local x = 2
	unitTest:assertEquals(x, 2)
end,
cloneValues = function(unitTest)
	local original = {positionxy = {x = 42, y = 3}, positionxy2 = {x = Choice{2,3,4}, y = "a"}}
	local copy =  cloneValues(original)
	unitTest:assertEquals(copy.positionxy.x, 42)
end
}
