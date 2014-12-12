
require("calibration")
--@header Calibration examples.
--- Basic example for testing Calibration type, using a simple equation and variating it's parameters according to a given range.

MyModel = Model{
	x = 1,
	y = 0,
	setup = function(self)
		self.t = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
	end
}


c = Calibration{
	model = MyModel,
	finalTime = 1,
	parameters = {x = { min = -100, max = 100}, y = { min = 1, max = 10}},
	fit = function(model)
		return model.value
	end
}

result = c:execute()

print(result)
