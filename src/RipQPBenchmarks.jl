module RipQPBenchmarks

# deps for benchmarks
using QuadraticModels, QPSReader
using QuadraticModelsGurobi, QuadraticModelsCPLEX
using CSV
using HSL, QDLDL
using Quadmath, DoubleFloats
using RipQP

using Requires
function __init__()
  @require QuadraticModelsXpress = "2cf8c267-6e70-4ce4-bd8d-41913dbccd90" using QuadraticModelsXpress
end

# deps for results
using Plots
using PGFPlotsX
using DataFrames, SolverTools
using SolverBenchmark
using PrettyTables

include("run_benchmarks.jl")
include("profiles.jl")
include("quad-table.jl")
include("smallest-quad-resid.jl")

end