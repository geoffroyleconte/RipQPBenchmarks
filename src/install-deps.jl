import Pkg

function add_CPLEX_deps()
  Pkg.add(url="https://github.com/JuliaSmoothOptimizers/QuadraticModelsCPLEX.jl")
end

function add_Gurobi_deps()
  Pkg.add(url="https://github.com/JuliaSmoothOptimizers/QuadraticModelsGurobi.jl")
end

function add_Xpress_deps()
  Pkg.add(url="https://github.com/JuliaSmoothOptimizers/QuadraticModelsXpress.jl")
end