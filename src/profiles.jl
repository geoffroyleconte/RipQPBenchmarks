# data_path = "C:\\Users\\Geoffroy Leconte\\Documents\\doctorat\\code\\docGL\\amdahl_benchmarks\\results"
data_path = "C:\\Users\\Geoffroy Leconte\\Documents\\doctorat\\code\\docGL\\benchmarks\\ripqp_paper"
using Plots
using DataFrames, SolverBenchmark, SolverTools
using CSV
# using FileIO

function solvers_dict(
  data_path::String;
  type::String = "lp", # "qp" for quadraticproblems
  run_cplex::Bool = false,
  run_gurobi::Bool = false,
  run_xpress::Bool = false,
  )

  open_file(fname; data_path = data_path) = CSV.read(joinpath(data_path, string(fname, ".csv")), DataFrame)
  run_cplex && (cplex1_stats = open_file(string("cplex1_", type)))
  run_gurobi && (gurobi1_stats = open_file(string("gurobi1_", type)))
  run_xpress && (xpress1_stats = open_file(string("xpress1_", type)))
  # gurobi_nops1_stats = open_file(string("gurobi_nops1_", type))
  # cplex_nops1_stats = open_file(string("cplex_nops1_", type))
  # xpress_nops1_stats = open_file(string("xpress_nops1_", type))
  ripqp1_stats = open_file(string("ripqp1_", type)) # compare commercial solvs + cc1
    
  out_dict = Dict{Symbol, DataFrames}(:ripqp => ripqp1_stats)
  run_cplex && (out_dict[:cplex] = cplex1_stats)
  run_gurobi && (out_dict[:gurobi] = gurobi1_stats)
  run_xpress && (out_dict[:xpress] = xpress1_stats)
  return out_dict
end

function factorizations_dict(
  data_path::String;
  type::String = "lp", # "qp" for quadraticproblems
  run_ma57::Bool = false,
  run_ma97::Bool = false,
  )

  open_file(fname; data_path = data_path) = CSV.read(joinpath(data_path, string(fname, ".csv")), DataFrame)
  ripqp1_stats = open_file(string("ripqp1_", type)) # compare commercial solvs + cc1
  ripqp_qdldl_stats = open_file(string("ripqp_qdldl1_", type))
  ripqp_cholmod_stats = open_file(string("ripqp_cholmod1_", type))
  run_ma57 && (ripqp_ma57_stats = open_file(string("ripqp_ma57", type)))
  run_ma97 && (ripqp_ma97_stats = open_file(string("ripqp_ma971", type)))

  out_dict = Dict(
      :ripqp => ripqp1_stats,
      :ripqp_qdldl => ripqp_qdldl_stats,
      :ripqp_cholmod => ripqp_cholmod_stats,
    )
  run_ma57 && (out_dict[:ripqp_ma57] = ripqp_ma57_stats)
  run_ma97 && (out_dict[:ripqp_ma97] = ripqp_ma97_stats)
  return out_dict
end

function centrality_corr_dict(data_path::String; type::String = "lp")
  open_file(fname; data_path = data_path) = CSV.read(joinpath(data_path, string(fname, ".csv")), DataFrame)
  ripqp1_stats = open_file(string("ripqp1_", type)) # compare commercial solvs + cc1
  ripqp_cc1_stats = open_file(string("ripqp_cc1_", type))
  return Dict(:ripqp => ripqp1_stats, :ripqp_cc => ripqp_cc1_stats)
end

function multi_dict(data_path::String; type::String = "lp")
  open_file(fname; data_path = data_path) = CSV.read(joinpath(data_path, string(fname, ".csv")), DataFrame)
  ripqp1_stats = open_file(string("ripqp1_", type))
  ripqp_multi1_stats = open_file(string("ripqp_multi1_", type))
  return Dict(:ripqp => ripqp1_stats, :ripqp_multi => ripqp_multi1_stats)
end

function multi_ma57_dict(data_path::String; type::String = "lp")
  open_file(fname; data_path = data_path) = CSV.read(joinpath(data_path, string(fname, ".csv")), DataFrame)
  ripqp_ma57_stats = open_file(string("ripqp_ma57", type))
  ripqp_ma57_multi_stats = open_file(string("ripqp_ma57_multi1_", type))
  return Dict(:ripqp_ma57 => ripqp_ma57_stats, :ripqp_ma57_multi => ripqp_ma57_multi_stats)
end

function multi2_ma57_dict(data_path::String; type::String = "lp")
  open_file(fname; data_path = data_path) = CSV.read(joinpath(data_path, string(fname, ".csv")), DataFrame)
  ripqp_ma57_stats = open_file(string("ripqp_ma57", type))
  ripqp_ma57_multi2_stats = open_file(string("ripqp_ma57_multi2_", type))
  return Dict(:ripqp_ma57 => ripqp_ma57_stats, :ripqp_ma57_multi2 => ripqp_ma57_multi2_stats)
