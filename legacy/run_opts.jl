module run_opts





using Plots
using Measures
using CSV
using Tables
using DataFrames


include("parameters.jl")
include("simulations.jl")
include("simulations_static.jl")
include("simulations_age_only.jl")
include("optimization.jl")
include("distancing_senarios.jl")
include("R0.jl")
include("initial_conditions.jl")
include("simulated_anealing.jl")


function temp_t(t)
    return 0.00005/t#exp(-0.003*t)+0.000005
end



"""
this function mirrors the function of the same name in the
optimization_with_resampling module but I have added
to it so it
"""
function run_optimization(q0, θ, βs, IC, suceptability, vaccine_eff, v, bins, fn,
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
            suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
            bins, life_expect)


    # set paremeters for deaths function
    f = μ -> -1 * simulations.deaths(params, μ)
    # run genetic algorithm
    best1, value1 = optimization.maximize(f,α0, num_steps, n, N_samples, N_out, N_iter)

    f_SA = x -> -1*f(x) # SA finds min so need to flip f
    # map soluton from GA to unconstrained space for SA
    x0 = simulated_anealing.inv_soft_max_grouped(best1, n-1, 6)

    x1, v_best1, i_best,  v_current, values1, acceptance = simulated_anealing.anealing(x0,trans, f_SA, SA_sigma, temp_t, SA_iter)

    # map back to constrained space
    best1 = simulated_anealing.soft_max_grouped(x1, 7, 6)


    ## repease for  years of life lost
    g = μ -> -1 * simulations.YLL(params, μ)

    best2, value2 = optimization.maximize(g,α0, num_steps, n, N_samples, N_out, N_iter)
    g_SA = x -> -1*g(x)

    x0 = simulated_anealing.inv_soft_max_grouped(best2, n-1, 6)

    x1, v_best2, i_best,  v_current, values2, acceptance = simulated_anealing.anealing(x0,trans, g_SA, SA_sigma, temp_t, SA_iter)

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


    CSV.write(join([fn, "_states.csv"]), Tables.table(states))
    CSV.write(join([fn, "_vaccines.csv"]), Tables.table(vaccines))
    CSV.write(join([fn, "_policies.csv"]), Tables.table(policies))
    CSV.write(join([fn, "_outcomes.csv"]), Tables.table(outcomes))

    #return states, vaccines, policies, outcomes

end






"""
this function mirrors the function of the same name in the
optimization_with_resampling module but I have added
to it so it
"""
function run_optimization_static(q0, θ, βs, IC, suceptability, vaccine_eff, v, bins, fn,
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



    # ************* #
    # time periods  #
    # ************* #



    # pick time breaks here to limit number of args to function
    t_breaks = [1] # high availability
    num_steps = 1
    T = 240

    # set parameters for genetic algorithm


    α0 = repeat([0.5],n) # initial proposal distribution


    # parameters for simulated anealing
    SA_iter =5000 # iteraitons
    SA_sigma = 0.001 # variance of proposal distibution
    trans  = x -> simulated_anealing.soft_max_grouped(x, n-1, 1) # transformaiton to unconstrained space



    params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
            suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
            bins, life_expect)


    # set paremeters for deaths function
    f = μ -> -1 * simulations_static.deaths(params, μ)
    # run genetic algorithm
    best1, value1 = optimization.maximize(f,α0, num_steps, n, N_samples, N_out, N_iter)

    f_SA = x -> -1*f(x) # SA finds min so need to flip f
    # map soluton from GA to unconstrained space for SA
    x0 = simulated_anealing.inv_soft_max_grouped(best1, n-1, 1)

    x1, v_best1, i_best,  v_current, values1, acceptance = simulated_anealing.anealing(x0,trans, f_SA, SA_sigma, temp_t, SA_iter)

    # map back to constrained space
    best1 = simulated_anealing.soft_max_grouped(x1, n-1, 1)


    ## repease for  years of life lost
    g = μ -> -1 * simulations.YLL(params, μ)

    best2, value2 = optimization.maximize(g,α0, num_steps, n, N_samples, N_out, N_iter)
    g_SA = x -> -1*g(x)

    x0 = simulated_anealing.inv_soft_max_grouped(best2, n-1, 1)

    x1, v_best2, i_best, v_current, values2, acceptance = simulated_anealing.anealing(x0,trans, g_SA, SA_sigma, temp_t, SA_iter)

    best2 = simulated_anealing.soft_max_grouped(x1, n-1, 1)

    # infections



    h = μ -> -1 * simulations.infections(params, μ)

    best3, value3 = optimization.maximize(h,α0, num_steps, n, N_samples, N_out, N_iter)

    h_SA = x -> -1*h(x)

    x0 = simulated_anealing.inv_soft_max_grouped(best3, n-1, 1)

    x1, v_best3, i_best, v_current, values3, acceptance = simulated_anealing.anealing(x0,trans, h_SA, SA_sigma, temp_t, SA_iter)

    best3 = simulated_anealing.soft_max_grouped(x1, n-1, 1)


    data_states_infections, data_vaccines_infections, outcomes_infections = simulations_static.simulate_data(params, best3)
    data_states_YLL, data_vaccines_YLL, outcomes_YLL = simulations_static.simulate_data(params, best2)
    data_states_deaths, data_vaccines_deaths, outcomes_deaths = simulations_static.simulate_data(params, best1)

    states = vcat(data_states_infections, data_states_YLL, data_states_deaths)
    vaccines = vcat(data_vaccines_infections, data_vaccines_YLL, data_vaccines_deaths)
    policies = hcat(best3, best2, best1)
    outcomes = hcat(outcomes_infections, outcomes_YLL, outcomes_deaths)

    CSV.write(join([fn, "_states.csv"]), Tables.table(states))
    CSV.write(join([fn, "_vaccines.csv"]), Tables.table(vaccines))
    CSV.write(join([fn, "_policies.csv"]), Tables.table(policies))
    CSV.write(join([fn, "_outcomes.csv"]), Tables.table(outcomes))


    return states, vaccines, policies, outcomes

