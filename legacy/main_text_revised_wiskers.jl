"""
run optimization for scenario presented in detail in main test
"""
module main_text

using Random
using Tables
using CSV

include("distancing_senarios.jl")
include("parameters.jl")
include("R0.jl")
include("initial_conditions.jl")
include("elasticity.jl")
include("run_opts_2.jl")
include("simulations.jl")



print(" ")
print("new verion!")
print(" ")

# vaccine supply
v(t) =  0.1/30


# #get sensetivity bars
# print("\n")
# print("generate range ")
# Random.seed!(202119)
# elasticity.generate_range(
#     join(["data_outputs/main_text_full", "_policies.csv"]), # path to file with solution
#     0.0025, # level of tolerance for accepted solutions
#     0.0005, # varaince of proposal distribtion
#     10000, # number of itterations per chain
#     30, # number of chains
#     100000, # maximum number of iterations before cahin is broken
#     R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.65, # NPI
#     distancing_senarios.constant_beta03_alpha04_40,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_04 ,
#         8,
#         R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
#         distancing_senarios.constant_beta03_alpha04_40,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]), # initial conditions
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work1,
#     v,
#     parameters.bins_04,
#     "data_outputs/main_text_full")

#
# elasticity.generate_range(
#     join(["data_outputs/main_text_full", "_policies.csv"]), # path to file with solution
#     0.01, # level of tolerance for accepted solutions
#     0.0005, # varaince of proposal distribtion
#     10000, # number of itterations per chain
#     30, # number of chains
#     100000, # maximum number of iterations before cahin is broken
#     R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.65, # NPI
#     distancing_senarios.constant_beta03_alpha04_40,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_04 ,
#         8,
#         R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
#         distancing_senarios.constant_beta03_alpha04_40,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]), # initial conditions
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work1,
#     v,
#     parameters.bins_04,
#     "data_outputs/main_text_full")

elasticity.generate_range(
    join(["data_outputs/main_text_full", "_policies.csv"]), # path to file with solution
    0.05, # level of tolerance for accepted solutions
    0.0005, # varaince of proposal distribtion
    10000, # number of itterations per chain
    30, # number of chains
    100000, # maximum number of iterations before cahin is broken
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65, # NPI
    distancing_senarios.constant_beta03_alpha04_40,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]), # initial conditions
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "data_outputs/main_text_full")



end
