-- @example Basic example for testing goodness-of-fit.
-- This example reproduces Figure 4 of from Costanza R.
-- Model goodness of fit: a multiple resolution procedure. Ecological modelling. 1989 Sep 15;47(3-4):199-215.
import("calibration")

scene1 = CellularSpace{
	file = filePath("costanza.pgm", "calibration"),
	attrname = "value"
}

scene2 = CellularSpace{
	file = filePath("costanza2.pgm", "calibration"),
	attrname = "value"
}

result, data = multiLevel{
	target = {scene1, scene2},
	select = "value",
	discrete = true
}

print("Ft = "..result)

chart = Chart{
	target = data,
	select = "fit",
	xLabel = "Window Size",
	yLabel = "Fit"
}

