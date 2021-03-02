"""
This file defines the derivitives for the leaky vaccine model.

vaccianted individuals are still part of the suceptible populations
but they are infected at a rate 1 - V_inf the rate of non-vaccianted
individuals, transmit the infection at a rate 1-V_trans the rate of
non-vacianted individuals and die at a rate 1-V_mort te rate of
non-vaccinated individuals.
"""
module derivitives_efficacies


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
    VE1,
    VE2,
    VE3, # efficency of vaccines
    t, # number of day from begining of simulation
    v, # vacine availability
    μ # allocation vector
    )
    # unpack state variables

    S = X[1:n]
    P = X[(1*n+1):(2*n)]
    P_E = X[(2*n+1):(3*n)]
    P_I_presym = X[(3*n+1):(4*n)]
    P_I_asym = X[(4*n+1):(5*n)]
    P_I_sym = X[(5*n+1):(6*n)]
    E = X[(6*n+1):(7*n)]
    I_presym = X[(7*n+1):(8*n)]
    I_asym = X[(8*n+1):(9*n)]
    I_sym = X[(9*n+1):(10*n)]
    D = X[(10*n+1):(11*n)]
    R = X[(11*n+1):(12*n)]
    P_R = X[(12*n+1):(13*n)]


    N = S .+ P .+ E .+ I_presym .+ I_asym .+ I_sym .+ R .+ P_E .+ P_I_presym .+ P_I_asym .+ P_I_sym .+ P_R

    # convert efficncies

    VEff1 = 1 .- VE1
    VEff2 = 1 .- VE2
    VEff3 = 1 .- VE3

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
    dS = S .* exp.(-q*Suceptability.*((β_presym*I_presym./N).+(β_asym*I_asym./N).+(β_sym*I_sym./N))
                    -q*Suceptability.*((β_presym*(VEff2.*P_I_presym)./N) .+(β_asym*(VEff2.*P_I_asym)./N) .+ (β_sym*(VEff2.*P_I_sym)./N))).-v(t)*μ



    # vacinated and protected
    inf_rate_P = exp.(-q*VEff1.*Suceptability.*((β_presym*I_presym./N).+(β_asym*I_asym./N).+(β_sym*I_sym./N))
            -q*VEff1.*Suceptability.*((β_presym*(VEff2.*P_I_presym)./N) .+(β_asym*(VEff2.*P_I_asym)./N) .+ (β_sym*(VEff2.*P_I_sym)./N)))



    dP =  v(t)*μ .+ P.*inf_rate_P

    move_P_E = exp.(-1 /D_exp)
    move_P_I_pre = exp(-1 /D_pre)
    move_P_I_asym = exp(-1/D_asym)
    move_P_I_sym = exp(-1/D_sym)

    dP_E = P .* (1 .- inf_rate_P) .+ P_E.* move_P_E


    dP_I_presym =  P_E.* (1 - move_P_E) .+ P_I_presym .* move_P_I_pre


    dP_I_asym = asym_rate.*P_I_presym .* (1 - move_P_I_pre) .+ P_I_asym .* move_P_I_asym


    dP_I_sym = (1 .-asym_rate).*P_I_presym .* (1 - move_P_I_pre) .+ P_I_sym .* move_P_I_sym #


    dP_R = P_R .+ (1 .- (IFR .* VEff3)) .*P_I_sym .* (1 -move_P_I_sym ) .+  P_I_asym .* (1 -move_P_I_asym )


    # Exposed individuals



    dE = S.*(1 .- exp.(-q*Suceptability.*((β_presym*I_presym./N).+(β_asym*I_asym./N).+(β_sym*I_sym./N))
                    -q*Suceptability.*((β_presym*(VEff2.*P_I_presym)./N) .+(β_asym*(VEff2.*P_I_asym)./N) .+ (β_sym*(VEff2.*P_I_sym)./N)))) .+ E .* exp.(-1 /D_exp)

    # presymptomatic
    dI_presym = I_presym .* exp(-1/D_pre) .+ E .*(1 - exp.(-1 /D_exp))

    # asymptomatic
    dI_asym = asym_rate.*I_presym .* (1 - exp(-1 /D_pre)) .+ I_asym .* exp(-1/D_asym)

    # symptomatic
    dI_sym = (1 .-asym_rate).*I_presym .* (1 - exp(-1 /D_pre)) .+ I_sym .* exp(-1/D_sym)

    # deaths
    dD = D .+ IFR.*I_sym .* (1 - exp(-1/D_sym)) .+ (VEff3 .* IFR) .* P_I_sym .* (1 -move_P_I_sym )

    # Recovered
    dR = R .+ (1 .-IFR).*I_sym .* (1 - exp(-1/D_sym)) .+ I_asym .* (1 - exp(-1/D_asym))



    # new value



    X_new = vcat( dS, dP, dP_E, dP_I_presym, dP_I_asym, dP_I_sym, dE, dI_presym, dI_asym, dI_sym, dD, dR, dP_R)



    return X_new
end



end


