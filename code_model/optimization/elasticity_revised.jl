"""
this module contians functions the find the values for the wiskers
in figure 2 of the paper.
"""
module elasticity_revised


using Plots
using Measures
using CSV
using Tables
using DataFrames


include("../parameters/parameters.jl")
include("../dynamics/simulations.jl")
include("../dynamics/simulations_static.jl")
include("../dynamics/simulations_age_only.jl")
include("../optimization/optimization_2.jl")
include("../parameters/distancing_senarios.jl")
include("../parameters/R0.jl")
include("../parameters/initial_conditions.jl")
include("../optimization/simulated_anealing.jl")


# load ranges

# if within 1% of bound stop

# if in first 3 decision periods check and increase of 4%

# check bound: if true return as new limit

# use linear search (golden search) to find break point
"""
bisection(f,min,max,start,tol)

this function uses Bisection to find the cuttoff point for the
error bar.

f - a function that takes a vlue in [min,max] and return true or false
min - the minimium value to search
max - the maximum value to search
start - start at the min or max value
tol - desirered tolerance fro the computation
"""
function bisection(f, min, max, start, tol)
    if start == "min"
        if f(min)
            return min
        else

            save = max
            while (max - min) > (2 * tol)


                val = (max + min)/2

                print("\n")
                print(val)
                t = f(val)
                if t
                    save = val
                    max = val
                else
                    min = val
                end

            end
        end
        print("\n")
        print("\n")
        print((max + min)/2)
        return (max + min)/2
    end

    if start == "max"
        if f(max)
            return max
        else

            save = min
            while (max - min) > (2 * tol)
                val = (max + min)/2
                t = f(val)
                if t
                    save = val
                    min = val
                else
                    max = val
                end

            end
        end
        print("\n")
        print("\n")
        print((max + min)/2)
        return (max + min)/2
    end

end





"""
get_indecies

this function takes a position on a policy vetor and returns the indcies needed
to run the fixed point optimizaiton algorithms
"""
function get_indecies(ind, n_groups, n_steps)

    @assert ind in 1:(n_groups*n_steps)

    r = floor(Int,mod(ind, n_groups))
    if r == 0
        r = n_groups
    end

    q = floor(Int,(ind- r)/n_groups)



    fixed_step_index = q + 1
    fixed_group_index = r
    variable_step_index = 1:n_steps
    variable_step_index = variable_step_index[variable_step_index .!= fixed_step_index]

    variable_group_index = 1:n_groups
    variable_group_index = variable_group_index[variable_group_index .!= fixed_group_index]

    return fixed_step_index, fixed_group_index, variable_step_index, variable_group_index
end




