"""
This Module loads all of the parameters from the
data_inputs and data_transformed files for use in the model
There are too many parameters to list here but the function of
each one is documented below.
"""
module parameters



using CSV
using DataFrames
# ****************** #
# global parameters
# ****************** #

# mild, presym, asym


# load the data frame of all the hard coded parameters
pop_df = DataFrame!(CSV.File("../data_transformed/population.csv"))
df = DataFrame!(CSV.File("../data_inputs/hard_coded_parameters.csv"))
IFR_age  = DataFrame!(CSV.File("../data_transformed/IFR.csv"))
IFR_age = IFR_age.IFR

sigma_asym = [0.16] # the rate of asymptomatic infection

life_expect_age  = DataFrame!(CSV.File("../data_transformed/life_expectancy.csv"))

life_expect_age = life_expect_age.life_expectancy # The expected year of life for each age group in the absence of COVID 19

# load the reletive transmission rates between symptom types
t_sym = df[(df.parameter .== "t_sym") .& (df.alternative .== 0), :].value[1]
t_asym = df[(df.parameter .== "t_asym") .& (df.alternative .== 0), :].value[1]
t_pre = df[(df.parameter .== "t_pre") .& (df.alternative .== 0), :].value[1]

# load values into a vector
transmisivity = [t_sym, t_asym, t_pre] # Abrams et al / Li et al


# load value of R0
R_0 = df[(df.parameter .== "R0") .& (df.alternative .== 0), :].value[1]

# load NPI levels
θ = df[(df.parameter .== "theta") .& (df.alternative .== 0), :].value[1]
θ_1 = df[(df.parameter .== "theta") .& (df.alternative .== 1), :].value[1]

# num ages

# load number of demographic groups n - age only m - essential workers
n = df[(df.parameter .== "n") .& (df.alternative .== 0), :].value[1]
n = Int(n)

m = df[(df.parameter .== "m") .& (df.alternative .== 0), :].value[1]
m = Int(m)

# load incubaiton/ recovery time
# all from Abrams and thier citations D_sym is unique to our model because we aggregate severe
# and mild symptomatic cases so not certian what to do here
D_exp = df[(df.parameter .== "D_exp") .& (df.alternative .== 0), :].value[1]
D_pre = df[(df.parameter .== "D_pre") .& (df.alternative .== 0), :].value[1]
D_asym = df[(df.parameter .== "D_asym") .& (df.alternative .== 0), :].value[1]
D_sym = df[(df.parameter .== "D_sym") .& (df.alternative .== 0), :].value[1]
 # this is generally based on Abrams et al estimates but is modified to account for a mix of mild and sever cases


# ******************************************* #
#  parameters for the essentail worker model
# ******************************************* #


# load the proporiton of essential workers from hard coded params
P_ess = df[(df.parameter .== "p") .& (df.alternative .== 0), :].value[1]
P_work = df[(df.parameter .== "p_work") .& (df.alternative .== 0), :].value[1]


# work scaling -  not used
#alpha_work = df[(df.parameter .== "alpha_work") .& (df.alternative .== 0), :].value[1]

# not used currently calcualtes the amount of sicial distancing in the work place
# if essential workers and nonessential workers are aggregated
#scaling = P_ess/P_work + alpha_work/P_work * (P_work - P_ess)


# get age bin sizes

bins_02 = pop_df[(pop_df.model .== "essential_worker") .& (pop_df.ess_size .== 0.2),:].size
bins_02 = bins_02 ./sum(bins_02 )


bins_04 = pop_df[(pop_df.model .== "essential_worker") .& (pop_df.ess_size .== 0.4),:].size
bins_04 = bins_04 ./sum(bins_04 )



