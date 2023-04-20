export quad_prec_table

# data_path = "C:\\Users\\Geoffroy Leconte\\Documents\\doctorat\\code\\docGL\\benchmarks\\ripqp_paper"
# using FileIO

function quad_prec_table(data_path::String, table_path::String)

  open_file(fname; data_path = data_path) = CSV.read(joinpath(data_path, string(fname, ".csv")), DataFrame)

  ripqp_multi1 = open_file("ripqp_multi1_quad")
  ripqp_mono1 = open_file("ripqp_mono1_quad")
  ripqp_multiquad1 = open_file("ripqp_multiquad1_quad") # en fait c'est le 4
  ripqp_multiquad2 = open_file("ripqp_multiquad2_nops_quad")

  pbs = ["TMA ME", "GlcAlift", "GlcAerWT"]

  header2 = [
    "solver",
    "time",
    "iter64",
    "iter128",
    "obj",
    "pdd",
    "pfeas",
    "dfeas",
  ]
  nh = length(header2)
  data2 = Matrix{Any}(undef, 12, nh)
  row_names2 = []
  for pb_index in 1:3
    push!(row_names2, pbs[pb_index])
    push!(row_names2, pbs[pb_index])
    push!(row_names2, pbs[pb_index])
    push!(row_names2, pbs[pb_index])
    data2[4 * (pb_index-1) + 1, :] .= [
      "multiquad1",
      ripqp_multiquad1.elapsed_time[pb_index],
      ripqp_multiquad1.iters_sp[pb_index],
      ripqp_multiquad1.iters_sp2[pb_index],
      ripqp_multiquad1.objective[pb_index],
      ripqp_multiquad1.pdd[pb_index],
      ripqp_multiquad1.primal_feas[pb_index],
      ripqp_multiquad1.dual_feas[pb_index],
    ]
    data2[4 * (pb_index-1) + 2, :] .= [
      "multi",
      ripqp_multi1.elapsed_time[pb_index],
      ripqp_multi1.iters_sp[pb_index],
      ripqp_multi1.iters_sp2[pb_index],
      ripqp_multi1.objective[pb_index],
      ripqp_multi1.pdd[pb_index],
      ripqp_multi1.primal_feas[pb_index],
      ripqp_multi1.dual_feas[pb_index],
    ]

    data2[4 * (pb_index-1) + 3, :] .= [
      "mono",
      ripqp_mono1.elapsed_time[pb_index],
      0,
      ripqp_mono1.iter[pb_index],
      ripqp_mono1.objective[pb_index],
      ripqp_mono1.pdd[pb_index],
      ripqp_mono1.primal_feas[pb_index],
      ripqp_mono1.dual_feas[pb_index],
    ]
    data2[4 * (pb_index-1) + 4, :] .= [
      "multiquad2",
      ripqp_multiquad2.elapsed_time[pb_index],
      ripqp_multiquad2.iters_sp[pb_index],
      ripqp_multiquad2.iters_sp2[pb_index],
      ripqp_multiquad2.objective[pb_index],
      ripqp_multiquad2.pdd[pb_index],
      ripqp_multiquad2.primal_feas[pb_index],
      ripqp_multiquad2.dual_feas[pb_index],
    ]
  end

  open(joinpath(table_path, "ripqp-quad.tex"), "w") do io
    println(io, "\\documentclass[varwidth=20cm,crop=true]{standalone}")
    println(io, "\\usepackage{longtable}")
    println(io, "\\begin{document}")
    pretty_table(
      io,
      data2; 
      header = header2,
      row_names= row_names2,
      title = "Benchmarks in quadruple precision",
      body_hlines = [4, 8],
      backend = Val(:latex),
      formatters = (ft_printf(["%7.1e", "%d", "%d", "%7.1e","%7.1e","%7.1e","%7.1e"], 2:8),
        (v, i, j) -> (SolverBenchmark.safe_latex_AbstractFloat(v)),
        )
      )
    println(io, "\\end{document}")
  end
  open(joinpath(table_path, "ripqp-quad.md"), "w") do io
    pretty_table(
      io,
      data2; 
      header = header2,
      row_names= row_names2,
      title = "Benchmarks in quadruple precision",
      body_hlines = [4, 8],
      formatters = (ft_printf(["%7.1e", "%d", "%d", "%7.1e","%7.1e","%7.1e","%7.1e"], 2:8),
        )
      )
end
  return nothing
end