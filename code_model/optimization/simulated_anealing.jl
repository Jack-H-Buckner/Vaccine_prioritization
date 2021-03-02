"""
This module contains code that runs a simple implementation of
simulated anealing.
"""
module simulated_anealing

using Random, Distributions
using LinearAlgebra
using NLsolve
using Plots
using Optim

Random.seed!(200915)

"""
this function runs a simulated anealing algorithm with proposal distribution
as a mutivariat normal distribution with zero covariance.

Two parameters can be changed over time sigma_t which is the variance of the
proposal distribution and p_t wich scales the accpetance ration

α < p_t F(x')/F(X)

not for large values of p_t the new sample is very liekly to be accepted
but if temp_t is small then it is unlikely to be selected.

Decreasing sigma over time increases the likelihood that a sample is accepted
but also reduces the chagne that a new (and better) basin of attraciton is
found.

T is the number of steps to run te algorithm for, another version will be created
that has a stopping criterion

In addition to returning the solution the algorithm returns a string of ones and
zeros ones for accepted samples and zeros for rejected samples. it also returns a
list of funtion values for newly accepted samples
"""
function anealing(x_0, transform, f, sigma, temp_t, T)


    ##################
    ## accumulators ##
    ##################

    acceptance = zeros(T) # set accumulator for accpeted proposals
    values = zeros(T) # set accumulator for function values of proposed solutions

    ###########################
    ## proposal distribution ##
    ###########################

    n = length(x_0) # get length of solution vector
    S = Matrix(1.0I,n,n) # set variance for proposal distribution
    m = zeros(n) # set mean for
    d = Distributions.MvNormal(sigma*S) # set proposal distribution

    #####################
    ## incumbent value ##
    #####################

    x = x_0 # set initial guess as incumbent
    v_current = f(transform(x_0)) # evalueate performance of initial guess and set and incumbent value

    #########################
    ## best value in chain ##
    #########################

    x_best = x_0 # set x_best to inital value
    v_best = v_current # set best value to value for inital sample
    i_best = 0 # start acumulator for iteration when best solution was found for diagnostics.

    for i in 1:T

        ####################
        ## print progress ##
        ####################

        if i % 1000 == 0
            print("itteration: ")
            print(i)
            print("\n")
        end

        ###########################
        ## proposal distribution ##
        ###########################

        x_prime = x .+ Random.rand(d,1) # generate new proposal
        v = f(transform(x_prime)) # evalueate prposal



        #########################
        ## best value in chain ##
        #########################

        if v < v_best # compare to best value on cahin
            x_best = x_prime # replace if better
            i_best = i # update best iteration
            v_best = v # update best value
        end


        #####################
        ## incumbent value ##
        #####################

        if v <  v_current # compare to incumbent
            x = x_prime # if improvement replace x
            v_current = v # replace incumbent value
            acceptance[i] = 1 # mark acceptance as 1
            values[i] = v_current # add to values accumulator

        elseif exp(-(v - v_current)/temp_t(i)) > Random.rand() # compare energy function to random number
            x = x_prime # if seelcted relace incumbent
            v_current = v
            acceptance[i] = 1
            values[i] = v_current
        else
            acceptance[i] = 0 # else update accumulators and start next iteration
            values[i] = v_current
        end


    end

    ####################
    ## print progress ##
    ####################


    return x_best, v_best, i_best, v_current, values, acceptance
end




"""
this function takes m vertically bound vectors in
Rn and transforms them on to the simplex in Rn+1
using the soft max transformation
"""
function soft_max_grouped(x,n,m)

    @assert length(x) == n*m

    x_new = zeros(n*m+m)
    n1 = n + 1

    for i in 1:m
        x_segment = vcat(0, x[((i-1)*n + 1):(i*n)])
        x_new[((i-1)*n1 + 1):(i*n1)] = exp.(x_segment )./sum(exp.(x_segment))
    end

    return x_new

end

"""
This function reverses the soft max function
it forces the first value in the vector to be zero
"""
function soft_max_inv(x)
    @assert abs(sum(x) - 1) < 10^(-8)
    return log.(x) .- log.(x)[1]
end


"""
this function applied the iverse soft max function to m
vertically bound vectors of length n + 1
"""
function inv_soft_max_grouped(x, n, m)
    @assert length(x) == (n+1)*m
    y = zeros(n*m)

    n1 = n + 1
    for i in 1:m
        y[((i-1)*n + 1):(i*n)] = soft_max_inv(x[((i-1)*n1 + 1):(i*n1)])[2:end]
    end

    return y
end



