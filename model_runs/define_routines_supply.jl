"""
this module defines a set of functions that call the simulations and optimization
functions and return the data needed to analysize the resutls. These function
differ from their analouge in define_routines.jl by the ability to tune the vaccine
supply and length of decision periods

run_optimization - all age groups and 6 decison periods
run_optimization_static - all age groups 1 decision period
run_optimization_age_only - essential workers not distiguised 6 decision periods
"""
module define_routines_supply


using Plots
using Measures
using CSV
using Tables
using DataFrames

print("here!")


include("../code_model/parameters/parameters.jl")
include("../code_model/dynamics/simulations.jl")
include("../code_model/dynamics/simulations_static.jl")
include("../code_model/dynamics/simulations_age_only.jl")
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
function run_optimization(q0, θ, βs, IC, suceptability, vaccine_eff, days_10, bins, fn,
                        N_samples, N_out, N_iter)

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


    v = t -> 0.1/days_10


    # ************* #
    # time periods  #
    # ************* #

    # pick time breaks here to limit number of args to function
    t_breaks = collect(1:days_10:(6*days_10)) # high availability
    num_steps = 6
    T = days_10 * 8

    # set parameters for genetic algorithm

 # number of generations
    α0 = repeat(repeat([0.5],n),num_steps) # initial proposal distribution


    # parameters for simulated anealing
    SA_iter = 20#000 # iteraitons
    SA_sigma = 0.001 # variance of proposal distibution
    trans  = x -> simulated_anealing.soft_max_grouped(x, n-1, 6) # transformaiton to unconstrained space



    print("zero")
    print("\n")


    params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
            suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
            bins, life_expect)


    # set paremeters for deaths function
    f = μ -> -1 * simulations.deaths(params, μ)
    # run genetic algorithm
    best1, value1 = optimization.maximize(f,α0, num_steps, n, N_samples, N_out, N_iter)

    f_SA = x -> -1*f(x) # SA finds min so need to flip f
    # map soluton from GA to unconstrained space for SA
    x0 = simulated_anealing.inv_soft_max_grouped(best1, n-1, 6)

    x1, v_best1, i_best, v_current, values1, acceptance = simulated_anealing.anealing(x0,trans, f_SA, SA_sigma, temp_t, SA_iter)

    # map back to constrained space
    best1 = simulated_anealing.soft_max_grouped(x1, 7, 6)


    ## repease for  years of life lost
    g = μ -> -1 * simulations.YLL(params, μ)

    best2, value2 = optimization.maximize(g,α0, num_steps, n, N_samples, N_out, N_iter)
    g_SA = x -> -1*g(x)

    x0 = simulated_anealing.inv_soft_max_grouped(best2, n-1, 6)

    x1, v_best2, i_best, v_current, values2, acceptance = simulated_anealing.anealing(x0,trans, g_SA, SA_sigma, temp_t, SA_iter)

    best2 = simulated_anealing.soft_max_grouped(x1, 7, 6)

    # infections



    h = μ -> -1 * simulations.infections(params, μ)

    best3, value3 = optimization.maximize(h,α0, num_steps, n, N_samples, N_out, N_iter)

    h_SA = x -> -1*h(x)

    x0 = simulated_anealing.inv_soft_max_grouped(best3, n-1, 6)

    x1, v_best3, i_best, v_current, values3, acceptance = simulated_anealing.anealing(x0,trans, h_SA, SA_sigma, temp_t, SA_iter)

    best3 = simulated_anealing.soft_max_grouped(x1, 7, 6)

    data_states_infections, data_vaccines_infections, outcomes_infections = simulations.simulate_data(params, best3)
    data_states_YLL, data_vaccines_YLL, outcomes_YLL = simulations.simulate_data(params, best2)
    data_states_deaths, data_vaccines_deaths, outcomes_deaths = simulations.simulate_data(params, best1)

    states = vcat(data_states_infections, data_states_YLL, data_states_deaths)
    vaccines = vcat(data_vaccines_infections, data_vaccines_YLL, data_vaccines_deaths)
    policies = hcat(best3, best2, best1)
    outcomes = hcat(outcomes_infections, outcomes_YLL, outcomes_deaths)


    CSV.write(join([fn, "_states"]), Tables.table(states))
    CSV.write(join([fn, "_vaccines"]), Tables.table(vaccines))
    CSV.write(join([fn, "_policies"]), Tables.table(policies))
    CSV.write(join([fn, "_outcomes"]), Tables.table(outcomes))

    return states, vaccines, policies, outcomes

end










