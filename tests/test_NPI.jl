module test_NPI

include("distancing_senarios.jl")
include("parameters.jl")
include("R0.jl")
include("initial_conditions.jl")
include("elasticity.jl")
include("run_opts.jl")

# vaccine supply

using Random
Random.seed!(20201119)
v(t) =  0.1/30
run_opts.run_optimization(
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.5,
    distancing_senarios.constant_beta01_alpha03_40_0509,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.5,
        distancing_senarios.constant_beta01_alpha03_40_0509,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]),
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    "data_outputs/test",

)

elasticity.generate_range(
    "data_outputs/test_policies.csv", # path to file with solution
    0.0025, # level of tolerance for accepted solutions
    0.005, # varaince of proposal distribtion
    1000, # number of itterations per chain
    10, # number of chains
    10000, # maximum number of iterations before cahin is broken
    R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
    0.65, # NPI
    distancing_senarios.constant_beta01_alpha04_40,
    initial_conditions.calc_IC(0.90,0.005,0.08,
        parameters.bins_04 ,
        8,
        R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.65,
        distancing_senarios.constant_beta01_alpha03_40,
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        parameters.sigma_asym[1]), # initial conditions
    parameters.suceptability_work1,
    parameters.vaccine_eff_work1,
    v,
    parameters.bins_04,
    ["data_outputs/test_policies.csv",
     "data_outputs/test_samples_policies.csv"]
)



end