"""
error_bar_search

this function
"""
function error_bar_search(
    #### defined value for error bar ####
    reference_val, # value at optimum
    tolerance, # allowed deviatin from toloerance
    min_or_max, # lower bound or upper bound for wisker
    initial_value, # initial value to start search
    index, # index of parameter for errorbar
    n_groups,# number of groups
    n_steps, # number of time steps

    #### parameters for optimization ####
    ### sea run_opts_2.jl for details
    objective,
    q0,
    θ,
    βs,
    IC,
    suceptability,
    vaccine_eff,
    v,
    bins,
    fn,
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma)


    ### get indexs
    fixed_step_index, fixed_group_index, variable_step_index, variable_group_index = get_indecies(index, n_groups, n_steps)

    print("\n")
    print("\n")
    print(variable_step_index)
    print("\n")
    print("\n")
    print(variable_group_index)

    # run algorithm for upper bounds
    if min_or_max == "max"

        if initial_value > 0.99
            return 0.995
        end

        if fixed_step_index < 4

            # check 2% greater than initial value
            fixed_value = initial_value + 0.02*initial_value

            # compute optimal value given fixed value
            val = run_opts_2.run_fixed_value(
                objective,
                n_groups, n_steps, fixed_step_index,fixed_group_index,
                fixed_value, variable_step_index, variable_group_index,

                q0, θ, βs, IC, suceptability, vaccine_eff,
                v, bins, fn, N_samples,  N_out, N_iter,
                concentration,
                SA_iter,
                SA_sigma
            )

            # check if value is within the tolerance
            if val > reference_val + tolerance
                # if value is not with in the tolerance return initial value plus 1%
                return fixed_value = initial_value + 0.01*initial_value
            else

                # define function that checks if the value of
                f = x -> run_opts_2.run_fixed_value(
                    objective,
                    n_groups, n_steps, fixed_step_index,fixed_group_index,
                    x, variable_step_index, variable_group_index,

                    q0, θ, βs, IC, suceptability, vaccine_eff,
                    v, bins, fn, N_samples,  N_out, N_iter,
                    concentration,
                    SA_iter,
                    SA_sigma
                )

                g = x -> f(x)<((1+tolerance)*reference_val)

                # define minimum and maximum value to check
                min = fixed_value

                max = 0.99

                # run bisection to find optimal bound
                return bisection(g, min, max, "max",  0.01)
            end


        else # if index not in first 3 periods go directly to bisection

            fixed_value = initial_value

            # define function that checks if the value of
            f = x -> run_opts_2.run_fixed_value(
                objective,
                n_groups, n_steps, fixed_step_index,fixed_group_index,
                x, variable_step_index, variable_group_index,

                q0, θ, βs, IC, suceptability, vaccine_eff,
                v, bins, fn, N_samples,  N_out, N_iter,
                concentration,
                SA_iter,
                SA_sigma
            )

            g = x -> f(x)<((1+tolerance)*reference_val)

            # define minimum and maximum value to check
            min = fixed_value

            max = 0.99

            # run bisection to find optimal bound
            return bisection(g, min, max, "max",  0.01)

        end

    else

        if initial_value < 0.01
            return 0.0005
        end

        # set fixed value to initial value
        fixed_value = initial_value
        if fixed_step_index < 4 # if in the firs 3 periods check an adjacent point

            # check 2% greater than initial value
            fixed_value = initial_value - 0.02*initial_value

            # compute optimal value given fixed value
            print(fixed_step_index)
            print("\n")
            val = run_opts_2.run_fixed_value(
                objective,
                n_groups, n_steps, fixed_step_index,fixed_group_index,
                fixed_value, variable_step_index, variable_group_index,

                q0, θ, βs, IC, suceptability, vaccine_eff,
                v, bins, fn, N_samples,  N_out, N_iter,
                concentration,
                SA_iter,
                SA_sigma
            )

            # check if value is within the tolerance
            if val > reference_val + tolerance
                # if value is not with in the tolerance return initial value plus 1%
                return fixed_value = initial_value - 0.01*initial_value
            else # if the value is not adjacent use bisection

                # define function that checks if the value of
                f = x -> run_opts_2.run_fixed_value(
                    objective,
                    n_groups, n_steps, fixed_step_index,fixed_group_index,
                    x, variable_step_index, variable_group_index,

                    q0, θ, βs, IC, suceptability, vaccine_eff,
                    v, bins, fn, N_samples,  N_out, N_iter,
                    concentration,
                    SA_iter,
                    SA_sigma
                )

                g = x -> f(x)<((1+tolerance)*reference_val)

                # define minimum and maximum value to check
                max = fixed_value

                min = 0.01


                # run bisection to find optimal bound
                return bisection(g, min, max, "min",  0.01)
            end

        else # if index not in first 3 periods go directly to bisection

            # define function that checks if the value of
            f = x -> run_opts_2.run_fixed_value(
                objective,
                n_groups, n_steps, fixed_step_index,fixed_group_index,
                x, variable_step_index, variable_group_index,

                q0, θ, βs, IC, suceptability, vaccine_eff,
                v, bins, fn, N_samples,  N_out, N_iter,
                concentration,
                SA_iter,
                SA_sigma
            )

            g = x -> f(x)<((1+tolerance)*reference_val)

            # define minimum and maximum value to check
            max = fixed_value

            min = 0.01

            # run bisection to find optimal bound
            return bisection(g, min, max, "min", 0.01)
        end
    end

