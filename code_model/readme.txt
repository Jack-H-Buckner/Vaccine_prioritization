This folder contains all of the code to run the model and some alternative
model structures. The code that simulates the epidemiological dynamics is
stored in the "dynamics" folder, the code that defines the optimization routines
is stored in the "optimization" folder, special parameters required for model runs
are stored in the "parameters" file and some tests to insure reproducibility
are stored in the "tests" folder.


folder contents:

dynamics:
derivitives_efficacies.jl - derivitives for leaky vaccine model
derivitives.jl - derivitives for base model (all or nothing vaccine)
simulations.jl - simulates the base model with vaccine allocated to each group
simulations_age_only.jl - simulated the base model with vaccine allocated by age alone
simulations_static.jl - simulated the base model with vaccine allocated in one shot
simulations_eficacies.jl - simulated the leaky vaccine model with dynamic allocation to each group
run_opts_2.jl
The simulations files define the functions that are used as the objective
for the optimization routines.

optimization
