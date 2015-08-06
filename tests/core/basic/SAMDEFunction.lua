local MyModel
MyModel = Model{
	x = Choice{ min = 1, max = 10},
	y = Choice{ min = 1, max = 10},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
	end
}
local varMatrix = {{1,10}, {1,10}}
local dim = 2
local paramList = {"x", "y"}
local finalTime = 1
local fit
fit = function(model)
	return model.value
end

return{
	SAMDECalibrate = function(unitTest)
		local c2 = SAMDE{
		model = MyModel,
		parameters = {x = Choice{min = 1, max = 10}, y = Choice{min = 1, max = 10}},
		size = 30,
		maxGen = 100,
		threshold = 1,
		fit = function(model, parameters)
			local m = model(parameters)
			m:execute()
			return m.value
		end}
		unitTest:assertEquals(c2.fit, 4)
		unitTest:assertEquals(c2.instance.x, 1)
		unitTest:assertEquals(c2.instance.y, 1)
	end
}