end





function error_bar_search_full_policy(
    #### manage files ####
    file_in, # e.g. "data_outputs/main_text_full_0.0025_bounds.csv"
    file_out, # e.g. "data_outputs/main_text_full_0.0025_bounds_refined.csv"
    over_write,

    #### defined value for error bar ####
    objective,
    reference_val, # value at optimum
    tolerance, # allowed deviatin from toloerance
    min_or_max, # lower bound or upper bound for wisker
    initial_value, # initial value to start search
    index, # index of parameter for errorbar
    n_groups,# number of groups
    n_steps, # number of time steps

    #### parameters for optimization ####
    ### sea run_opts_2.jl for details
    q0,
    θ,
    βs,
    IC,
    suceptability,
    vaccine_eff,
    v,
    bins,
    fn,
    N_samples, # population size
    N_out,
    N_iter,
    concentration,
    SA_iter,
    SA_sigma)


    # # load data
    # sol = DataFrame!(CSV.File(file_in))
    # if over_write
    #     # if over writing do nothing
    # else
    #     # add column to indicate if a row is been modified
    #     sol = hcat(sol, zeros(3*n_groups*n_steps))
    #     rename!(sol, :x1 => :refined_min)
    #     sol = hcat(sol, zeros(3*n_groups*n_steps))
    #     rename!(sol, :x1 => :refined_max)
    # end



    j = 0
    for i in index
        print("\n")
        print("\n")
        print(i)
        # counter
        j += 1

        # indicate value has been change


        new_val = error_bar_search(
            #### defined value for error bar ####
            reference_val, # value at optimum
            tolerance, # allowed deviatin from toloerance
            min_or_max, # lower bound or upper bound for wisker
            initial_value[i], # initial value to start search
            i, # index of parameter for errorbar
            n_groups,# number of groups
            n_steps, # number of time steps

            #### parameters for optimization ####
            ### sea run_opts_2.jl for details
            objective,
            q0,
            θ,
            βs,
            IC,
            suceptability,
            vaccine_eff,
            v,
            bins,
            fn,
            N_samples, # population size
            N_out,
            N_iter,
            concentration,
            SA_iter,
            SA_sigma)


        # write data to file

        sol = DataFrame!(CSV.File(file_in))
        if over_write
            # if over writing do nothing
        elseif j == 1
            # add column to indicate if a row is been modified
            sol = hcat(sol, zeros(3*n_groups*n_steps))
            rename!(sol, :x1 => :refined_min)
            sol = hcat(sol, zeros(3*n_groups*n_steps))
            rename!(sol, :x1 => :refined_max)
        else
            sol = DataFrame!(CSV.File(file_out))
            # after iteration 1 start over writing
        end

        if min_or_max == "max"
            print("here: max")
            sol.refined_max[(sol.Column49 .== objective) .& (sol.index .== i)] .= 1
        else
            print("here: min")
            sol.refined_min[(sol.Column49 .== objective) .& (sol.index .== i)] .= 1
        end

        if min_or_max == "min"
            sol.min[(sol.Column49 .== objective) .& (sol.index .== i)] .= new_val
        else
            sol.max[(sol.Column49 .== objective) .& (sol.index .== i)] .= new_val
        end


        # write data to file after first
        CSV.write(file_out, sol)

    end



end





#### tests ####

function f(val)
    return val < 0.92
end

function test_search()
    bisection(f, 0.5, 1.0, "max", 0.05)
end




function test_get_indecies()
    print(get_indecies(25, 8, 6))
end







end
