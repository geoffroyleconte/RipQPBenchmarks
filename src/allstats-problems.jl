safe_latex_customstring(s::AbstractString) = "\\(" * replace(s, "_" => "\\_") * "\\)"
function safe_latex_customstring(col::Integer)
  # by this point, the table value should already have been converted to a string
  return (s, i, j) -> begin
    j != col && return s
    return safe_latex_customstring(s)
  end
end

function save_benchmark_table(save_path, stats)
  # SolverBenchmark.default_formatters[InlineString] = "%15s"
  hdr_override = Dict(
    :name => "Name",
    :nvar => "n",
    :ncon => "m",
    :elapsed_time => "time (s)",
    :iter => "iter tot",
    :iters_sp => "iter32",
    :iters_sp2 => "iter64",
    :primal_feas => "pfeas",
    :dual_feas => "dfeas",
  )

  fmt_override = Dict(
    :status => "15s",
    :objective => "%8.1e",
    :elapsed_time => "%8.1e",
    :primal_feas => "%8.1e",
    :dual_feas => "%8.1e",
    :pdd => "%8.1e",
  )
  pretty_stats(stdout,
    stats[!, [:name, :nvar, :ncon, :status, :objective, :pdd, :primal_feas, :dual_feas, :elapsed_time, :iter, :iters_sp, :iters_sp2]],
    hdr_override = hdr_override,
    col_formatters = fmt_override,)

  open(joinpath(save_path, "ripqp_multi1_qp.tex"), "w") do io
    pretty_latex_stats(io,
      stats[!, [:name, :nvar, :ncon, :status, :objective, :pdd, :primal_feas, :dual_feas, :elapsed_time, :iter, :iters_sp, :iters_sp2]],
      hdr_override = hdr_override,
      col_formatters = fmt_override,
      formatters = (ft_printf(["15s", "%7.1e", "%7.1e","%7.1e","%7.1e", "%7.1e"], [4, 5, 6,7,8, 9]),
      SolverBenchmark.safe_latex_AbstractFloat_col(5),
      SolverBenchmark.safe_latex_AbstractFloat_col(6),
      SolverBenchmark.safe_latex_AbstractFloat_col(7),
      SolverBenchmark.safe_latex_AbstractFloat_col(8),
      SolverBenchmark.safe_latex_AbstractFloat_col(9),
      safe_latex_customstring(4)))
  end
end