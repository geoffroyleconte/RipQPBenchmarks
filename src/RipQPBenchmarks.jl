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

export ripqp_all_benchmarks

function ripqp_all_benchmarks(
  save_path;
  run_cplex = false,
  run_gurobi = false,
  run_xpress = false,
  run_ma57 = false,
  run_ma97 = false,
  plot_extension = ".pdf",
)
  run_benchmarks_solvers(
    save_path;
    run_cplex = run_cplex,
    run_gurobi = run_gurobi,
    run_xpress = run_xpress,
    run_ma57 = run_ma57,
    run_ma97 = run_ma97,
  )
  save_all_profiles(
    save_path,
    save_path;
    plot_extension = plot_extension,
    run_cplex = run_cplex,
    run_gurobi = run_gurobi,
    run_xpress = run_xpress,
    run_ma57 = run_ma57,
    run_ma97 = run_ma97,
  )
  println("profiles LP and QP done")

  run_benchmarks_quad(save_path)
  quad_prec_table(save_path, save_path)
  println("tables quad precision done")

  smallest_quad_resid_table(save_path)
  println("smallest residuals quad precision done")
  return nothing
end

end