end

function multi_ma57_all_dict(data_path::String; type::String = "lp")
  open_file(fname; data_path = data_path) = CSV.read(joinpath(data_path, string(fname, ".csv")), DataFrame)
  ripqp_ma57_stats = open_file(string("ripqp_ma57", type))
  ripqp_ma57_multi_stats = open_file(string("ripqp_ma57_multi1_", type))
  ripqp_ma57_multi2_stats = open_file(string("ripqp_ma57_multi2_", type))
  return Dict(
    :ripqp_ma57 => ripqp_ma57_stats,
    :ripqp_ma57_multi => ripqp_ma57_multi_stats,
    :ripqp_ma57_multi2 => ripqp_ma57_multi2_stats,
  )
end

function multifact_dict(data_path::String; type::String = "lp")
  open_file(fname; data_path = data_path) = CSV.read(joinpath(data_path, string(fname, ".csv")), DataFrame)
  ripqp_multi1_stats = open_file(string("ripqp_multi1_", type))
  ripqp_ldlprecond1_stats = open_file(string("ripqp_ldlprecond1_", type)) # regu1 1.0e-8, stop crit 64, no equi
  ripqp_ldlprecond2_stats = open_file(string("ripqp_ldlprecond2_", type)) # regu1 1.0e-8 equi
  return Dict(
    :ripqp_multi => ripqp_multi1_stats,
    :ripqp_multifact1 => ripqp_ldlprecond1_stats,
    :ripqp_multifact2 => ripqp_ldlprecond2_stats,
  )
end

function multifact_limited_dict(data_path::String; type::String = "lp")
  open_file(fname; data_path = data_path) = CSV.read(joinpath(data_path, string(fname, ".csv")), DataFrame)
  ripqp_ldlprecond1_stats = open_file(string("ripqp_ldlprecond1_", type)) # regu1 1.0e-8, stop crit 64, no equi
  ripqp_lldlprecond1_stats = open_file(string("ripqp_lldlprecond_", type)) # regu1 1.0e-8, stop crit 64, no equi, new regu_try_catch
  return Dict(
    :ripqp_multifact1 => ripqp_ldlprecond1_stats,
    :ripqp_multifact_lldl => ripqp_lldlprecond1_stats,
  )
end

function dfstat_time(df)
  output = zeros(length(df.status))
  for i=1:length(df.status)
    if df.primal_feas[i] === missing || df.objective[i] == Inf
      output[i] = Inf
    else 
      output[i] = df.elapsed_time[i]
    end
    if df.status[i] ∉ ["first_order", "acceptable"]
      output[i] = Inf
    end
  end
  return output
end

function dfstat_energy(df)
  output = zeros(length(df.status))
  for i=1:length(df.status)
    if df.primal_feas[i] === missing || df.objective[i] == Inf
      output[i] = Inf
    else 
      output[i] = df.relative_iter_cnt[i]
    end
    if df.status[i] ∉ ["first_order", "acceptable"]
      output[i] = Inf
    end
  end
  return output
end

function dfstat_energy2(df)
  output = zeros(length(df.status))
  for i=1:length(df.status)
    if df.primal_feas[i] === missing || df.objective[i] == Inf
      output[i] = Inf
    else 
      output[i] = 4 * df.iters_sp2[i] + df.iters_sp[i]
    end
    if df.status[i] ∉ ["first_order", "acceptable"]
      output[i] = Inf
    end
  end
  return output
end

function netlib_profile_time(stats, save_path::String)
  pgfplotsx()
  perf = performance_profile(stats, dfstat_time, legend=:bottomright, b = SolverBenchmark.BenchmarkProfiles.PGFPlotsXBackend())
  title!("Performance profile (Netlib problems)")
  savefig(perf, save_path)
end

function netlib_profile_energy(stats, save_path::String)
  pgfplotsx()
  perf = performance_profile(stats, dfstat_energy, legend=:bottomright, b = SolverBenchmark.BenchmarkProfiles.PGFPlotsXBackend())
  title!("Performance profile (Netlib problems)")
  savefig(perf, save_path)
end

function mm_profile_energy(stats, save_path::String)
  pgfplotsx()
  perf = performance_profile(stats, dfstat_time, legend=:bottomright, b = SolverBenchmark.BenchmarkProfiles.PGFPlotsXBackend())
  title!("Performance profile (Maros and Meszaros problems)")
  savefig(perf, save_path)
end

function mm_profile_energy(stats, save_path::String)
  pgfplotsx()
  perf = performance_profile(stats, dfstat_energy, legend=:bottomright, b = SolverBenchmark.BenchmarkProfiles.PGFPlotsXBackend())
  title!("Performance profile (Maros and Meszaros problems)")
  savefig(perf, save_path)
end

