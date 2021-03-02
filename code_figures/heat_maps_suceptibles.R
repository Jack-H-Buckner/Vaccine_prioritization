
###-------------
### libraries
###-------------
library(dplyr)
library(plyr)
library(ggplot2)
library(reshape2)
library(ggpattern)
library(viridis)



setwd("~/desktop/Dynamic_Vaccine_Allocation")



t = 240 
N_groups = 8
N_states = 9
state = "E"
obj = "Infections"
v_eff = 0.9

dat <- read.csv("data_outputs/alt_20_cl_states.csv")


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

dat_S <- dat %>% dplyr::filter(time == 90, state_var == "S")

dat_P <- dat %>% 
  dplyr::filter(time == 90, state_var == "P") %>% 
  dplyr::mutate(value = value/v_eff)


dat_v <- dat_P

dat_v$suceptibles <- dat_S$value

dat_v <- dat_v %>% dplyr::mutate(v =  value/(suceptibles+ value))

ggplot(dat_v,
       aes(x = age_group, y = 1, fill = v))+
  theme_minimal()+
  geom_tile(height = 0.9)+
  facet_wrap(~objective, ncol = 1)+
  scale_fill_viridis(name = "Perecent of group")+
  xlab("Demographic  group")+ 
  ylab("Alternative scenario")+
  theme(
    strip.text = element_text(size=12, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=12, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=12, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=12,family="Times New Roman"),
    legend.position="bottom")




