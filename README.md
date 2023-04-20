# RipQPBenchmarks

A repository launching benchmarks with RipQP and saving performance profiles and tables to measure performance.
The benchmarks use the Netlib problems (LPs), the Maros and Meszaros problems (QPS), and the problems from the article (in quadruple precision):

* D. Ma, L. Yang, R. M. T. Fleming, I. Thiele, B. O. Palsson, and M. A. Saunders, [*Reliable and efficient solution of genome-scale models of Metabolism and macromolecular Expression*](https://doi.org/10.1038/srep40863), Scientific Reports, 7(1):40863, Feb. 2017. ISSN 2045-2322.

## Install deps

To launch all benchmarks, you will need:
- CPLEX and CPLEX.jl: follow the instructions at https://github.com/jump-dev/CPLEX.jl
- Gurobi and Gurobi.jl: follow the instructions at https://github.com/jump-dev/Gurobi.jl
- Xpress and Xpress.jl: follow the instructions at https://github.com/jump-dev/Xpress.jl
- MA57, MA97 and HSL.jl: follow the instructions at https://github.com/JuliaSmoothOptimizers/HSL.jl

Then, use

```julia
pkg> add https://github.com/geoffroyleconte/RipQPBenchmarks.jl.git
```

## Running all benchmarks

All the benchmarks, profiles and tables can be generated with the function

```julia
using RipQPBenchmarks
save_path = "./" # your path to save stats
ripqp_all_benchmarks(
  save_path;
  run_cplex = false,
  run_gurobi = false,
  run_xpress = false,
  run_ma57 = false,
  run_ma97 = false,
  plot_extension = ".pdf",
)
```

`save_path` is the directory where the benchmarks (`.CSV` files), the profiles, and the tables (saved as `.md` and `.tex`) will be saved.
The `plot_extension` keyword argument used to generate the performance profile has only been tested with `".pdf"`.
Set the keyword arguments `run_cplex`, `run_gurobi`, etc... according to the installed deps.

This function might take a long time to execute (more than 2 days on a slow computer for me).

## Computing the profiles only

To run the benchmarks on Netlib and Maros and Meszaros problems, use

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
where `data_path` is the path containing the results of the benchmarks (`save_path` of the previous section) and `profile_path` is the path where the profiles should be saved (can be the same as `data_path`).

## Computing the tables in quadruple precision only

To run the benchmarks on the problems in quadruple precision, use

```julia
run_benchmarks_quad(save_path)
```

To generate the table in quadruple precision, use

```julia
quad_prec_table(data_path, table_path)
```

where `data_path` is the path containing the results of the benchmarks (`save_path` of the benchmark section)
and `table_path` is the path where the tables should be saved.

To generate the table of the smallest residuals that RipQP can reach for the problems in quadruple precision, use

```julia
smallest_quad_resid_table(table_path)
```
