export run_benchmarks_solvers, run_benchmarks_quad, createQuadraticModel_T

function createQuadraticModel(qpdata; name="qp_pb")
    return QuadraticModel(qpdata.c, qpdata.qrows, qpdata.qcols, qpdata.qvals,
            Arows=qpdata.arows, Acols=qpdata.acols, Avals=qpdata.avals,
            lcon=qpdata.lcon, ucon=qpdata.ucon, lvar=qpdata.lvar, uvar=qpdata.uvar,
            c0=qpdata.c0, name=name)
end

save_path = "/home/gelecd/code/docGL/benchmarks/ripqp_paper"

function optimize_ripqp(path_pb :: String, ripqp_func :: Function)
    problems = []
    i_max = 1000
    i = 1
    for file_name in readdir(path_pb)
         if file_name[end-3:end] == ".SIF" 
             println(file_name)
             pb_i = string(path_pb, "/", file_name)
             if file_name in ["BLEND.SIF"; "DFL001.SIF"; "FORPLAN.SIF"; "GFRD-PNC.SIF"; "SIERRA.SIF";
                         "EXDATA.SIF"; "QFORPLAN.SIF"; "QGFRDXPN.SIF"; "VALUES.SIF"]
                 qpdata_i = readqps(pb_i, mpsformat=:fixed)
             else
                 qpdata_i = readqps(pb_i)
             end
             push!(problems, createQuadraticModel(qpdata_i, name=file_name[1:end-4]))

             if i==i_max
                 break
             end
             i += 1
         end
    end

    return solve_problems(ripqp_func, problems)
end

