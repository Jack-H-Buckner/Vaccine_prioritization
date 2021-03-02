"""
This file contains funciton that return contact matrices scaled
to reflect a given level of sicail distancing.
"""
module distancing_senarios


include("parameters.jl")


# contacts 20

# increasing social contacts
function constant_beta03_alpha03_20(t, infections, increment)

    cnt = parameters.cnt_dist_20(parameters.cnt_work_20, 0.3, 0.3)
    cnt_sym = parameters.cnt_dist_20(parameters.cnt_work_20, 0.3, 0.3)

    return cnt_sym, cnt, cnt,  increment
end


function constant_beta07_alpha03_20(t, infections, increment)

    cnt = parameters.cnt_dist_20(parameters.cnt_work_20, 0.7, 0.3)
    cnt_sym = parameters.cnt_dist_20(parameters.cnt_work_20, 0.7, 0.3)

    return cnt_sym, cnt, cnt,  increment
end



function constant_beta03_alpha04_20(t, infections, increment)

    cnt = parameters.cnt_dist_20(parameters.cnt_work_20, 0.3, 0.4)
    cnt_sym = parameters.cnt_dist_20(parameters.cnt_work_20, 0.3, 0.4)

    return cnt_sym, cnt, cnt,  increment
end


function constant_beta07_alpha04_20(t, infections, increment)

    cnt = parameters.cnt_dist_20(parameters.cnt_work_20, 0.7, 0.4)
    cnt_sym = parameters.cnt_dist_20(parameters.cnt_work_20, 0.7, 0.4)

    return cnt_sym, cnt, cnt,  increment
end


function constant_beta01_alpha05_20(t, infections, increment)

    cnt = parameters.cnt_dist_20(parameters.cnt_work_20, 0.1, 0.5)
    cnt_sym = parameters.cnt_dist_20(parameters.cnt_work_20, 0.1, 0.5)

    return cnt_sym, cnt, cnt,  increment
end


function constant_beta01_alpha06_20(t, infections, increment)

    cnt = parameters.cnt_dist_20(parameters.cnt_work_20, 0.1, 0.6)
    cnt_sym = parameters.cnt_dist_20(parameters.cnt_work_20, 0.1, 0.6)

    return cnt_sym, cnt, cnt,  increment
end


# increasing work contacts
function constant_beta01_alpha04_20_0309(t, infections, increment)

    cnt = parameters.cnt_dist_20(parameters.cnt_work_20_0309, 0.1, 0.4)
    cnt_sym = parameters.cnt_dist_20(parameters.cnt_work_20_0309, 0.1, 0.4)

    return cnt_sym, cnt, cnt,  increment
end

function constant_beta01_alpha04_20_0411(t, infections, increment)

    cnt = parameters.cnt_dist_20(parameters.cnt_work_20_0411, 0.1, 0.4)
    cnt_sym = parameters.cnt_dist_20(parameters.cnt_work_20_0411, 0.1, 0.4)

    return cnt_sym, cnt, cnt,  increment
end

function constant_beta01_alpha04_20_05145(t, infections, increment)

    cnt = parameters.cnt_dist_20(parameters.cnt_work_20_05145, 0.1, 0.4)
    cnt_sym = parameters.cnt_dist_20(parameters.cnt_work_20_05145, 0.1, 0.4)

    return cnt_sym, cnt, cnt,  increment
end

function constant_beta01_alpha04_20_06185(t, infections, increment)

    cnt = parameters.cnt_dist_20(parameters.cnt_work_20_06185, 0.1, 0.4)
    cnt_sym = parameters.cnt_dist_20(parameters.cnt_work_20_06185, 0.1, 0.4)

    return cnt_sym, cnt, cnt,  increment
end

# alternative structure
function constant_beta03_alpha04_20_cl(t, infections, increment)

    cnt = parameters.cnt_dist_20(parameters.cnt_work_20_cl, 0.3, 0.4)
    cnt_sym = parameters.cnt_dist_20(parameters.cnt_work_20_cl, 0.3, 0.4)

    return cnt_sym, cnt, cnt,  increment
end



# contacts 40

# increasing social contacts
function constant_beta03_alpha02_40(t, infections, increment)

    cnt = parameters.cnt_dist_40(parameters.cnt_work_40, 0.3, 0.2)
    cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40, 0.3, 0.2)

    return cnt_sym, cnt, cnt,  increment
end

function constant_beta01_alpha03_40(t, infections, increment)

    cnt = parameters.cnt_dist_40(parameters.cnt_work_40, 0.1, 0.3)
    cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40, 0.1, 0.3)

    return cnt_sym, cnt, cnt,  increment
end



function constant_beta03_alpha03_40(t, infections, increment)

    cnt = parameters.cnt_dist_40(parameters.cnt_work_40, 0.3, 0.3)
    cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40, 0.3, 0.3)

    return cnt_sym, cnt, cnt,  increment
end


function constant_beta07_alpha03_40(t, infections, increment)

    cnt = parameters.cnt_dist_40(parameters.cnt_work_40, 0.7, 0.3)
    cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40, 0.7, 0.3)

    return cnt_sym, cnt, cnt,  increment
end



