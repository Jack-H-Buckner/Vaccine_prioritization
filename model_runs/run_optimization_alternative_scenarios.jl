"""
run optimization for scenario presented in detail in main test
"""
module alternative_scenarios

using Random

include("../code_model/parameters/distancing_senarios.jl")
include("../code_model/parameters/parameters.jl")
include("../code_model/parameters/R0.jl")
include("../code_model/parameters/initial_conditions.jl")
include("../code_model/dynamics/simulations.jl")

include("define_routines.jl")
include("define_routines_supply.jl")

# Using fewer samples because only the low elasticity region is presented
N_samples = [30000, 5000, 5000, 20000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,500,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1,]
N_iter = 11

N_iter_anealing = 25000

# vaccine supply
v(t) =  0.1/30

# weak NPI
print("\n")
print("Weak NPI")
define_routines.run_optimization(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.75,
    distancing_senarios.constant_beta03_alpha04_40,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.75,
        distancing_senarios.constant_beta03_alpha04_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "../data_outputs/weak_NPI",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)
#
#
#
# # strong NPI
# N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
# N_out = [1000,500,500,250,500,250,500,100,100,100,100]
# concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
# N_iter = 11
Random.seed!(171)
# N_iter_anealing = 20000
print("\n")
print("Strong NPI")
define_routines.run_optimization(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.5,
    distancing_senarios.constant_beta01_alpha03_40,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.5,
        distancing_senarios.constant_beta01_alpha03_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "../data_outputs/strong_NPI",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)
#
#
#

# high initial infecitons
# N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
# N_out = [1000,500,500,250,500,250,500,100,100,100,100]
# concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
# N_iter = 11
Random.seed!(991118541)
# N_iter_anealing = 20000
print("\n")
print("high_initial_infections")
define_routines.run_optimization(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta03_alpha04_40,
    initial_conditions.calc_IC(0.90,0.015,0.08,
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
    "../data_outputs/high_initial_infections",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)
#
#
# # high sucept children
# print("\n")
# print("high_sucept_children")
# N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
# N_out = [1000,500,500,250,500,250,500,100,100,100,100]
# concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
# N_iter = 11
Random.seed!(10411111111100)
# N_iter_anealing = 20000
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
    parameters.suceptability_work3,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "../data_outputs/high_sucept_children",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)


#
# #Low effectiveness 60+
# print("\n")
# print("Low_effectiveness_60")
# N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
# N_out = [1000,500,500,250,500,250,500,100,100,100,100]
# concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
# N_iter = 11
Random.seed!(110198101999997)
# N_iter_anealing = 20000
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
    parameters.vaccine_eff_work3,
    v,
    parameters.bins_04,
    "../data_outputs/Low_effectiveness_60",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)
#
#
#
# # Low effectiveness
# print("\n")
# print("Low_effectiveness")
# N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
# N_out = [1000,500,500,250,500,250,500,100,100,100,100]
# concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
# N_iter = 11
Random.seed!(995454)
# N_iter_anealing = 20000
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
    parameters.vaccine_eff_work2,
    v,
    parameters.bins_04,
    "../data_outputs/Low_effectiveness",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)



# # schools open
# print("\n")
# print("schools open")
# N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
# N_out = [1000,500,500,250,500,250,500,100,100,100,100]
# concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
# N_iter = 11
Random.seed!(925112019)
# N_iter_anealing = 20000
define_routines.run_optimization(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta07_alpha04_40,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta07_alpha04_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "../data_outputs/schools_open",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)
#
#
#
#
#
#
## low supply
# print("\n")
# print("low_supply")
# N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
# N_out = [1000,500,500,250,500,250,500,100,100,100,100]
# concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
# N_iter = 11
Random.seed!(608201118)
# N_iter_anealing = 20000
define_routines.run_optimization_supply(
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
    60,
    parameters.bins_04,
    "../data_outputs/low_supply",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)

#
# # high social/other contacts
# print("\n")
# print("high social/other contact rate")
# N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
# N_out = [1000,500,500,250,500,250,500,100,100,100,100]
# concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
# N_iter = 11
Random.seed!(101141996)
# N_iter_anealing = 20000
define_routines.run_optimization(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta03_alpha05_40,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha05_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "../data_outputs/high_contacts_social",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)




# vaccine supply
v(t) =  0.1/30
#
# weak NPI
print("\n")
print("Weak NPI")
 Random.seed!(141996)
 # N_iter_anealing = 20000
define_routines.run_optimization_rampup(
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
    60,
    30,
    1,
    parameters.bins_04,
    "../data_outputs/Ramp_up",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)

end
