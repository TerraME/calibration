import("calibration")
local s = package.config:sub(1, 1)
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
local m = MultipleRuns{
		folderName = tmpDir()..s.."saveCSVTests",
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
		output = function(model)
			return model.value
		end
	}
	m:saveCSV("resultsT", ";")
