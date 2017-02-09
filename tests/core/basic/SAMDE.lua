local myModelSamde = Model{
	x = Choice{min = 1, max = 10},
	y = Choice{min = 1, max = 10},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
			end}
		}
end}

local discreteSamde = Model{
	x = Choice{min = 1, max = 10},
	y = Choice{min = 1, max = 10},
	z = Choice{"high", "low"},
	finalTime = 1,
	init = function(self)
		self.timer = Timer{
			Event{action = function()
				if self.z == "high" then
					self.value = 2 * self.x ^2 - 3 * self.x + 4 + self.y
				elseif self.z == "low" then
					self.value = 2 * self.x ^2 - 3 * self.x + 4 - self.y
				end
			end}
		}
end}
return{
	SAMDE = function(unitTest)
		local c1 = SAMDE{
			model = myModelSamde,
			parameters = {x = Choice{min = 1, max = 10, step = 1}, y = Choice{min = 1, max = 10, step = 0.3}},
			size = 30,
			maxGen = 100,
			maximize = true,
			threshold = 200,
			fit = function(model)
				return model.value
			end
		}

		unitTest:assertEquals(c1.fit, 184, 1)
		unitTest:assertEquals(c1.instance.x, 10, 1)
		unitTest:assertEquals(c1.instance.y, 10, 1)

		local c2 = SAMDE{
			model = myModelSamde,
			parameters = {x = Choice{min = 1, max = 10}, y = Choice{min = 1, max = 10}, finalTime = 1},
			size = 30,
			maxGen = 100,
			threshold = 1,
			fit = function(model)
				return model.value
			end
		}

		unitTest:assertEquals(c2.fit, 4, 1)
		unitTest:assertEquals(c2.instance.x, 1, 1)
		unitTest:assertEquals(c2.instance.y, 1, 1)

		local c3 = SAMDE{
			model = myModelSamde,
			parameters = {x = Choice{min = 1, max = 10}, y = Choice{min = 1, max = 10}},
			size = 30,
			maxGen = 100,
			threshold = 100,
			maximize = true,
			fit = function(model)
				return model.value
			end
		}

		unitTest:assertEquals(c3.fit, 142, 50)
		unitTest:assertEquals(c3.instance.x, 6, 5)
		unitTest:assertEquals(c3.instance.y, 6, 5)

		local c4 = SAMDE{
			model = myModelSamde,
			parameters = {x = Choice{min = 1, max = 10, step = 1}, y = Choice{min = 1, max = 10, step = 0.3}},
			fit = function(model)
				return model.value
			end
		}

		unitTest:assertEquals(c4.fit, 4, 1)
		unitTest:assertEquals(c4.instance.x, 1, 1)
		unitTest:assertEquals(c4.instance.y, 1, 1)
		unitTest:assertEquals(c4.fit, 4, 1)
		unitTest:assertEquals(c4.instance.x, 1, 1)
		unitTest:assertEquals(c4.instance.y, 1, 1)
	
		local c51 = SAMDE{
			model = myModelSamde,
			parameters = {x = Choice{min = 1, max = 10, step = 1}, y = Choice{min = 1, max = 10, step = 0.3}},
			size = 30,
			maxGen = 100,
			threshold = 1,
			fit = function(model)
				return model.value
			end
		}

		unitTest:assertEquals(c51.fit, 5, 1)
		unitTest:assertEquals(c51.instance.x, 1, 1)
		unitTest:assertEquals(c51.instance.y, 2, 1)

		local c52 = SAMDE{
			model = myModelSamde,
			parameters = {x = Choice{min = 1, max = 10, step = 1}, y = Choice{2,3,4,9}},
			size = 30,
			maxGen = 100,
			threshold = 1,
			fit = function(model)
				return model.value
			end
		}

		unitTest:assertEquals(c52.fit, 5, 1)
		unitTest:assertEquals(c52.instance.x, 1, 1)
		unitTest:assertEquals(c52.instance.y, 2, 1)

		local c6 = SAMDE{
			model = myModelSamde,
			parameters = {x = Choice{1,3,5,6}, y = Choice{2,3,4,9}},
			maximize = true,
			fit = function(model)
				return model.value
			end
		}

		unitTest:assertEquals(c6.fit, 67, 1)
		unitTest:assertEquals(c6.instance.x, 6, 1)
		unitTest:assertEquals(c6.instance.y, 9, 1)

		local c7 = SAMDE{
			model = discreteSamde,
			parameters = {x = Choice{1,3,5,6}, y = Choice{2,3,4,9}, z = Choice{"high", "low"}},
			threshold = -6,
			maxGen = 100,
			fit = function(model)
				return model.value
			end
		}

		unitTest:assertEquals(c7.fit, -6, 6)
		unitTest:assertEquals(c7.instance.x, 1, 6)
		unitTest:assertEquals(c7.instance.y, 9, 6)
		unitTest:assertEquals(c7.instance.z, "low")

		local c8 = SAMDE{
			model = discreteSamde,
			parameters = {x = Choice{1,3,5,6}, y = Choice{2,3,4,9}, z = Choice{"high", "low"}},
			maxGen = 100,
			threshold = 67,
			maximize = true,
			fit = function(model)
				return model.value
			end
		}

		unitTest:assertEquals(c8.fit, 67, 1)
		unitTest:assertEquals(c8.instance.x, 6, 1)
		unitTest:assertEquals(c8.instance.y, 9, 1)
		unitTest:assertEquals(c8.instance.z, "high")
	end
}

