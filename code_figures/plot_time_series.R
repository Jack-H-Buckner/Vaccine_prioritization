library(ggplot2)
library(dplyr)
library(reshape2)
library(plyr)
setwd("~/desktop/Dynamic_Vaccine_Allocation")


time_sereis <- function(fn, t, N_groups, N_states, state, obj) {
  dat<- read.csv(fn)


  dat$time <- rep(1:t,3)
  dat$objective <- c(rep("Infections",t), rep("YLL",t), rep("Deaths",t))

  dat <- dat %>% melt(id.vars = c("time", "objective"))

  dat <- dat %>% 
    dplyr::mutate(col_num = as.numeric(gsub("Column", "", variable))) %>%
    dplyr::mutate(age_group = col_num %% N_groups,
          state_var = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0)) 






  dat$age_group <- mapvalues(dat$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h"))
  dat$state_var <- mapvalues(dat$state_var, 
                             0:8, 
                             c("S", "P", "F", "E", "I_pre", "I_asy", "I_sym", "D", "R"))

  dat <- dat %>% dplyr::select(-col_num)


  p <- ggplot(dat %>% 
           dplyr::filter(state_var ==  state,
                         objective == obj), 
         aes(x = time, y = value, color = age_group ) )+
    geom_line()+theme_test() + scale_color_brewer(palette = "Dark2")
  
  return(p)

}


time_sereis("data_outputs/model_run_beta01_alpha04_theta_065_test_states.csv",
            240, 8, 9, "E", "Infections")
