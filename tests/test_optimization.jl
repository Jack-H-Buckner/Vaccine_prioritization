"""
This file has function calls to repeate the optimization process
several times to insure that the restuls are reproducible



"""
module test_opt_2

using Random


include("../code_model/parameters/distancing_senarios.jl")
include("../code_model/parameters/parameters.jl")
include("../code_model/parameters/R0.jl")
include("../code_model/parameters/initial_conditions.jl")
include("../code_model/dynamics/simulations.jl")
include("../model_runs/define_routines.jl")


# seed1 20201119
# seed2 3201961
# seed3 2141996
# seed4 2101993
# seed5 1061961


##### infections


## these values have been changed since and may not be tunded apropreatly - need to check before using
N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,500,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 11

SA_iter = 20000
SA_sigma = 0.001
Random.seed!(20201119)
v(t) =  0.1/30
print("here")
define_routines.run_test(
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
    "../data_outputs/test_opt1",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "infections"
)



Random.seed!(20201119)
print("here")
define_routines.run_test(
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
    "../data_outputs/test_opt1_re",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "infections"
)
#
#
Random.seed!(3201961)
define_routines.run_test(
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
    "../data_outputs/test_opt2",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "infections"
)


Random.seed!(2141996)
define_routines.run_test(
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
    "../data_outputs/test_opt3",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "infections"
)


Random.seed!(2101993)
define_routines.run_test(
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
    "../data_outputs/test_opt4",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "infections"
)


Random.seed!(1061961)
define_routines.run_test(
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
    "../data_outputs/test_opt5",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "infections"
)


Random.seed!(20201119)

print("here")
define_routines.run_test(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta01_alpha03_40,
    initial_conditions.calc_IC(0.90,0.015,0.08,
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
    "../data_outputs/test_opt6",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "infections"
)

Random.seed!(3201961)
define_routines.run_test(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta01_alpha03_40,
    initial_conditions.calc_IC(0.90,0.015,0.08,
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
    "../data_outputs/test_opt7",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "infections"
)



Random.seed!(2141996)
define_routines.run_test(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta01_alpha03_40,
    initial_conditions.calc_IC(0.90,0.015,0.08,
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
    "../data_outputs/test_opt8",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "infections"
)




##### deaths
# test2 params
N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,500,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 11

SA_iter = 20000
SA_sigma = 0.001
Random.seed!(20201119)
v(t) =  0.1/30
print("here")
define_routines.run_test(
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
    "../data_outputs/test_opt1",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "deaths"
)



Random.seed!(20201119)
print("here")
define_routines.run_test(
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
    "../data_outputs/test_opt1_re",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "deaths"
)
#
#
Random.seed!(3201961)
define_routines.run_test(
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
    "../data_outputs/test_opt2",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "deaths"
)


Random.seed!(2141996)
define_routines.run_test(
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
    "../data_outputs/test_opt3",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "deaths"
)


Random.seed!(2101993)
define_routines.run_test(
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
    "../data_outputs/test_opt4",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "deaths"
)


Random.seed!(1061961)
define_routines.run_test(
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
    "../data_outputs/test_opt5",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "deaths"
)


Random.seed!(20201119)

print("here")
define_routines.run_test(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta01_alpha03_40,
    initial_conditions.calc_IC(0.90,0.015,0.08,
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
    "../data_outputs/test_opt6",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "deaths"
)

Random.seed!(3201961)
define_routines.run_test(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta01_alpha03_40,
    initial_conditions.calc_IC(0.90,0.015,0.08,
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
    "../data_outputs/test_opt7",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "deaths"
)



Random.seed!(2141996)
define_routines.run_test(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta01_alpha03_40,
    initial_conditions.calc_IC(0.90,0.015,0.08,
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
    "../data_outputs/test_opt8",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "deaths"
)





##### YLL


# test2 params
N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,500,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 11

SA_iter = 20000
SA_sigma = 0.001
Random.seed!(20201119)
v(t) =  0.1/30
print("here")
define_routines.run_test(
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
    "../data_outputs/test_opt1",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "YLL"
)



Random.seed!(20201119)
print("here")
define_routines.run_test(
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
    "../data_outputs/test_opt1_re",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "YLL"
)
#
#
Random.seed!(3201961)
define_routines.run_test(
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
    "../data_outputs/test_opt2",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "YLL"
)


Random.seed!(2141996)
define_routines.run_test(
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
    "../data_outputs/test_opt3",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "YLL"
)


Random.seed!(2101993)
define_routines.run_test(
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
    "../data_outputs/test_opt4",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "YLL"
)


Random.seed!(1061961)
define_routines.run_test(
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
    "../data_outputs/test_opt5",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "YLL"
)


Random.seed!(20201119)

print("here")
define_routines.run_test(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta01_alpha03_40,
    initial_conditions.calc_IC(0.90,0.015,0.08,
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
    "../data_outputs/test_opt6",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "YLL"
)

Random.seed!(3201961)
define_routines.run_test(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta01_alpha03_40,
    initial_conditions.calc_IC(0.90,0.015,0.08,
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
    "../data_outputs/test_opt7",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "YLL"
)



Random.seed!(2141996)
define_routines.run_test(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta01_alpha03_40,
    initial_conditions.calc_IC(0.90,0.015,0.08,
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
    "../data_outputs/test_opt8",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma,
    "YLL"
)



end
