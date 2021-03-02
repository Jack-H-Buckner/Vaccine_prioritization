module initial_conditions

using LinearAlgebra
include("derivitives.jl")
include("parameters.jl")
include("distancing_senarios.jl")

"""
This function makes a rough estimate of the correct initial conditions
that is the used by the calc IC function as a starting point
"""
function calc_IC_naive(S,I_sym)

    # get asymptomatic rate
    σ = parameters.asym_rate_work[1]

    # calculate rough proportion if each infected class
    I_exp = I_sym * parameters.D_exp/parameters.D_sym
    I_pre = I_sym * parameters.D_pre/parameters.D_sym
    I_asym = I_sym * parameters.D_asym/parameters.D_sym * σ/(1-σ)

    return [S, I_exp , I_pre, I_asym, I_sym]
end
"""
this function calcualted the proprotion of infected indivual by age group
when the outbreak is growing (shrinking) at a given rate. is also computes the
proporiton of infected individuals of each symptom type.

This is done by simulating teh model for 25 days starting at the initialization
defined by the calc_IC_naive function.

Once the reletive proporitons are found for each age group and symptom type are
found these proprotions are scaled to match the desired initial level of infections.
"""
function calc_IC(S, I, R, bins,  n, q, betas,
    suceptability,
    vaccine_eff,
    asym_rate)

    # calcualted guess of IC
    IC = calc_IC_naive(S,I)


    S1 = IC[1] .* bins ./sum(bins)

    P = repeat([0], n)
    F = repeat([0], n)
    E = repeat([0.000005], n)
    I_pre = repeat([IC[2]], n) .* bins./sum(bins)
    I_asym = repeat([IC[3]], n).* bins./sum(bins)
    I_sym = repeat([IC[4]], n).* bins./sum(bins)
    D = repeat([0.00], n)
    R1 = 0.08 .* bins ./sum(bins)
    X = vcat(S1,P,F,E,I_pre,I_asym,I_sym,D,R1)

    D_exp = parameters.D_exp
    D_pre = parameters.D_pre
    D_asym = parameters.D_asym
    D_sym = parameters.D_sym

    t = parameters.transmisivity
    infections = sum(X[(5*n+1):(6*n)] .+ X[(6*n+1):(7*n)])
    i = 0
    f = x -> 0
    IFR = repeat([0],n)
    betas = betas(1,1,0)

    beta1 = betas[3]
    beta2 = betas[2]
    beta3 = betas[1]

    for i in 1:25

        i += 1
        X = derivitives.mod1_discrete(X, # state varabibles S P F I_pre I_asym I_mild D R
            n, # number of groups
            q, # transmission rate
            beta1, beta2, beta3, # transmission rates
            D_pre, D_asym, D_sym, D_exp, # symptom durations
            asym_rate,
            suceptability, # suceptability to infections by age
            IFR, # infection fataity rates
            vaccine_eff, # efficency of vaccines
            i,
            f, # vacine availability
            repeat([0],n) # allocation vector
            )

        infections = sum(X[(5*n+1):(6*n)] .+ X[(6*n+1):(7*n)])

    end

    X = I * X ./ infections
    X[(8*n+1):(9*n)] = R .* bins ./sum(bins)


    X[1:n] = S .* bins ./sum(bins)

    return X

end




"""
The COVID 19 models before vaccine becoe avaialble are identical
so the original calc_IC function can be used and the output extended
fo the efficacies model.
"""
function calc_IC_efficencies(S, I, R, bins,  n, q, betas,
    suceptability,
    vaccine_eff,
    asym_rate)

    X = calc_IC(S, I, R, bins,  n, q, betas,
        suceptability,
        vaccine_eff,
        asym_rate)

    # unpack X

    S = X[1:n] # symptomatic
    P = X[(n+1):(2*n)] # protected
    F = X[(2*n+1):(3*n)] # failed
    E = X[(3*n+1):(4*n)] # exposed
    I_presym = X[(4*n+1):(5*n)] # presymptimatic
    I_asym = X[(5*n+1):(6*n)] # asymptomatic
    I_sym = X[(6*n+1):(7*n)] # symptomatic
    D = X[(7*n+1):(8*n)] # deaths
    R = X[(8*n+1):(9*n)] # recovered

    # add zeros for protected categories
    P_E = zeros(n)
    P_I_pre = zeros(n)
    P_I_asym = zeros(n)
    P_I_sym = zeros(n)
    P_R = zeros(n)

    X = vcat(S, P, P_E, P_I_pre, P_I_asym, P_I_sym, E, I_presym, I_asym, I_sym, D, R, P_R)
    return X
end



function test()
    return calc_IC(0.9,
        0.01,
        parameters.bins_work,
        8,
        0.04,
        distancing_senarios.constant_alpha05_beta03_rho025_work,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]
        )
end


end
