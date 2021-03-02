"""
This file defines the genetic algorithm used to optimized the vaccine allocaiton
strategies.

this method samples policies 
"""
module optimization_2


using Distributions
using Optim
using ForwardDiff
using Plots
using IterTools
using LineSearches

"""
soft_plus(x)

This function transforms input values to remain on the positive real line.
The funciton asymthotically aproaches 0 for negative values and aproches
f(x) = x for positive values.
"""
soft_plus(x) = log(1+exp(x))





"""
update_alpha(n_steps,n, points, concentration, N_out)

This function takes that samples returned from the
previous generation and updated the parameter α used to
generate the next generation.

This is currently done calculating the mean value of the
samples and scaling them by a factor that is taken as a
parameter of the opimizaiton process.

future work shoudl imporve on this approach. The Dirichlet distribution
parameter α can be decomposed into two parts a vector on the sumples μ and a
conentration parameter 1/σ. It should be fairly easy to updated with function
to calcualte μ as is done here and then use maximum likelihood estimation to
find the parameter σ that best fits the selected samples. With this aproach the
variance of the samples will be tuned automatically, and allow for the variance
of samples to differ at each time step.
"""
function update_alpha(points,concentration, N_out)

    acc = points[:,1]
    for i in 2:N_out
        acc .+= points[:,i]
    end
    return concentration .* acc
end

"""
sample_f

This funtion samples N_samples new policies test them against for
and returns the N_out best policies.

f: the objective function
α: the parameters for the policy generating process
n_steps: the number of time steps
n: the number of groups
N_samples: the number of samples to test
N_out: the number of samples to select
"""
function sample_f(f, α, n_steps, n, N_samples, N_out)

    sample = zeros(n*n_steps, N_samples)

    for i in 1:n_steps
        d = Dirichlet(soft_plus.(α[(1 + (i-1)*n):(i * n)]))
        sample[(1 + (i-1)*n):(i * n),:] = rand(d, N_samples)
    end
    vals = mapslices(f, sample, dims = 1)

    max = zeros(n*n_steps, N_out)
    vals = transpose(vals)
    best = α
    value = 0
    for i in 1:N_out
        ind = argmax(vals)
        val = vals[ind]
        vals[ind] = -10000000
        if i == 1
            best = sample[:,ind]
            value = val
        end

        max[:,i] = sample[:,ind]
    end
    return max, best, value
end


"""
maximize

This function maximizes the objective function f using
a genetic algorithm.

f: function - the objective function
α0: vector of floats - the initial paramters for the policy generation process
n_steps: int - number of time steps
N_samples: vector of ints - the number of samples each iteration
N_out: vector of ints - the number of samples saved each iteration
N_iter: int -  the number of iterations to run.
"""
function maximize(f,α0, n_steps, n, N_samples, N_out, N_iter, concentration)

    α = α0
    value1 = -100000000
    best = α
    for i in 1:N_iter
        print(i)
        print(" ")
        samples, best_i, value = sample_f(f, α, n_steps, n, N_samples[i], N_out[i])

        if i < N_iter
            α = update_alpha(samples, concentration[i], N_out[i])
        end
        print("\n")
        print(α)
        print("\n")
        if value > value1
            best = best_i
            value1 = value
        end

    end
    return best, value1

end




#### add function that perform the same as above but keep one parameter fixed ###


"""
update_alpha(n_steps,n, points)

This function uses the Nelder-Mead algorithm implimented in Optim.jl
to find the parameters for the policy generating process (a list of n_steps
dirichelt distributions ) that would be most likely to produce new policies
similar to the ones saved int he previous round.

n_steps: the number of
"""
function update_alpha_fixed_val(points,
    n_groups,
    n_steps,
    fixed_step_index,
    fixed_group_index,
    fixed_value,
    variable_step_index,
    variable_group_index,
    concentration,
    N_out)


    acc_α = zeros(n_steps - 1, n_groups)
    acc_α_fixed = zeros(n_groups-1)



    # calcualte mean
    for i in 1:N_out

        # loop over varaible groups
        for j in 1:(n_groups-1)
            acc_α_fixed[j] += points[n_groups*(fixed_step_index-1) + variable_group_index[j],i]
        end

        for j in 1:(n_steps-1)

            acc_α[j,:] += points[(n_groups*(variable_step_index[j]-1)+1):(n_groups*variable_step_index[j]),i]
        end

    end



    return acc_α .* concentration, acc_α_fixed .* concentration
end







