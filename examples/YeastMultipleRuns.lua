-- @example Basic example for testing MultipleRuns type
-- using a basic Yeast model.

if not isLoaded("calibration") then
    import("calibration")
end

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

Yeast = Model{
    cells     = 9.6,
    ref       = 0,
    diff      = 0,
    capacity  = 665.0,
    rate      = Choice{min = 0, max = 2.5},
    finalTime = 9,
    rms       = 0,
	init = function(model)
		model.chart1 = Chart{
			target = model,
			select = {"cells", "ref"}
		}

		model.chart2 = Chart{
			target = model,
			select = "diff"
		}

		model.timer = Timer{
			Event{action = function(event)
				local time = event:getTime()

            	model.ref   = data [time]
            	model.diff  = model.cells - model.ref
            	model.rms   = model.rms + model.diff * model.diff
            	model.cells = model.cells + model.cells * model.rate * (1 - model.cells / model.capacity)
			end},
			Event{action = model.chart1},
			Event{action = model.chart2}
		}
	end
}

mr = MultipleRuns{
    model = Yeast,
    parameters = {rate = Choice{min = 0, max = 2.5, step = 0.1}},
    hideGraphs = true,
	output = {"rms"}
}

Chart{
	data = mr,
	select = "rms",
	xAxis = "rate"
}

