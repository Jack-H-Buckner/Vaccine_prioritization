"""
run optimization for scenario presented in detail in main test
"""
module test_NPI_scenarios

using Random
using Tables
using CSV

include("distancing_senarios.jl")
include("parameters.jl")
include("R0.jl")
include("initial_conditions.jl")
include("simulations.jl")
include("run_opts_2.jl")
include("run_opts_supply.jl")


# # maintext
# n = 8 #
# q = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65
# βs = distancing_senarios.constant_beta01_alpha04_40 # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
# D_exp = parameters.D_exp # duration of exposed phase
# D_pre = parameters.D_pre # duration of presymptomatic phase
# D_asym = parameters.D_asym # duration of asymptomatic phase
# D_sym = parameters.D_sym # duration of symptomatic phase
# asym_rate = parameters.asym_rate_work # asymptomatic rate
# Suceptability = parameters.suceptability_work1 # reletive suceptibility to infection
# IFR = parameters.IFR_work # infection fataity rates
# vaccine_eff = parameters.vaccine_eff_work1 # effetiveness of the vaccine
# T = 240
# t_breaks = [1] # switch policy
# num_steps = 1
# bins = parameters.bins_04 # size of age classes
# life_expect = parameters.life_expect_work # life expectancy for each age
#
# params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
#         Suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
#         bins, life_expect)
#
# v(t) = 0.0
#
# params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
#         Suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
#         bins, life_expect)
#
#
# data_state, data_vaccines, outcomes = simulations.simulate_data(params, 0 * parameters.bins_04)
#
# CSV.write(join(["data_outputs/main_text_no_vaccine_test", "_outcomes.csv"]), Tables.table(hcat(outcomes, ["Infections","YLL","Deaths"])))
# CSV.write(join(["data_outputs/main_text_no_vaccine_test", "_states.csv"]), Tables.table(data_state))
#
#
# # maintext
# n = 8 #
# q = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.75
# βs = distancing_senarios.constant_beta01_alpha04_40 # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
# D_exp = parameters.D_exp # duration of exposed phase
# D_pre = parameters.D_pre # duration of presymptomatic phase
# D_asym = parameters.D_asym # duration of asymptomatic phase
# D_sym = parameters.D_sym # duration of symptomatic phase
# asym_rate = parameters.asym_rate_work # asymptomatic rate
# Suceptability = parameters.suceptability_work1 # reletive suceptibility to infection
# IFR = parameters.IFR_work # infection fataity rates
# vaccine_eff = parameters.vaccine_eff_work1 # effetiveness of the vaccine
# T = 240
# t_breaks = [1] # switch policy
# num_steps = 1
# bins = parameters.bins_04 # size of age classes
# life_expect = parameters.life_expect_work # life expectancy for each age
#
# params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
#         Suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
#         bins, life_expect)
#
# v(t) = 0.0
#
# params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
#         Suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
#         bins, life_expect)
#
#
# data_state, data_vaccines, outcomes = simulations.simulate_data(params, 0 * parameters.bins_04)
#
# CSV.write(join(["data_outputs/main_text_no_vaccine_test", "_outcomes.csv"]), Tables.table(hcat(outcomes, ["Infections","YLL","Deaths"])))
# CSV.write(join(["data_outputs/main_text_no_vaccine_test", "_states.csv"]), Tables.table(data_state))
#
v(t) = 0.0

X0 = initial_conditions.calc_IC(0.90,0.005,0.08,
    parameters.bins_04 ,
    8,
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.4,
    distancing_senarios.constant_beta01_alpha03_40,
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    parameters.sigma_asym[1])

# maintext
n = 8 #
q = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.4
βs = distancing_senarios.constant_beta01_alpha03_40 # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
D_exp = parameters.D_exp # duration of exposed phase
D_pre = parameters.D_pre # duration of presymptomatic phase
D_asym = parameters.D_asym # duration of asymptomatic phase
D_sym = parameters.D_sym # duration of symptomatic phase
asym_rate = parameters.asym_rate_work # asymptomatic rate
Suceptability = parameters.suceptability_work1 # reletive suceptibility to infection
IFR = parameters.IFR_work # infection fataity rates
vaccine_eff = parameters.vaccine_eff_work1 # effetiveness of the vaccine
T = 240
t_breaks = [1] # switch policy
num_steps = 1
bins = parameters.bins_04 # size of age classes
life_expect = parameters.life_expect_work # life expectancy for each age

