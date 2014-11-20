
require("calibration")


MyModel = Model{
	x = 1,
	setup = function(self)
		self.t = Timer{
			Event{action = function()
				self.value = 2 * self.x ^2 - 3 * self.x + 4
			end}
		}
	end
}

--[[
for i = 1, 10 do
	m = MyModel{x = i}

	m:execute(1)

	print(m.value)
end
--]]

c = Calibration{
	model = MyModel,
	parameters = {x = {-100, 100}},
	fit = function(model)
		return model.value
	end
}

result = c:execute()

print(result)


--[[ 
local min = 0
local best_x = 0
for i = -100, 100 do
	m = MyModel{x = i}

	m:execute(1)

	if i == -100 then
		min = m.value
		best_x = -100 
	else
		if m.value< min then
			min = m.value
			best_x = i
		end
	end
end

print ("Min: "..min.." Best X: "..best_x)
--Min = 3 and best_x = 1

]]--
