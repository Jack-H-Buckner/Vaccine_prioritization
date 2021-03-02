"""
repeats several modle runs to insure consisten performance
"""
module test_opt_fixed_value

using Random
using Plots

include("distancing_senarios.jl")
include("parameters.jl")
include("R0.jl")
include("initial_conditions.jl")
include("elasticity.jl")
include("run_opts_2.jl")
include("optimization_2.jl")
include("simulated_anealing.jl")


# seed1 20201119
# seed2 3201961
# seed3 2141996
# seed4 2101993
# seed5 1061961



# Run test with free values
N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000] #[20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,500,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 11 # 11

SA_iter = 50000
SA_sigma = 0.001
#Random.seed!(20201119)
v(t) =  0.1/30
# print("here")
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
#     "data_outputs/test_full",
#     N_samples, # population size
#     N_out,
#     N_iter,
#     concentration
# )


run_opts_2.run_fixed_value(
    8,
    6,
    1,
    4,
    0.2,
    [2,3,4,5,6],
    [1,2,3,5,6,7,8],
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
    "data_outputs/test_fixed_6",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma
)

plot(values1)
savefig("~/documents/values_plot_fixed.png")
plot(acceptance)
savefig("~/documents/acceptance_plot_fixed.png")

#
# #### test against simple function ###
#
# function objective_function(x)
#
#     x_min = 0.25*ones(12)
#
#     x = (x_min .- x).^2
#
#     return -1*sum(x)
#
# end
#
# best, value1 = optimization_2.maximize(objective_function , 4*ones(12), 3, 4, [10000, 10000,500,250,125,50], [1000, 100,50,25,12,5], 5, [0.01,0.1,1.0,2.0,8,10])
# print("\n")
# print(best)
# print("\n")
# print(value1)
# print("\n")
# print("\n")
# print("\n")
#
#
#
#
# best, value1 = optimization_2.maximize_fixed_val(
#     objective_function,
#     4, # number of groups
#     3, # number of steps
#     2, # fixed step
#     2, # fixed group
#     0.25, # fixed value
#     [1,3], # step indecies
#     [1,3,4], # group indicies
#     0.5*ones(2,4), # alpha variable
#     0.5*ones(3), # alpha fixd
#     [1000,500,250,125,50],
#     [100,50,25,12,5], 5,
#     [0.1,0.5,1.0,4,10]
# )
#
#
# print("\n")
# print("\n")
# print(best)
# print("\n")
# print(value1)
# print("\n")
# print("\n")
#
# function objective_function_SA(x)
#
#     x_min = 0.25*ones(12)
#     x = (x_min .- x).^2
#     return sum(x)
#
# end
#
# function temp_t(t)
#     return 0.05/t#exp(-0.003*t)+0.000005
# end
# best, v_best1, i_best,  v_current, values1, acceptance = simulated_anealing.anealing_fixed_val(
#     best,
#     objective_function_SA,
#     0.00000005,
#     4,
#     3,
#     2, # fixed step
#     2, # fixed group
#     0.25, # fixed value
#     [1,3], # step indecies
#     [1,3,4], # group indicies
#     temp_t,
#     50000)
#
# print("\n")
# print("\n")
# print(best)
# print("\n")
# print(v_best1)
# plot(values1)
# savefig("~/documents/my_plot.png")


end
