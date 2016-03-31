-- @example Fire in the forest example using  multiple runs repeateated strategy.
if not isLoaded("ca") then
   import("ca")
end
import("calibration")
i = 0

local m = MultipleRuns{
	model = Fire,
	hideGraphs = true,
	strategy = "repeated", -- #ADDISSUE# se tirar este parametro, a mensagem
	                        -- de erro diz que #2 is mandatory, 
							-- deveria ser 'strategy is mandatory'
							-- feito.

							-- Novamente, este parametro poderia ser
							-- removido e ainda assim o calibration deveria
							-- saber o que fazer.
							-- Isso se tornou impossivel de ser feito, 
							-- depois de adicionar a opcao de quantity ao factorial,
							-- pois tanto ele quanto o sample usam quantity e Choice.
							-- O que podemos fazer seria ele usar o sample por default nesses casos.
	quantity = 10,
	parameters = {
		empty = 0.3,
		dim = 30
	},
	forest = function(model)
		print(i) -- #ADDISSUE# possibilitar que o multipleruns mostre na
				-- tela algo que diga o que ele esta processando, do
				-- tipo "executing 1/10". nos outros casos, que for uma
				-- combinacao de parametros pode mostrar os parametros
				-- esta opcao deve ter como valor default false, para 
				-- nao mostrar nada na tela. O que tem neste script eh
				-- uma gambiarra para mostrar algo conforme os movelos vao
				-- sendo processados.
		i = i + 1
		return model.cs:forest()
	end
}
local sum = 0
forEachElement(m.forest, function(idx, value)
	sum = sum + value
end)

print("Average forest in the end of "..m.quantity.." simulations: "..sum / m.quantity)

