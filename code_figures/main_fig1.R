
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
dat_full_sol <- read.csv("data_outputs/main_text_full_policies_1.csv")
dat_full_errors <- read.csv("data_outputs/main_text_full_samples.csv")
dat_full_outcomes <- read.csv("data_outputs/main_text_full_outcomes.csv")
dat_full_states <- read.csv("data_outputs/main_text_full_states.csv")

# age only 
dat_age_sol <- read.csv("data_outputs/main_text_age_only_policies.csv")
dat_age_outcomes <- read.csv("data_outputs/main_text_age_only_outcomes.csv")

# static policy
dat_static_sol <- read.csv("data_outputs/main_text_static_policies.csv")
dat_static_outcomes <- read.csv("data_outputs/main_text_static_outcomes.csv")

# uniform policy
dat_uniform_outcomes <- read.csv("data_outputs/main_text_uniform_outcomes.csv")

###----------------------
### process policy data 
###----------------------

# full optimization 
names(dat_full_sol) <- c("Infections", "YLL", "Deaths") # label columns 
dat_full_sol$constraint <- c("Full") # add column for optimization constraints
dat_full_sol$col_num <- 1:48 # column number for age groups 

N_groups <- 8
dat_full_sol <- dat_full_sol %>% 
  reshape2::melt(id.var = c("constraint", "col_num")) %>% # reshape
  dplyr::mutate(age_group = col_num %% N_groups, # age groups 
                 period = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0))%>% # period 
  dplyr::select(-col_num) # remove extra column 
dat_full_sol$age_group <- mapvalues(dat_full_sol$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h")) 
dat_full_sol$period <- mapvalues(dat_full_sol$period, c(0:5), 1:6) 


# age only policy
names(dat_age_sol) <- c("Infections", "YLL", "Deaths")
dat_age_sol$constraint <- c("age_only")
dat_age_sol$col_num <- 1:36

N_groups <- 6
dat_age_sol <- dat_age_sol %>% 
  reshape2::melt(id.var = c("constraint", "col_num")) %>% # reshape
  dplyr::mutate(age_group = col_num %% N_groups, # age groups 
                period = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0))%>% # period 
  dplyr::select(-col_num) # remove extra column 
dat_age_sol$age_group <- mapvalues(dat_age_sol$age_group, c(1:5,0), c("a", "b", "c", "d","e","f")) 
dat_age_sol$period <- mapvalues(dat_age_sol$period, c(1:5,0), 1:6) 


# static policy
names(dat_static_sol) <- c("Infections", "YLL", "Deaths") # label columns 
dat_static_sol$constraint <- c("Full") # add column for optimization constraints
dat_static_sol$col_num <- 1:8 # column number for age groups 

N_groups <- 8
dat_static_sol <- dat_static_sol %>% 
  reshape2::melt(id.var = c("constraint", "col_num")) %>% # reshape
  dplyr::mutate(age_group = col_num %% N_groups, # age groups 
                period = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0))%>% # period 
  dplyr::select(-col_num) # remove extra column 
dat_static_sol$age_group <- mapvalues(dat_static_sol$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h")) 



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



###-----------------
### process errors 
###-----------------
# min and max values
dat_point_errors <- dat_full_errors %>% melt(id.var = c("Column49"))

N_groups <- 8

dat_point_errors <- dat_point_errors %>% 
  dplyr::mutate(col_num = as.numeric(gsub("Column", "", variable))) %>%
  dplyr::mutate(age_group = col_num %% N_groups,
                period = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0)) %>%
  dplyr::group_by(age_group, period, Column49)%>%
  dplyr::summarize(min = min(value),
                   max = max(value))









###--------------------
### comparison plot 
###--------------------

dat_all_outcomes
dat_uniform_outcomes$Outcome <- c("Infections", "YLL", "Deaths")
names(dat_uniform_outcomes) <- c("unif_value", "row", "Outcome")
dat_uniform_outcomes <- dat_uniform_outcomes %>% dplyr::select(-row)