function run_benchmarks_solvers(
  save_path::String;
  run_cplex::Bool = false,
  run_gurobi::Bool = false,
  run_xpress::Bool = false,
  run_ma57::Bool = false,
  run_ma97::Bool = false,
)
  # download netlib and mm problems
  path_pb_lp = fetch_netlib()
  path_pb_qp = fetch_mm()

  function save_problems(file_path :: String, ripqp_func :: Function, 
                       path_pb_lp :: String = path_pb_lp, path_pb_qp :: String = path_pb_qp)

    lp_classic =  optimize_ripqp(path_pb_lp, ripqp_func)
    CSV.write(string(file_path, "_lp.csv"), lp_classic)
    qp_classic =  optimize_ripqp(path_pb_qp, ripqp_func)
    CSV.write(string(file_path, "_qp.csv"), qp_classic)
    
    return Nothing
  end

  # create functions used to solve the problems
  # run each function on one problem to compile 
  pb = string(path_pb_lp, "/AGG.SIF")
  # pb2 = string(path_pb_qp, "/AUG2D.SIF")
  qpdata = readqps(pb);
  qm = createQuadraticModel(qpdata)

  ripqp1(QM) = ripqp(QM, sp = K2LDLParams(),
                      itol = InputTol(max_iter = 800, max_time=1200.))
  stats = ripqp1(qm)
  ripqp_cc(QM) = ripqp(QM, sp = K2LDLParams(), kc = -1,
                      itol = InputTol(max_iter = 800, max_time=1200.))
  stats = ripqp_cc(qm)
  if run_ma57
    ripqpma57(QM) = ripqp(QM,
                        sp = K2LDLParams(fact_alg = HSLMA57Fact()),
                        itol = InputTol(max_iter = 800, max_time=1200.))
    stats = ripqpma57(qm)
    ripqpma57_multi1(QM) = ripqp(QM, mode = :multi,
                                sp = K2LDLParams{Float32}(fact_alg = HSLMA57Fact()),
                                itol = InputTol(max_iter = 800, max_time=1200.))
    stats = ripqpma57_multi1(qm)
    ripqpma57_multi2(QM) = ripqp(QM, mode = :multi, early_multi_stop = false,
                        sp = K2LDLParams{Float32}(safety_dist_bnd = false,
                            fact_alg = HSLMA57Fact(), ρ_min=Float32(1.0e-7), δ_min = Float32(1.0e-7)),
                        itol = InputTol(max_iter = 800, max_time=1200.,
                                        ϵ_pdd1 = 1.0e0, ϵ_rb1 = 1.0e-2, ϵ_rc1 = 1.0e-2))
    stats = ripqpma57_multi2(qm)
  end
  ripqp_ldlprecond1(QM) = ripqp(QM, mode = :multi,
                      sp = K2KrylovParams(uplo = :U,
                          form_mat = true, equilibrate = false, kmethod = :gmres,
                          preconditioner = LDL(T = Float32, warm_start = true),
                          ρ_min=1.0e-8, δ_min = 1.0e-8,
                          mem = 10, itmax = 10,
                          atol0 = 1.0e-2, rtol0 = 1.0e-2,
                          atol_min = 1.0e-8, rtol_min = 1.0e-8,
                          ),
                          sp2 = K2KrylovParams(uplo = :U,
                          form_mat = true, equilibrate = false, kmethod = :gmres,
                          preconditioner = LDL(T = Float64, warm_start = true),
                          ρ_min=1.0e-8, δ_min = 1.0e-8,
                          mem = 5,
                          itmax = 5,
                          atol0 = 1.0e-2, rtol0 = 1.0e-2,
                          atol_min = 1.0e-10, rtol_min = 1.0e-10,
                          ),
                      solve_method = PC(),
                      itol = InputTol(max_iter = 800, max_time=1200.,
                                      ϵ_pdd1 = 1.0e-8, ϵ_rb1 = 1.0e-6,
                                      ϵ_rc1 = 1.0e-6))
  stats = ripqp_ldlprecond1(qm)
  ripqp_ldlprecond2(QM) = ripqp(QM, mode = :multi,
                      sp = K2KrylovParams(uplo = :U,
                          form_mat = true, equilibrate = true, kmethod = :gmres,
                          preconditioner = LDL(T = Float32, warm_start = true),
                          ρ_min=1.0e-8, δ_min = 1.0e-8,
                          mem = 10, itmax = 10,
                          atol0 = 1.0e-2, rtol0 = 1.0e-2,
                          atol_min = 1.0e-8, rtol_min = 1.0e-8,
                          ),
                          sp2 = K2KrylovParams(uplo = :U,
                          form_mat = true, equilibrate = true, kmethod = :gmres,
                          preconditioner = LDL(T = Float64, warm_start = true),
                          ρ_min=1.0e-8, δ_min = 1.0e-8,
                          mem = 5,
                          itmax = 5,
                          atol0 = 1.0e-2, rtol0 = 1.0e-2,
                          atol_min = 1.0e-10, rtol_min = 1.0e-10,
                          ),
                      solve_method = PC(),
                      itol = InputTol(max_iter = 800, max_time=1200.,
                                      ϵ_pdd1 = 1.0e-8, ϵ_rb1 = 1.0e-6,
                                      ϵ_rc1 = 1.0e-6))
  stats = ripqp_ldlprecond2(qm)
  ripqp_lldlprecond(QM) = ripqp(QM, mode = :multi, 
                      sp = K2KrylovParams(uplo = :L,
                          form_mat = true, equilibrate = false, kmethod = :gmres,
                          preconditioner = LDL(fact_alg = LLDLFact(mem=20), pos = :R,
                                              T = Float32, warm_start = true),
                          ρ_min=1.0e-8, δ_min = 1.0e-8,
                          mem = 10, itmax = 10,
                          atol0 = 1.0e-2, rtol0 = 1.0e-2,
                          atol_min = 1.0e-8, rtol_min = 1.0e-8,
                          ),
                          sp2 = K2KrylovParams(uplo = :U,
                          form_mat = true, equilibrate = false, kmethod = :gmres,
                          preconditioner = LDL(T = Float64, pos = :R, warm_start = true),
                          ρ_min=1.0e-8, δ_min = 1.0e-8,
                          mem = 5,
                          itmax = 5,
                          atol0 = 1.0e-2, rtol0 = 1.0e-2,
                          atol_min = 1.0e-10, rtol_min = 1.0e-10,
                          ),
                      solve_method = IPF(), solve_method2 = PC(),
                      itol = InputTol(max_iter = 800, max_time=1200.))
  stats = ripqp_lldlprecond(qm)
  if run_ma97
    ripqpma97(QM) = ripqp(QM,
                        sp = K2LDLParams(fact_alg = HSLMA97Fact()),
                        itol = InputTol(max_iter = 800, max_time=1200.))
    stats = ripqpma97(qm)
  end
  ripqpqdldl(QM) = ripqp(QM, 
                      sp = K2LDLParams(fact_alg = QDLDLFact()),
                      itol = InputTol(max_iter = 800, max_time=1200.))
  stats = ripqpqdldl(qm)
  ripqpcholmod(QM) = ripqp(QM, 
                      sp = K2LDLParams(fact_alg = CholmodFact()),
                      itol = InputTol(max_iter = 800, max_time=1200.))
  stats = ripqpcholmod(qm)
  if run_cplex
    cplex2(QM) = cplex(QM, crossover=2, display=0, threads=1)
    stats = cplex2(qm)  # compile code
  end
  if run_gurobi
    gurobi2(QM) = gurobi(QM, crossover=0, display=0, threads=1)
    stats = gurobi2(qm)  # compile code
  end
  if run_xpress
    xpress2(QM) = xpress(QM, crossover=0, threads=1)
    stats = xpress2(qm)  # compile code
  end
  ripqp_multi(QM) = ripqp(QM, mode=:multi, itol = InputTol(max_iter = 800, max_time=1200.))
  stats = ripqp_multi(qm)

  # run benchmarks
  save_problems(string(save_path, "/ripqp1"), ripqp1)
  run_gurobi && save_problems(string(save_path, "/gurobi1"), gurobi2)
  run_cplex && save_problems(string(save_path, "/cplex1"), cplex2)
  run_xpress && save_problems(string(save_path, "/xpress1"), xpress2)

  save_problems(string(save_path, "/ripqp_cc1"), ripqp_cc)

  run_ma57 && save_problems(string(save_path, "/ripqp_ma57"), ripqpma57)
  run_ma97 && save_problems(string(save_path, "/ripqp_ma971"), ripqpma97)
  save_problems(string(save_path, "/ripqp_qdldl1"), ripqpqdldl)
  save_problems(string(save_path, "/ripqp_cholmod1"), ripqpcholmod)

  save_problems(string(save_path, "/ripqp_multi1"), ripqp_multi)
  run_ma57 && save_problems(string(save_path, "/ripqp_ma57_multi1"), ripqpma57_multi1) # check regu
  run_ma57 && save_problems(string(save_path, "/ripqp_ma57_multi2"), ripqpma57_multi2) # check regu

  save_problems(string(save_path, "/ripqp_ldlprecond1"), ripqp_ldlprecond1)
  save_problems(string(save_path, "/ripqp_ldlprecond2"), ripqp_ldlprecond2)
  save_problems(string(save_path, "/ripqp_lldlprecond"), ripqp_lldlprecond)

  # save_problems(string(save_path, "/ripqp_ldlprecondma57"), ripqp_ldlprecond)
