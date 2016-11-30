-- @example Basic example for SAMDE using Yeast model.
-- It runs SAMDE to compute the best fit given a range
-- of growth rates.
-- @image yeast-samde.bmp

import("sysdyn")
import("calibration")

data = {
	[0] = 9.6,
	[1] = 29.0,
	[2] = 71.1,
	[3] = 174.6,
	[4] = 350.7,
	[5] = 513.3,
	[6] = 594.4,
	[7] = 640.8,
	[8] = 655.9,
	[9] = 661.8
}

local yeastSim = SAMDE{
	hideGraphs = true,
	model = Yeast,
	parameters = {rate = Choice{min = 1, max = 2.5}},
	fit = function(model)
		local result = 0
		local diff

		forEachElement(model.finalCells, function(pos, cell)
				diff  = cell - data[pos]
				result = result + diff * diff
		end)

		return result
end}

print("Difference between data and best simulation: "..yeastSim.fit)
print ("Rate: "..yeastSim.instance.rate)

mydata = {data = data, simulation = yeastSim.instance.finalCells}

chart = Chart{
	data = mydata,
	select = {"data", "simulation"},
	label = {"Data", "Best simulation"},
	title = "Cells"
}


-- adicionar este grafico aa documentacao do exemplo
-- adicionar grafico aa documentacao do exemplo abaixo
