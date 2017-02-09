-- @example Basic example for testing goodnessofFit type,
-- Example described in the Costanza paper.
import("calibration")

local cs12 = CellularSpace{
	file = filePath("Costanza.pgm", "calibration")
}

local cs22 = CellularSpace{
	file = filePath("Costanza2.pgm", "calibration"),
	attrname = "Costanza"
}

local result1 = multiLevel{
	cs1 = cs12,
	cs2 = cs22,
	attribute = "Costanza",
	continuous = false,
	graphics = true
}

local result2 = multiLevel{
	cs1 = cs12,
	cs2 = cs22,
	attribute = "Costanza",
	continuous = true,
	graphics = true
}

print("result1: "..result1)
print("result2: "..result2)
