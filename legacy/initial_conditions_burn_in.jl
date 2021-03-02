"""
This module contains functions to generate intial conditions from the
model using a burn in period that simulates the initial outbreak in the
spring/ summer, a lull in cases in the late summer/ fall and an increase in
cases until the vaccine becomes available in the winter
"""
module initial_conditions_burn_in

include("simulations.jl")

"""
burn_in(T_periods,q,params)

burn_in simulates from the model without vaccines and returns the final
state of the system starting from an infection rate of 1 per 100,000 in.
each age group. It simulates the dynamics with transmission parameters
q in each of the n time periods. The length of each time period is given in
the T_periods vector and the associated transmission proability q in the
vector q.

T_periods - length of each time period
q - transmission probability in each time period
params - all other parameters
"""
function burn_in(T_periods,q,params)

    # unpack the parameters
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

    # set the initial conditions
    S = rep([0.99999], n)
    P = repeat([0.0], n)
    F = repeat([0.0], n)
    E = repeat([1.0-0.99999], n)
    I_pre = repeat([0.0], n)
    I_asym = repeat([0.0], n)
    I_sym = repeat([0.0], n)
    D = repeat([0.0], n)
    R = repeat([0.0], n)
    X = vcat(S,P,F,E,I_pre,I_asym,I_sym,D,R)

    # set params for simulation
    params[1] = X
    μ = zeros([0],n)

    # set number of time steps
    num_steps = length(T_periods)

    #loop over time periods
    for i in 1:num_steps
        params[3] = q[i]
        params[14] = T_periods[i]
        X = simulations.simulate(params, μ)
        params[1] = X
    end

    return X

end

"""
plot_burn_in(T_periods, q, params)

This function run the burn in prodecure to set the initial initial_conditions
define in the function burn_in. This function simulates time steps of 7 days
and saves the state of the system
"""
function plot_burn_in(T_periods, q, params)
    # unpack the parameters
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

    # set the initial conditions
    S = rep([0.99999], n)
    P = repeat([0.0], n)
    F = repeat([0.0], n)
    E = repeat([1.0-0.99999], n)
    I_pre = repeat([0.0], n)
    I_asym = repeat([0.0], n)
    I_sym = repeat([0.0], n)
    D = repeat([0.0], n)
    R = repeat([0.0], n)
    X = vcat(S,P,F,E,I_pre,I_asym,I_sym,D,R)

    # set params for simulation
    params[1] = X
    μ = zeros([0],n)

    # set number of time steps
    num_steps = length(T_periods)

    #loop over time periods
    time_step = zeros(num_steps)
    infections = zeros(num_steps, n)
    deaths = zeros(num_steps, n)

    time = 0
    for i in 1:num_steps
        step_size = T_periods[i]
        params[3] = q[i]
        params[14] = T_periods[i]
        X = simulations.simulate(params, μ)
        params[1] = X
        time += step_size
        time_step[i] = time
        infections[i,:] = X[(6*n + 1):(7*n)]
        deaths[i,:] = X[(7*n + 1):(8*n)]
    end

    return time_step, infections, deaths
end




######  run test with plot  ######


# define parameters
n = parameters.m # number of groups


# ***************** #
# transmission rate #
# ***************** #
q0 = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]
theta = vcat(repeat([1.0],8), repeat([0.5], 30), repeat([0.75], 6))
q = q0.*θ

# ***************** #
#    time periods   #
# ***************** #

T_periods = 1:7:309

T = 7
t_breaks = [1] # high availability
num_steps = 1

# ********************** #
# set initial conditions #
# ********************** #
# these are set in the function so can be an arbitrar value here
X0 = [1]



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




# ************** #
# vaccine supply #
# ************** #
v(t) =  0

# *************** #
#  contact rates  #
# *************** #
βs =

# suceptibilty by age class
suceptability = parameters.suceptability_work1

# suceptibilty by age class
vaccine_eff = parameters.vaccine_eff_work1
bins = parameters.bins_04

params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
        suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
        bins, life_expect)

end