"""
sample_f

This funtion samples N_samples new policies test them against for
and returns the N_out best policies.

f: the objective function
n_groups: number of age n_groups
n_steps: number of time n_steps
fixed_step_index: the time step with the fixed value
fixed_group_index: the group with the fixed value
α: a n_groups by (n_steps - 1) matrix
α_fixed: a vector of length n_groups - 1
variable_group_index: indexes for groups w/o fixed values
variable_step_index: indexes for steps w/o fixed values
N_samples: the number of samples to test
N_out: the number of samples to select
"""
function sample_f_fixed_val(f,
    n_groups,
    n_steps,
    fixed_step_index,
    fixed_group_index,
    fixed_value,
    variable_step_index,
    variable_group_index,
    α,
    α_fixed,
    n_samples,
    N_out)

    @assert !(fixed_group_index  in variable_group_index)
    @assert !(fixed_step_index in variable_step_index)
    @assert (length(variable_group_index) + 1) == n_groups
    @assert (length(variable_step_index) + 1) == n_steps
    @assert sum(variable_step_index .< (n_steps+1)) == length(variable_step_index)
    @assert sum(variable_group_index .< (n_groups+1)) == length(variable_group_index)




    sample = zeros(n_groups*n_steps, n_samples )



    for i in 1:length(variable_step_index)

        d = Dirichlet(soft_plus.(α[i,:]))
        j = variable_step_index[i]
        sample[(1 + (j-1)*n_groups):(j * n_groups),:] = rand(d, n_samples)
    end

    for i in 1:n_samples

        d = Dirichlet(soft_plus.(α_fixed))
        s = rand(d, 1)
        s = (1-fixed_value)  .* s

        s_new = zeros(n_groups)

        for j in 1:length(variable_group_index)
            s_new[variable_group_index[j]] = s[j]
        end
        s_new[fixed_group_index] = fixed_value

        sample[(1 + (fixed_step_index-1)*n_groups):(fixed_step_index * n_groups),i] = s_new

    end



    vals = mapslices(f, sample, dims = 1)

    max = zeros(n_groups*n_steps, N_out)
    vals = transpose(vals)
    best = zeros(n_groups*n_steps)
    value = 0



    for i in 1:N_out
        ind = argmax(vals)
        val = vals[ind]
        vals[ind] = -10000000
        if i == 1
            best = sample[:,ind]
            value = val
        end

        max[:,i] = sample[:,ind]
    end



    return max, best, value


end






"""
maximize

This function maximizes the objective function f using
a genetic algorithm.

f: function - the objective function
α0: vector of floats - the initial paramters for the policy generation process
n_steps: int - number of time steps
N_samples: vector of ints - the number of samples each iteration
N_out: vector of ints - the number of samples saved each iteration
N_iter: int -  the number of iterations to run.
"""
function maximize_fixed_val(f,
    n_groups,
    n_steps,
    fixed_step_index,
    fixed_group_index,
    fixed_value,
    variable_step_index,
    variable_group_index,
    α,
    α_fixed,
    n_samples,
    N_out,
    N_iter,
    concentration)

    value1 = -100000000
    best = zeros(n_groups*n_steps)
    for i in 1:N_iter
        print(i)
        print(" ")
        samples, best_i, value = sample_f_fixed_val(f,
            n_groups,
            n_steps,
            fixed_step_index,
            fixed_group_index,
            fixed_value,
            variable_step_index,
            variable_group_index,
            α,
            α_fixed,
            n_samples[i],
            N_out[i])

        if i < N_iter
            α, α_fixed = update_alpha_fixed_val(samples,
                n_groups,
                n_steps,
                fixed_step_index,
                fixed_group_index,
                fixed_value,
                variable_step_index,
                variable_group_index,
                concentration[i],
                N_out[i])
        end


        if value > value1
            best = best_i
            value1 = value
        end

    end
    return best, value1

end



### some function to test the indexing


function test_update_alpha()

    points = [1 1 1; 1 1 1; 0 0 0; 1 1 1; 0 0 0; 1 1 1; 1 1 1; 0 0 0; 1 1 1; 1 1 1; 1 1 1; 0 0 0]
    n_groups = 3
    n_steps = 4
    fixed_step_index = 2
    fixed_group_index = 3
    fixed_value = 0
    variable_step_index = [1,3,4]
    variable_group_index = [1,2]
    concentration = 0.5
    N_out = 3

    print(
    update_alpha_fixed_val(points,
        n_groups,
        n_steps,
        fixed_step_index,
        fixed_group_index,
        fixed_value,
        variable_step_index,
        variable_group_index,
        concentration,
        N_out)
    )
end



end # module



# """
# log_like(n_steps, n, points, α)
#
# This function calcualtes the likelihood that a vaccien policy,
# which is defined as a list of n_steps vecotrs of length n where
# the elements of the vectors add to one, was generated from
# a set of diriclet distributions parameterized by the elements
# of α. Here α is a vector of length n_steps*n where every n elements
# is a set of parameters for the diriclet distribution that generated
# the policy at the i ∈ 1:n_steps period.
#
# n_steps:  the numebr of items in each tuple
# n: the number of dimensions per step
# points: is a tupple of arrays
# α: is a vector of length n_groups*n_steps
# """
# function log_like(n_steps, n, points, α)
#     #print(points)
#     acc = 0
#     for i in 1:n_steps
#         d = Dirichlet(soft_plus.(α[(1 + (i-1)*n):(i * n)]))
#         vals = mapslices(x -> -log(pdf(d, x)), points[(1 + (i-1)*n):(i * n),:], dims = 1)
#         acc += sum(vals)
#     end
#     return acc
# end