"""
this function mirrors the function of the same name in the
optimization_with_resampling module but I have added
to it so it
"""
function run_optimization_static(q0, θ, βs, IC, suceptability, vaccine_eff, days_10, bins, fn)


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

    v = t -> 0.1/days_10


    # ************* #
    # time periods  #
    # ************* #



    # pick time breaks here to limit number of args to function
    t_breaks = [1] # high availability
    num_steps = 1
    T = 8*days_10

    # set parameters for genetic algorithm

    N_samples = [5000, 2500, 1000, 500, 500, 500, 500, 500, 100, 100, 50, 50, 50, 50, 50, 25, 25, 25, 25] # population size
    N_out = [500, 100, 100, 50, 50, 10, 10, 10, 10,  10, 10, 10, 10, 10, 10, 5, 5, 5, 5] # surivors
    N_iter = 7 # number of generations
    α0 = repeat([0.5],n) # initial proposal distribution


    # parameters for simulated anealing
    SA_iter = 15000 # iteraitons
    SA_sigma = 0.001 # variance of proposal distibution
    trans  = x -> simulated_anealing.soft_max_grouped(x, n-1, 1) # transformaiton to unconstrained space



    print("zero")
    print("\n")


    params[1] = X0 # state varabibles S P F I_pre I_asym I_mild D R
    params[2] = n# number of groups
    params[3] = q# transmission rate
    params[4] = βs# function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
    params[5] = D_pre# duration
    params[6] = D_asym
    params[7] = D_sym
    params[8] = D_exp
    params[9] = asym_rate # asymptomatic rate
    params[10] = Suceptability# reletive suceptibility to infection
    params[11] = IFR# infection fatality rate
    params[12] = vaccine_eff# effetiveness of the vaccine
    params[13] = v# supply per day
    params[14] = t_breaks# switch policy
    params[15] = N_steps# number of time to switch policy
    params[16] = bins# size of age classes
    params[17] = life_expect # life expectancy for each age


    # set paremeters for deaths function
    f = μ -> -1 * simulations_static.deaths(params, μ)
    # run genetic algorithm
    best1, value1 = optimization.maximize(f,α0, num_steps, n, N_samples, N_out, N_iter)

    f_SA = x -> -1*f(x) # SA finds min so need to flip f
    # map soluton from GA to unconstrained space for SA
    x0 = simulated_anealing.inv_soft_max_grouped(best1, n-1, 1)

    x1, v_best1, i_best, x_current, v_current, values1, acceptance = simulated_anealing.anealing(x0,trans, f_SA, SA_sigma, temp_t, SA_iter)

    # map back to constrained space
    best1 = simulated_anealing.soft_max_grouped(x1, n-1, 1)


    ## repease for  years of life lost
    g = μ -> -1 * simulations.YLL(params, μ)

    best2, value2 = optimization.maximize(g,α0, num_steps, n, N_samples, N_out, N_iter)
    g_SA = x -> -1*g(x)

    x0 = simulated_anealing.inv_soft_max_grouped(best2, n-1, 1)

    x1, v_best2, i_best, x_current, v_current, values2, acceptance = simulated_anealing.anealing(x0,trans, g_SA, SA_sigma, temp_t, SA_iter)

    best2 = simulated_anealing.soft_max_grouped(x1, n-1, 1)

    # infections



    h = μ -> -1 * simulations.infections(params, μ)

    best3, value3 = optimization.maximize(h,α0, num_steps, n, N_samples, N_out, N_iter)

    h_SA = x -> -1*h(x)

    x0 = simulated_anealing.inv_soft_max_grouped(best3, n-1, 1)

    x1, v_best3, i_best, x_current, v_current, values3, acceptance = simulated_anealing.anealing(x0,trans, h_SA, SA_sigma, temp_t, SA_iter)

    best3 = simulated_anealing.soft_max_grouped(x1, n-1, 1)


    data_states_infections, data_vaccines_infections, outcomes_infections = simulations_static.simulate_data(params, best3)
    data_states_YLL, data_vaccines_YLL, outcomes_YLL = simulations_static.simulate_data(params, best2)
    data_states_deaths, data_vaccines_deaths, outcomes_deaths = simulations_static.simulate_data(params, best1)

    states = vcat(data_states_infections, data_states_YLL, data_states_deaths)
    vaccines = vcat(data_vaccines_infections, data_vaccines_YLL, data_vaccines_deaths)
    policies = hcat(best1, best2, best3)
    outcomes = hcat(outcomes_infections, outcomes_YLL, outcomes_deaths)

    CSV.write(join([fn, "_states"]), Tables.table(states))
    CSV.write(join([fn, "_vaccines"]), Tables.table(vaccines))
    CSV.write(join([fn, "_policies"]), Tables.table(policies))
    CSV.write(join([fn, "_outcomes"]), Tables.table(outcomes))


    return states, vaccines, policies, outcomes

end






