local s = package.config:sub(1, 1)
import("calibration")
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
	local m3 = MultipleRuns{
		folderName = tmpDir()..s.."MultipleRunsTests",
		model = MyModel,
		strategy = "repeated",
		parameters = {x = 2, y = 5},
		quantity = 3,
		output = function(model)
			return model.value
		end,
		additionalF = function(model)
			return "test"
		end
	}

	print("end")