#
# module derivitives
#
#
#
# """
# This function runs a disrete aproximation of the COVID 19 vaccine model
# This aproximation is used inplace of continuous method like RK45 to increase
# the numerical efficency of the program.
#
# This function takes a state vector X and the model parameters and
# updates X on a one day increment.
#
#
# Checks:
#
# The total number of individuals is conserved:
#     - catches miss specification of recovery rates
#     - catches mismatch in new exposed and decrease in suceptibles
# """
# function mod1_discrete(
#     X, # state varabibles S P F E I_pre I_asym I_mild D R
#     n, # number of groups
#     q, # transmission rate
#     β_presym, β_asym, β_sym, # transmission rates
#     D_pre, D_asym, D_sym, D_exp, # symptom durations
#     asym_rate, # asymptomatic rate
#     Suceptability, # suceptability to infections by age
#     IFR, # infection fataity rates
#     vaccine_eff, # efficency of vaccines
#     t, # number of day from begining of simulation
#     v, # vacine availability
#     μ # allocation vector
#     )
#     # unpack state variables
#
#     S = X[1:n]
#     P = X[(1*n+1):(2*n)]
#     P_E = X[(2*n+1):(3*n)]
#     P_I_pre = X[(3*n+1):(4*n)]
#     P_I_asym = X[(4*n+1):(5*n)]
#     P_I_sym = X[(5*n+1):(6*n)]
#     E = X[(6*n+1):(7*n)]
#     I_presym = X[(7*n+1):(8*n)]
#     I_asym = X[(8*n+1):(9*n)]
#     I_sym = X[(9*n+1):(10*n)]
#     D = X[(10*n+1):(11*n)]
#     R = X[(11*n+1):(12*n)]
#     P_R = X[(12*n+1):(13*n)]
#
#
#     N = S .+ P .+ F .+ E .+ I_presym .+ I_asym .+ I_sym .+ R
#
#     # ensure that number vaccinated is less than the number of suscpetibles
#     μ[v(t)*μ .> S] = S[v(t)*μ .> S]
#
#     # define the transmission matrices
#     # an scale by the reletive infectiousness of each symptom type
#     t_sym = parameters.transmisivity
#     β_presym = β_presym*t_sym[2]
#     β_asym = β_asym*t_sym[3]
#     β_sym = β_sym*t_sym[1]
#
#     # define derivitives
#
#     # new susceptibles
#     dS = S .* exp.(-q*Suceptability.*((β_presym*I_presym./N).+(β_asym*I_asym./N).+(β_sym*I_sym./N))
#                     -q*Suceptability.*((β_presym*(VE2.*P_I_presym)./N) .+(β_asym*(VE2.*P_I_asym)./N) .+ (β_sym*(VE2.*P_I_sym)./N))).-v(t)*μ
#
#
#
#     # vacinated and protected
#     dP =  v(t)*μ .- P.*exp.(-q*V1.*Suceptability.*((β_presym*I_presym./N).+(β_asym*I_asym./N).+(β_sym*I_sym./N))
#                     -q*V1.*Suceptability.*((β_presym*(VE2.*P_I_presym)./N) .+(β_asym*(VE2.*P_I_asym)./N) .+ (β_sym*(VE2.*P_I_sym)./N)))
#
#     dP_E = P .* (1 .- exp.(-q*Suceptability .* ((β_presym * I_presym./N) .+
#     (β_asym * I_asym./N) .+ (β_sym * I_sym./N)))) .+ P_E.* exp.(-1 /D_exp)
#
#
#     dP_I_presym =  P_E.* (1 - exp.(-1 /D_exp)) .- P_I_presy .* (1 - exp.(-1 /D_pre))
#
#
#     dP_I_asym = asym_rate.*P_I_presym .* (1 - exp(-1 /D_pre)) .+ P_I_asym .* exp(-1/D_asym)
#
#
#     dP_I_sym = (1 .-asym_rate).*P_I_presym .* (1 - exp(-1 /D_pre)) .+ P_I_sym .* exp(-1/D_sym)
#
#
#     # Exposed individuals
#     dE = S.*(1 .- exp.(-q*Suceptability.*((β_presym*I_presym./N).+(β_asym*I_asym./N).+(β_sym*I_sym./N))
#                     -q*Suceptability.*((β_presym*VE2.*P_I_presym./N) .+(β_asym*VE2.*P_I_asym./N) .+ (β_sym*VE2.*P_I_sym./N)))) .+ E .* exp.(-1 /D_exp)
#
#     # presymptomatic
#     dI_presym = I_presym .* exp(-1/D_pre) + E .*(1 - exp.(-1 /D_exp))
#
#     # asymptomatic
#     dI_asym = asym_rate.*I_presym .* (1 - exp(-1 /D_pre)) .+ I_asym .* exp(-1/D_asym)
#
#     # symptomatic
#     dI_sym = (1 .-asym_rate).*I_presym .* (1 - exp(-1 /D_pre)) .+ I_sym .* exp(-1/D_sym)
#
#     # deaths
#     dD = D .+ IFR.*I_sym .* (1 - exp(-1/D_sym))
#
#     # Recovered
#     dR = R .+ (1 .-IFR).*I_sym .* (1 - exp(-1/D_sym)) .+ I_asym .* (1 - exp(-1/D_asym))
#
#     dP_R = P_R .+ P_I_sym .* (1 -exp(-1/D_sym)) .+  P_I_asym .* (1 -exp(-1/D_asym))
#
#     # new value
#     X_new = vcat( dS, dP, dP_E, dP_I_presym, dP_I_asym, dP_I_sym, dE, dI_presym, dI_asym, dI_sym, dD, dR, dP_R)
#
#     return X_new
# end
#
#
#
# end
