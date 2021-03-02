"""
The code in this file run the optimizations for the "base scenario"
presentated in the main text. It also saves some key parameters that
are presented in the paper and its apendicies.
"""
module main_text

print("new!")


include("../code_model/parameters/distancing_senarios.jl")
include("../code_model/parameters/parameters.jl")
include("../code_model/parameters/R0.jl")
include("../code_model/parameters/initial_conditions.jl")
include("../code_model/dynamics/simulations.jl")

include("../model_runs/define_routines.jl")


using Random
using Tables
using CSV


#
# sampling parameters for dynamic opt

# These parameters for the optimizaiton differ from the setting used
# for the figures in the paper. this change was unintntional, but can be
# reveresed if required w/ githubs histry.
N_samples = [30000, 5000, 5000, 20000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,500,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1,]
N_iter = 11

N_iter_anealing = 25000
Random.seed!(20201119)
v(t) =  0.1/30
#full optimization
print("\n")
print("full opt")
define_routines.run_optimization(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta03_alpha04_40,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "../data_outputs/main_text_full",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)


# Age only
print("\n")
print("age only")
N_samples = [30000, 5000, 5000, 20000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,500,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1,]
N_iter = 11

N_iter_anealing = 25000

# N_samples = [10]
# N_out = [1]
# N_iter = 1

Random.seed!(101719)
define_routines.run_optimization_age_only(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta03_alpha04_40,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "../data_outputs/main_text_age_only",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)



# sampling parameters for static opt
N_samples = [10000, 5000, 5000, 5000, 2500, 2500, 5000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,500,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 11

# # test
# N_samples_static = [10]
# N_out_static = [1]
# N_iter_static = 1
Random.seed!(10101565)
# static
print("\n")
print("static")
define_routines.run_optimization_static(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta03_alpha04_40,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "../data_outputs/main_text_static",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)





 ### this code save some key parameter values to use as a counter factual.
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

v(t) = 0.1/30
data_state, data_vaccines, outcomes = simulations.simulate_data(params, parameters.bins_04)

CSV.write(join(["../data_outputs/main_text_uniform", "_outcomes.csv"]), Tables.table(hcat(outcomes, ["Infections","YLL","Deaths"])))
CSV.write(join(["../data_outputs/main_text_uniform", "_states.csv"]), Tables.table(data_state))


v(t) = 0.0

params = (X0, n, q, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
        Suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
        bins, life_expect)


data_state, data_vaccines, outcomes = simulations.simulate_data(params, 0 * parameters.bins_04)

CSV.write(join(["../data_outputs/main_text_no_vaccine", "_outcomes.csv"]), Tables.table(hcat(outcomes, ["Infections","YLL","Deaths"])))
CSV.write(join(["../data_outputs/main_text_no_vaccine", "_states.csv"]), Tables.table(data_state))


#print base contact matrix

contacts = distancing_senarios.constant_beta03_alpha04_40(1, 0.000001, 1)
CSV.write(join(["../data_outputs/contact_matrix_main", ".csv"]), Tables.table(contacts[1]))



### initial deaths
# calcualte initial deaths

X = initial_conditions.calc_IC(0.90,0.005,0.08,
    parameters.bins_04 ,
    8,
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
    distancing_senarios.constant_beta03_alpha04_40,
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    parameters.sigma_asym[1])
n = 8
R = X[(8*n+1):(9*n)]
D = parameters.IFR_work.*R
print(D)
CSV.write("../data_outputs/inital_deaths.csv", Tables.table(hcat(D)))

X = initial_conditions.calc_IC(0.90,0.005,0.08,
    parameters.bins_04 ,
    8,
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
    distancing_senarios.constant_beta03_alpha04_40,
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    parameters.sigma_asym[1])
n = 8
I = X[(5*n+1):(6*n)]
D = parameters.IFR_work.*I
print(D)
CSV.write("../data_outputs/inital_deaths_cal2.csv", Tables.table(hcat(D)))


end
