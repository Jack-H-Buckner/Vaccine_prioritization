"""
This module contains derivities and set functions for continuous and
discrete models of COVID 19 infection dynamics

that parameters for these models are stored in the
parameters.jl file
"""
module derivitives

include("../parameters/parameters.jl")

"""
This function runs a disrete aproximation of the COVID 19 vaccine model
This aproximation is used inplace of continuous method like RK45 to increase
the numerical efficency of the program.

This function takes a state vector X and the model parameters and
updates X on a one day increment.


Checks:

The total number of individuals is conserved:
    - catches miss specification of recovery rates
    - catches mismatch in new exposed and decrease in suceptibles
"""
function mod1_discrete(
    X, # state varabibles S P F E I_pre I_asym I_mild D R
    n, # number of groups
    q, # transmission rate
    β_presym, β_asym, β_sym, # transmission rates
    D_pre, D_asym, D_sym, D_exp, # symptom durations
    asym_rate, # asymptomatic rate
    Suceptability, # suceptability to infections by age
    IFR, # infection fataity rates
    vaccine_eff, # efficency of vaccines
    t, # number of day from begining of simulation
    v, # vacine availability
    μ # allocation vector
    )


    # unpack state variables
    S = X[1:n] # symptomatic
    P = X[(n+1):(2*n)] # protected
    F = X[(2*n+1):(3*n)] # failed
    E = X[(3*n+1):(4*n)] # exposed
    I_presym = X[(4*n+1):(5*n)] # presymptimatic
    I_asym = X[(5*n+1):(6*n)] # asymptomatic
    I_sym = X[(6*n+1):(7*n)] # symptomatic
    D = X[(7*n+1):(8*n)] # deaths
    R = X[(8*n+1):(9*n)] # recovered


    N = S .+ P .+ F .+ E .+ I_presym .+ I_asym .+ I_sym .+ R

    # ensure that number vaccinated is less than the number of suscpetibles
    μ[v(t)*μ .> S] = S[v(t)*μ .> S]

    # define the transmission matrices
    # an scale by the reletive infectiousness of each symptom type
    t_sym = parameters.transmisivity
    β_presym = β_presym*t_sym[2]
    β_asym = β_asym*t_sym[3]
    β_sym = β_sym*t_sym[1]

    # define derivitives

    # new susceptibles
    dS = S .* exp.(-q*Suceptability .* ((β_presym * I_presym./N) .+(β_asym * I_asym./N) .+ (β_sym * I_sym./N))) .- v(t)*μ

    # protected
    dP = P + v(t)*μ.*vaccine_eff

    # failed vaccine
    dF = F .* exp.(-q*Suceptability .* ((β_presym * I_presym./N) .+
    (β_asym * I_asym./N) .+ (β_sym * I_sym./N))).+ v(t)*μ.*(1.0 .-vaccine_eff)

    # Exposed individuals
    dE = S.*(1 .- exp.(-q*Suceptability .* ((β_presym * I_presym./N) .+(β_asym * I_asym./N) .+ (β_sym * I_sym./N)))) .+
    F .* (1 .- exp.(-q*Suceptability .* ((β_presym * I_presym./N) .+ (β_asym * I_asym./N) .+ (β_sym * I_sym./N)))) .+
        E .* exp.(-1 /D_exp)

    # presymptomatic
    dI_presym = I_presym .* exp(-1/D_pre) + E .*(1 - exp.(-1 /D_exp))

    # asymptomatic
    dI_asym = asym_rate.*I_presym .* (1 - exp(-1 /D_pre)) .+ I_asym .* exp(-1/D_asym)

    # symptomatic
    dI_sym = (1 .-asym_rate).*I_presym .* (1 - exp(-1 /D_pre)) .+ I_sym .* exp(-1/D_sym)

    # deaths
    dD = D .+ IFR.*I_sym .* (1 - exp(-1/D_sym))

    # Recovered
    dR = R .+ (1 .-IFR).*I_sym .* (1 - exp(-1/D_sym)) .+ I_asym .* (1 - exp(-1/D_asym))

    # new value
    X_new = vcat( dS, dP, dF, dE, dI_presym, dI_asym, dI_sym, dD, dR)

    return X_new
