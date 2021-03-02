module alternative_structures_R0

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
include("run_opts_efficencies.jl")
Random.seed!(3201961)


# sampling parameters for dynamic opt
N_samples = [30000, 5000, 5000, 20000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,500,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1,]
N_iter = 11

Random.seed!(20201119)
v(t) =  0.1/30


# Random.seed!(20201119)
# N_iter_anealing = 25000
# run_opts_2.run_optimization(
#     R0.solve_R_20(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.2,
#     distancing_senarios.constant_beta03_alpha04_20,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_02 ,
#         8,
#         R0.solve_R_20(parameters.R_0, parameters.suceptability_work1).zero[1]*0.2,
#         distancing_senarios.constant_beta03_alpha04_20,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]),
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work1,
#     v,
#     parameters.bins_02,
#     "data_outputs/alt_20_20",
#     N_samples, # population size
#     N_out,
#     N_iter,
#     concentration,
#     N_iter_anealing
# )



# Random.seed!(20201119)
# N_iter_anealing = 25000
# run_opts_2.run_optimization(
#     R0.solve_R_20(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.4,
#     distancing_senarios.constant_beta03_alpha04_20,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_02 ,
#         8,
#         R0.solve_R_20(parameters.R_0, parameters.suceptability_work1).zero[1]*0.4,
#         distancing_senarios.constant_beta03_alpha04_20,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]),
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work1,
#     v,
#     parameters.bins_02,
#     "data_outputs/alt_20_40",
#     N_samples, # population size
#     N_out,
#     N_iter,
#     concentration,
#     N_iter_anealing
# )




# Random.seed!(20201119)
# N_iter_anealing = 25000
# run_opts_2.run_optimization(
#     R0.solve_R_20(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.6,
#     distancing_senarios.constant_beta03_alpha04_20,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_02 ,
#         8,
#         R0.solve_R_20(parameters.R_0, parameters.suceptability_work1).zero[1]*0.6,
#         distancing_senarios.constant_beta03_alpha04_20,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]),
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work1,
#     v,
#     parameters.bins_02,
#     "data_outputs/alt_20_60",
#     N_samples, # population size
#     N_out,
#     N_iter,
#     concentration,
#     N_iter_anealing
# )

#
#
#
#
Random.seed!(20201119)
N_iter_anealing = 25000
run_opts_2.run_optimization(
    R0.solve_R_20(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.8,
    distancing_senarios.constant_beta03_alpha04_20,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_02 ,
        8,
        R0.solve_R_20(parameters.R_0, parameters.suceptability_work1).zero[1]*0.8,
        distancing_senarios.constant_beta03_alpha04_20,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_02,
    "data_outputs/alt_20_80",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)



end
