module RipQP

# deps for benchmarks
using QuadraticModels, QPSReader
using QuadraticModelsGurobi, QuadraticModelsCPLEX, QuadraticModelsXpress
using CSV
using SolverBenchmark
using HSL, QDLDL
using Quadmath, DoubleFloats
using RipQP

# deps for results
using Plots
using DataFrames, SolverTools
using PrettyTables

include("install-deps.jl")
include("run_benchmarks.jl")
include("profiles.jl")
include("quad-table.jl")

end