"""
this function uses markov chains to search for solutions near
the optimal solution.
"""
function sensetivity_resampling(x, transform, f, epsilon, sigma, num_samples, max_iter, n_chains)


    v0 = f(transform(x)) # find value optimal soltuion


    ##################
    ## accumulators ##
    ##################

    # get length of soltuion in constrained and unconstrained space
    n = length(transform(x))
    m = length(x)
    # set accumulaors for sampled values and solutions
    samples = zeros((num_samples*n_chains)+1,n)
    values = zeros(num_samples*n_chains+1)
    samples[1,:] = transform(x)
    i = 2 # accumulator for accumulator index!



    ###########################
    ## proposal distribution ##
    ###########################

    S = Matrix(1.0I,m,m)
    d = Distributions.MvNormal(sigma*S)

    x0 = x

    x_best = x0

    for j in 1:n_chains # loop over the number of chains

        #####################
        ## incumbent value ##
        #####################

        x = x_best

        k = 1 # set an accumulator for total number of iterations
        h = 1 # set accumulator for total number of samples



        while (h < (num_samples + 1)) & (k < max_iter)

            k += 1 # update number of iterations

            x_prime = x .+ Random.rand(d,1) # sample next proposed solution
            v = f(transform(x_prime)) # get value

            if v < v0  # if best value found
                samples[i,:] = transform(x_prime)  # add solution to accumualtor in consrained space
                x = x_prime # update incumbent
                v0 = v # update max value
                values[i] = v0  # add value to list
                i += 1 # update accumulators
                h+=1
                x_best = x_prime
                print("new optimum found!!! ")
                print("\n")




            elseif v < v0+epsilon # if new valu with in tolerance
                samples[i,:] = transform(x_prime) # add to list of samples
                x = x_prime # update incumbent
                values[i] = v
                i += 1
                h+=1
            end

        end
        print("\n")
        print(k) # print number of intertions as a diagnostic
    end

    keep = values .< v0+epsilon
    samples = samples[keep,:]

    return x_best, samples, values # return list of values and samples
end







# soft max transfrom
"""
this function transforms a vector from the real line to the
simplex.
"""
function soft_max(x)

    x = vcat(0,x)
    return exp.(x)./sum(exp.(x))

end



###########################

###  fixed parameter !  ###

###########################



"""
this function takes m vertically bound vectors in
Rn and transforms them on to the simplex in Rn+1
using the soft max transformation
"""
function soft_max_grouped_fixed_val(
    x, # n_group - 1 by n_step - 1 matrix
    x_fixed, # n_group - 2 vector
    n_groups, # number of groups
    n_steps, # number of time steps
    fixed_step_index, # int
    fixed_group_index, # int
    fixed_value, # value!
    variable_step_index, # vector of indicies length n_steps - 1
    variable_group_index) # vector of group indices of length n_groups - 1


    y = zeros(n_groups*n_steps)

    for i in 1:(n_steps - 1)
        ind = variable_step_index[i]
        y[((ind-1)*n_groups+1):(ind*n_groups)] = soft_max(x[i,:])
    end

    y_fixed = (1-fixed_value)*soft_max(x_fixed)
    y_fixed_full = zeros(n_groups)

    for i in 1:(n_groups-1)
        ind = variable_group_index[i]
        y_fixed_full[ind] = y_fixed[i]
    end



    y_fixed_full[fixed_group_index] = fixed_value

    ind = fixed_step_index
    y[((ind-1)*n_groups+1):(ind*n_groups)] = y_fixed_full

    return y

end



"""
this function applied the iverse soft max function to m
vertically bound vectors of length n + 1
"""
function inv_soft_max_grouped_fixed(
    x, # n_group * n_step vector
    n_groups, # number of gorups
    n_steps, # number of time steps
    fixed_step_index, # int
    fixed_group_index, # int
    fixed_value, # value!
    variable_step_index, # vector of indicies length n_steps - 1
    variable_group_index) # vector of group indices of length n_groups - 1

    @assert x[(fixed_step_index-1)*n_groups+fixed_group_index] == fixed_value

    x_new = zeros(n_steps-1,n_groups-1,)
    x_fixed = zeros(n_groups-2)

    for i in 1:(n_steps-1)
        ind = variable_step_index[i]
        x_step = x[((ind-1)*n_groups+1):(ind*n_groups)]

        x_new[i,:] = soft_max_inv(x_step)[2:n_groups] # invert soft max and remove zero entry
    end

    ind = fixed_step_index
    x_fixed_step = x[((ind-1)*n_groups+1):(ind*n_groups)]
    x_fixed_step_variable_groups = zeros(n_groups-1)

    for i in 1:(n_groups-1)
        ind = variable_group_index[i]
        #print(ind)
        x_fixed_step_variable_groups[i] = x_fixed_step[ind]
    end

    x_fixed_step_variable_groups = x_fixed_step_variable_groups./(1-fixed_value)

    x_fixed = soft_max_inv(x_fixed_step_variable_groups)[2:(n_groups-1)]

    return x_new, x_fixed
