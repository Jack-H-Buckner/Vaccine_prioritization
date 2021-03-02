"""
This module contains function that run the full age and essential worker
model.

It contians five functions:

simulate:
this function runs the models for a desired number of steps with a given
Vaccine policy

simulate_data:
similar to simulate, but returns data on the trajectory of cases and the
outcomes for plottine

deaths:
used in optimizaiton, simulates and returns the total nuber of deaths under
a given vaccine policy

YLL:
used in optimizaiton, simulates and returns the total nuber of YLL under
a given vaccine policy

infections:
used in optimizaiton, simulates and returns the total nuber of infections under
a given vaccine policy

"""
module simulations

using Plots
include("../parameters/parameters.jl")
include("derivitives.jl")

"""
This function runs the model for a fixd period of time and returns the resutls

it is used to calcualte total deaths infections and YLL later in this module

The best check here is to compare to the output form other functions that run the model
such as the plot model in the R0 module.


"""
function simulate(params, μ)

    X0 = params[1] # state varabibles S P F I_pre I_asym I_mild D R
    n = params[2] # number of groups
    q = params[3] # transmission rate
    βs = params[4] # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
    D_pre = params[5] # duration
    D_asym = params[6]
    D_sym = params[7]
    D_exp = params[8]
    asym_rate = params[9] # asymptomatic rate
    Suceptability = params[10] # reletive suceptibility to infection
    IFR = params[11] # infection fatality rate
    vaccine_eff = params[12] # effetiveness of the vaccine
    v = params[13] # supply per day
    T = params[14]
    t_breaks = params[15] # switch policy
    N_steps = params[16] # number of time to switch policy
    bins = params[17] # size of age classes
    life_expect = params[18] # life expectancy for each age

    t_step = 0 # set time step accumulator for decision periods
    increment = 0 # set increment for social distancing
    μ1 = μ[1:n] # grab the first month decision

    X = X0
    for i in 1:T # loop over days

        I_sym = X[(6*n+1):(7*n)] # grab total infections for social distancing rule


        β_sym, β_presym, β_asym, increment = βs(i, sum(I_sym), increment) # get contact matrices

        # Increment the time step when the date reaches the
        # one of the decision period breaks.
        if i in t_breaks

            μ1 = μ[(t_step*n + 1):((t_step + 1)*n)]

            t_step += 1
        end

        # update state
        X = derivitives.mod1_discrete(X, # state varabibles S P F I_pre I_asym I_mild D R
            n, # number of groups
            q, # transmission rate
            β_presym, β_asym, β_sym, # transmission rates
            D_pre, D_asym, D_sym, D_exp, # symptom durations
            asym_rate,
            Suceptability, # suceptability to infections by age
            IFR, # infection fataity rates
            vaccine_eff, # efficency of vaccines
            i,
            v, # vacine availability
            μ1 # allocation vector
        )

    end

    return X

end





"""
this function takes a policy and a set of parameters and runs a simulation of
the model. It then returns the cumulative number of individuals n each age group
vaccinated on a given day, the full set of state variables X for a given day.
"""
function simulate_data(params, μ)

    X0 = params[1] # state varabibles S P F I_pre I_asym I_mild D R
    n = params[2] # number of groups
    q = params[3] # transmission rate
    βs = params[4] # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
    D_pre = params[5] # duration
    D_asym = params[6]
    D_sym = params[7]
    D_exp = params[8]
    asym_rate = params[9] # asymptomatic rate
    Suceptability = params[10] # reletive suceptibility to infection
    IFR = params[11] # infection fatality rate
    vaccine_eff = params[12] # effetiveness of the vaccine
    v = params[13] # supply per day
    T = params[14]
    t_breaks = params[15] # switch policy
    N_steps = params[16] # number of time to switch policy
    bins = params[17] # size of age classes
    life_expect = params[18] # life expectancy for each age



    X = X0


    t_step = 0 # initialize time step for decision periods

    data_disease = zeros(T, length(X)) # initialize accumulator for infection time series
    data_vaccines = zeros(T+1, n)
    data_vaccines[1,:] = repeat([0], n)
    increment = 0 # set increment for social distancing

    μ1 = μ[1:n] # get first month allocaiton


    for t in 1:T

        I_sym = X[(6*n+1):(7*n)] # grab infections for contact matrices and accumlator

        β_sym, β_presym, β_asym, increment = βs(t, sum(I_sym), increment)


        if t in t_breaks


            start = (t_step-1)*n + 1 # calcualte indecies for most recent vacine allocaiton
            stop = t_step*n

            μ1 = μ[(t_step*n + 1):((t_step + 1)*n)]
            t_step += 1


            if t_step > 1

                start1 = ((t_step-1)-1)*n + 1 # update bounds to grab allocatios for next decision period
                stop1 = (t_step-1)*n

            end

        end


        # accumulate data for states
        data_disease[t,:] = X
        data_vaccines[t+1,:] = data_vaccines[t,:] .+ μ1 .* v(t)

        # update state
        X = derivitives.mod1_discrete(X, # state varabibles S P F I_pre I_asym I_mild D R
            n, # number of groups
            q, # transmission rate
            β_presym, β_asym, β_sym, # transmission rates
            D_pre, D_asym, D_sym, D_exp,# symptom durations
            asym_rate,
            Suceptability, # suceptability to infections by age
            IFR, # infection fataity rates
            vaccine_eff, # efficency of vaccines
            t,
            v, # vacine availability
            μ1 # allocation vector
        )


    end

    infections = sum(X[(8*n+1):(9*n)].+X[(7*n+1):(8*n)])
    YLL = sum(life_expect .* X[(7*n+1):(8*n)])
    deaths = sum(X[(7*n+1):(8*n)])

    return data_disease, data_vaccines,[infections, YLL, deaths]
end







# these function calcualte the outcomes for the optimization
# it is critical that the indexing in the return statment is correct
# other wise the functions just call simulate.
"""
calcualtes the total number of deaths given a vaccine policy
"""
function deaths(params, μ)

    X = simulate(params, μ)
    n = params[2] # number of groups

    return sum(X[(7*n+1):(8*n)])
end



"""
calcualtes the total number of years of life lost given a vaccine policy
"""
function YLL(params, μ)

    X = simulate(params, μ)
    n = params[2] # number of groups
    life_expect = params[18]

    return sum(life_expect .* X[(7*n+1):(8*n)])
end






"""
calcualtes the total number of infections given a vaccine policy
"""
function infections(params, μ)

    X = simulate(params, μ)
    n = params[2] # number of groups

    return sum(X[(8*n+1):(9*n)])#.+X[(7*n+1):(8*n)]
end



end