dat_all_outcomes <- merge(dat_all_outcomes, dat_uniform_outcomes, by = "Outcome")

dat_all_outcomes$Outcome <- factor(dat_all_outcomes$Outcome, c("Infections", "YLL", "Deaths"))
dat_all_outcomes$Constraint <- factor(dat_all_outcomes$Constraint, c("Full", "age_only", "static"))

ggplot(dat_all_outcomes%>%
         dplyr::mutate(value = 1 - value/unif_value)) +
  geom_col_pattern(
    aes(x = Policy, y = as.numeric(value), pattern_fill = Policy, pattern_angle = Constraint), 
    position=position_dodge(width = 0.8), 
    width = 0.7,
    colour  = 'black',
    pattern_density= 0.99,
    pattern_key_scale_factor = 2.0,
    pattern = 'stripe',
    fill = "grey"
  )+facet_wrap(~Outcome, nrow = 1)+
  theme_bw()+
  scale_pattern_fill_brewer(palette = "Accent")




###--------------------
### full solution 
###--------------------




# get raw total 
dat_full_errors_summary <- dat_full_errors %>% melt(id.var = c("Column49"))

N_groups <- 8
N_periods <- 6

dat_full_errors_summary <- dat_full_errors_summary %>% 
  dplyr::mutate(col_num = as.numeric(gsub("Column", "", variable))) %>%
  dplyr::mutate(age_group = col_num %% N_groups,
                period = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0)) %>%
  dplyr::filter(value != 0)%>%
  dplyr::group_by(age_group, period, Column49)%>%
  dplyr::summarize(min = min(value),
                   max = max(value))

dat_full_errors_summary$age_group <- plyr::mapvalues(dat_full_errors_summary$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h")) 
dat_full_errors_summary$period <- mapvalues(dat_full_errors_summary$period, c(0:5), 1:6) 


names(dat_full_errors_summary) <- c("age_group", "period", "objective", "min", "max")


# get cumulative
#sample_counts <- table(dat_full_errors$Column49)
#dat_full_errors$sample_no <- c(1:sample_counts[1], 1:sample_counts[2],1:sample_counts[3])


dat_full_errors <- dat_full_errors %>% 
  dplyr::group_by(Column49)%>%
  dplyr::mutate(sample_no = 1:n())%>%
  dplyr::ungroup()



# melt
dat_full_errors_melt <- dat_full_errors %>% melt(id.var = c("Column49","sample_no"))


dat_full_errors_melt <- dat_full_errors_melt %>% 
  dplyr::mutate(col_num = as.numeric(gsub("Column", "", variable))) %>%
  dplyr::mutate(age_group = col_num %% N_groups,
                period = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0))

