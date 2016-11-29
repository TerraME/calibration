
-- @example Example that uses MultipleRuns to compute wow many cells agents moving randomly can
-- reach. It uses a model that starts with a given number of agents randomly distributed in
-- space and runs a small number of steps. The output shows a logistic growth of cells
-- where at least one agent has passed during each simulation. Note that the curve sometimes
-- has a negative derivative. As we increase the initial number of agents, sometimes the number
-- of covered cells diminishes due to randomness.
SingleAgentModel = Model{
    finalTime = 20,
    quantity = 20,
    init = function(model)
        model.cell = Cell{
            state = "empty",
            execute = function(self)
                if not self:isEmpty() then
                    self.state = "full"
                end
            end
        }
        
        model.cs = CellularSpace{
            xdim = 40,
            instance = model.cell
        }
        
        model.cs:createNeighborhood{}
        
        model.agent = Agent{
            execute = function(self)
                local cell = self:getCell():getNeighborhood():sample()
                
                if cell:isEmpty() then
                    self:move(cell)
                end
            end
        }
        
        model.society = Society{
            instance = model.agent,
            quantity = model.quantity
        }
        
        model.env = Environment{
            model.cs,
            model.society
        }
        
        model.env:createPlacement{}
    
        model.map1 = Map{
            target = model.cs,
            grouping = "placement",
            max = 1,
            min = 0,
            slices = 2,
            color = "YlOrRd"
        }
    
        model.map2 = Map{
            target = model.cs,
            select = "state",
            value = {"empty", "full"},
            color = {"white", "blue"}
        }
    
        model.timer = Timer{
            Event{action = model.society},
            Event{action = model.cs},
            Event{action = model.map1},
            Event{action = model.map2}
        }

    end
}

import("calibration")

mr = MultipleRuns{
    model = SingleAgentModel,
    parameters = {
        quantity = Choice{min = 5, max = 455, step = 5},
    },
    total = function(model)
        return #model.cs:split("state").full
    end
}

Chart{
    data = mr,
    select = "total",
    xAxis = "quantity"
}


