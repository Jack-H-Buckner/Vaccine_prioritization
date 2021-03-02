

###-------------
### libraries
###-------------
library(dplyr)
library(plyr)
library(ggplot2)
library(reshape2)
library(ggpattern)
###-------------
### set wd
###-------------

setwd("~/desktop/Dynamic_Vaccine_Allocation")


###-------------
### load data 
###-------------

# optimization
dat_main_text <- read.csv("data_outputs/main_text_test_states.csv")

dat_strong_NPI <- read.csv("data_outputs/strong_NPI_test_states.csv")

dat_weak_NPI <- read.csv("data_outputs/weak_NPI_test_states.csv")



###-------------------
### plot time series
###-------------------



t = 240 
N_groups = 8
N_states = 9
state = "I_sym"
obj = "Infections"


dat_main_text$time <- 1:t
dat_main_text$objective <- "main_text"


dat_strong_NPI$time <- 1:t
dat_strong_NPI$objective <- "Strong NPI"


dat_weak_NPI$time <- 1:t
dat_weak_NPI$objective <- "Weak NPI"

dat <- rbind(dat_main_text, dat_strong_NPI, dat_weak_NPI)


dat <- dat %>% melt(id.vars = c("time", "objective"))

dat <- dat %>% 
  dplyr::mutate(col_num = as.numeric(gsub("Column", "", variable))) %>%
  dplyr::mutate(age_group = col_num %% N_groups,
                state_var = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0)) 




dat$age_group <- mapvalues(dat$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h"))
dat$state_var <- mapvalues(dat$state_var, 
                           0:8, 
                           c("S", "P", "F", "E", "I_pre", "I_asy", "I_sym", "D", "R"))

dat <- dat %>% 
  dplyr::select(-col_num) %>%
  dplyr::group_by(time, objective, state_var)%>%
  dplyr::summarize(value = sum(value))%>%
  filter(state_var == "I_sym")


dat$objective <- factor(dat$objective, c("main_text","Strong NPI","Weak NPI"))

ggplot(dat, 
            aes(x = time, 
                y = 100*value, 
                color = objective,
                linetype = objective))+
  geom_line()+
  scale_color_brewer(palette="Dark2", 
                     name = "Policy", 
                     labels = c("main_text","Strong NPI","Weak NPI"))+ 
  scale_linetype_manual( values = c("solid", "dotted", "12345678", "dotdash", "longdash"),
                         name = "Policy", 
                         labels = c("main_text","Strong NPI","Weak NPI"))+
  theme_minimal()+
  xlab("Time")+
  ylab("Symptomatic infections per 1000")+
  theme(
    strip.text = element_text(size=12, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=12, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=12, face="bold",family="Times New Roman"),
    legend.title = element_text(size=12, face="bold",family="Times New Roman"),
    legend.text = element_text(size=12,family="Times New Roman"))












