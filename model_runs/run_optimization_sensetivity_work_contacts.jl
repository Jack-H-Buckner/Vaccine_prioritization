module work_contacts

using Random
using Tables
using CSV

include("../code_model/parameters/distancing_senarios.jl")
include("../code_model/parameters/parameters.jl")
include("../code_model/parameters/R0.jl")
include("../code_model/parameters/initial_conditions.jl")
include("../code_model/dynamics/simulations.jl")

include("define_routines.jl")
include("define_routines_supply.jl")
Random.seed!(3201961)


# sampling parameters for dynamic opt
N_samples = [20000, 5000, 5000, 10000, 2500, 2500, 10000, 1000, 1000, 1000, 1000]
N_out = [1000,500,500,250,500,250,500,100,100,100,100]
concentration = [0.01,0.01,0.01,0.05,0.05,0.1,0.2,0.2,1,1,1]
N_iter = 11

N_iter_anealing = 20000
v(t) =  0.1/30
# full optimization
print("\n")
print("full opt")
define_routines.run_optimization(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta03_alpha04_40_0304,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40_0304,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "data_outputs/work_contacts_0304",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)

Random.seed!(32961)
define_routines.run_optimization(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta03_alpha04_40_0407,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40_0407,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "data_outputs/work_contacts_0407",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)


Random.seed!(3)
define_routines.run_optimization(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta03_alpha04_40_0509,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40_0509,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "data_outputs/work_contacts_0509",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)


Random.seed!(112358)
define_routines.run_optimization(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65,
    distancing_senarios.constant_beta03_alpha04_40_0611,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta03_alpha04_40_0611,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "data_outputs/work_contacts_0611",
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    N_iter_anealing
)

end  # module
