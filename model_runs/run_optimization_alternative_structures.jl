module alternative_structures

using Random
using Tables
using CSV

include("../code_model/parameters/distancing_senarios.jl")
include("../code_model/parameters/parameters.jl")
include("../code_model/parameters/R0.jl")
include("../code_model/parameters/initial_conditions.jl")

include("define_routines.jl")
include("define_routines_efficencies.jl")


Random.seed!(3201961)


# sampling parameters for dynamic opt
N_samples = [30000, 5000, 5000, 20000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,500,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1,]
N_iter = 11

Random.seed!(20201119)
v(t) =  0.1/30


#
define_routines_efficencies.run_optimization(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta03_alpha04_40,
    initial_conditions.calc_IC_efficencies(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    0.9, # suceptibility
    0.0, # infectiousness
    0.00, # severe disease
    v,
    parameters.bins_04,
    "../data_outputs/alt_leaky_sucept_only",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)



Random.seed!(20201119)
v(t) =  0.1/30


#
define_routines_efficencies.run_optimization(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta03_alpha04_40,
    initial_conditions.calc_IC_efficencies(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    0.9, # suceptibility
    0.9, # infectiousness
    0.9, # severe disease
    v,
    parameters.bins_04,
    "../data_outputs/alt_leaky",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)



Random.seed!(20201119)
N_iter_anealing = 25000
define_routines.run_optimization(
    R0.solve_R_20(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta03_alpha04_20,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_02 ,
        8,
        R0.solve_R_20(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_20,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_02,
    "../data_outputs/alt_20",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)


define_routines.run_optimization(
    R0.solve_R_20(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta03_alpha04_20_cl,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_02 ,
        8,
        R0.solve_R_20(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_20_cl,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_02,
    "../data_outputs/alt_20_cl",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)




Random.seed!(20201119)

define_routines.run_optimization(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta03_alpha04_40_cl,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40_cl,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "../data_outputs/alt_40_cl",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)
#
#






end