dat_full_errors_melt$age_group <- plyr::mapvalues(dat_full_errors_melt$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h")) 
dat_full_errors_melt$period <- mapvalues(dat_full_errors_melt$period, c(0:5), 1:6) 

dat_full_errors_melt <- dat_full_errors_melt %>% dplyr::select(-variable,-col_num)
# recast with time steps as columns
dat_full_errors_recast <- dcast(dat_full_errors_melt, age_group + Column49+ sample_no ~ period)
names(dat_full_errors_recast) <- c("age_group", "Policy", "sample_no", "one", "two", "three", "four", "five","six")






dat_cumulative_errors <- dat_full_errors_recast %>% # assumes sumpy is 10% per month 
  dplyr::mutate(sum_three = one+two+three, sum_six = one+two+three+four+five+six) %>%
  dplyr::filter(sum_three != 0, sum_six != 0)%>% # filter zeros 
  dplyr::group_by(age_group,Policy)%>%
  dplyr::summarize(min_cum_three = 0.1*min(sum_three),
                  max_cum_three = 0.1*max(sum_three),
                  min_cum_six = 0.1*min(sum_six),
                  max_cum_six = 0.1*max(sum_six))

dat_cumulative_errors$age_group <- plyr::mapvalues(dat_cumulative_errors$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h")) 

# get group sizes 

bins <- read.csv("data_transformed/population.csv")
bins <- bins %>% filter(ess_size == 0.4)
bins$age_group <- c("a","b","c","d*","e","f*","g","h")
bins$size <- bins$size/sum(bins$size)
bins <- bins %>% dplyr::select(age_group, size)


# divide by group sizes to get proportions
dat_cumulative_errors <- merge(dat_cumulative_errors, bins, by = "age_group") %>%
  dplyr::mutate(min_cum_three = min_cum_three/size,
                max_cum_three = max_cum_three/size,
                min_cum_six = min_cum_six/size,
                max_cum_six = max_cum_six/size)
  


names(dat_full_sol) <- c("constraint", "objective","value","age_group","period") 

dat_full_sol <- dat_full_sol %>% dplyr::select(-constraint)

dat_full_sol <- merge(dat_full_sol, dat_full_errors_summary, by = c("objective", "age_group","period" ))

p1 <- ggplot(
     dat_full_sol,
      aes(x = period, # aesthetics 
         fill = age_group, 
         y = 100*as.numeric(value)))+
  
    geom_bar(stat="identity", # use geom_bar with dodging to get grouped bar charts 
           position=position_dodge(width = 0.85), 
           width = 0.75,
           color = "black",
           size = 0.1)+
    geom_text(aes(label=age_group),  # place labels above each bar 
            position=position_dodge(width=0.85), 
            vjust=-0.75,
            family="Times New Roman",
            size = 2)+
    geom_errorbar(aes(ymin = 100*min, ymax = 100*max),
                position=position_dodge(width = 0.85))+
    facet_wrap(~objective, ncol = 1)+
    theme_minimal()+
    scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                    name = "Age group",
                    labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", 
                               "e: 40-59 ", "f: 40-59*", "g: 60 - 74", "h: 75+"))+
    xlab("Decision period (months)")+ # axis lables 
    ylab("Percent of vaccines")+
    ylim(0,100)+ 
    theme(
      strip.text = element_text(size=10, face="bold",family="Times New Roman"),
      axis.title.x = element_text(size=10,family="Times New Roman"),
      axis.text = element_text(size=10,family="Times New Roman", color = "black"),
      axis.title.y = element_text(size=10,family="Times New Roman"),
      legend.title = element_text(size=10, face="bold",family="Times New Roman"),
      legend.text = element_text(size=10,family="Times New Roman"),
      legend.key.size = unit(0.75, "line"),
      legend.position="bottom")



###-------------------
### cumulative plots
###-------------------

# get cumulative for optima

dat_full_sol_extended <- reshape2::dcast(dat_full_sol, constraint+variable+age_group ~ period) %>%
  dplyr::select(-constraint)

names(dat_full_sol_extended) <- c("Policy", "age_group", "one", "two", "three", "four", "five", "six")



dat_full_sol_cumulative <- dat_full_sol_extended %>% # assumes sumpy is 10% per month 
  dplyr::mutate(sum_three = one+two+three, sum_six = one+two+three+four+five+six) %>%
  dplyr::filter(sum_three != 0, sum_six != 0)%>% # filter zeros 
  dplyr::group_by(age_group,Policy)%>%
  dplyr::summarize(three = 0.1*sum_three,
                   six = 0.1*sum_six)

dat_full_sol_cumulative_melt <- dat_full_sol_cumulative %>%
  reshape2::melt(id.vars = c("age_group" , "Policy"))

dat_full_sol_cumulative_melt$period <- c(rep(3, 24),rep(6, 24)) 






dat_cumulative_errors_melt <- dat_cumulative_errors %>%
  reshape2::melt(id.vars = c("age_group" , "Policy", "size"))

