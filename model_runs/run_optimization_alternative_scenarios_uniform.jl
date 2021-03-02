"""
run alternative scenarios with uniform allocaiton
"""
module alternative_scenarios_uniform





using Random
using Tables
using CSV





include("../code_model/parameters/distancing_senarios.jl")
include("../code_model/parameters/parameters.jl")
include("../code_model/parameters/R0.jl")
include("../code_model/parameters/initial_conditions.jl")
include("../code_model/dynamics/simulations.jl")





v(t) = 0.1/30





# weak NPI
X0 = initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.75,
        distancing_senarios.constant_beta03_alpha04_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]) # state varabibles S P F I_pre I_asym I_mild D R

n = 8 #
q = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.75
βs = distancing_senarios.constant_beta03_alpha04_40 # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
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

v(t) = 0.1/30
data_state, data_vaccines, outcomes = simulations.simulate_data(params, parameters.bins_04)

CSV.write(join(["../data_outputs/weak_NPI_uniform", "_outcomes.csv"]), Tables.table(hcat(outcomes, ["Infections","YLL","Deaths"])))
CSV.write(join(["../data_outputs/weak_NPI_uniform", "_states.csv"]), Tables.table(data_state))








# strong NPI
X0 = initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.5,
        distancing_senarios.constant_beta01_alpha03_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]) # state varabibles S P F I_pre I_asym I_mild D R

n = 8 #
q = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.5
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

v(t) = 0.1/30
data_state, data_vaccines, outcomes = simulations.simulate_data(params, parameters.bins_04)

CSV.write(join(["../data_outputs/strong_NPI_uniform", "_outcomes.csv"]), Tables.table(hcat(outcomes, ["Infections","YLL","Deaths"])))
CSV.write(join(["../data_outputs/strong_NPI_uniform", "_states.csv"]), Tables.table(data_state))









#high initial infections


X0 = initial_conditions.calc_IC(0.90,0.015,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]) # state varabibles S P F I_pre I_asym I_mild D R

n = 8 #
q = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65
βs = distancing_senarios.constant_beta03_alpha04_40 # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
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

v(t) = 0.1/30
data_state, data_vaccines, outcomes = simulations.simulate_data(params, parameters.bins_04)

CSV.write(join(["../data_outputs/high_initial_infections_uniform", "_outcomes.csv"]), Tables.table(hcat(outcomes, ["Infections","YLL","Deaths"])))
CSV.write(join(["../data_outputs/high_initial_infections_uniform", "_states.csv"]), Tables.table(data_state))











#high sucept children


X0 = initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40,
        parameters.suceptability_work3,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]) # state varabibles S P F I_pre I_asym I_mild D R

n = 8 #
q = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65
βs = distancing_senarios.constant_beta03_alpha04_40 # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
D_exp = parameters.D_exp # duration of exposed phase
D_pre = parameters.D_pre # duration of presymptomatic phase
D_asym = parameters.D_asym # duration of asymptomatic phase
D_sym = parameters.D_sym # duration of symptomatic phase
asym_rate = parameters.asym_rate_work # asymptomatic rate
Suceptability = parameters.suceptability_work3 # reletive suceptibility to infection
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

v(t) = 0.1/30
data_state, data_vaccines, outcomes = simulations.simulate_data(params, parameters.bins_04)

CSV.write(join(["../data_outputs/high_sucept_children_uniform", "_outcomes.csv"]), Tables.table(hcat(outcomes, ["Infections","YLL","Deaths"])))
CSV.write(join(["../data_outputs/high_sucept_children_uniform", "_states.csv"]), Tables.table(data_state))












#high Low_effectiveness_60


X0 = initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work3,
        parameters.sigma_asym[1]) # state varabibles S P F I_pre I_asym I_mild D R

n = 8 #
q = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65
βs = distancing_senarios.constant_beta03_alpha04_40 # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
D_exp = parameters.D_exp # duration of exposed phase
D_pre = parameters.D_pre # duration of presymptomatic phase
D_asym = parameters.D_asym # duration of asymptomatic phase
D_sym = parameters.D_sym # duration of symptomatic phase
asym_rate = parameters.asym_rate_work # asymptomatic rate
Suceptability = parameters.suceptability_work1 # reletive suceptibility to infection
IFR = parameters.IFR_work # infection fataity rates
vaccine_eff = parameters.vaccine_eff_work3 # effetiveness of the vaccine
T = 240
t_breaks = [1] # switch policy
num_steps = 1
bins = parameters.bins_04 # size of age classes
life_expect = parameters.life_expect_work # life expectancy for each age

