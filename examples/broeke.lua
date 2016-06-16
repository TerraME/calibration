
-- An implementation of the model described in
-- ten Broeke, Guus, George van Voorn, and Arend Ligtenberg. 
-- "Which Sensitivity Analysis Method Should I Use for My Agent-Based Model?." 
-- Journal of Artificial Societies & Social Simulation 19.1 (2016).
-- http://jasss.soc.surrey.ac.uk/19/1/5.html

agent = Agent{
	-- # rever estes valores abaixo
	energy = 10,
	harvestcoef = 0.1,
	movecoef = 0.1,
	maxHarvest = 0.5,
	energyMaintenance = 0.1,
	energyMove = 0.5,
	decide = function(self)
		local cell = self:getCell()
		local best
		local bestResource = 0

		forEachNeighbor(cell, function(cell, neigh)
			local neighResource = neigh:getResource()
			if neighResource / #neigh:getAgents() > bestResource then
				best = neigh
				bestResource = neighResource / #neigh:getAgents()
			end
		end)

		local expected = bestResource - self.energyMove -- A10

		self.bestNeighbor = best

		-- TODO AQUI
--		local pmove = Random{p = math.exp(-

		-- # verificar se a melhor decisao e ficar ou se mover
		-- # alterar self.decision de acordo com maintenance abaixo
	end,
	harvest = function(self)
		local cell = self:getCell()

		-- # nao esta de acordo com o artigo
		-- parece que tem uma falha no artigo pois o harvest tem que ser dividido pelos agentes
		-- que estao na mesma celula

		if cell.resource < self.maxHarvest then
			self.energy = self.energy + cell.resource
			cell.resource = 0
		else
			self.energy = self.energy + 0.5
			cell.resource = cell.resource - self.maxHarvest
		end
	end,
	maintenance = function(self)
		self.energy = self.energy - self.energyMaintenance

		if self.decision == "harvest" then
			self:harvest()
		elseif self.decision == "relocate" then
			self:relocate()
		else
			customError("No decision was made!")
		end

		self.decision = nil

		self.energy = self.energy - self.energyMaintenance

		local probDie = Random{p = math.exp(-self.mortalityCoef * self.energy)}

		if probDie:sample() then
			self:die()
			return
		end

		local probBreed = Random{p = 1 - math.exp(-self.birthCoe * (self.energy - self.birthEnergy))}
		if probBreed:sample() then
			local ag1 = self:reproduce()
			local ag2 = self:reproduce()

			ag1.energy = self.energy / 2
			ag2.energy = self.energy / 2

			ag1:mutation()
			ag2:mutation()

			self:die()
		end
	end,
	mutation = function(self)
		local variation = Random{min = -self.variation, max = self.variation}

		self.harvestCoef = self.harvestCoef + variation:sample()

		if self.harvestCoef < -1 then self.harvestCoef = 0 end
		if self.harvestCoef >  1 then self.harvestCoef = 1 end -- this was not in the paper

		self.moveCoef = self.moveCoef + variation:sample()

		if self.moveCoef < -1 then self.moveCoef = 0 end
		if self.moveCoef >  1 then self.moveCoef = 1 end -- this was not in the paper
	end,
	relocate = function(self)
		self.energy = self.energy - self.energyMove

		self:move(self.bestNeighbor)
		self.bestNeighbor = nil
	end,
	breed = function(self)
		self.energy = self.energy - self.birthEnergy
	end
}

soc = Society{
	instance = agent,
	quantity = 100
}

cell = Cell{
	diffusioncoef = 0.1,
	growthRate = 0.1,
	resource = 10,
	diffusionCoef = 0.1,
	carryingCapacity = 2,
	resourceUncertainty = 0.1,
	getResource = function(self)
		-- this function should use a normal distribution, but we are using just a 
		-- N(0, self.resourceUncertainty)

		local uncertainty = Random{min = -self.resourceUncertainty, max = self.resourceUncertainty}
		-- TODO: when change this script to Model, use r as a singleton

		return self.resource + uncertainty:sample()
	end,
	grow = function(self)
		self.resource = ( self.past.resource * self.carryingCapacity * math.exp(self.growthRate) ) / 
		                ( self.carryingCapacity + self.past.resource * math.exp(self.growthRate) )
						+ self.past.resource

		-- the line below was not in the original paper
		if self.resource > 100 then self.resource = 100 end
	end,
	diffuse = function(self)
		local sum = 0

		forEachNeighbor(self, function(cell, neigh)
			sum = sum + neigh.past.resource
			-- it is written as R*_{i'j'}, but I could not find where i' or j' is defined
		end)

		-- using past here needs to synchronize space again after calling this function
		self.resource = (1 - 4 * self.diffusionCoef) * self.past.resource + 1 * self.diffusionCoef * sum
		+ self.past.resource

		-- the line below was not in the original paper
		if self.resource > 100 then self.resource = 100 end
	end
}

cs = CellularSpace{
	instance = cell,
	xdim = 33
}

map = Map{
	target = cs,
	select = "resource",
	color = "Greens",
	min = 0,
	max = 100,
	slices = 8
}

cs:createNeighborhood{
	strategy = "vonneumann",
	wrap = true
}

env = Environment{cs, soc}
env:createPlacement()

c = Chart{
	target = soc
}

t = Timer{
	Event{action = function()
		cs:synchronize()
		cs:grow()
		cs:synchronize()
		cs:diffuse()

		g = Group{
			target = soc
		}

		g:randomize()
		g:decide()
		g:maintenance()
	end},
	Event{action = map},
	Event{action = c}
}

t:run(10)

