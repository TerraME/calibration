-- @example Basic example for testing SAMDE type
-- using a SysDyn model.
import("calibration")
import("ca")
abm = Wolfram
testParameters = {"rule"}
minRule = 0
maxRule = 255
repetitions = 2
points = 9
rangePoints = {}
rangePoints[0] = minRule
for i = 1, points do
    rangePoints[i] = minRule + math.floor( i * (maxRule - minRule) / (points + 1))  
end
rangePoints[points+1] = maxRule
forEachOrderedElement(testParameters, function(parameter, att, typ)
    sensivityTest = MultipleRuns{
        folderName = tmpDir(),
        quantity = 2,
        model = abm,
        -- hideGraphs = true,
        -- If this is true, observers are turned off but model does not work. I think this is a bug in terrame disableGraphs().
        parameters = {parameter = Choice(rangePoints)},
        strategy = "factorial",
        output = function ( model )
            counter = 0
            forEachOrderedElement(model.cs.cells, function(id, at, ty)
                if at.state == "alive" then
                    counter = counter + 1
                end
            end)
            return counter
        end
    }
end)

sensivityTest:saveCSV("results", ";")
