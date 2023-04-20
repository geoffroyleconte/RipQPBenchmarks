export ripqp_multi_quad2_small_res, smallest_quad_resid_table

ripqp_multi_quad2_small_res(qm; max_iter = 700, T = Float128, Tlow = Float64) = ripqp(
  qm, 
  mode = :multi,
  early_multi_stop = false,
  sp = K2KrylovParams{Tlow}( # solve in Float64
    uplo = :U,
    kmethod=:gmres,
    form_mat = true,
    equilibrate = false,
    itmax = 100,
    mem = 100,
    preconditioner = LDL(T = Tlow, pos = :R, warm_start = true),
    ρ_min=1.0e-15,
    δ_min = 1.0e-15,
    atol_min = 1.0e-16,
    rtol_min = 1.0e-16,
  ),
    sp2 = K2KrylovParams{T}( # solve in Float128
    uplo = :U,
    kmethod=:gmres,
    form_mat = true,
    equilibrate = false,
    itmax = 5,
    mem = 5,
    preconditioner = LDL(T = T, pos = :R, warm_start = true),
    ρ_min=T(1.0e-15),
    δ_min = T(1.0e-15),
    atol_min = T(1.0e-16),
    rtol_min = T(1.0e-16),
  ),
  solve_method=IPF(),
  solve_method2=PC(),
  itol = InputTol(
    T,
    max_iter = max_iter,
    max_time = 20000.0,
    max_iter1 = 100,
    ϵ_pdd1 = T(1.0e1),
    ϵ_rc1 = T(1.0e-6),
    ϵ_rb1 = T(1.0e-6),
    ϵ_rb = T(1e-40),
  ),
  display = true,
)

function smallest_quad_resid_table(table_path::String)
  T = Float128
  path_pb = joinpath(dirname(@__DIR__), "problems")
  qm_TMA_ME = createQuadraticModel_T(readqps(joinpath(path_pb, "TMA_ME.mps")), T=T)
  stats_TMA_ME = ripqp_multi_quad2_small_res(qm_TMA_ME; max_iter = 174)
  qm_GlcAlift = createQuadraticModel_T(readqps(joinpath(path_pb, "GlcAlift.mps")), T=T)
  stats_GlcAlift = ripqp_multi_quad2_small_res(qm_GlcAlift; max_iter = 709)
  qm_GlcAerWT = createQuadraticModel_T(readqps(joinpath(path_pb, "GlcAerWT.mps")), T=T)
  stats_GlcAerWT = ripqp_multi_quad2_small_res(qm_GlcAerWT; max_iter = 319)
  header = ["pdd", "pfeas", "dfeas", "itertot"]
  row_names = ["TMA ME", "GlcAlift", "GlcAerWT"]
  data = [stats_TMA_ME.solver_specific[:pdd]   stats_TMA_ME.primal_feas   stats_TMA_ME.dual_feas   stats_TMA_ME.iter;
          stats_GlcAlift.solver_specific[:pdd] stats_GlcAlift.primal_feas stats_GlcAlift.dual_feas stats_GlcAlift.iter;
          stats_GlcAerWT.solver_specific[:pdd] stats_GlcAerWT.primal_feas stats_GlcAerWT.dual_feas stats_GlcAerWT.iter;
          ]
  open(joinpath(table_path, "ripqp-smallest-quad-resid.tex"), "w") do io
    println(io, "\\documentclass[varwidth=20cm,crop=true]{standalone}")
    println(io, "\\usepackage{longtable}")
    println(io, "\\begin{document}")
    pretty_table(
      io,
      data; 
      header = header,
      row_names= row_names,
      title = "Smallest residuals for RipQP multiquad2",
      backend = Val(:latex),
      formatters = (ft_printf(["%7.1e", "%7.1e", "%7.1e", "%d"], 1:4),
        (v, i, j) -> (SolverBenchmark.safe_latex_AbstractFloat(v)),
        )
    )
    println(io, "\\end{document}")
  end
  open(joinpath(table_path, "ripqp-smallest-quad-resid.md"), "w") do io
      pretty_table(
        io,
        data; 
        header = header,
        row_names= row_names,
        title = "Smallest residuals for RipQP multiquad2",
        formatters = (ft_printf(["%7.1e", "%7.1e", "%7.1e", "%d"], 1:4),
          )
      )
  end
  return nothing
end