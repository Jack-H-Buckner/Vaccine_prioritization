"""
repeats several modle runs to insure consisten performance
"""
module test_opt

using Random

include("distancing_senarios.jl")
include("parameters.jl")
include("R0.jl")
include("initial_conditions.jl")
include("elasticity.jl")
include("run_opts.jl")

# seed1 20201119
# seed2 3201961
# seed3 2141996
# seed4 2101993
# seed5 1061961


N_samples = [15000, 10000, 10000, 5000, 5000, 2500, 2500, 1000, 1000, 500, 500, 100, 100]
N_out = [2500, 2500, 2000, 1000, 1000, 750, 750, 500, 500, 50, 50, 10, 10]
N_iter = 10
Random.seed!(20201119)
v(t) =  0.1/30
run_opts.run_test(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.base_senario,
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
    "data_outputs/test_relaxed_dist_test1_params1",
    N_samples, # population size
    N_out,
    N_iter
)

Random.seed!(3201961)
run_opts.run_test(
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
    "data_outputs/test_relaxed_dist_test1_params2",
    N_samples, # population size
    N_out,
    N_iter
)

#
Random.seed!(2141996)
run_opts.run_test(
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
    "data_outputs/test_relaxed_dist_test1_params3",
    N_samples, # population size
    N_out,
    N_iter
)


Random.seed!(2101993)
run_opts.run_test(
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
    "data_outputs/test_relaxed_dist_test1_params4",
    N_samples, # population size
    N_out,
    N_iter
)


Random.seed!(1061961)
run_opts.run_test(
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
    "data_outputs/test_relaxed_dist_test1_params5",
    N_samples, # population size
    N_out,
    N_iter
)


end