end






"""
this function mirrors the function of the same name in the
optimization_with_resampling module but I have added
to it so it
"""
function run_optimization_age_only(q0, θ, βs, IC, suceptability, vaccine_eff, v, bins, fn,
                                    N_samples, N_out, N_iter)



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



    # ************* #
    # time periods  #
    # ************* #

    days_10 = 30

    # pick time breaks here to limit number of args to function
    t_breaks = collect(1:days_10:(6*days_10)) # high availability
    num_steps = 6
    T = days_10 * 8

    # set parameters for genetic algorithm


    α0 = repeat(repeat([0.5],n_opt),num_steps) # initial proposal distribution


    # parameters for simulated anealing
    SA_iter = 20000 # iteraitons
    SA_sigma = 0.001 # variance of proposal distibution
    trans  = x -> simulated_anealing.soft_max_grouped(x, n_opt-1, 6) # transformaiton to unconstrained space


    params = (X0, n, n_opt, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
            suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
            bins, life_expect)


    # set paremeters for deaths function
    f = μ -> -1 * simulations_age_only.deaths(params, μ)
    # run genetic algorithm
    best1, value1 = optimization.maximize(f,α0, num_steps, n_opt, N_samples, N_out, N_iter)

    f_SA = x -> -1*f(x) # SA finds min so need to flip f
    # map soluton from GA to unconstrained space for SA
    x0 = simulated_anealing.inv_soft_max_grouped(best1, n_opt-1, 6)

    x1, v_best1, i_best, v_current, values1, acceptance = simulated_anealing.anealing(x0,trans, f_SA, SA_sigma, temp_t, SA_iter)

    # map back to constrained space
    best1 = simulated_anealing.soft_max_grouped(x1, n_opt-1, 6)


    ## repease for  years of life lost
    g = μ -> -1 * simulations_age_only.YLL(params, μ)

    best2, value2 = optimization.maximize(g,α0, num_steps, n_opt, N_samples, N_out, N_iter)
    g_SA = x -> -1*g(x)

    x0 = simulated_anealing.inv_soft_max_grouped(best2, n_opt-1, 6)

    x1, v_best2, i_best,  v_current, values2, acceptance = simulated_anealing.anealing(x0,trans, g_SA, SA_sigma, temp_t, SA_iter)

    best2 = simulated_anealing.soft_max_grouped(x1, n_opt-1, 6)

    # infections



    h = μ -> -1 * simulations_age_only.infections(params, μ)

    best3, value3 = optimization.maximize(h,α0, num_steps, n_opt, N_samples, N_out, N_iter)

    h_SA = x -> -1*h(x)

    x0 = simulated_anealing.inv_soft_max_grouped(best3, n_opt-1, 6)

    x1, v_best3, i_best,  v_current, values3, acceptance = simulated_anealing.anealing(x0,trans, h_SA, SA_sigma, temp_t, SA_iter)

    best3 = simulated_anealing.soft_max_grouped(x1, n_opt-1, 6)

    data_states_infections, data_vaccines_infections, outcomes_infections = simulations_age_only.simulate_data(params, best3)
    data_states_YLL, data_vaccines_YLL, outcomes_YLL = simulations_age_only.simulate_data(params, best2)
    data_states_deaths, data_vaccines_deaths, outcomes_deaths = simulations_age_only.simulate_data(params, best1)

    states = vcat(data_states_infections, data_states_YLL, data_states_deaths)
    vaccines = vcat(data_vaccines_infections, data_vaccines_YLL, data_vaccines_deaths)
    policies = hcat(best3, best2, best1)
    outcomes = hcat(outcomes_infections, outcomes_YLL, outcomes_deaths)

    CSV.write(join([fn, "_states.csv"]), Tables.table(states))
    CSV.write(join([fn, "_vaccines.csv"]), Tables.table(vaccines))
    CSV.write(join([fn, "_policies.csv"]), Tables.table(policies))
    CSV.write(join([fn, "_outcomes.csv"]), Tables.table(outcomes))

    return states, vaccines, policies, outcomes

end





function run_test(q0, θ, βs, IC, suceptability, vaccine_eff, v, bins,fn,
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
        #N_samples = [15000, 10000, 5000, 2500, 1000, 1000, 500, 500, 500, 500, 100, 100, 50, 50] # population size
        #N_out = [5000, 3000, 2000, 750, 250, 100, 100, 100, 50, 50, 30, 10, 10, 10]# surivors
        #N_iter = 12 # number of generations
        α0 = repeat(repeat([0.5],n),num_steps) # initial proposal distribution


        # parameters for simulated anealing
        SA_iter = 20000 # iteraitons
        SA_sigma = 0.001 # variance of proposal distibution
        trans  = x -> simulated_anealing.soft_max_grouped(x, n-1, 6) # transformaiton to unconstrained space


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

        x1, v_best1, i_best,  v_current, values1, acceptance = simulated_anealing.anealing(x0,trans, f_SA, SA_sigma, temp_t, SA_iter)

        # map back to constrained space
        best1 = simulated_anealing.soft_max_grouped(x1, 7, 6)

        policies = hcat(best1)


        CSV.write(join([fn, "_policies.csv"]), Tables.table(policies))


        #return states, vaccines, policies, outcomes



end




end