function constant_beta03_alpha04_40(t, infections, increment)

    cnt = parameters.cnt_dist_40(parameters.cnt_work_40, 0.3, 0.4)
    cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40, 0.3, 0.4)

    return cnt_sym, cnt, cnt,  increment
end


function constant_beta07_alpha04_40(t, infections, increment)

    cnt = parameters.cnt_dist_40(parameters.cnt_work_40, 0.7, 0.4)
    cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40, 0.7, 0.4)

    return cnt_sym, cnt, cnt,  increment
end


function constant_beta03_alpha05_40(t, infections, increment)

    cnt = parameters.cnt_dist_40(parameters.cnt_work_40, 0.3, 0.5)
    cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40, 0.3, 0.5)

    return cnt_sym, cnt, cnt,  increment
end


function constant_beta03_alpha06_40(t, infections, increment)

    cnt = parameters.cnt_dist_40(parameters.cnt_work_40, 0.3, 0.6)
    cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40, 0.3, 0.6)

    return cnt_sym, cnt, cnt,  increment
end


# increasing work contacts
function constant_beta03_alpha04_40_0304(t, infections, increment)

    cnt = parameters.cnt_dist_40(parameters.cnt_work_40_0304, 0.3, 0.4)
    cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40_0304, 0.3, 0.4)

    return cnt_sym, cnt, cnt,  increment
end

function constant_beta03_alpha04_40_0407(t, infections, increment)

    cnt = parameters.cnt_dist_40(parameters.cnt_work_40_0407, 0.3, 0.4)
    cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40_0407, 0.3, 0.4)

    return cnt_sym, cnt, cnt,  increment
end

function constant_beta03_alpha04_40_0509(t, infections, increment)

    cnt = parameters.cnt_dist_40(parameters.cnt_work_40_0509, 0.3, 0.4)
    cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40_0509, 0.3, 0.4)

    return cnt_sym, cnt, cnt,  increment
end


function constant_beta03_alpha03_40_0509(t, infections, increment)

    cnt = parameters.cnt_dist_40(parameters.cnt_work_40_0509, 0.3, 0.3)
    cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40_0509, 0.3, 0.3)

    return cnt_sym, cnt, cnt,  increment
end


function constant_beta03_alpha04_40_0611(t, infections, increment)

    cnt = parameters.cnt_dist_40(parameters.cnt_work_40_0611, 0.3, 0.4)
    cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40_0611, 0.3, 0.4)

    return cnt_sym, cnt, cnt,  increment
end

# alternative structure
function constant_beta03_alpha04_40_cl(t, infections, increment)

    cnt = parameters.cnt_dist_40(parameters.cnt_work_40_cl, 0.3, 0.4)
    cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40_cl, 0.3, 0.4)

    return cnt_sym, cnt, cnt,  increment
end










"""
This function returns the contact matrices for the simulations
when new infections fall below 20 per 100000 social distancing is relaxed


value after social distancing is relaxed is half way between the original
value and one.


Checks:
    projected new infections can be compared to the infections plotted but the
    simulations.simulate_data function

    The transition point can be printed and is visible in infections plot

    invalid value of the increment will cause the function to fail and pring a
    warning
"""
function base_senario(t, infections, increment)
    D_sym = parameters.D_sym


    new_observed_infections = 100000 *0.2*infections/D_sym # assuing 1 in five new infections as new_observed_infections

    # end the run if increment is less than zero
    if increment < 0
        print("There has been an issue: 1")
        return
    end


    # if the infectios are above the threshold of 4 per 10000000
    # and the increment is zero then do social distancing 1
    if (new_observed_infections >= 4.0) & (increment == 0)

        cnt = parameters.cnt_dist_40(parameters.cnt_work_40, 0.1, 0.3)
        cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40, 0.1, 0.3)

        return  cnt_sym, cnt, cnt,  increment

    # if the infections are above the threshold but the incremnt
    # is greater than zero then do relaxed distancing and
    # reduce the increment by one

    elseif (new_observed_infections >= 4) & (increment  > 0)

        increment += -1
        cnt = parameters.cnt_dist_40(parameters.cnt_work_40_0611, 0.75, 0.8)
        cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40_0611, 0.75, 0.8)


        return cnt_sym, cnt, cnt,  increment

    # if infections are below the threshold and the increment in zero
    # then set the increment to 14 days and do relaxed distancing
    elseif (new_observed_infections < 4) & (increment  == 0)
        #print(t)
        #print("    ")
        increment = 14
        cnt = parameters.cnt_dist_40(parameters.cnt_work_40_0611, 0.75, 0.8)
        cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40_0611, 0.75, 0.8)


        return  cnt_sym, cnt, cnt,  increment

    # if infections are below the threshold and the increment is greater than
    # zero then reduce the increment by one and do relaxed distancing

    elseif (new_observed_infections < 4) && (increment > 0)
        increment += -1
        cnt = parameters.cnt_dist_40(parameters.cnt_work_40_0611, 0.75, 0.8)
        cnt_sym = parameters.cnt_dist_40(parameters.cnt_work_40_0611, 0.75, 0.8)


        return  cnt_sym, cnt, cnt,  increment
    end

    print("There has been an issue: 2")
end


end