function save_all_profiles(
  data_path::String,
  profile_path::String;
  plot_extension::String = ".pdf",
  run_cplex::Bool = false,
  run_gurobi::Bool = false,
  run_xpress::Bool = false,
  run_ma57::Bool = false,
  run_ma97::Bool = false,
)

  solver_stats_lp = solvers_dict(
    data_path;
    type = "lp",
    run_cplex = run_cplex,
    run_gurobi = run_gurobi,
    run_xpress = run_xpress,
  )
  netlib_profile_time(solver_stats_lp, string(profile_path, "solvers_time_lp", plot_extension)) # fig 2
  solver_stats_qp = solvers_dict(
    data_path;
    type = "qp",
    run_cplex = run_cplex,
    run_gurobi = run_gurobi,
    run_xpress = run_xpress,
  )
  mm_profile_time(solver_stats_qp, string(profile_path, "solvers_time_qp", plot_extension)) # fig 3

  factorization_stats_lp = factorizations_dict(
    data_path;
    type = "lp",
    run_ma57 = run_ma57,
    run_ma97 = run_ma97,
  )
  netlib_profile_time(factorization_stats_lp, string(profile_path, "factorizations_time_lp", plot_extension)) # fig 4
  factorization_stats_qp = factorizations_dict(
    data_path;
    type = "lp",
    run_ma57 = run_ma57,
    run_ma97 = run_ma97,
  )
  mm_profile_time(factorization_stats_qp, string(profile_path, "factorizations_time_qp", plot_extension)) # fig 5

  stats_cc_lp = centrality_corr_dict(data_path; type = "lp")
  netlib_profile_time(stats_cc_lp, string(profile_path, "cc_time_lp", plot_extension)) # fig 6
  stats_cc_qp = centrality_corr_dict(data_path; type = "qp")
  mm_profile_time(stats_cc_qp, string(profile_path, "cc_time_qp", plot_extension)) # fig 7

  stats_multi_lp = multi_dict(data_path; type = "lp")
  netlib_profile_energy(stats_multi_lp, string(profile_path, "multi_energy_lp", plot_extension)) # fig 8
  stats_multi_qp = multi_dict(data_path; type = "qp")
  mm_profile_energy(stats_multi_qp, string(profile_path, "multi_energy_qp", plot_extension)) # fig 9

  if run_ma57
    stats_ma57_mutli1_lp = multi_ma57_dict(data_path; type = "lp")
    netlib_profile_time(stats_ma57_mutli1_lp, string(profile_path, "ma57_multi1_time_lp", plot_extension)) # fig 10
    stats_ma57_mutli1_qp = multi_ma57_dict(data_path; type = "qp")
    mm_profile_time(stats_ma57_mutli1_qp, string(profile_path, "ma57_multi1_time_qp", plot_extension)) # fig 11

    stats_ma57_mutli2_lp = multi2_ma57_dict(data_path; type = "lp")
    netlib_profile_time(stats_ma57_mutli2_lp, string(profile_path, "ma57_multi2_time_lp", plot_extension)) # fig 12
    stats_ma57_mutli2_qp = multi2_ma57_dict(data_path; type = "qp")
    mm_profile_time(stats_ma57_mutli2_qp, string(profile_path, "ma57_multi2_time_qp", plot_extension)) # fig 13

    stats_ma57_mutli_all_lp = multi_ma57_all_dict(data_path; type = "lp")
    netlib_profile_energy(stats_ma57_mutli_all_lp, string(profile_path, "ma57_multi_all_energy_lp", plot_extension)) # fig 14
    stats_ma57_mutli_all_qp = multi_ma57_all_dict(data_path; type = "qp")
    mm_profile_energy(stats_ma57_mutli_all_qp, string(profile_path, "ma57_multi_all_energy_qp", plot_extension)) # fig 15
  end

  stats_mutlifact_lp = multifact_dict(data_path; type = "lp")
  netlib_profile_energy2(stats_mutlifact_lp, string(profile_path, "multifact_energy_lp", plot_extension)) # fig 16
  stats_mutlifact_qp = multifact_dict(data_path; type = "qp")
  mm_profile_energy2(stats_mutlifact_qp, string(profile_path, "multifact_energy_qp", plot_extension)) # fig 17

  stats_mutlifact_lim_lp = multifact_limited_dict(data_path; type = "lp")
  netlib_profile_energy2(stats_mutlifact_lim_lp, string(profile_path, "multifact_limited_energy_lp", plot_extension)) # fig 18
  stats_mutlifact_lim_qp = multifact_limited_dict(data_path; type = "qp")
  mm_profile_energy2(stats_mutlifact_lim_qp, string(profile_path, "multifact_limited_energy_qp", plot_extension)) # fig 19

  netlib_profile_time(stats_mutlifact_lim_lp, string(profile_path, "multifact_limited_time_lp", plot_extension)) # fig 20
  netlib_profile_time(stats_mutlifact_lim_qp, string(profile_path, "multifact_limited_time_qp", plot_extension)) # fig 21
end
