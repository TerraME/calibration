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
			showProgress = false,
			parameters = {
				position = {
					x = Choice{-100, -1, 0, 1, 2, 100},
					y = Choice{min = 1, max = 10, step = 1}},
				finalTime = 1
			 },
			additionalF = function()
				return "test"
			end
		}

		unitTest:assertEquals(mPosition.output.position_x[1], -100)
		unitTest:assertEquals(mPosition.output[1].position_y, 1)
		unitTest:assertEquals(mPosition.output[1].simulations, 'finalTime_1_position_x_-100_position_y_1_')

		local mPosition2 = MultipleRuns{
			model = MyModelPosition,
			showProgress = false,
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
			end
		}

		unitTest:assertEquals(mPosition2.output[1].position.x, -100)
		unitTest:assertEquals(mPosition2.output[1].position.y, 1)

		local m4Tab = MultipleRuns{
			model = MyModel3,
			showProgress = false,
			strategy = "sample",
			parameters = {
				parameters3 = {
					x = Choice{-100, -1, 0, 1, 2, 100},
					y = Choice{min = 1, max = 10, step = 1},
					z = 1
				},
			},
			quantity = 5,
			repetition = 2
		}

		unitTest:assertEquals(m4Tab.output.simulations[5], "1_execution_3")
		unitTest:assertEquals(m4Tab.output.simulations[6], "2_execution_3")
		unitTest:assertEquals(m4Tab.output.simulations[1], "1_execution_1")
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
	end,
	timeToString = function(unitTest)
		local t1 = 0
		unitTest:assertEquals(timeToString(t1), "less than one second")
		local t2 = 1
		unitTest:assertEquals(timeToString(t2), "1 second")
		local t3 = 2
		unitTest:assertEquals(timeToString(t3), "2 seconds")
		local t4 = 59
		unitTest:assertEquals(timeToString(t4), "59 seconds")
		local t5 = 60
		unitTest:assertEquals(timeToString(t5), "1 minute")
		local t6 = 61
		unitTest:assertEquals(timeToString(t6), "1 minute and 1 second")
		local t7 = 62
		unitTest:assertEquals(timeToString(t7), "1 minute and 2 seconds")
		local t8 = 300
		unitTest:assertEquals(timeToString(t8), "5 minutes")
		local t9 = 3599
		unitTest:assertEquals(timeToString(t9), "59 minutes and 59 seconds")
		local t10 = 3600
		unitTest:assertEquals(timeToString(t10), "1 hour")
		local t11 = 3601
		unitTest:assertEquals(timeToString(t11), "1 hour")
		local t12 = 3659
		unitTest:assertEquals(timeToString(t12), "1 hour")
		local t13 = 3660
		unitTest:assertEquals(timeToString(t13), "1 hour and 1 minute")
		local t14 = 3720
		unitTest:assertEquals(timeToString(t14), "1 hour and 2 minutes")
		local t15 = 7200
		unitTest:assertEquals(timeToString(t15), "2 hours")
		local t16 = 7259
		unitTest:assertEquals(timeToString(t16), "2 hours")
		local t17 = 7260
		unitTest:assertEquals(timeToString(t17), "2 hours and 1 minute")
		local t18 = 7320
		unitTest:assertEquals(timeToString(t18), "2 hours and 2 minutes")
		local t19 = 86399
		unitTest:assertEquals(timeToString(t19), "23 hours and 59 minutes")
		local t20 = 86400
		unitTest:assertEquals(timeToString(t20), "1 day")
		local t21 = 86401
		unitTest:assertEquals(timeToString(t21), "1 day")
		local t22 = 86460
		unitTest:assertEquals(timeToString(t22), "1 day")
		local t23 = 90000
		unitTest:assertEquals(timeToString(t23), "1 day and 1 hour")
		local t24 = 93600
		unitTest:assertEquals(timeToString(t24), "1 day and 2 hours")
		local t25 = 172800
		unitTest:assertEquals(timeToString(t25), "2 days")
		local t26 = 86465321
		unitTest:assertEquals(timeToString(t26), "1000 days and 18 hours")
	end
}
