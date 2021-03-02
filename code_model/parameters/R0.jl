"""
This module is used to calibrate the model to the apropreate R0
"""
module R0

using NLsolve
using LinearAlgebra
using CSV
using Tables
using Plots
using DataFrames
include("parameters.jl")
include("distancing_senarios.jl")
include("../dynamics/simulations.jl")
include("../dynamics/derivitives.jl")


"""
q - transmission probability per contact time
c_asym, c_presym, c_sym - contact matrix from group i to group i in time per day
D_presym, D_asym, D_sym - symptom durations
p - size of each populaiton group sums to one

"""
function calc_R0(q, s, c_asym, c_presym, c_sym, D_presym, D_asym, D_sym, p)
    t = parameters.transmisivity
    sigma = parameters.sigma_asym[1]
    t = parameters.transmisivity
    m_sym = (1-sigma)*q*t[1]*D_sym*s.*transpose(c_sym)
    m_asym = (sigma)*q*t[2]*D_asym*s.*transpose(c_asym)
    m_presym = q*t[3]*D_presym*s.*transpose(c_presym)
    M = m_sym .+ m_asym .+ m_presym
    ev = LinearAlgebra.eigen(M)
    return ev.values[argmax(ev.values)]

end

"""
thi sfunciton calls nlsolve from the NLsolve library to fine the value of
q (transmission rate) required for a specified value of R0
"""
function solve_R0(R, s, c_asym, c_presym, c_sym, D_presym, D_asym, D_sym, p)
    f = x -> [R - calc_R0(x[1], s, c_asym, c_presym, c_sym, D_presym, D_asym, D_sym, p)]
    sol = nlsolve(f, [0.05])
    return sol
end


"""
This funciton calls solve_R0 with the parameters specified for the front line
worker model were 20% of the adult popualtion is modeled in a sperate high
contact rate group.
"""
function solve_R_20(R, s)

    c_asym = parameters.cnt_total_20
    c_presym = parameters.cnt_total_20
    c_sym = parameters.cnt_total_sym_20

    D_exp = parameters.D_exp
    D_pre = parameters.D_pre
    D_asym = parameters.D_asym
    D_sym = parameters.D_sym
    p = parameters.bins_02

    solve_R0(R, s, c_asym, c_presym, c_sym, D_pre, D_asym, D_sym, p)
end


#q_20 = solve_R_20(parameters.R_0, parameters.suceptability_work1).zero[1]



"""
This funciton calls solve_R0 with the parameters specified for the front line
worker model were 20% of the adult popualtion is modeled in a sperate high
contact rate group.
"""
function solve_R_40(R, s)

    c_asym = parameters.cnt_total_40
    c_presym = parameters.cnt_total_40
    c_sym = parameters.cnt_total_sym_40

    D_exp = parameters.D_exp
    D_pre = parameters.D_pre
    D_asym = parameters.D_asym
    D_sym = parameters.D_sym
    p = parameters.bins_02

    solve_R0(R, s, c_asym, c_presym, c_sym, D_pre, D_asym, D_sym, p)
end


#q_40 = solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]


end