end





function sample_fixed_val(
    x,
    x_fixed,
    sigma,
    n_groups, # number of gorups
    n_steps)

    S = Matrix(1.0I,n_groups-1,n_groups-1)
    d = Distributions.MvNormal(sigma*S)

    x_prime = zeros(n_steps - 1,n_groups-1)



    for i in 1:(n_steps-1)


        x_prime[i,:] = x[i,:] .+ Random.rand(d,1)
    end


    S = Matrix(1.0I,n_groups-2,n_groups-2)
    d = Distributions.MvNormal(sigma*S)

    x_fixed_prime = x_fixed .+ Random.rand(d,1)



    return x_prime, x_fixed_prime

end







"""
this function runs a simulated anealing algorithm with proposal distribution
as a mutivariat normal distribution with zero covariance.

Two parameters can be changed over time sigma_t which is the variance of the
proposal distribution and p_t wich scales the accpetance ration

α < p_t F(x')/F(X)

not for large values of p_t the new sample is very liekly to be accepted
but if temp_t is small then it is unlikely to be selected.

Decreasing sigma over time increases the likelihood that a sample is accepted
but also reduces the chagne that a new (and better) basin of attraciton is
found.

T is the number of steps to run te algorithm for, another version will be created
that has a stopping criterion

In addition to returning the solution the algorithm returns a string of ones and
zeros ones for accepted samples and zeros for rejected samples. it also returns a
list of funtion values for newly accepted samples
"""
function anealing_fixed_val(
    x_0,
    f,
    sigma,
    n_groups,
    n_steps,
    fixed_step_index, # int
    fixed_group_index, # int
    fixed_value, # value!
    variable_step_index, # vector of indicies length n_steps - 1
    variable_group_index,
    temp_t,
    T)


    ##################
    ## accumulators ##
    ##################

    acceptance = zeros(T) # set accumulator for accpeted proposals
    values = zeros(T) # set accumulator for function values of proposed solutions


    #####################
    ## incumbent value ##
    #####################


    v_current = f(x_0) # evalueate performance of initial guess and set and incumbent value

    #########################
    ## best value in chain ##


    print(x_0)


    x_best, x_fixed_best = inv_soft_max_grouped_fixed(
        x_0, # n_group * n_step vector
        n_groups, # number of gorups
        n_steps, # number of time steps
        fixed_step_index, # int
        fixed_group_index, # int
        fixed_value, # value!
        variable_step_index, # vector of indicies length n_steps - 1
        variable_group_index)


    print("\n")
    print("\n")

    print(soft_max_grouped_fixed_val(
        x_best, # n_group - 1 by n_step - 1 matrix
        x_fixed_best, # n_group - 2 vector
        n_groups, # number of groups
        n_steps, # number of time steps
        fixed_step_index, # int
        fixed_group_index, # int
        fixed_value, # value!
        variable_step_index, # vector of indicies length n_steps - 1
        variable_group_index))



    x = x_best
    x_fixed = x_fixed_best
    v_best = v_current # set best value to value for inital sample
    i_best = 0 # start acumulator for iteration when best solution was found for diagnostics.

    for i in 1:T

        ####################
        ## print progress ##
        ####################

        if i % 1000 == 0
            print("itteration: ")
            print(i)
            print("\n")
        end

        ###########################
        ## proposal distribution ##
        ###########################

        x_prime, x_fixed_prime = sample_fixed_val(
            x,
            x_fixed,
            sigma,
            n_groups, # number of gorups
            n_steps)



        x_t = soft_max_grouped_fixed_val(
            x_prime, # n_group - 1 by n_step - 1 matrix
            x_fixed_prime, # n_group - 2 vector
            n_groups, # number of groups
            n_steps, # number of time steps
            fixed_step_index, # int
            fixed_group_index, # int
            fixed_value, # value!
            variable_step_index, # vector of indicies length n_steps - 1
            variable_group_index)

        # print("\n")
        # print("\n")
        # print("proposed value: ")
        # print(x_t)

        #print("\n")
        #print("\n")
        #print(x_t)
        #print("\n")


        v = f(x_t) # evalueate prposal

        #########################
        ## best value in chain ##
        #########################

        if v < v_best # compare to best value on cahin
            x_best = x_prime # replace if better
            x_fixed_best = x_fixed_prime
            i_best = i # update best iteration
            v_best = v # update best value
        end


        #####################
        ## incumbent value ##
        #####################

        if v <  v_current # compare to incumbent

            x = x_prime # if improvement replace x
            x_fixed = x_fixed_prime
            v_current = v # replace incumbent value
            acceptance[i] = 1 # mark acceptance as 1
            values[i] = v_current # add to values accumulator

        elseif exp(-(v - v_current)/temp_t(i)) > Random.rand() # compare energy function to random number
            x = x_prime # if seelcted relace incumbent
            x_fixed = x_fixed_prime
            v_current = v
            acceptance[i] = 1
            values[i] = v_current
        else
            acceptance[i] = 0 # else update accumulators and start next iteration
            values[i] = v_current
        end


    end

    ####################
    ## print progress ##
    ####################

    x_best = soft_max_grouped_fixed_val(
        x_best, # n_group - 1 by n_step - 1 matrix
        x_fixed_best, # n_group - 2 vector
        n_groups, # number of groups
        n_steps, # number of time steps
        fixed_step_index, # int
        fixed_group_index, # int
        fixed_value, # value!
        variable_step_index, # vector of indicies length n_steps - 1
        variable_group_index)

    return x_best, v_best, i_best, v_current, values, acceptance

