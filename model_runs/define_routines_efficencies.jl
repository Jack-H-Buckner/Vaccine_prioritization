"""
this module defines a set of functions that call the simulations and optimization
functions and return the data needed to analysize the resutls.

this module only contains the function run_optimization which runs the optimizaiton
for all 6 decision periods and 8 demographic groups.
"""
module define_routines_efficencies


using Plots
using Measures
using CSV
using Tables
using DataFrames

include("../code_model/parameters/parameters.jl")
include("../code_model/dynamics/simulations_eficacies.jl")
include("../code_model/optimization/optimization_2.jl")
include("../code_model/parameters/distancing_senarios.jl")
include("../code_model/parameters/R0.jl")
include("../code_model/parameters/initial_conditions.jl")
include("../code_model/optimization/simulated_anealing.jl")




function temp_t(t)
    return 0.00005/t#exp(-0.003*t)+0.000005
end



"""
this function mirrors the function of the same name in the
optimization_with_resampling module but I have added
to it so it
"""
function run_optimization(q0, θ, βs, IC, suceptability, V1, V2, V3, v, bins, fn,
                        N_samples, N_out, N_iter, concentration)



    # define parameters
    n = parameters.m # number of groups


    # ***************** #
    # transmission rate #
    # ***************** #

    q = q0*θ


    # ********************** #
    # set initial conditions #
    # ********************** #


    X0 = IC

     # length of simulaitons

    # ************** #
    # epi parameters #
    # ************** #

    D_exp = parameters.D_exp # duration of exposed phase
    D_pre = parameters.D_pre # duration of presymptomatic phase
    D_asym = parameters.D_asym # duration of asymptomatic phase
    D_sym = parameters.D_sym # duration of symptomatic phase
    asym_rate = parameters.asym_rate_work # proportion os asymptomatic cases


    IFR = parameters.IFR_work # infection fataity rates
    life_expect = parameters.life_expect_work # life expectancy



    # ************* #
    # time periods  #
    # ************* #

    days_10 = 30

    # pick time breaks here to limit number of args to function
    t_breaks = collect(1:days_10:(6*days_10)) # high availability
    num_steps = 6
    T = days_10 * 8

    # set parameters for genetic algorithm

    #N_samples = [15000, 10000, 10000, 10000, 5000, 5000, 1000, 1000, 500, 500, 100, 100, 50, 50] # population size
    #N_out = [5000, 3000, 2000, 1000, 1000, 500, 300, 100, 100, 50, 30, 10, 10, 10]

    α0 = repeat(repeat([0.5],n),num_steps) # initial proposal distribution


    # parameters for simulated anealing
    SA_iter = 20000 # iteraitons
    SA_sigma = 0.001 # variance of proposal distibution
    trans  = x -> simulated_anealing.soft_max_grouped(x, n-1, 6) # transformaiton to unconstrained space


    params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
            suceptability, IFR, V1, V2, V3, v, T, t_breaks, num_steps,
            bins, life_expect)


    # set paremeters for deaths function
    f = μ -> -1 * simulations_efficacies.deaths(params, μ)
    # run genetic algorithm
    best1, value1 = optimization_2.maximize(f,α0, num_steps, n, N_samples, N_out, N_iter, concentration)

    f_SA = x -> -1*f(x) # SA finds min so need to flip f
    # map soluton from GA to unconstrained space for SA
    x0 = simulated_anealing.inv_soft_max_grouped(best1, n-1, 6)

    x1, v_best1, i_best,  v_current, values1, acceptance = simulated_anealing.anealing(x0,trans, f_SA, SA_sigma, temp_t, SA_iter)

    # map back to constrained space
    best1 = simulated_anealing.soft_max_grouped(x1, 7, 6)


    ## repease for  years of life lost
    g = μ -> -1 * simulations_efficacies.YLL(params, μ)

    best2, value2 = optimization_2.maximize(g,α0, num_steps, n, N_samples, N_out, N_iter, concentration)
    g_SA = x -> -1*g(x)

    x0 = simulated_anealing.inv_soft_max_grouped(best2, n-1, 6)

    x1, v_best2, i_best,  v_current, values2, acceptance = simulated_anealing.anealing(x0,trans, g_SA, SA_sigma, temp_t, SA_iter)

    best2 = simulated_anealing.soft_max_grouped(x1, 7, 6)

    # infections



    h = μ -> -1 * simulations_efficacies.infections(params, μ)

    best3, value3 = optimization_2.maximize(h,α0, num_steps, n, N_samples, N_out, N_iter, concentration)

    h_SA = x -> -1*h(x)

    x0 = simulated_anealing.inv_soft_max_grouped(best3, n-1, 6)

    x1, v_best3, i_best, v_current, values3, acceptance = simulated_anealing.anealing(x0,trans, h_SA, SA_sigma, temp_t, SA_iter)

    best3 = simulated_anealing.soft_max_grouped(x1, 7, 6)

    data_states_infections, data_vaccines_infections, outcomes_infections = simulations_efficacies.simulate_data(params, best3)
    data_states_YLL, data_vaccines_YLL, outcomes_YLL = simulations_efficacies.simulate_data(params, best2)
    data_states_deaths, data_vaccines_deaths, outcomes_deaths = simulations_efficacies.simulate_data(params, best1)

    states = vcat(data_states_infections, data_states_YLL, data_states_deaths)
    vaccines = vcat(data_vaccines_infections, data_vaccines_YLL, data_vaccines_deaths)
    policies = hcat(best3, best2, best1)
    outcomes = hcat(outcomes_infections, outcomes_YLL, outcomes_deaths)


    CSV.write(join([fn, "_states.csv"]), Tables.table(states))
    CSV.write(join([fn, "_vaccines.csv"]), Tables.table(vaccines))
    CSV.write(join([fn, "_policies.csv"]), Tables.table(policies))
    CSV.write(join([fn, "_outcomes.csv"]), Tables.table(outcomes))

    #return states, vaccines, policies, outcomes

end






end