end

function createQuadraticModel_T(qpdata; T = Float128, name="qp_pb")
    return QuadraticModel(convert(Array{T}, qpdata.c), qpdata.qrows, qpdata.qcols,
            convert(Array{T}, qpdata.qvals),
            Arows=qpdata.arows, Acols=qpdata.acols,
            Avals=convert(Array{T}, qpdata.avals),
            lcon=convert(Array{T}, qpdata.lcon),
            ucon=convert(Array{T}, qpdata.ucon),
            lvar=convert(Array{T}, qpdata.lvar),
            uvar=convert(Array{T}, qpdata.uvar),
            c0=T(qpdata.c0), x0 = zeros(T, length(qpdata.c)), name=name)
end


function optimize_ripqp(path_pb :: String, ripqp_func :: Function, T::DataType)
  problems = [
    createQuadraticModel_T(readqps(string(path_pb, "/TMA_ME_presolved.mps")), T = T, name = "TMA_ME"),
    createQuadraticModel_T(readqps(string(path_pb, "/GlcAlift_presolved.mps")), T = T, name = "GlcAlift"),
    createQuadraticModel_T(readqps(string(path_pb, "/GlcAerWT_presolved.mps")), T = T, name = "GlcAerWT"),
  ]

  return solve_problems(ripqp_func, problems)