end



"""
same as previous function but extra vaccines are realocated at random
"""
function mod1_discrete_leftovers(
    X, # state varabibles S P F E I_pre I_asym I_mild D R
    n, # number of groups
    q, # transmission rate
    β_presym, β_asym, β_sym, # transmission rates
    D_pre, D_asym, D_sym, D_exp, # symptom durations
    asym_rate, # asymptomatic rate
    Suceptability, # suceptability to infections by age
    IFR, # infection fataity rates
    vaccine_eff, # efficency of vaccines
    t, # number of day from begining of simulation
    v, # vacine availability
    μ # allocation vector
    )


    # unpack state variables
    S = X[1:n] # symptomatic
    P = X[(n+1):(2*n)] # protected
    F = X[(2*n+1):(3*n)] # failed
    E = X[(3*n+1):(4*n)] # exposed
    I_presym = X[(4*n+1):(5*n)] # presymptimatic
    I_asym = X[(5*n+1):(6*n)] # asymptomatic
    I_sym = X[(6*n+1):(7*n)] # symptomatic
    D = X[(7*n+1):(8*n)] # deaths
    R = X[(8*n+1):(9*n)] # recovered


    N = S .+ P .+ F .+ E .+ I_presym .+ I_asym .+ I_sym .+ R

    # ensure that number vaccinated is less than the number of suscpetibles


    inds = v(t)*μ .> S
    if any(v(t)*μ .> S)

        v_excess = sum(v(t)*μ[v(t)*μ .> S] .- S[v(t)*μ .> S]) # compute excess vaccines

        μ[v(t)*μ .> S] = S[v(t)*μ .> S] # remove excess vaccines
        μ[.!(inds)] = v_excess * S[.!(inds)] ./ sum(S[.!(inds)])   # realocate randomly


    end

    μ[v(t)*μ .> S] = S[v(t)*μ .> S] # double check constraint

    # define the transmission matrices
    # an scale by the reletive infectiousness of each symptom type
    t_sym = parameters.transmisivity
    β_presym = β_presym*t_sym[2]
    β_asym = β_asym*t_sym[3]
    β_sym = β_sym*t_sym[1]

    # define derivitives

    # new susceptibles
    dS = S .* exp.(-q*Suceptability .* ((β_presym * I_presym./N) .+(β_asym * I_asym./N) .+ (β_sym * I_sym./N))) .- v(t)*μ

    # protected
    dP = P + v(t)*μ.*vaccine_eff

    # failed vaccine
    dF = F .* exp.(-q*Suceptability .* ((β_presym * I_presym./N) .+
    (β_asym * I_asym./N) .+ (β_sym * I_sym./N))).+ v(t)*μ.*(1.0 .-vaccine_eff)

    # Exposed individuals
    dE = S.*(1 .- exp.(-q*Suceptability .* ((β_presym * I_presym./N) .+(β_asym * I_asym./N) .+ (β_sym * I_sym./N)))) .+
    F .* (1 .- exp.(-q*Suceptability .* ((β_presym * I_presym./N) .+ (β_asym * I_asym./N) .+ (β_sym * I_sym./N)))) .+
        E .* exp.(-1 /D_exp)

    # presymptomatic
    dI_presym = I_presym .* exp(-1/D_pre) + E .*(1 - exp.(-1 /D_exp))

    # asymptomatic
    dI_asym = asym_rate.*I_presym .* (1 - exp(-1 /D_pre)) .+ I_asym .* exp(-1/D_asym)

    # symptomatic
    dI_sym = (1 .-asym_rate).*I_presym .* (1 - exp(-1 /D_pre)) .+ I_sym .* exp(-1/D_sym)

    # deaths
    dD = D .+ IFR.*I_sym .* (1 - exp(-1/D_sym))

    # Recovered
    dR = R .+ (1 .-IFR).*I_sym .* (1 - exp(-1/D_sym)) .+ I_asym .* (1 - exp(-1/D_asym))

    # new value
    X_new = vcat( dS, dP, dF, dE, dI_presym, dI_asym, dI_sym, dD, dR)

    return X_new
end



end # module
