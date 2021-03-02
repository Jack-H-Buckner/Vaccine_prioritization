"""
this file defines the genetic algorithm used to optimized the vaccine allocaiton
strategies.
"""
module optimization


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
log_like(n_steps, n, points, α)

This function calcualtes the likelihood that a vaccien policy,
which is defined as a list of n_steps vecotrs of length n where
the elements of the vectors add to one, was generated from
a set of diriclet distributions parameterized by the elements
of α. Here α is a vector of length n_steps*n where every n elements
is a set of parameters for the diriclet distribution that generated
the policy at the i ∈ 1:n_steps period.

n_steps:  the numebr of items in each tuple
n: the number of dimensions per step
points: is a tupple of arrays
α: is a vector of length n_groups*n_steps
"""
function log_like(n_steps, n, points, α)
    #print(points)
    acc = 0
    for i in 1:n_steps
        d = Dirichlet(soft_plus.(α[(1 + (i-1)*n):(i * n)]))
        vals = mapslices(x -> -log(pdf(d, x)), points[(1 + (i-1)*n):(i * n),:], dims = 1)
        acc += sum(vals)
    end
    return acc
end


"""
MLE(n_steps,n, points)

This function uses the Nelder-Mead algorithm implimented in Optim.jl
to find the parameters for the policy generating process (a list of n_steps
dirichelt distributions ) that would be most likely to produce new policies
similar to the ones saved int he previous round.

n_steps: the number of
"""
function MLE(n_steps,n, points)
    lower = repeat([10^-5], size(points,1))
    upper = repeat([Inf], size(points,1))
    f(x) = log_like(n_steps,n, points,x)

    #initial_x = repeat([0.0001], size(points,1))
    #inner_optimizer = GradientDescent(linesearch=LineSearches.BackTracking(order=3))
    #results = optimize(f, lower, upper, initial_x, Fminbox(inner_optimizer))

    results = optimize(f, repeat([0.0], size(points,1)),
    repeat([1000.], size(points,1)), repeat([1.5], size(points,1)))

    #results = optimize(f, repeat([0.0], size(points,1)), SimulatedAnnealing())

    return results.minimizer
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
function maximize(f,α0, n_steps, n, N_samples, N_out, N_iter)

    α = α0
    value1 = -100000000
    best = α
    for i in 1:N_iter
        print(i)
        samples, best_i, value = sample_f(f, α, n_steps, n, N_samples[i], N_out[i])

        if i < N_iter
            α = MLE(n_steps, n, samples)
        end

        if value > value1
            best = best_i
            value1 = value
        end

    end
    return best, value1

end





end # module
