module test_policies_static



using Plots
using Measures
using CSV
using Tables
using DataFrames

include("../code_model/parameters/distancing_senarios.jl")
include("../code_model/parameters/parameters.jl")
include("../code_model/parameters/R0.jl")
include("../code_model/parameters/initial_conditions.jl")
include("../code_model/dynamics/simulations.jl")



function get_outcomes(policy_path, params)

    # load fixed parameters
    D_exp = parameters.D_exp # duration of exposed phase
    D_pre = parameters.D_pre # duration of presymptomatic phase
    D_asym = parameters.D_asym # duration of asymptomatic phase
    D_sym = parameters.D_sym # duration of symptomatic phase
    asym_rate = parameters.asym_rate_work # proportion os asymptomatic cases


    IFR = parameters.IFR_work # infection fataity rates
    life_expect = parameters.life_expect_work # life expectancy

    n = 8


    # load varaible params

    q, θ, βs, X0, suceptability, vaccine_eff, days_10, bins, t_breaks, T, v = params


    # t_breaks = [1] # high availability
    num_steps = 1
    # T = days_10 * 8
    # v(t) = 0.1/days_10


    params = (X0, n, q*θ, βs, D_pre, D_asym, D_sym, D_exp, asym_rate,
            suceptability, IFR, vaccine_eff, v, T, t_breaks, num_steps,
            bins, life_expect)

    sol = DataFrame!(CSV.File(policy_path))

    mu_infections = sol.Column1
    mu_YLL = sol.Column2
    mu_deaths = sol.Column3

    data_states, data_states, outcomes_infections = simulations.simulate_data(params, mu_infections)
    data_states, data_states, outcomes_YLL = simulations.simulate_data(params, mu_YLL)
    data_states, data_states, outcomes_deaths = simulations.simulate_data(params, mu_deaths)

    return outcomes_infections[1], outcomes_YLL[2], outcomes_deaths[3]

end # outcomes

v(t) = 0.1/30
# tests
policy_path_main_text = "../data_outputs/main_text_static_policies.csv"
params_main_text =  (R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
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
        30,
    parameters.bins_04,
    [1],
    240,
    v
)

# print tese to check against value form optimizaiton
# to insure the params are correct
# print(get_outcomes(policy_path_main_text, params_main_text))
# print("\n")
#
# # tests
policy_path_weak_NPI = "../data_outputs/static_weak_NPI_policies.csv"
params_weak_NPI =  (R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
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
    30,
    parameters.bins_04,
    [1],
    240,
    v
)

# print tese to check against value form optimizaiton
# to insure the params are correct
print(get_outcomes(policy_path_weak_NPI, params_weak_NPI))
print("\n")
#
# tests
policy_path_strong_NPI = "../data_outputs/static_strong_NPI_policies.csv"
params_strong_NPI =  (R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
        0.5,
        distancing_senarios.constant_beta03_alpha04_40,
        initial_conditions.calc_IC(0.90,0.005,0.08,
            parameters.bins_04 ,
            8,
            R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1]*0.5,
            distancing_senarios.constant_beta03_alpha04_40,
            parameters.suceptability_work1,
            parameters.vaccine_eff_work1,
            parameters.sigma_asym[1]),
        parameters.suceptability_work1,
        parameters.vaccine_eff_work1,
        30,
        parameters.bins_04,
        [1],
        240,
        v)

# print tese to check against value form optimizaiton
# to insure the params are correct
print(get_outcomes(policy_path_strong_NPI, params_strong_NPI))
print("\n")

# tests
policy_path_high_init_infections = "../data_outputs/static_high_initial_infections_policies.csv"
params_high_init_infections =  (R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
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
        30,
        parameters.bins_04,
        [1],
        240,
        v)

# print tese to check against value form optimizaiton
# to insure the params are correct
print(get_outcomes(policy_path_high_init_infections, params_high_init_infections))
print("\n")



# tests
policy_path_high_sucept_children = "../data_outputs/static_high_sucept_children_policies.csv"
params_high_sucept_children =  (R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
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
        30,
        parameters.bins_04,
        [1],
        240,
        v)

# print tese to check against value form optimizaiton
# to insure the params are correct
print(get_outcomes(policy_path_high_sucept_children, params_high_sucept_children))
print("\n")


# tests
policy_path_low_effectiveness_60 = "../data_outputs/static_Low_effectiveness_60_policies.csv"
params_low_effectiveness_60 =  (R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
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
        30,
        parameters.bins_04,
        [1],
        240,
        v)

