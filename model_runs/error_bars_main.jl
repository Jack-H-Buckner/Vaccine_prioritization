"""
runs the analyses defined in elasticity_revised.jl
"""
module error_bars


using Plots
using Measures
using CSV
using Tables
using DataFrames


include("../code_model/parameters/parameters.jl")
include("../code_model/dynamics/simulations.jl")
include("../code_model/dynamics/simulations_static.jl")
include("../code_model/dynamics/simulations_age_only.jl")
include("../code_model/optimization/optimization_2.jl")
include("../code_model/parameters/distancing_senarios.jl")
include("../code_model/parameters/R0.jl")
include("../code_model/parameters/initial_conditions.jl")
include("../code_model/optimization/simulated_anealing.jl")
include9"../code_model/optimization/elasticity_revised.jl")
#########################

### run for main text ###

#########################

#### manage data #####

sol = DataFrame!(CSV.File("data_outputs/main_text_full_0.0025_bounds.csv"))
min_YLL = sol.min[sol.Column49 .== "YLL"]
max_YLL = sol.max[sol.Column49 .== "YLL"]

min_infections = sol.min[sol.Column49 .== "Infections"]
max_infections = sol.max[sol.Column49 .== "Infections"]

min_deaths = sol.min[sol.Column49 .== "Deaths"]
max_deaths = sol.max[sol.Column49 .== "Deaths"]

vals = DataFrame!(CSV.File("data_outputs/main_text_full_outcomes.csv"))
val_infections = vals.Column1[1]
val_YLL = vals.Column2[2]
val_deaths = vals.Column3[3]

### set parameters ####
N_samples = [10000, 5000, 5000, 5000, 2500, 2500, 1000, 1000, 1000, 1000, 1000] #[20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,500,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 7 # 11

SA_iter = 10000
SA_sigma = 0.001
#Random.seed!(20201119)
v(t) =  0.1/30


### minimum YLL ###
#1:16

elasticity_revised.error_bar_search_full_policy(
    #### manage files ####
    "data_outputs/main_text_full_0.005_bounds_refined_2.csv",
    "data_outputs/main_text_full_0.005_bounds_refined_2.csv",
    true,
    #### defined value for error bar ####
    "Infections", val_infections, 0.005, "max", max_infections, 1:48, 8, 6,
    #### parameters for optimization ####
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65, distancing_senarios.constant_beta03_alpha04_40,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04,8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40, parameters.suceptability_work1,
        parameters.vaccine_eff_work1, parameters.sigma_asym[1]),
    parameters.suceptability_work1, parameters.vaccine_eff_work1,
    v, parameters.bins_04, "data_outputs/test_errorbars.csv",
    N_samples, N_out, N_iter, concentration, SA_iter, SA_sigma
)


elasticity_revised.error_bar_search_full_policy(
    #### manage files ####
    "data_outputs/main_text_full_0.005_bounds_refined.csv",
    "data_outputs/main_text_full_0.005_bounds_refined.csv",
    true,
    #### defined value for error bar ####
    "YLL", val_YLL, 0.005, "min", min_YLL, 1:48, 8, 6,
    #### parameters for optimization ####
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65, distancing_senarios.constant_beta03_alpha04_40,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04,8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40, parameters.suceptability_work1,
        parameters.vaccine_eff_work1, parameters.sigma_asym[1]),
    parameters.suceptability_work1, parameters.vaccine_eff_work1,
    v, parameters.bins_04, "data_outputs/test_errorbars.csv",
    N_samples, N_out, N_iter, concentration, SA_iter, SA_sigma
)
end