"""
this function mirrors the function of the same name in the
optimization_with_resampling module but I have added
to it so it
"""
function run_optimization_age_only(q0, θ, βs, IC, suceptability, vaccine_eff, days_10, bins, fn)


    # define parameters
    n = parameters.m # number of groups
    n_opt = 6

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



    v = t -> 0.1/days_10


    # ************* #
    # time periods  #
    # ************* #

    # pick time breaks here to limit number of args to function
    t_breaks = collect(1:days_10:(6*days_10)) # high availability
    num_steps = 6
    T = days_10 * 8

    # set parameters for genetic algorithm

    N_samples = [5000, 5000, 1000, 500, 500, 500, 500, 500, 100, 100, 50, 50, 50, 50, 50, 25, 25, 25, 25] # population size
    N_out = [500, 100, 100, 50, 50, 10, 10, 10, 10,  10, 10, 10, 10, 10, 10, 5, 5, 5, 5] # surivors
    N_iter = 7 # number of generations
    α0 = repeat(repeat([0.5],n_opt),num_steps) # initial proposal distribution


    # parameters for simulated anealing
    SA_iter = 10000 # iteraitons
    SA_sigma = 0.001 # variance of proposal distibution
    trans  = x -> simulated_anealing.soft_max_grouped(x, n-1, 6) # transformaiton to unconstrained space



    print("zero")
    print("\n")


    params[1] = X0 # state varabibles S P F I_pre I_asym I_mild D R
    params[2] = n# number of groups
    params[3] = n_opt
    params[4] = q# transmission rate
    params[5] = βs# function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
    params[6] = D_pre# duration
    params[7] = D_asym
    params[8] = D_sym
    params[9] = D_exp
    params[10] = asym_rate # asymptomatic rate
    params[11] = Suceptability# reletive suceptibility to infection
    params[12] = IFR# infection fatality rate
    params[13] = vaccine_eff# effetiveness of the vaccine
    params[14] = v# supply per day
    params[15] = t_breaks# switch policy
    params[16] = N_steps# number of time to switch policy
    params[17] = bins# size of age classes
    params[18] = life_expect # life expectancy for each age


    # set paremeters for deaths function
    f = μ -> -1 * simulations_age_only.deaths(params, μ)
    # run genetic algorithm
    best1, value1 = optimization.maximize(f,α0, num_steps, n_opt, N_samples, N_out, N_iter)

    f_SA = x -> -1*f(x) # SA finds min so need to flip f
    # map soluton from GA to unconstrained space for SA
    x0 = simulated_anealing.inv_soft_max_grouped(best1, n_opt-1, 6)

    x1, v_best1, i_best, x_current, v_current, values1, acceptance = simulated_anealing.anealing(x0,trans, f_SA, SA_sigma, temp_t, SA_iter)

    # map back to constrained space
    best1 = simulated_anealing.soft_max_grouped(x1, n_opt-1, 6)


    ## repease for  years of life lost
    g = μ -> -1 * simulations_age_only.YLL(params, μ)

    best2, value2 = optimization.maximize(g,α0, num_steps, n_opt, N_samples, N_out, N_iter)
    g_SA = x -> -1*g(x)

    x0 = simulated_anealing.inv_soft_max_grouped(best2, n_opt-1, 6)

    x1, v_best2, i_best, x_current, v_current, values2, acceptance = simulated_anealing.anealing(x0,trans, g_SA, SA_sigma, temp_t, SA_iter)

    best2 = simulated_anealing.soft_max_grouped(x1, n_opt-1, 6)

    # infections



    h = μ -> -1 * simulations_age_only.infections(params, μ)

    best3, value3 = optimization.maximize(h,α0, num_steps, n_opt, N_samples, N_out, N_iter)

    h_SA = x -> -1*h(x)

    x0 = simulated_anealing.inv_soft_max_grouped(best3, n_opt-1, 6)

    x1, v_best3, i_best, x_current, v_current, values3, acceptance = simulated_anealing.anealing(x0,trans, h_SA, SA_sigma, temp_t, SA_iter)

    best3 = simulated_anealing.soft_max_grouped(x1, n_opt-1, 6)

    data_states_infections, data_vaccines_infections, outcomes_infections = simulations_age_only.simulate_data(params, best3)
    data_states_YLL, data_vaccines_YLL, outcomes_YLL = simulations_age_only.simulate_data(params, best2)
    data_states_deaths, data_vaccines_deaths, outcomes_deaths = simulations_age_only.simulate_data(params, best1)

    states = vcat(data_states_infections, data_states_YLL, data_states_deaths)
    vaccines = vcat(data_vaccines_infections, data_vaccines_YLL, data_vaccines_deaths)
    policies = hcat(best1, best2, best3)
    outcomes = hcat(outcomes_infections, outcomes_YLL, outcomes_deaths)

    CSV.write(join([fn, "_states"]), Tables.table(states))
    CSV.write(join([fn, "_vaccines"]), Tables.table(vaccines))
    CSV.write(join([fn, "_policies"]), Tables.table(policies))
    CSV.write(join([fn, "_outcomes"]), Tables.table(outcomes))

    return states, vaccines, policies, outcomes

end













end
