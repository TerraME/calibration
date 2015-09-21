-- @example Basic example for testing goodnessofFit type, 
-- Example described in the Costanza paper.
import("calibration")
local cs12 = CellularSpace{
	database = file("Costanza.map", "calibration"),
	attrname = "Costanza"
}
		local cs22 = CellularSpace{
	database = file("Costanza2.map", "calibration"),
	attrname = "Costanza"
}

local result = multiLevel(cs12, cs22, "Costanza")
local result2 = multiLevel(cs12, cs22, "Costanza", true)
print("result"..result)
print("result2"..result2)