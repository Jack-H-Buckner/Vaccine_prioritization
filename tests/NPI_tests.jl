module NPI_tests

using Random


include("distancing_senarios.jl")
include("parameters.jl")
include("R0.jl")
include("initial_conditions.jl")
include("elasticity.jl")
include("run_opts_2.jl")
include("simulations.jl")



# # sampling parameters for dynamic opt
# N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
# N_out = [1000,500,500,250,500,250,500,100,100,100,100]
# concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
# N_iter = 11
#
# N_iter_anealing = 20000
# Random.seed!(20201119)
# v(t) =  0.1/30
# # full optimization
# print("\n")
# print("full opt")
# run_opts_2.run_optimization(
#     R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.2,
#     distancing_senarios.constant_beta03_alpha04_40,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_04 ,
#         8,
#         R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.2,
#         distancing_senarios.constant_beta03_alpha04_40,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]),
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work1,
#     v,
#     parameters.bins_04,
#     "data_outputs/NPI_02",
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
#
#
#
# # sampling parameters for dynamic opt
# N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
# N_out = [1000,500,500,250,500,250,500,100,100,100,100]
# concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
# N_iter = 11
#
# N_iter_anealing = 20000
# Random.seed!(20201119)
# v(t) =  0.1/30
# # full optimization
# print("\n")
# print("full opt")
# run_opts_2.run_optimization(
#     R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.4,
#     distancing_senarios.constant_beta03_alpha04_40,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_04 ,
#         8,
#         R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.4,
#         distancing_senarios.constant_beta03_alpha04_40,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]),
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work1,
#     v,
#     parameters.bins_04,
#     "data_outputs/NPI_04",
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
# # sampling parameters for dynamic opt
# N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
# N_out = [1000,500,500,250,500,250,500,100,100,100,100]
# concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
# N_iter = 11
#
# N_iter_anealing = 20000
# Random.seed!(20201119)
# v(t) =  0.1/30
# # full optimization
# print("\n")
# print("full opt")
# run_opts_2.run_optimization(
#     R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.6,
#     distancing_senarios.constant_beta03_alpha04_40,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_04 ,
#         8,
#         R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.6,
#         distancing_senarios.constant_beta03_alpha04_40,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]),
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work1,
#     v,
#     parameters.bins_04,
#     "data_outputs/NPI_06",
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
# # sampling parameters for dynamic opt
# N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
# N_out = [1000,500,500,250,500,250,500,100,100,100,100]
# concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
# N_iter = 11
#
# N_iter_anealing = 20000
# Random.seed!(20201119)
# v(t) =  0.1/30
# # full optimization
# print("\n")
# print("full opt")
# run_opts_2.run_optimization(
#     R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
#     0.8,
#     distancing_senarios.constant_beta03_alpha04_40,
#     initial_conditions.calc_IC(0.90,0.005,0.08,
#         parameters.bins_04 ,
#         8,
#         R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.8,
#         distancing_senarios.constant_beta03_alpha04_40,
#         parameters.suceptability_work1,
#         parameters.vaccine_eff_work1,
#         parameters.sigma_asym[1]),
#     parameters.suceptability_work1,
#     parameters.vaccine_eff_work1,
#     v,
#     parameters.bins_04,
#     "data_outputs/NPI_08",
#     N_samples, # population size
#     N_out,
#     N_iter,
#     concentration,
#     N_iter_anealing
# )
#
#


# calculate R_T
# maintext
n = 8 #
q = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]
βs = distancing_senarios.constant_beta01_alpha03_40 # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
D_exp = parameters.D_exp # duration of exposed phase
D_pre = parameters.D_pre # duration of presymptomatic phase
D_asym = parameters.D_asym # duration of asymptomatic phase
D_sym = parameters.D_sym # duration of symptomatic phase
Suceptability = parameters.suceptability_work1 # reletive suceptibility to infection


R0_20 = R0.calc_R0(q*0.2, Suceptability, βs(1,1,1)[1], βs(1,1,1)[2], βs(1,1,1)[3], D_pre, D_asym, D_sym, repeat([0.9],8))
R0_40 = R0.calc_R0(q*0.4, Suceptability, βs(1,1,1)[1], βs(1,1,1)[2], βs(1,1,1)[3], D_pre, D_asym, D_sym, repeat([0.9],8))
R0_60 = R0.calc_R0(q*0.6, Suceptability, βs(1,1,1)[1], βs(1,1,1)[2], βs(1,1,1)[3], D_pre, D_asym, D_sym, repeat([0.9],8))
R0_80 = R0.calc_R0(q*0.8, Suceptability, βs(1,1,1)[1], βs(1,1,1)[2], βs(1,1,1)[3], D_pre, D_asym, D_sym, repeat([0.9],8))


print("R_t 20%: ")
print(R0_20)
print("\n")

print("R_t 20%: ")
print(R0_40)
print("\n")

print("R_t 20%: ")
print(R0_60)
print("\n")

print("R_t 20%: ")
print(R0_80)
print("\n")


end # module