end

function optimize_ripqp_nops(path_pb :: String, ripqp_func :: Function, T::DataType)
  problems = [
    createQuadraticModel_T(readqps(string(path_pb, "/TMA_ME.mps")), T = T, name = "TMA_ME"),
    createQuadraticModel_T(readqps(string(path_pb, "/GlcAlift.mps")), T = T, name = "GlcAlift"),
    createQuadraticModel_T(readqps(string(path_pb, "/GlcAerWT.mps")), T = T, name = "GlcAerWT"),
  ]

  return solve_problems(ripqp_func, problems)
end

# save_path = "/home/gelecd/code/docGL/benchmarks/ripqp_paper"
function run_benchmarks_quad(save_path::String)

  T = Float128
  Tlow = Float64

  path_pb = joinpath(dirname(@__DIR__), "problems")

  function save_quad_problems(file_path :: String, ripqp_func :: Function; path_pb :: String = path_pb, T = T)
    lp_stats = optimize_ripqp(path_pb, ripqp_func, T)
    CSV.write(string(file_path, "_quad.csv"), lp_stats)
    return Nothing
  end
  function save_quad_problems_nops(file_path :: String, ripqp_func :: Function; path_pb :: String = path_pb, T = T)
    lp_stats = optimize_ripqp_nops(path_pb, ripqp_func, T)
    CSV.write(string(file_path, "_nops_quad.csv"), lp_stats)
    return Nothing
  end

  # compile
  path_pb_lp = fetch_netlib()
  qm1 = createQuadraticModel_T(readqps(string(path_pb_lp, "/AFIRO.SIF")), T=T)
  ripqp_mono(qm) = ripqp(qm, itol = InputTol(T; max_iter = 800, max_time=1200.))
  stats = ripqp_mono(qm1)
  ripqp_multi(qm) = ripqp(qm, mode=:multi, itol = InputTol(T; max_iter = 800, max_time=1200.))
  stats = ripqp_multi(qm1)
  ripqp_multi_quad1(qm; T = T, Tlow = Tlow) = ripqp(qm, 
    mode = :multi,
    early_multi_stop = false,
    sp = K2KrylovParams{Tlow}( # solve in Float64
      uplo = :U,
      kmethod=:gmres,
      form_mat = true,
      equilibrate = false,
      itmax = 50,
      mem = 50,
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
    itol = InputTol(T, max_iter = 7000, max_time = 20000.0, max_iter1 = 200, ϵ_pdd1 = T(1.0e1),
      ϵ_rc1 = T(1.0e-6), ϵ_rb1 = T(1.0e-6)),
    display = true,
  )
  stats = ripqp_multi_quad1(qm1)
  ripqp_multi_quad2(qm; T = T, Tlow = Tlow) = ripqp(qm, 
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
    itol = InputTol(T, max_iter = 7000, max_time = 20000.0, max_iter1 = 100, ϵ_pdd1 = T(1.0e1),
      ϵ_rc1 = T(1.0e-6), ϵ_rb1 = T(1.0e-6)),
    display = true,
  )
  stats = ripqp_multi_quad2(qm1)
  
  save_quad_problems(string(save_path, "/ripqp_multi1"), ripqp_multi, T = T)
  save_quad_problems(string(save_path, "/ripqp_mono1"), ripqp_mono, T = T)
  save_quad_problems(string(save_path, "/ripqp_multiquad1"), ripqp_multi_quad1, T = T)
  save_quad_problems_nops(string(save_path, "/ripqp_multiquad2"), ripqp_multi_quad2, T = T)
end