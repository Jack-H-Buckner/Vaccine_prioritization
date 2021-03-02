"""
run optimization for scenario presented in detail in main test
"""
module alternative_scenarios_static

using Random

include("../code_model/parameters/distancing_senarios.jl")
include("../code_model/parameters/parameters.jl")
include("../code_model/parameters/R0.jl")
include("../code_model/parameters/initial_conditions.jl")
include("../code_model/dynamics/simulations.jl")

include("define_routines.jl")
include("define_routines_supply.jl")

# Using fewer samples because only the low elasticity region is presented
N_samples = [10000, 5000, 5000, 5000, 2500, 2500, 1000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,100,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 11
Random.seed!(13201961)


# vaccine supply
v(t) =  0.1/30
#
# weak NPI
print("\n")
print("Weak NPI")
#
define_routines.run_optimization_static(
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
    "../data_outputs/static_weak_NPI",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)



# # strong NPI
N_samples = [10000, 5000, 5000, 5000, 2500, 2500, 1000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,100,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 11
Random.seed!(171)
print("\n")
print("Strong NPI")
define_routines.run_optimization_static(
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
    "../data_outputs/static_strong_NPI",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)




# high initial infecitons
N_samples = [10000, 5000, 5000, 5000, 2500, 2500, 1000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,100,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 11
Random.seed!(991118541)
print("\n")
print("high_initial_infections")
define_routines.run_optimization_static(
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
    "../data_outputs/static_high_initial_infections",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)


# high sucept children
print("\n")
print("high_sucept_children")
N_samples = [10000, 5000, 5000, 5000, 2500, 2500, 1000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,100,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 11
Random.seed!(10411111111100)
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
    parameters.suceptability_work3,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "../data_outputs/static_high_sucept_children",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)



#Low effectiveness 60+
print("\n")
print("Low_effectiveness_60")
N_samples = [10000, 5000, 5000, 5000, 2500, 2500, 1000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,100,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 11
Random.seed!(110198101999997)
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
    parameters.vaccine_eff_work3,
    v,
    parameters.bins_04,
    "../data_outputs/static_Low_effectiveness_60",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)



# Low effectiveness
print("\n")
print("Low_effectiveness")
N_samples = [10000, 5000, 5000, 5000, 2500, 2500, 1000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,100,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 11
Random.seed!(995454)
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
    parameters.vaccine_eff_work2,
    v,
    parameters.bins_04,
    "../data_outputs/static_Low_effectiveness",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)

#
#
# schools open
print("\n")
print("schools open")
N_samples = [10000, 5000, 5000, 5000, 2500, 2500, 1000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,100,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 11
Random.seed!(925112019)
define_routines.run_optimization_static(
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
    "../data_outputs/static_schools_open",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)






# low supply
print("\n")
print("low_supply")
N_samples = [10000, 5000, 5000, 5000, 2500, 2500, 1000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,100,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 11
Random.seed!(608201118)
define_routines.run_optimization_static(
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
    x -> 0.1/60,
    parameters.bins_04,
    "../data_outputs/static_low_supply",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)


# high social/other contacts
print("\n")
print("high social/other contact rate")
N_samples = [10000, 5000, 5000, 5000, 2500, 2500, 1000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,100,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 11
Random.seed!(101141996)
define_routines.run_optimization_static(
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
    "../data_outputs/static_high_contacts_social",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)




# vaccine supply
function v(t)
    if t < 60
        return 0.1/60
    else
        return 0.15/30
    end

end
#
# weak NPI
print("\n")
print("Weak NPI")
 Random.seed!(141996)
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
    "../data_outputs/static_Ramp_up",
    N_samples, # population size
    N_out,
    N_iter,
    concentration
)

end