# print tese to check against value form optimizaiton
# to insure the params are correct
print(get_outcomes(policy_path_low_effectiveness_60, params_low_effectiveness_60))
print("\n")


# tests
policy_path_Low_effectiveness = "../data_outputs/static_Low_effectiveness_policies.csv"
params_Low_effectiveness =  (R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
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
    30,
    parameters.bins_04,
    [1],
    240,
    v)

# print tese to check against value form optimizaiton
# to insure the params are correct
print(get_outcomes(policy_path_Low_effectiveness, params_Low_effectiveness))
print("\n")


# tests
policy_path_schools_open = "../data_outputs/static_schools_open_policies.csv"
params_schools_open =  (R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
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
        30,
        parameters.bins_04,
        [1],
        240,
        v)

# print tese to check against value form optimizaiton
# to insure the params are correct
print(get_outcomes(policy_path_schools_open, params_schools_open))
print("\n")




# tests
policy_path_low_supply = "../data_outputs/static_low_supply_policies.csv"
params_low_supply =  (R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
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
        60,
        parameters.bins_04,
        [1],
        240,
        x->0.1/60)

# print tese to check against value form optimizaiton
# to insure the params are correct
print(get_outcomes(policy_path_low_supply, params_low_supply))
print("\n")




# tests
policy_path_high_contacts_social = "../data_outputs/static_high_contacts_social_policies.csv"
params_high_contacts_social =  (R0.solve_R_40(parameters.R_0, parameters.suceptability_work1).zero[1],
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
        30,
        parameters.bins_04,
        [1],
        240,
        v)


# print tese to check against value form optimizaiton
# to insure the params are correct
print(get_outcomes(policy_path_high_contacts_social, params_high_contacts_social))
print("\n")
function v2(t)
    if t < 60
        return 0.1/60
    else
        return 0.15/30
    end

end
# tests
policy_ramp_up = "../data_outputs/static_Ramp_up_policies.csv"
params_ramp_up =  (
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
        30,
        parameters.bins_04,
        [1],
        240,
        v2)


# print tese to check against value form optimizaiton
# to insure the params are correct
print(get_outcomes(policy_path_high_contacts_social, params_high_contacts_social))
print("\n")

Policy_names = (
    "Base scenario",
    "Weak NPI",
    "Strong NPI",
    "High init. infects.",
    "High sucept. ages < 20",
    "Low V eff. ages > 60",
    "Low eff",
    "Schools open",
    "Low supply",
    "High contacts",
    "Ramp up"
)


params = Dict(
    "Base scenario" => params_main_text,
    "Weak NPI" => params_weak_NPI,
    "Strong NPI" => params_strong_NPI,
    "High init. infects." => params_high_init_infections,
    "High sucept. ages < 20" => params_high_sucept_children,
    "Low V eff. ages > 60" => params_low_effectiveness_60,
    "Low eff" => params_Low_effectiveness,
    "Schools open" => params_schools_open,
    "Low supply" => params_low_supply,
    "High contacts" => params_high_contacts_social,
    "Ramp up" => params_ramp_up
)

paths = (
    policy_path_main_text,
    policy_path_weak_NPI,
    policy_path_strong_NPI,
    policy_path_high_init_infections,
    policy_path_high_sucept_children,
    policy_path_low_effectiveness_60,
    policy_path_Low_effectiveness,
    policy_path_schools_open,
    policy_path_low_supply,
    policy_path_high_contacts_social,
    policy_ramp_up
)


function make_comparisions(Policy_names, params, paths)

    acc = DataFrame(Policy = ["left blank"], Params = ["left blank"], outcomes = ["left blank"],value = [-9999.99])

    l = length(Policy_names)
    for i in 1:l
        for j in 1:l
            infections, YLL, deaths = get_outcomes(paths[i], params[Policy_names[j]])
            row_1 = DataFrame(Policy = [Policy_names[i]], Params = [Policy_names[j]], outcomes = ["Infecitons"],value = [infections])
            row_2 = DataFrame(Policy = [Policy_names[i]], Params = [Policy_names[j]], outcomes = ["YLL"],value = [YLL])
            row_3 = DataFrame(Policy = [Policy_names[i]], Params = [Policy_names[j]], outcomes = ["Deaths"],value = [deaths])
            append!(acc, row_1)
            append!(acc, row_2)
            append!(acc, row_3)
        end
    end
    return acc
end

CSV.write("../data_outputs/static_comparison_data.csv", make_comparisions(Policy_names, params, paths))



end # module
