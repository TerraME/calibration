-- Creating Models
local MyModel = Model{
	x = Choice{-100, -1, 0, 1, 2, 100},
	y = Choice{min = 1, max = 10, step = 1},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
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
local MyModel2 = Model{
	x = Choice{-100, -1, 0, 1, 2, 100},
	y2 = Mandatory("number"),
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y2
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
-- It's here just so all lines are executed:
local MyModel3Inv = Model{
	parameters3 = {
		x = Choice{-100, -1, 0, 1, 2, 100},
		y = Choice{min = 1, max = 10, step = 1},
		f = Choice{1, 2 ,3}
	},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.parameters3.f ^2 - 3 * self.parameters3.f + 4 + self.parameters3.y
			end}
	}
end
}
local MyModel4 = Model{
	x = Choice{-100, -1, 0, 1, 2, 100},
	y = Choice{min = 1, max = 10, step = 1},
	z = Choice{-50, -3, 0, 1, 2, 50},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = self.z * 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
	}
	end
}

return{
	MultipleRuns = function(unitTest)
		local m = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			parameters = {
				x = Choice{-100, -1, 0, 1, 2, 100},
				y = Choice{min = 1, max = 10, step = 1},
				finalTime = 1
			 },
			additionalF = function(_)
				return "test"
			end,
			output = {"value"}
		}

		unitTest:assertEquals(m.output.x[1], -100)
		unitTest:assertEquals(m.output.y[1], 1)
		unitTest:assertEquals(m.output.simulations[1], 'finalTime_1_x_-100_y_1_')

		local mPosition = MultipleRuns{
			model = MyModelPosition,
			parameters = {
				position = {
					x = Choice{-100, -1, 0, 1, 2, 100},
					y = Choice{min = 1, max = 10, step = 1}
				},
				finalTime = 1
			 },
			additionalF = function(_)
				return "test"
			end,
			output = {"value"}
		}

		unitTest:assertEquals(mPosition.output[1].position_x, -100)
		unitTest:assertEquals(mPosition.output[1].position_y, 1)
		unitTest:assertEquals(mPosition.output[1].simulations, 'finalTime_1_position_x_-100_position_y_1_')

		local mQuant = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			repetition = 2,
			parameters = {
				x = Choice{-100, -1, 0, 1, 2, 100},
				y = Choice{min = 1, max = 10, step = 1},
				finalTime = 1
			 },
			additionalF = function(_)
				return "test"
			end,
			output = {"value"}
		}

		unitTest:assertEquals(mQuant.output[1].simulations, '1_execution_finalTime_1_x_-100_y_1_')
		unitTest:assertEquals(mQuant.output[61].simulations, '2_execution_finalTime_1_x_-100_y_1_')

		local mQuant2 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			repetition = 2,
			parameters = {
				x = Choice{-100, -1, 0, 1, 2, 100},
				y = Choice{1,2,3,4,5},
				finalTime = 1
			 },
			additionalF = function(_)
				return "test"
			end,
			output = {"value"}
		}

		unitTest:assertEquals(mQuant2.output[1].simulations, '1_execution_finalTime_1_x_-100_y_1_')

		local mMan = MultipleRuns{
			model = MyModel2,
			strategy = "factorial",
			parameters = {
				x = Choice{-100, -1, 0, 1, 2, 100},
				y2 = Choice{min = 1, max = 10, step = 1},
				finalTime = 1
			 },
			additionalF = function(_)
				return "test"
			end,
			output = {"value"}
		}

		unitTest:assertEquals(mMan.output[1].x, -100)
		unitTest:assertEquals(mMan.output[1].y2, 1)
		unitTest:assertEquals(mMan.output[1].simulations, 'finalTime_1_x_-100_y2_1_')

		local mMandChoiceTable = MultipleRuns{
			model = MyModel2,
			strategy = "factorial",
			parameters = {
					x = Choice{-100, -1, 0, 1, 2, 100},
					y2 = Choice{1,2,3,4,5},
				finalTime = 1
			 },
			additionalF = function(_)
				return "test"
			end,
			output = {"value"}
		}

		unitTest:assertEquals(mMandChoiceTable.output[1].x, -100)
		unitTest:assertEquals(mMandChoiceTable.output[1].y2, 1)

		local mTab = MultipleRuns{
			model = MyModel3,
			strategy = "factorial",
			parameters = {
				parameters3 = {
					x = Choice{-100, -1, 0, 1, 2, 100},
					y = Choice{min = 1, max = 10, step = 1},
					z = 1
				 },
				finalTime = 1
			},
			additionalF = function(model)
				return (model.value)
			end,
			output = {"value"}
		}

		unitTest:assertEquals(mTab.output[1].parameters3_x, -100)
		unitTest:assertEquals(mTab.output[1].parameters3_y, 1)
		unitTest:assertEquals(mTab.output[1].simulations, 'finalTime_1_parameters3_x_-100_parameters3_y_1_parameters3_z_1_')

		local mTab2 = MultipleRuns{
			model = MyModel3Inv,
			strategy = "factorial",
			parameters = {
				parameters3 = {
					x = Choice{-100, -1, 0, 1, 2, 100},
					y = Choice{min = 1, max = 10, step = 1},
					f = 1
				 },
				finalTime = 1
			},
			additionalF = function(model)
				return (model.value)
			end
		}

		unitTest:assertEquals(mTab2.output[1].parameters3_x, -100)
		unitTest:assertEquals(mTab2.output[1].parameters3_y, 1)

		local mSingle = MultipleRuns{
			model = MyModel4,
			parameters = {
				x = Choice{-100, -1, 0, 1, 2, 100},
				y = Choice{min = 1, max = 10, step = 1},
				z = 1,
				finalTime = 1
			 },
			additionalF = function(_)
				return "test"
			end,
			output = {"value"}
		}

		unitTest:assertEquals(mSingle.output[1].x, -100)
		unitTest:assertEquals(mSingle.output[1].y, 1)
		unitTest:assertEquals(mSingle.output[1].simulations, 'finalTime_1_x_-100_y_1_z_1_')

		local m2 = MultipleRuns{
			model = MyModel,
			strategy = "selected",
			parameters = {
				scenario1 = {x = 2, y = 5},
				scenario2 = {x = 1, y = 3}
			 },
			output = {"value"},
			additionalF = function(_)
				return "test"
			end
		}

		unitTest:assertEquals(m2.output[1].x, 2)
		unitTest:assertEquals(m2.output[1].y, 5)
		unitTest:assertEquals(m2.output[2].x, 1)
		unitTest:assertEquals(m2.output[2].y, 3)
		unitTest:assertEquals(m2.output[1].simulations, "scenario1")

		local m2Tab = MultipleRuns{
			model = MyModel3,
			parameters = {
				scenario1 = {parameters3 = {x = 2, y = 5, z = 1}},
				scenario2 = {parameters3 = {x = 1, y = 3, z = 1}}
			 },
			output = {"value"}
		}

		unitTest:assertEquals(m2Tab.output[1].parameters3.x, 2)
		unitTest:assertEquals(m2Tab.output[1].parameters3.y, 5)
		unitTest:assertEquals(m2Tab.output[2].parameters3.x, 1)
		unitTest:assertEquals(m2Tab.output[2].parameters3.y, 3)
		unitTest:assertEquals(m2Tab.output[1].simulations, "scenario1")

		local m3 = MultipleRuns{
			model = MyModel,
			parameters = {scenario1 = {x = 2, y = 5}},
			repetition = 3,
			output = {"value"},
			additionalF = function(_)
				return "test"
			end
		}

		unitTest:assertEquals(m3.output[1].x, 2)
		unitTest:assertEquals(m3.output[2].x, 2)
		unitTest:assertEquals(m3.output[3].x, 2)
		unitTest:assertEquals(m3.output[1].y, 5)
		unitTest:assertEquals(m3.output[2].y, 5)
		unitTest:assertEquals(m3.output[3].y, 5)
		unitTest:assertEquals(m3.output[1].simulations, "1_execution_scenario1")

		local m3Tab = MultipleRuns{
			model = MyModel3,
			parameters = {scenario1 = {parameters3 = {x = 2, y = 5, z = 1}}},
			repetition = 3,
			output = {"value"}
		}

		-- CHECK HERE!! It should be parameters3_x

		unitTest:assertEquals(m3Tab.output[1].parameters3.x, 2)
		unitTest:assertEquals(m3Tab.output[2].parameters3.x, 2)
		unitTest:assertEquals(m3Tab.output[3].parameters3.x, 2)
		unitTest:assertEquals(m3Tab.output[1].parameters3.y, 5)
		unitTest:assertEquals(m3Tab.output[2].parameters3.y, 5)
		unitTest:assertEquals(m3Tab.output[3].parameters3.y, 5)
		unitTest:assertEquals(m3Tab.output[1].simulations, "1_execution_scenario1")

		local m4 = MultipleRuns{
			model = MyModel,
			parameters = {
				x = Choice{-100, -1, 0, 1, 2, 100},
				y = Choice{min = 1, max = 10, step = 1}
			 },
			quantity = 5,
			output = {"value"},
			additionalF = function(_)
				return "test"
			end
		}

		unitTest:assertEquals(m4.output[5].simulations, "5")
		unitTest:assertEquals(m4.output[1].simulations, "1")

		local m4Single = MultipleRuns{
			model = MyModel4,
			strategy = "sample",
			parameters = {
				x = Choice{-100, -1, 0, 1, 2, 100},
				y = Choice{min = 1, max = 10, step = 1},
				z = 1,
				finalTime = 1
			 },
			quantity = 5,
			output = {"value"}
		}

		unitTest:assertEquals(m4Single.output[5].simulations, "5")
		unitTest:assertEquals(m4Single.output[1].simulations, "1")

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

		unitTest:assertEquals(m4Tab.output[5].simulations, "1_execution_5")
		unitTest:assertEquals(m4Tab.output[6].simulations, "2_execution_1")
		unitTest:assertEquals(m4Tab.output[1].simulations, "1_execution_1")
	end
}
