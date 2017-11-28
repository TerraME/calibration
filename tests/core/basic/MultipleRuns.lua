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

local MyModel5 = Model{
	x = Choice{-100, -1, 0, 1, 2, 100},
	y = Choice{min = 1, max = 10, step = 1},
	values = {},
	xs = {},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
				table.insert(self.values, self.value)
				table.insert(self.xs, self.timer:getTime())
			end},
			Event{start = finalTime, priority = 5, action = function()
				local df = DataFrame{value = self.values, x = self.xs}
				df:save("data.csv")
			end}
	}
	end
}

local MyModel6 = Model{
	position = {
		x = Choice{-100, -1, 0, 1, 2, 100},
		y = Choice{min = 1, max = 10, step = 1}
	},
	values = {},
	xs = {},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.position.x ^2 - 3 * self.position.x + 4 + self.position.y
				table.insert(self.values, self.value)
				table.insert(self.xs, self.timer:getTime())
			end},
			Event{start = finalTime, priority = 5, action = function()
				local df = DataFrame{value = self.values, x = self.xs}
				df:save("data.csv")
			end}
	}
	end
}

local function fileExists(name)
	local sep = sessionInfo().separator
    return File(currentDir().."results"..sep..name..sep.."data.csv"):exists()
end

return{
	MultipleRuns = function(unitTest)
		local m = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			showProgress = false,
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
			showProgress = false,
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
			showProgress = false,
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
		unitTest:assertEquals(mQuant.output[2].simulations, '2_execution_finalTime_1_x_-100_y_1_')

		local mQuant2 = MultipleRuns{
			model = MyModel,
			strategy = "factorial",
			showProgress = false,
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
			showProgress = false,
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
			showProgress = false,
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
			showProgress = false,
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
			showProgress = false,
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
			showProgress = false,
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
			showProgress = false,
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
			showProgress = false,
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
			showProgress = false,
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
			showProgress = false,
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
			showProgress = false,
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
			showProgress = false,
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
			repetition = 2,
			output = {"value"}
		}

		unitTest:assertEquals(m4Tab.output[5].simulations, "1_execution_3")
		unitTest:assertEquals(m4Tab.output[6].simulations, "2_execution_3")
		unitTest:assertEquals(m4Tab.output[1].simulations, "1_execution_1")

		local summaryM1 = MultipleRuns{
			model = MyModel,
			showProgress = false,
			parameters = {
				x = Choice{-1, 0, 1},
			},
			repetition = 2,
			output = {"value"},
			additionalF = function(model)
				return model.x
			end,
			summary = function(result)
				local s = 0
				forEachElement(result.additionalF, function(_, f)
					s = s + f
				end)
				return {mean = s / result.repetition}
			end
		}

		unitTest:assertEquals(summaryM1.summary.x[1], -1)
		unitTest:assertEquals(summaryM1.summary.mean[1], -1)
		local summaryM2 = MultipleRuns{
			model = MyModelPosition,
			showProgress = false,
			parameters = {
				position = {
					x = Choice{-100, -1, 0, 1, 2, 100},
					y = Choice{1, 2, 3, 4, 5, 6, 7, 9, 10}
				},
				finalTime = 1
			},
			repetition = 2,
			additionalF = function(model)
				return model.position.x + model.position.y
			end,
			summary = function(result)
				local s = 0
				forEachElement(result.additionalF, function(_, f)
					s = s + f
				end)
				return {mean = s / result.repetition}
			end
		}

		unitTest:assertEquals(summaryM2.summary.mean[1], -99)
		unitTest:assertEquals(summaryM2.summary.position[1].x, -100)
		unitTest:assertEquals(summaryM2.summary.position[1].y, 1)
		local summaryM3 = MultipleRuns{
			model = MyModelPosition,
			showProgress = false,
			parameters = {
				position = {
					x = Choice{-100, -1, 0, 1, 2, 100},
					y = Choice{min = 1, max = 10, step = 1}
				},
				finalTime = 1
			},
			repetition = 2,
			additionalF = function(model)
				return model.position.x + model.position.y
			end,
			summary = function(result)
				local s = 0
				forEachElement(result.additionalF, function(_, f)
					s = s + f
				end)
				return {mean = s / result.repetition}
			end
		}

		unitTest:assertEquals(summaryM3.summary.mean[1], -99)
		unitTest:assertEquals(summaryM3.summary.position[1].x, -100)
		unitTest:assertEquals(summaryM3.summary.position[1].y, 1)
		local summaryM4 = MultipleRuns{
			model = MyModel,
			strategy = "selected",
			showProgress = false,
			parameters = {
				scenario1 = {x = 2, y = 5},
				scenario2 = {x = 1, y = 3}
			},
			repetition = 2,
			output = {"value"},
			additionalF = function()
				return 1
			end,
			summary = function(result)
				local s = 0
				forEachElement(result.additionalF, function(_, f)
					s = s + f
				end)

				return {mean = s / result.repetition}
			end
		}

		unitTest:assertEquals(summaryM4.summary.mean[1], 1)
		local summaryM5 = MultipleRuns{
			model = MyModel4,
			showProgress = false,
			strategy = "sample",
			parameters = {
				x = Choice{-100, -1, 0, 1, 2, 100},
				y = Choice{min = 1, max = 10, step = 1},
				z = 1,
				finalTime = 1
			},
			quantity = 5,
			repetition = 2,
			additionalF = function()
				return 1
			end,
			summary = function(result)
				local s = 0
				forEachElement(result.additionalF, function(_, f)
					s = s + f
				end)

				return {mean = s / result.repetition}
			end
		}

		unitTest:assertEquals(summaryM5.summary.mean[1], 1)
		MultipleRuns{
			model = MyModel5,
			showProgress = false,
			parameters = {
				x = Choice{-1, 0, 1},
				y = Choice{1, 2, 3},
			},
			folderName = "results"
		}

		unitTest:assert(fileExists("x_0_y_1_"))
		unitTest:assert(fileExists("x_1_y_1_"))
		unitTest:assert(fileExists("x_-1_y_1_"))
		unitTest:assert(fileExists("x_0_y_2_"))
		unitTest:assert(fileExists("x_1_y_2_"))
		unitTest:assert(fileExists("x_-1_y_2_"))
		unitTest:assert(fileExists("x_0_y_3_"))
		unitTest:assert(fileExists("x_1_y_3_"))
		unitTest:assert(fileExists("x_-1_y_3_"))
		unitTest:assert(Directory(currentDir().."results"):delete())
		MultipleRuns{
			model = MyModel5,
			showProgress = false,
			parameters = {
				x = Choice{-1, 0, 1},
			},
			repetition = 2,
			folderName = "results"
		}

		unitTest:assert(fileExists("1_execution_x_0_"))
		unitTest:assert(fileExists("1_execution_x_1_"))
		unitTest:assert(fileExists("1_execution_x_-1_"))
		unitTest:assert(fileExists("2_execution_x_0_"))
		unitTest:assert(fileExists("2_execution_x_1_"))
		unitTest:assert(fileExists("2_execution_x_-1_"))
		unitTest:assert(Directory(currentDir().."results"):delete())
		MultipleRuns{
			model = MyModel5,
			showProgress = false,
			parameters = {
				x = Choice{0, 1},
				y = Choice{1, 2}
			},
			repetition = 2,
			folderName = "results"
		}

		unitTest:assert(fileExists("1_execution_x_0_y_1_"))
		unitTest:assert(fileExists("1_execution_x_0_y_2_"))
		unitTest:assert(fileExists("1_execution_x_1_y_1_"))
		unitTest:assert(fileExists("1_execution_x_1_y_2_"))
		unitTest:assert(fileExists("2_execution_x_0_y_1_"))
		unitTest:assert(fileExists("2_execution_x_0_y_2_"))
		unitTest:assert(fileExists("2_execution_x_1_y_1_"))
		unitTest:assert(fileExists("2_execution_x_1_y_2_"))
		unitTest:assert(Directory(currentDir().."results"):delete())
		MultipleRuns{
			model = MyModel6,
			showProgress = false,
			parameters = {position = {
				x = Choice{0, 1},
				y = Choice{1, 2}
			}},
			repetition = 2,
			folderName = "results"
		}

		unitTest:assert(fileExists("1_execution_position_x_0_position_y_1_"))
		unitTest:assert(fileExists("1_execution_position_x_0_position_y_2_"))
		unitTest:assert(fileExists("1_execution_position_x_1_position_y_1_"))
		unitTest:assert(fileExists("1_execution_position_x_1_position_y_2_"))
		unitTest:assert(fileExists("2_execution_position_x_0_position_y_1_"))
		unitTest:assert(fileExists("2_execution_position_x_0_position_y_2_"))
		unitTest:assert(fileExists("2_execution_position_x_1_position_y_1_"))
		unitTest:assert(fileExists("2_execution_position_x_1_position_y_2_"))
		unitTest:assert(Directory(currentDir().."results"):delete())

		MultipleRuns{
			model = MyModel5,
			showProgress = false,
			strategy = "selected",
			parameters = {
				scenario1 = {x = 0, y = 1},
				scenario2 = {x = 1, y = 2},
				scenario3 = {x = -1, y = 3}
			},
			repetition = 2,
			folderName = "results"
		}

		unitTest:assert(fileExists("1_execution_scenario1"))
		unitTest:assert(fileExists("1_execution_scenario2"))
		unitTest:assert(fileExists("1_execution_scenario3"))
		unitTest:assert(fileExists("2_execution_scenario1"))
		unitTest:assert(fileExists("2_execution_scenario2"))
		unitTest:assert(fileExists("2_execution_scenario3"))
		unitTest:assert(Directory(currentDir().."results"):delete())

		MultipleRuns{
			model = MyModel5,
			showProgress = false,
			strategy = "sample",
			quantity = 3,
			repetition = 2,
			parameters = {
				x = Choice{0, 1, -1}
			},
			folderName = "results"
		}

		unitTest:assert(fileExists("1_execution_1"))
		unitTest:assert(fileExists("2_execution_1"))
		unitTest:assert(fileExists("1_execution_2"))
		unitTest:assert(fileExists("2_execution_2"))
		unitTest:assert(fileExists("1_execution_3"))
		unitTest:assert(fileExists("2_execution_3"))
		unitTest:assert(Directory(currentDir().."results"):delete())
	end
}