end








##############################

#####       tests       ######

##############################


function test_soft_max_grouped_fixed_val()
    print(soft_max_grouped_fixed_val(
        [0 0 0; 0 0 0; 0 0 0], # n_group - 1 by n_step - 1 matrix
        [0,0], # n_group - 2 vector
        4, # number of groups
        4, # number of time steps
        3, # int
        3, # int
        0.5, # value!
        [1,2,4], # vector of indicies length n_steps - 1
        [1,2,4])
    )
end


function test_inv_soft_max_grouped()
    print(
        inv_soft_max_grouped_fixed(
            [0.99,0.005,0.005, 0.5,0.25,0.25, 0.125, 0.375, 0.5], # n_group * n_step vector
            3, # number of gorups
            3, # number of time steps
            1, # int
            1, # int
            0.99, # value!
            [2,3], # vector of indicies length n_steps - 1
            [2,3])
    )
end

function test_soft_max_and_inverse()

    x = [0.5,0.1,0.1,0.3, 0.25,0.25,0.25,0.25, 0.05,0.05,0.05,0.85]#[0.25,0.25,0.5, 0.5,0.25,0.25, 0.5, 0.3, 0.2]

    x_variable, x_fixed = inv_soft_max_grouped_fixed(
        x, # n_group * n_step vector
        4, # number of groups
        3, # number of time steps
        2, # int
        2, # int
        0.25, # value!
        [1,3], # vector of indicies length n_steps - 1
        [1,3,4])

    print("\n")
    print(x_variable)
    print("\n")
    print("\n")
    print(x_fixed)
    print("\n")
    print("\n")

    print(
    soft_max_grouped_fixed_val(
        x_variable, # n_group - 1 by n_step - 1 matrix
        x_fixed, # n_group - 2 vector
        4, # number of gorups
        3, # number of time steps
        2, # int
        2, # int
        0.25, # value!
        [1,3], # vector of indicies length n_steps - 1
        [1,3,4])

    )
    print("\n")
    print("\n")


    x = soft_max_grouped_fixed_val(
        [0 0 0; 0 0 0; 0 0 0], # n_group - 1 by n_step - 1 matrix
        [0,0], # n_group - 2 vector
        4, # number of groups
        4, # number of time steps
        3, # int
        3, # int
        0.5, # value!
        [1,2,4], # vector of indicies length n_steps - 1
        [1,2,4])

    print(
    inv_soft_max_grouped_fixed(
        x, # n_group * n_step vector
        4, # number of groups
        4, # number of time steps
        3, # int
        3, # int
        0.5, # value!
        [1,2,4], # vector of indicies length n_steps - 1
        [1,2,4])
    )



end

Random.seed!(202019)
function test_sample_fixed_value()
    x, x_fixed = sample_fixed_val(
        [0.0 0 0 0 0; 0 0 0 0 0], # n_group - 1 by n_step - 1 matrix
        [0.0,0,0,0], # n_group - 2 vector
        0.0005,
        6, # number of groups
        3)

    print(x)
    print(
        soft_max_grouped_fixed_val(
        x,
        x_fixed,
        6, # number of groups
        3, # number of time steps
        1, # int
        3, # int
        0.5, # value!
        [2,3], # vector of indicies length n_steps - 1
        [1,2,4,5,6]
        )
    )
    x = soft_max_grouped_fixed_val(
    x,
    x_fixed,
    6, # number of groups
    3, # number of time steps
    1, # int
    3, # int
    0.5, # value!
    [2,3], # vector of indicies length n_steps - 1
    [1,2,4,5,6]
    )
    plot(x)
    savefig("~/documents/test_sample_fixed_val1.png")
end


end