dat_cumulative_errors_melt$period<- c(rep(3, 48),rep(6, 48)) 
dat_cumulative_errors_melt$min_max<- c(rep("min", 24),rep("max", 24),
                                       rep("min", 24),rep("max", 24)) 

dat_cumulative_errors_melt <- dcast(dat_cumulative_errors_melt, 
                                    age_group + Policy+ size + period ~ min_max)




data_cumulative <- merge(dat_full_sol_cumulative_melt,dat_cumulative_errors_melt,
                         by = c("age_group","Policy","period")) %>%
  dplyr::mutate(value = value/size)

names(data_cumulative) <- c("age_group", "objective", "period", "variable", "value", "size", "max", "min")

#acc <- c()
#acc2 <- c()
#for(i in 1:nrow(data_cumulative)){
#  if(data_cumulative$max[i] > 1){
#    acc <- append(acc, 1)
#  }else{
#    acc <- append(acc, data_cumulative$max[i])
#  }
#  if(data_cumulative$value[i] > 1){
#    acc2 <- append(acc2, 1)
#  }else{
#    acc2 <- append(acc2, data_cumulative$value[i])
#  }
#}

#data_cumulative$max <- acc
#data_cumulative$value <- acc2
p2 <- ggplot(
    data_cumulative,
    aes(x = as.factor(period), # aesthetics 
        fill = age_group, 
       y = 100*as.numeric(value)))+
  
    geom_bar(stat="identity", # use geom_bar with dodging to get grouped bar charts 
           position=position_dodge(width = 0.85), 
           width = 0.75,
           color = "black",
           size = 0.1)+
    geom_text(aes(label=age_group),  # place labels above each bar 
            position=position_dodge(width=0.85), 
            vjust=-0.75,
            family="Times New Roman",
            size = 2)+
    geom_errorbar(aes(ymin = 100*min, ymax = 100*max),
                position=position_dodge(width = 0.85),
                size = 0.5)+
    facet_wrap(~objective, ncol = 1)+
    theme_minimal()+
    scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                    name = "Age group",
                    labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", 
                               "e: 40-59 ", "f: 40-59*", "g: 60 - 74", "h: 75+"))+
    xlab("Decision period (months)")+ 
    ylab("Percent of age group (cumulative)")+
    theme(
      strip.text = element_text(size=10, face="bold",family="Times New Roman"),
      axis.title.x = element_text(size=10,family="Times New Roman"),
      axis.text = element_text(size=10,family="Times New Roman", color = "black"),
      axis.title.y = element_text(size=10,family="Times New Roman"),
      legend.title = element_text(size=10, face="bold",family="Times New Roman"),
      legend.text = element_text(size=10,family="Times New Roman"),
      legend.key.size = unit(0.75, "line"),
      legend.position="bottom")





p <- lemon::grid_arrange_shared_legend(p1, p2, ncol=2, widths = c(5,2.0))


###-------------------
### plot time series
###-------------------

# load base lines
uniform_time <- read.csv("data_outputs/main_text_uniform_states.csv")
no_vaccine_time <- read.csv("data_outputs/main_text_no_vaccine_states.csv")

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

ggplot(dat, 
       aes(x = time, 
           y = 100*value, 
           color = objective,
           linetype = objective))+
  geom_line()+
  scale_color_brewer(palette="Dark2", 
                     name = "Policy", 
                     labels = c("No vaccines", "Proportional", "Min death", "Min YLL", "Min infection"))+ 
  scale_linetype_manual( values = c("solid", "dotted", "12345678", "dotdash", "longdash"),
                         name = "Policy", 
                         labels = c("No vaccines", "Proportional", "Min death", "Min YLL", "Min infection"))+
  theme_bw()+
  xlab("Time")+
  ylab("Symptomatic infections per 1000")+
  theme(text = element_text(family = "Times New Roman"))










