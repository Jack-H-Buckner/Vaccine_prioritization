module generate_range_alt_scenario




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

v(t) = 0.1/30

# print("\n")
# print("weak NPI")
# #get sensetivity bars
# print("\n")
# print("generate range ")
# Random.seed!(202119)
# elasticity.generate_range(
#     join(["data_outputs/weak_NPI", "_policies.csv"]), # path to file with solution
#     0.0025, # level of tolerance for accepted solutions
#     0.0005, # varaince of proposal distribtion
#     5000, # number of itterations per chain
#     10, # number of chains
#     100000, # maximum number of iterations before cahin is broken
#     R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.75,
#     distancing_senarios.constant_beta03_alpha04_40,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_04 ,
#         8,
#         R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.75,
#         distancing_senarios.constant_beta03_alpha04_40,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]),
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work1,
#     v,
#     parameters.bins_04,
#     "data_outputs/weak_NPI"
# )
#
#
#
# v(t) = 0.1/30
#
# Random.seed!(171)
# N_iter_anealing = 20000
# print("\n")
# print("Strong NPI")
# elasticity.generate_range(
#     join(["data_outputs/strong_NPI", "_policies.csv"]), # path to file with solution
#     0.0025, # level of tolerance for accepted solutions
#     0.0005, # varaince of proposal distribtion
#     5000, # number of itterations per chain
#     10, # number of chains
#     100000, # maximum number of iterations before cahin is broken
#     R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.5,
#     distancing_senarios.constant_beta01_alpha03_40,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_04 ,
#         8,
#         R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.5,
#         distancing_senarios.constant_beta01_alpha03_40,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]),
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work1,
#     v,
#     parameters.bins_04,
#     "data_outputs/strong_NPI",
# )


#
# v(t) = 0.1/30
#
# Random.seed!(991118541)
# N_iter_anealing = 20000
# print("\n")
# print("high_initial_infections")
# elasticity.generate_range(
#     join(["data_outputs/high_initial_infections", "_policies.csv"]), # path to file with solution
#     0.0025, # level of tolerance for accepted solutions
#     0.0005, # varaince of proposal distribtion
#     5000, # number of itterations per chain
#     10, # number of chains
#     100000, # maximum number of iterations before cahin is broken
#     R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.65,
#     distancing_senarios.constant_beta03_alpha04_40,
#     initial_conditions.calc_IC(0.90,0.015,0.08,
#         parameters.bins_04 ,
#         8,
#         R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
#         distancing_senarios.constant_beta03_alpha04_40,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]),
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work1,
#     v,
#     parameters.bins_04,
#     "data_outputs/high_initial_infections"
# )
#
#
#
#
#
#
# v(t) = 0.1/30
#
# Random.seed!(10411111111100)
# N_iter_anealing = 20000
# elasticity.generate_range(
#     join(["data_outputs/high_sucept_children", "_policies.csv"]), # path to file with solution
#     0.0025, # level of tolerance for accepted solutions
#     0.0005, # varaince of proposal distribtion
#     5000, # number of itterations per chain
#     10, # number of chains
#     100000, # maximum number of iterations before cahin is broken
#     R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.65,
#     distancing_senarios.constant_beta03_alpha04_40,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_04 ,
#         8,
#         R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
#         distancing_senarios.constant_beta03_alpha04_40,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]),
#     parameters.suceptability_work3,
#     parameters.vaccine_eff_work1,
#     v,
#     parameters.bins_04,
#     "data_outputs/high_sucept_children",
# )







#
# v(t) = 0.1/30
# Random.seed!(110198101999997)
# N_iter_anealing = 20000
# elasticity.generate_range(
#     join(["data_outputs/Low_effectiveness_60", "_policies.csv"]), # path to file with solution
#     0.0025, # level of tolerance for accepted solutions
#     0.0005, # varaince of proposal distribtion
#     5000, # number of itterations per chain
#     10, # number of chains
#     100000, # maximum number of iterations before cahin is broken
#     R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.65,
#     distancing_senarios.constant_beta03_alpha04_40,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_04 ,
#         8,
#         R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
#         distancing_senarios.constant_beta03_alpha04_40,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]),
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work3,
#     v,
#     parameters.bins_04,
#     "data_outputs/Low_effectiveness_60"
# )
#
#
#
#
#
#
#
#
# v(t) = 0.1/30
# Random.seed!(995454)
# N_iter_anealing = 20000
# elasticity.generate_range(
#     join(["data_outputs/Low_effectiveness", "_policies.csv"]), # path to file with solution
#     0.0025, # level of tolerance for accepted solutions
#     0.0005, # varaince of proposal distribtion
#     5000, # number of itterations per chain
#     10, # number of chains
#     100000, # maximum number of iterations before cahin is broken
#     R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.65,
#     distancing_senarios.constant_beta03_alpha04_40,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_04 ,
#         8,
#         R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
#         distancing_senarios.constant_beta03_alpha04_40,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]),
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work2,
#     v,
#     parameters.bins_04,
#     "data_outputs/Low_effectiveness"
# )




v(t) = 0.1/30
Random.seed!(925112019)
N_iter_anealing = 20000
elasticity.generate_range(
    join(["data_outputs/schools_open", "_policies.csv"]), # path to file with solution
    0.0025, # level of tolerance for accepted solutions
    0.0005, # varaince of proposal distribtion
    5000, # number of itterations per chain
    10, # number of chains
    100000, # maximum number of iterations before cahin is broken
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta07_alpha04_40,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta07_alpha04_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "data_outputs/schools_open"
)






v(t) = 0.1/30
Random.seed!(101141996)
N_iter_anealing = 20000
elasticity.generate_range(
    join(["data_outputs/high_contacts_social", "_policies.csv"]), # path to file with solution
    0.0025, # level of tolerance for accepted solutions
    0.0005, # varaince of proposal distribtion
    5000, # number of itterations per chain
    10, # number of chains
    100000, # maximum number of iterations before cahin is broken
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta03_alpha05_40,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha05_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "data_outputs/high_contacts_social"
)



end
