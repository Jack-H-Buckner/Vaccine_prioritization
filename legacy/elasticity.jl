module elasticity


using Plots
using Measures
using CSV
using Tables
using DataFrames

include("parameters.jl")
include("simulations.jl")
include("optimization.jl")
include("simulated_anealing.jl")

function generate_range(
    fn_in, # path to file with solution
    tol, # level of tolerance for accepted solutions
    sigma, # varaince of proposal distribtion
    iter, # number of itterations per chain
    n_chains, # number of chains
    max_iter, # maximum number of iterations before cahin is broken
    q0, # transmision
    θ, # NPI
    βs, # conact rates
    X0, # initial conditions
    suceptability, # suceptability for each gorup
    vaccine_eff , # vaccine effective ness
    v, # vaccine constraint
    bins,
    fn_out) # path to file for output data


    # load adn unpack solutions
    sol = DataFrame!(CSV.File(fn_in))

    sol_deaths = sol.Column3
    #sol_deaths = map(x->parse(Float64,x),sol_deaths)

    sol_YLL = sol.Column2
    #sol_YLL = map(x->parse(Float64,x),sol_YLL)

    sol_infections = sol.Column1
    #sol_infections = map(x->parse(Float64,x),sol_infections)

    # set parameters
    q = q0 * θ # q
    n = 8 # number of gorups

    # set decision periods and simulation length
    t_breaks = [1, 30, 60, 90, 120, 150] # high availability
    num_steps = 6
    T = 240



    # ************** #
    # epi parameters #
    # ************** #
    D_exp = parameters.D_exp # duration of exposed
    D_pre = parameters.D_pre # duration of presymptomatic
    D_asym = parameters.D_asym # duration of asyptomatic
    D_sym = parameters.D_sym # duration of symptomatic
    asym_rate = parameters.asym_rate_work # duration of asymptomatic rate


    IFR = parameters.IFR_work # infection fataity rates
    life_expect = parameters.life_expect_work


    params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
            suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
            bins, life_expect)


    f = μ -> simulations.deaths(params, μ)


    # evalueate at optimal solution
    v_best_deaths = f(sol_deaths)

    # repeate for YLL
    g = μ -> simulations.YLL(params, μ)


    v_best_YLL = g(sol_YLL)

    h = μ -> simulations.infections(params, μ)

    v_best_infections = h(sol_infections)


    # transform soltuion to unonstrained space
    sol_deaths = simulated_anealing.inv_soft_max_grouped(sol_deaths, n-1, 6)

    # search for near optimal solutions
    best_deaths, samples_deaths, values_deaths = simulated_anealing.sensetivity_resampling(
                sol_deaths, # unconstrianed solution
                x -> simulated_anealing.soft_max_grouped(x, n-1, 6), # trasnformation to constrained space
                f, # function to minimize
                abs(v_best_deaths * tol), # tolerance set to tol x 100% of vest value
                sigma, # varaince of proposal distribution
                iter, # number of iterations
                max_iter, # maximum number of iterations per chain
                n_chains) # number of chains


    # repeate for YLL
    sol_YLL = simulated_anealing.inv_soft_max_grouped(sol_YLL, n-1, 6)

    best_YLL, samples_YLL, values_YLL = simulated_anealing.sensetivity_resampling(
                sol_YLL,
                x -> simulated_anealing.soft_max_grouped(x, n-1, 6),
                g,
                abs(v_best_YLL * tol),
                sigma,
                iter,
                max_iter,
                n_chains)


    # repeate for infections
    sol_infections = simulated_anealing.inv_soft_max_grouped(sol_infections, n-1, 6)

    best_infections, samples_infections, values_infections = simulated_anealing.sensetivity_resampling(
                sol_infections,
                x -> simulated_anealing.soft_max_grouped(x, n-1, 6),
                h,
                abs(v_best_infections * tol),
                sigma,
                iter,
                max_iter,
                n_chains)



    # caluclated cumulative ranges



    # label data and bind into a single table
    samples_deaths = hcat(samples_deaths, repeat(["Deaths"], size(samples_deaths)[1]))
    samples_YLL = hcat(samples_YLL, repeat(["YLL"], size(samples_YLL)[1]))
    samples_infections = hcat(samples_infections, repeat(["Infections"], size(samples_infections)[1]))



    best_deaths = simulated_anealing.soft_max_grouped(best_deaths, n-1, 6)


    best_YLL = simulated_anealing.soft_max_grouped(best_YLL, n-1, 6)


    best_infections = simulated_anealing.soft_max_grouped(best_infections, n-1, 6)



    CSV.write(join([fn_out, "_policies_1.csv"]), Tables.table(hcat(best_infections, best_YLL, best_deaths)))
    CSV.write(join([fn_out,"_", tol ,"_samples.csv"]), Tables.table(vcat(samples_infections, samples_YLL, samples_deaths)))



end




end