params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
        Suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
        bins, life_expect)

v(t) = 0.0

params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
        Suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
        bins, life_expect)

R0_strong = R0.calc_R0(q, Suceptability, βs(1,1,1)[1], βs(1,1,1)[2], βs(1,1,1)[3], D_pre, D_asym, D_sym, repeat([0.9],8))
print(R0_strong)
print("\n")

data_state, data_vaccines, outcomes = simulations.simulate_data(params, 0 * parameters.bins_04)

CSV.write(join(["data_outputs/strong_NPI_test", "_outcomes.csv"]), Tables.table(hcat(outcomes, ["Infections","YLL","Deaths"])))
CSV.write(join(["data_outputs/strong_NPI_test", "_states.csv"]), Tables.table(data_state))



X0 = initial_conditions.calc_IC(0.90,0.005,0.08,
    parameters.bins_04 ,
    8,
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.5,
    distancing_senarios.constant_beta01_alpha04_40,
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    parameters.sigma_asym[1])

n = 8 #
q = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.5
βs = distancing_senarios.constant_beta01_alpha04_40 # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
D_exp = parameters.D_exp # duration of exposed phase
D_pre = parameters.D_pre # duration of presymptomatic phase
D_asym = parameters.D_asym # duration of asymptomatic phase
D_sym = parameters.D_sym # duration of symptomatic phase
asym_rate = parameters.asym_rate_work # asymptomatic rate
Suceptability = parameters.suceptability_work1 # reletive suceptibility to infection
IFR = parameters.IFR_work # infection fataity rates
vaccine_eff = parameters.vaccine_eff_work1 # effetiveness of the vaccine
T = 240
t_breaks = [1] # switch policy
num_steps = 1
bins = parameters.bins_04 # size of age classes
life_expect = parameters.life_expect_work # life expectancy for each age

R0_main = R0.calc_R0(q, Suceptability, βs(1,1,1)[1], βs(1,1,1)[2], βs(1,1,1)[3], D_pre, D_asym, D_sym, repeat([0.9],8))
print(R0_main)
print("\n")

params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
        Suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
        bins, life_expect)

v(t) = 0.0

params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
        Suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
        bins, life_expect)


data_state, data_vaccines, outcomes = simulations.simulate_data(params, 0 * parameters.bins_04)

CSV.write(join(["data_outputs/main_text_test", "_outcomes.csv"]), Tables.table(hcat(outcomes, ["Infections","YLL","Deaths"])))
CSV.write(join(["data_outputs/main_text_test", "_states.csv"]), Tables.table(data_state))


X0 = initial_conditions.calc_IC(0.90,0.005,0.08,
    parameters.bins_04 ,
    8,
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.75,
    distancing_senarios.constant_beta01_alpha04_40,
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    parameters.sigma_asym[1])

n = 8 #
q = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.75
βs = distancing_senarios.constant_beta01_alpha04_40 # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
D_exp = parameters.D_exp # duration of exposed phase
D_pre = parameters.D_pre # duration of presymptomatic phase
D_asym = parameters.D_asym # duration of asymptomatic phase
D_sym = parameters.D_sym # duration of symptomatic phase
asym_rate = parameters.asym_rate_work # asymptomatic rate
Suceptability = parameters.suceptability_work1 # reletive suceptibility to infection
IFR = parameters.IFR_work # infection fataity rates
vaccine_eff = parameters.vaccine_eff_work1 # effetiveness of the vaccine
T = 240
t_breaks = [1] # switch policy
num_steps = 1
bins = parameters.bins_04 # size of age classes
life_expect = parameters.life_expect_work # life expectancy for each age

params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
        Suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
        bins, life_expect)

v(t) = 0.0
R0_weak = R0.calc_R0(q, Suceptability, βs(1,1,1)[1], βs(1,1,1)[2], βs(1,1,1)[3], D_pre, D_asym, D_sym, repeat([0.9],8))
print(R0_weak)
print("\n")


data_state, data_vaccines, outcomes = simulations.simulate_data(params, 0 * parameters.bins_04)

CSV.write(join(["data_outputs/weak_NPI_test", "_outcomes.csv"]), Tables.table(hcat(outcomes, ["Infections","YLL","Deaths"])))
CSV.write(join(["data_outputs/weak_NPI_test", "_states.csv"]), Tables.table(data_state))
end