# define susceptibles for essential worker age model
suceptability_work1 = [0.5, 0.5, 1, 1, 1, 1, 1, 1] # lower suceptability of YO < 20 (Davies et al.)
suceptability_work2 = [0.34, 0.40, 1, 1, 1, 1, 1, 1]
suceptability_work3 = [1.0, 1.0, 1, 1, 1, 1, 1, 1]
suceptability_test = [0.0, 0.0, 1, 1, 1, 1, 1, 1]
suceptability_work02 = [0.2, 0.2, 1, 1, 1, 1, 1, 1]
suceptability_work03 = [0.3, 0.3, 1, 1, 1, 1, 1, 1]
suceptability_work04 = [0.4, 0.4, 1, 1, 1, 1, 1, 1]
suceptability_work05 = [0.5, 0.5, 1, 1, 1, 1, 1, 1]
suceptability_work06 = [0.6, 0.6, 1, 1, 1, 1, 1, 1]
suceptability_work07 = [0.7, 0.7, 1, 1, 1, 1, 1, 1]
suceptability_work08 = [0.8, 0.8, 1, 1, 1, 1, 1, 1]
suceptability_work09 = [0.9, 0.9, 1, 1, 1, 1, 1, 1]
suceptability_work10 = [1.0, 1.0, 1, 1, 1, 1, 1, 1]
# created vector from age specific IFR loaded previously
IFR_work = [IFR_age[1],IFR_age[2],IFR_age[3],IFR_age[3],IFR_age[4],IFR_age[4],IFR_age[5],IFR_age[6]]


# hard code the vaccine efficency

vaccine_eff_work1 = repeat([0.9],8)
vaccine_eff_work2 = repeat([0.5],8)
vaccine_eff_work3 = [0.9,0.9,0.9,0.9,0.9,0.9,0.5,0.5]
vaccine_eff_work4 = [0.65,0.65,0.65,0.65,0.65,0.65,0.45,0.45]
vaccine_eff_work5 = [0.65,0.65,0.65,0.65,0.65,0.65,0.35,0.35]
vaccine_eff_work6 = [0.65,0.65,0.65,0.65,0.65,0.65,0.25,0.25]
vaccine_eff_work7 = [0.65,0.65,0.65,0.65,0.65,0.65,0.15,0.15]
# symptomatic rate

# not used
asym_rate_work = repeat(sigma_asym, m) # conflictining informaiton here using Byambasuren et ak meta analysis

# hard code vector of life expectancy rates
life_expect_work = [life_expect_age[1], life_expect_age[2],life_expect_age[3],life_expect_age[3],life_expect_age[4],life_expect_age[4],life_expect_age[5],life_expect_age[6]]


# load contact matrices from r output 3 results check for symetry and plotted in figures folder
cnt_home_20 = DataFrame!(CSV.File("../data_transformed/contacts_home_base_20.csv"))
cnt_home_20 = convert(Matrix, cnt_home_20[:,(1:m).+1])

cnt_home_40 = DataFrame!(CSV.File("../data_transformed/contacts_home_base_40.csv"))
cnt_home_40 = convert(Matrix, cnt_home_40[:,(1:m).+1])



cnt_school_20 = DataFrame!(CSV.File("../data_transformed/contacts_school_base_20.csv"))
cnt_school_20 = convert(Matrix, cnt_school_20[:,(1:m).+1])

cnt_school_40 = DataFrame!(CSV.File("../data_transformed/contacts_school_base_40.csv"))
cnt_school_40 = convert(Matrix, cnt_school_40[:,(1:m).+1])



cnt_other_20 = DataFrame!(CSV.File("../data_transformed/contacts_other_base_20.csv"))
cnt_other_20 = convert(Matrix, cnt_other_20[:,(1:m).+1])

cnt_other_40 = DataFrame!(CSV.File("../data_transformed/contacts_other_base_40.csv"))
cnt_other_40 = convert(Matrix, cnt_other_40[:,(1:m).+1])





# work contact rates alternatives
cnt_work_20_0309 = DataFrame!(CSV.File("../data_transformed/contacts_work_base_20_0309.csv"))
cnt_work_20_0309 = convert(Matrix, cnt_work_20_0309[:,(1:m).+1])

cnt_work_20 = DataFrame!(CSV.File("../data_transformed/contacts_work_base_20.csv"))
cnt_work_20 = convert(Matrix, cnt_work_20[:,(1:m).+1])

cnt_work_20_0411 = DataFrame!(CSV.File("../data_transformed/contacts_work_base_20_0411.csv"))
cnt_work_20_0411 = convert(Matrix, cnt_work_20_0411[:,(1:m).+1])

cnt_work_20_05145 = DataFrame!(CSV.File("../data_transformed/contacts_work_base_20_05145.csv"))
cnt_work_20_05145 = convert(Matrix, cnt_work_20_05145[:,(1:m).+1])

