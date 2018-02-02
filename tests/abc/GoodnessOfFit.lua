
return{
	multiLevel = function(unitTest)
		local cs = CellularSpace{
			file = filePath("costanza.pgm", "calibration")}
		local cs2 = CellularSpace{
			file = filePath("costanza2.pgm", "calibration"),
			attrname = "costanza"}

		-- Discrete Tests:
		local result, data = multiLevel{
			target = {cs, cs2},
			select = "costanza",
			discrete = true
		}

		unitTest:assertEquals(result, 0.865, 0.01) -- 0.84 is the Total Fitness in Costanza Paper Example.

		local chart = _Gtme.Chart{
			target = data,
			select = "fit"
		}

		unitTest:assertSnapshot(chart, "costanza-original.png")

		result, data = multiLevel{
			target = {cs, cs2},
			select = "costanza",
			log = true,
			discrete = true
		}

		unitTest:assertEquals(result, 0.85, 0.01)

		chart = _Gtme.Chart{
			target = data,
			select = "fit",
			xLabel = "Window Size",
			yLabel = "Fit"
		}

		unitTest:assertSnapshot(chart, "costanza-log.png")
	end
}
