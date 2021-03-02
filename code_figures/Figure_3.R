
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

# full solution
dat_full_outcomes <- read.csv("data_outputs/main_text_full_outcomes.csv")


# age only 
dat_age_outcomes <- read.csv("data_outputs/main_text_age_only_outcomes.csv")

# static policy
dat_static_outcomes <- read.csv("data_outputs/main_text_static_outcomes.csv")

# uniform policy
dat_uniform_outcomes <- read.csv("data_outputs/main_text_uniform_outcomes.csv")



###----------------------
### process outcome data 
###----------------------

# full outcomes data 
names(dat_full_outcomes) <- c("Infections", "YLL", "Deaths") 
dat_full_outcomes$outcomes <- c("Infections", "YLL", "Deaths") 
dat_full_outcomes <- dat_full_outcomes %>% reshape2::melt(id.var = "outcomes")
dat_full_outcomes$constraint <- c("Full")
names(dat_full_outcomes) <- c("Outcome", "Policy", "value", "Constraint")


# age only outcomes data 
names(dat_age_outcomes) <- c("Infections", "YLL", "Deaths") 
dat_age_outcomes$outcomes <- c("Infections", "YLL", "Deaths") 
dat_age_outcomes <- dat_age_outcomes %>% reshape2::melt(id.var = "outcomes")
dat_age_outcomes$constraint <- c("age_only")
names(dat_age_outcomes) <- c("Outcome", "Policy", "value", "Constraint")


# age only outcomes data 
names(dat_static_outcomes) <- c("Infections", "YLL", "Deaths") 
dat_static_outcomes$outcomes <- c("Infections", "YLL", "Deaths") 
dat_static_outcomes <- dat_static_outcomes %>% reshape2::melt(id.var = "outcomes")
dat_static_outcomes$constraint <- c("static")
names(dat_static_outcomes) <- c("Outcome", "Policy", "value", "Constraint")

# combine data sets
dat_all_outcomes <- rbind(dat_full_outcomes, dat_age_outcomes, dat_static_outcomes)




###--------------------
### comparison plot 
###--------------------

dat_all_outcomes
dat_uniform_outcomes$Outcome <- c("Infections", "YLL", "Deaths")
names(dat_uniform_outcomes) <- c("unif_value", "row", "Outcome")
dat_uniform_outcomes <- dat_uniform_outcomes %>% dplyr::select(-row)

dat_all_outcomes <- merge(dat_all_outcomes, dat_uniform_outcomes, by = "Outcome")

dat_all_outcomes$Outcome <- factor(dat_all_outcomes$Outcome, c("Infections", "YLL", "Deaths"))

dat_all_outcomes$Outcome <- mapvalues(dat_all_outcomes$Outcome, 
                                      c("Infections", "YLL", "Deaths"),
                                      c("Resulting infections", "Resulting YLL", "Resulting deaths"))

dat_all_outcomes$Constraint <- factor(dat_all_outcomes$Constraint, c("Full", "age_only", "static"))

dat_all_outcomes$Constraint <- mapvalues(dat_all_outcomes$Constraint, c("Full", "age_only", "static"),
                                         c("None", "Age only", "Static"))

p <- ggplot(dat_all_outcomes%>%
         dplyr::mutate(value = 1 - value/unif_value)) +
  geom_col_pattern(
    aes(x = Policy, y = 100*as.numeric(value), pattern_fill = Policy, pattern_angle = Constraint), 
    position=position_dodge(width = 0.8), 
    width = 0.7,
    colour  = 'black',
    pattern_density= 0.99,
    pattern_key_scale_factor = 2.0,
    pattern = 'stripe',
    fill = "grey"
  )+facet_wrap(~Outcome, nrow = 1)+
  theme_bw()+
  scale_pattern_fill_brewer(palette = "Accent",
                            name = "Policy objective")+
  ylab("Percentage improvement relative to untargeted vaccination")+
  xlab("Policy objective")+
  theme(
    strip.text = element_text(size=20, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=20, face="bold",family="Times New Roman"),
    axis.text = element_text(size=17,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=17, face="bold",family="Times New Roman"),
    legend.title = element_text(size=20, face="bold",family="Times New Roman"),
    legend.text = element_text(size=20,family="Times New Roman"))



ggsave(
  "figures/Outcomes.png",
  plot = p,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 10,
  height = 6.5,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)











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
dat_full_states <- read.csv("data_outputs/main_text_full_states.csv")


# load base lines
uniform_time <- read.csv("data_outputs/main_text_uniform_states.csv")
no_vaccine_time <- read.csv("data_outputs/main_text_no_vaccine_states.csv")



###-------------------
### plot time series
###-------------------



t = 240 
N_groups = 8
N_states = 9
state = "E"
obj = "Infections"

dat <- dat_full_states

dat$time <- rep(1:t,3)
dat$objective <- c(rep("Infections",t), rep("YLL",t), rep("Deaths",t))

uniform_time$time <- 1:t
no_vaccine_time$time <- 1:t

uniform_time$objective <- c("uniform")
no_vaccine_time$objective <- c("no_vaccine")


dat <- rbind(dat,uniform_time,no_vaccine_time)


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


dat$objective <- factor(dat$objective, c("no_vaccine", "uniform","Deaths","YLL","Infections"))

p <- ggplot(dat, 
            aes(x = time, 
                y = 1000*value, 
                color = objective,
                linetype = objective))+
  geom_line(size = 1.5)+
  scale_color_brewer(palette="Dark2", 
                     name = "Policy", 
                     labels = c("No vaccines", "Untargeted", "Min death", "Min YLL", "Min infection"))+ 
  scale_linetype_manual( values = c("solid", "dotted", "12345678", "dotdash", "longdash"),
                         name = "Policy", 
                         labels = c("No vaccines", "Untargeted", "Min death", "Min YLL", "Min infection"))+
  theme_bw()+
  xlab("Time (days)")+
  ylab("Symptomatic infections per 1,000")+
  theme(
    strip.text = element_text(size=20, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=20, face="bold",family="Times New Roman"),
    axis.text = element_text(size=16,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=20, face="bold",family="Times New Roman"),
    legend.title = element_text(size=20, face="bold",family="Times New Roman"),
    legend.text = element_text(size=20,family="Times New Roman"),
    legend.position = c(0.75, 0.75),
    legend.key.width = unit(2, 'cm'),
    legend.background = element_rect(fill = "white", color = "black"))




ggsave(
  "figures/time_series.png",
  plot = p,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 8.0,
  height = 6.5,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)
