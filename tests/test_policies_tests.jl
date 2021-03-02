module test_policies_tests

using Plots
using Measures
using CSV
using Tables
using DataFrames

include("parameters.jl")
include("simulations.jl")
include("optimization.jl")
include("distancing_senarios.jl")
include("R0.jl")
include("initial_conditions.jl")
include("simulated_anealing.jl")

df = DataFrame!(CSV.File("data_outputs/main_text_full_policies_1.csv"))
rename!(df, Dict("Column1" => "infections", "Column2" => "YLL", "Column3" => "deaths"))

μ_infections =  df.infections
μ_YLL = df.YLL
μ_deaths = df.deaths

print(μ_infections[1:8])

days_10 = 30

v(t) = 0.1/days_10
t_breaks = collect(1:days_10:(6*days_10)) # high availability
num_steps = 6
T = days_10 * 8

n = 8 #

q = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1] * 0.65 # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
D_pre = parameters.D_pre# duration
D_asym = parameters.D_asym
D_sym = parameters.D_sym
D_exp = parameters.D_exp
asym_rate = parameters.asym_rate_work # asymptomatic rate
IFR = IFR = parameters.IFR_work # infection fatality rate
T = 240
t_breaks = [1] # switch policy
num_steps = 1
bins = parameters.bins_04 # size of age classes
life_expect = parameters.life_expect_work # life expectancy for each age


IC = initial_conditions.calc_IC(0.90,0.005,0.08,
    parameters.bins_04 ,
    8,
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.75,
    distancing_senarios.constant_beta01_alpha03_40,
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    parameters.sigma_asym[1])

βs = distancing_senarios.constant_beta01_alpha03_40


params = (IC, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
        parameters.suceptability_work1, IFR, parameters.vaccine_eff_work1, v,
        T, t_breaks, num_steps, bins, life_expect)


outcomes_infections = simulations.YLL(params, μ_infections)
outcomes_YLL = simulations.YLL(params, μ_YLL)
outcomes_YLL = simulations.YLL(params, μ_YLL)
outcomes_deaths = simulations.YLL(params, μ_deaths)
print(simulations.YLL(params, μ_YLL) > simulations.deaths(params, μ_YLL))
print("\n")
print(outcomes_infections)
print("\n")
print(outcomes_YLL)
print("\n")
print(life_expect)
end
