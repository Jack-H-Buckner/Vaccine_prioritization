"""
repeats several modle runs to insure consisten performance.
Becasue the optimization is not convex convergence to an optimal solution
cannot be guaranteed however concistent results can be achieved. This module
runs th eoptimization five times with a fixed set of parameters. We find that
the solutions converge consistently in the first four decision periods where the
solutions are inelastic. These parameters will suffice for the sensetivity analyses
where we only present informaiton from these initial periods
"""
module test_opt_2

using Random

include("distancing_senarios.jl")
include("parameters.jl")
include("R0.jl")
include("initial_conditions.jl")
include("elasticity.jl")
include("run_opts_2.jl")

# seed1 20201119
# seed2 3201961
# seed3 2141996
# seed4 2101993
# seed5 1061961


N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,500,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 11
Random.seed!(20201119)
v(t) =  0.1/30
run_opts_2.run_test(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta01_alpha04_40,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta01_alpha03_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "data_outputs/test_opts_1",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)

Random.seed!(3201961)
run_opts_2.run_test(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.base_senario,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.base_senario,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "data_outputs/test_opts_2",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)

#
Random.seed!(2141996)
run_opts_2.run_test(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.base_senario,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.base_senario,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "data_outputs/test_opts_3",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)

#
# Random.seed!(2101993)
# run_opts_2.run_test(
#     R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.65,
#     distancing_senarios.base_senario,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_04 ,
#         8,
#         R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
#         distancing_senarios.base_senario,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]),
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work1,
#     v,
#     parameters.bins_04,
#     "data_outputs/test_opts_4",
#     N_samples, # population size
#     N_out,
#     N_iter,
#     concentration
# )
#
#
# Random.seed!(1061961)
# run_opts_2.run_test(
#     R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.65,
#     distancing_senarios.base_senario,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_04 ,
#         8,
#         R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
#         distancing_senarios.base_senario,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]),
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work1,
#     v,
#     parameters.bins_04,
#     "data_outputs/test_opts_5",
#     N_samples, # population size
#     N_out,
#     N_iter,
#     concentration
# )
#
#
#
# Random.seed!(10619615)
# run_opts_2.run_test(
#     R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.65,
#     distancing_senarios.base_senario,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_04 ,
#         8,
#         R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
#         distancing_senarios.base_senario,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]),
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work1,
#     v,
#     parameters.bins_04,
#     "data_outputs/test_opts_6",
#     N_samples, # population size
#     N_out,
#     N_iter,
#     concentration
# )


end
