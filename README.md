# RipQPBenchmarks

A repository launching benchmarks with RipQP and saving performance profiles and tables to measure performance.

## Launching Benchmarks

To launch all benchmarks, you will need:
- CPLEX and CPLEX.jl: follow the instructions at https://github.com/jump-dev/CPLEX.jl
- Gurobi and Gurobi.jl: follow the instructions at https://github.com/jump-dev/Gurobi.jl
- Xpress and Xpress.jl: follow the instructions at https://github.com/jump-dev/Xpress.jl
- MA57, MA97 and HSL.jl: follow the instructions at https://github.com/JuliaSmoothOptimizers/HSL.jl

Then, use

```julia
save_path = "./" # your path to save stats
run_benchmarks_solvers(
  save_path;
  run_cplex = false,
  run_gurobi = false,
  run_xpress = false,
  run_ma57 = false,
  run_ma97 = false,
)
```
and modify the keyword arguments `run_cplex` etc... if you have the required dependencies installed to run all benchmarks executed on the Netlib and Maros and Meszaros test sets.

To run the benchmarks used to solve the problems in quadruple precision mentionned in the article:

* D. Ma, L. Yang, R. M. T. Fleming, I. Thiele, B. O. Palsson, and M. A. Saunders, [*Reliable and efficient solution of genome-scale models of Metabolism and macromolecular Expression*](https://doi.org/10.1038/srep40863), Scientific Reports, 7(1):40863, Feb. 2017. ISSN 2045-2322.

use

```julia
run_benchmarks_quad(save_path)
```

## Saving performance profiles

To save the performance profiles computed on the Netlib and Maros and Meszaros datasets, use

```julia
save_all_profiles(
  data_path,
  profile_path;
  plot_extension = ".pdf",
  run_cplex = false,
  run_gurobi = false,
  run_xpress = false,
  run_ma57 = false,
  run_ma97 = false,
)
```

where `data_path` is the path containing the results of the benchmarks (`save_path` of the previous section) and `profile_path` is the path where the profiles should be saved.

## Getting the benchmark tables in quadruple precision

```julia
quad_prec_table(data_path; latex = false)
```

where `data_path` is the path containing the results of the benchmarks (`save_path` of the benchmark section).
Use `latex = true` to get the tables in LaTeX formatting.