cnt_work_20_06185 = DataFrame!(CSV.File("../data_transformed/contacts_work_base_20_06185.csv"))
cnt_work_20_06185 = convert(Matrix, cnt_work_20_06185[:,(1:m).+1])




cnt_work_40_0304 = DataFrame!(CSV.File("../data_transformed/contacts_work_base_40_0304.csv"))
cnt_work_40_0304 = convert(Matrix, cnt_work_40_0304[:,(1:m).+1])

cnt_work_40 = DataFrame!(CSV.File("../data_transformed/contacts_work_base_40.csv"))
cnt_work_40 = convert(Matrix, cnt_work_40[:,(1:m).+1])

cnt_work_40_0407 = DataFrame!(CSV.File("../data_transformed/contacts_work_base_40_0407.csv"))
cnt_work_40_0407 = convert(Matrix, cnt_work_40_0407[:,(1:m).+1])

cnt_work_40_0509 = DataFrame!(CSV.File("../data_transformed/contacts_work_base_40_0509.csv"))
cnt_work_40_0509 = convert(Matrix, cnt_work_40_0509[:,(1:m).+1])

cnt_work_40_0611 = DataFrame!(CSV.File("../data_transformed/contacts_work_base_40_0611.csv"))
cnt_work_40_0611 = convert(Matrix, cnt_work_40_0611[:,(1:m).+1])



# work for R0 calcl

cnt_work_20_R0 = DataFrame!(CSV.File("../data_transformed/contacts_work_base_20_R0.csv"))
cnt_work_20_R0 = convert(Matrix, cnt_work_20_R0[:,(1:m).+1])

cnt_work_40_R0 = DataFrame!(CSV.File("../data_transformed/contacts_work_base_40_R0.csv"))
cnt_work_40_R0 = convert(Matrix, cnt_work_40_R0[:,(1:m).+1])


# concentrated alternative model

cnt_work_20_cl = DataFrame!(CSV.File("../data_transformed/contacts_work_base_20_cl.csv"))
cnt_work_20_cl = convert(Matrix, cnt_work_20_cl[:,(1:m).+1])

cnt_work_40_cl = DataFrame!(CSV.File("../data_transformed/contacts_work_base_40_cl.csv"))
cnt_work_40_cl = convert(Matrix, cnt_work_40_cl[:,(1:m).+1])


# build total contacts of R0 calcualtion
cnt_total_20 = cnt_home_20 .+ cnt_work_20_R0 .+ cnt_school_20 .+ cnt_other_20
cnt_total_sym_20 = cnt_home_20 .+ 0.09 .* cnt_work_20_R0 .+ 0.09 .* cnt_school_20 .+ 0.25 .* cnt_other_20

cnt_total_40 = cnt_home_40 .+ cnt_work_40_R0 .+ cnt_school_40 .+ cnt_other_40
cnt_total_sym_40 = cnt_home_40 .+ 0.09 .* cnt_work_40_R0 .+ 0.09 .* cnt_school_40 .+ 0.25 .* cnt_other_40



# functions that create total matrices with socail distancing
function cnt_dist_20(work_matrix, beta, rho)
    cnt_home_20 .+  work_matrix .+ beta .* cnt_school_20 .+ rho .* cnt_other_20
end

function cnt_dist_40(work_matrix, beta, rho)
    cnt_home_40 .+  work_matrix .+ beta .* cnt_school_40 .+ rho .* cnt_other_40
end


function cnt_dist_sym_20(work_matrix, beta, rho)
    cnt_home_20 .+ 0.09 .* work_matrix .+ 0.09 .* beta .* cnt_school_20 .+ 0.25 .* rho .* cnt_other_20
end

function cnt_dist_sym_40(work_matrix, beta, rho)
    cnt_home_40 .+  0.09 .*work_matrix .+ 0.09 .* beta .* cnt_school_40 .+ 0.25 .* rho .* cnt_other_40
end

# ******************************* #
#  vaccine availaiblity senarios
# ******************************* #

v_high_constant(t) = 0.6/180

function v_rampup(t)
    if t < 90
        0.05/30 # 5% per month
    else
        0.15/30 # 15% per month
    end
end

v_low_constant(t) =  0.6/360
v_high_increasing(t) = t*1.2/180^2
v_low_increasing(t) = t*1.2/360^2


end
