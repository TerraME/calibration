local s = package.config:sub(1, 1)
import("calibration")
-- Creating Models
print("potato")
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


	local m3 = MultipleRuns{
		folderName = tmpDir()..s.."MultipleRunsTests",
		model = MyModel,
		parameters = {x = 2, y = 5},
		repeats = 3,
		output = function(model)
			return model.value
		end,
		additionalF = function(model)
			return "test"
		end
	}
	local m3Tab = MultipleRuns{
		folderName = tmpDir()..s.."MultipleRunsTests",
		model = MyModel3,
		parameters = {parameters3 = {x = 2, y = 5, z = 1}},
		repeats = 3,
		output = function(model)
			return model.value
		end
	}
	print("potato")
	print(m3:get(1).x == 2)
	print(m3:get(2).x == 2)
	print(m3:get(3).x == 2)
	-- unitTest:assert(m3:get(1).y == 5 and m3:get(2).y == 5 and m3:get(3).y == 5)
	-- unitTest:assert(m3Tab:get(1).parameters3.x == 2 and m3Tab:get(2).parameters3.x == 2 and m3Tab:get(3).parameters3.x == 2)
	-- unitTest:assert(m3Tab:get(1).parameters3.y == 5 and m3Tab:get(2).parameters3.y == 5 and m3Tab:get(3).parameters3.y == 5)
	-- unitTest:assertEquals(m3:get(1).simulations, "scenario")
	-- unitTest:assertEquals(m3Tab:get(1).simulations, "scenario")