params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
        Suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
        bins, life_expect)

v(t) = 0.1/30
data_state, data_vaccines, outcomes = simulations.simulate_data(params, parameters.bins_04)

CSV.write(join(["../data_outputs/Low_effectiveness_60_uniform", "_outcomes.csv"]), Tables.table(hcat(outcomes, ["Infections","YLL","Deaths"])))
CSV.write(join(["../data_outputs/Low_effectiveness_60_uniform", "_states.csv"]), Tables.table(data_state))












#Low effectiveness


X0 = initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work2,
        parameters.sigma_asym[1]) # state varabibles S P F I_pre I_asym I_mild D R

n = 8 #
q = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65
βs = distancing_senarios.constant_beta03_alpha04_40 # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
D_exp = parameters.D_exp # duration of exposed phase
D_pre = parameters.D_pre # duration of presymptomatic phase
D_asym = parameters.D_asym # duration of asymptomatic phase
D_sym = parameters.D_sym # duration of symptomatic phase
asym_rate = parameters.asym_rate_work # asymptomatic rate
Suceptability = parameters.suceptability_work1 # reletive suceptibility to infection
IFR = parameters.IFR_work # infection fataity rates
vaccine_eff = parameters.vaccine_eff_work2 # effetiveness of the vaccine
T = 240
t_breaks = [1] # switch policy
num_steps = 1
bins = parameters.bins_04 # size of age classes
life_expect = parameters.life_expect_work # life expectancy for each age

params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
        Suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
        bins, life_expect)

v(t) = 0.1/30
data_state, data_vaccines, outcomes = simulations.simulate_data(params, parameters.bins_04)

CSV.write(join(["../data_outputs/Low effectiveness_uniform", "_outcomes.csv"]), Tables.table(hcat(outcomes, ["Infections","YLL","Deaths"])))
CSV.write(join(["../data_outputs/Low effectiveness_uniform", "_states.csv"]), Tables.table(data_state))













#schools open

X0 = initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta07_alpha04_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]) # state varabibles S P F I_pre I_asym I_mild D R

n = 8 #
q = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65
βs = distancing_senarios.constant_beta07_alpha04_40 # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
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

v(t) = 0.1/30
data_state, data_vaccines, outcomes = simulations.simulate_data(params, parameters.bins_04)

CSV.write(join(["../data_outputs/schools_open_uniform", "_outcomes.csv"]), Tables.table(hcat(outcomes, ["Infections","YLL","Deaths"])))
CSV.write(join(["../data_outputs/schools_open_uniform", "_states.csv"]), Tables.table(data_state))












# low supply
v(t) = 0.1/60
X0 = initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]) # state varabibles S P F I_pre I_asym I_mild D R

n = 8 #
q = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65
βs = distancing_senarios.constant_beta03_alpha04_40 # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
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

v(t) = 0.1/60
data_state, data_vaccines, outcomes = simulations.simulate_data(params, parameters.bins_04)

CSV.write(join(["../data_outputs/Low_supply_uniform", "_outcomes.csv"]), Tables.table(hcat(outcomes, ["Infections","YLL","Deaths"])))
CSV.write(join(["../data_outputs/Low_supply_uniform", "_states.csv"]), Tables.table(data_state))


v(t) = 0.1/30











# high contact rates
X0 = initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha05_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]) # state varabibles S P F I_pre I_asym I_mild D R

n = 8 #
q = R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65
βs = distancing_senarios.constant_beta03_alpha05_40 # function of time, cases and increment, returns updated incrment and (β_sym, β_asym, β_presym)
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

v(t) = 0.1/30
data_state, data_vaccines, outcomes = simulations.simulate_data(params, parameters.bins_04)

CSV.write(join(["../data_outputs/high_contacts_social_uniform", "_outcomes.csv"]), Tables.table(hcat(outcomes, ["Infections","YLL","Deaths"])))
CSV.write(join(["../data_outputs/high_contacts_social_uniform", "_states.csv"]), Tables.table(data_state))
















end
