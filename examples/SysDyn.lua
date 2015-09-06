if not isLoaded("sysdyn") then
	import("sysdyn")
end

if not isLoaded("calibration") then
	import("calibration")
end

data = {}
data [0] = 9.6
data [1] = 29.0
data [2] = 71.1
data [3] = 174.6
data [4] = 350.7
data [5] = 513.3
data [6] = 594.4
data [7] = 640.8
data [8] = 655.9
data [9] = 661.8

yeast = SysDynModel{ 
    
    cells      =    9.6,
    ref        =    0,
    diff       =    0,
    capacity   =  665.0,
    rate       =    Choice{min = 1, max = 2},
    finalTime  =    9,
    rms        = 0,
    changes = function (model, time)
            model.ref   = data [time]
            model.diff  = model.cells - model.ref
            model.rms   = model.rms + model.diff * model.diff
            model.cells = model.cells +
                          model.cells * model.rate * ( 1 - model.cells/model.capacity)
    end,

    graphics = { 
		timeseries = { {"cells", "ref"}, {"diff"}
                     }
        }
}

local c1 = SAMDE{
	model = yeast,
	parameters = {rate = Choice{min = 1, max = 1.5}},
	fit = function(model)
		return math.sqrt (model.rms)
end}

print ("rate "..c1.instance.rate.." rms error "..c1.fit)
   