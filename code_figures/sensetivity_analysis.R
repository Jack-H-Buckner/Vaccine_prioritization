

###-------------
### libraries
###-------------
library(dplyr)
library(plyr)
library(ggplot2)
library(reshape2)
library(ggpattern)
library(viridis)
library(gridExtra)
###-------------
### set wd
###-------------


setwd("~/desktop/Dynamic_Vaccine_Allocation")









#####################################
#####################################
###                               ###                               
###       NPI                     ###
###                               ###   
##################################### 
##################################### 


dat_scenarions <- data.frame(age_group = c("!"), Policy= c("!"), variable = c("!"), 
                             value = c(1), period = c(1), size = c(1), scenario = c("name"))


sc_names <- c("20% (2.0)",
              "40% (1.5)",
              "60% (1.0)",
              "80% (0.5)")

fn <- c("data_outputs/NPI_02_policies.csv",
        "data_outputs/NPI_04_policies.csv",
        "data_outputs/NPI_06_policies.csv",
        "data_outputs/NPI_08_policies.csv")



for( i in 1:length(fn)){
  ###-------------
  ### load data 
  ###-------------
  print(i)
  
  # full solution
  dat_full_sol <- read.csv(fn[i])
  
  
  
  ###--------------------------
  ### process point estimates
  ###--------------------------
  
  # add names and group labels to full solution
  names(dat_full_sol) <- c("Infections", "YLL", "Deaths") # label columns 
  dat_full_sol$constraint <- c("Full") # add column for optimization constraints
  dat_full_sol$col_num <- 1:48 # column number for age groups 
  
  N_groups <- 8
  dat_full_sol <- dat_full_sol %>% 
    reshape2::melt(id.var = c("constraint", "col_num")) %>% # reshape
    dplyr::mutate(age_group = col_num %% N_groups, # age groups 
                  period = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0))%>% # period 
    dplyr::select(-col_num) # remove extra column 
  dat_full_sol$age_group <- mapvalues(dat_full_sol$age_group, c(1:7,0), c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 
  dat_full_sol$age_group <- factor(dat_full_sol$age_group,c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 
  dat_full_sol$period <- mapvalues(dat_full_sol$period, c(0:5), 1:6) 
  
  
  
  ###--------------------------
  ### process cumulative estimates
  ###--------------------------
  
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
  
  
  
  ## load and merge pop sizes   
  
  bins <- read.csv("data_transformed/population.csv")
  bins <- bins %>% filter(ess_size == 0.4)
  bins$age_group <- c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")
  bins$size <- bins$size/sum(bins$size)
  bins <- bins %>% dplyr::select(age_group, size)
  
  data_cumulative <- merge(dat_full_sol_cumulative_melt, bins, by = "age_group") %>%
    dplyr::mutate(value = value/size)
  
  names(data_cumulative) <- c("age_group", "Policy", "variable", "value", "period", "size")
  
  
  acc <- c()
  
  for(j in 1:nrow(data_cumulative)){
    if(data_cumulative$value[j] > 1){
      acc <- append(acc, 1)
    }else{
      acc <- append(acc, data_cumulative$value[j])
    }
  }
  
  data_cumulative$value <- acc
  
  print(sc_names[i])
  print(i)
  data_cumulative$scenario <- sc_names[i]
  
  
  dat_scenarions <- rbind(dat_scenarions , data_cumulative)
  
}

dat <- dat_scenarions %>% filter(age_group != "!")


dat$scenario <- factor(dat$scenario, rev(sc_names))

# reorder outcomes
dat$Policy <- factor(dat$Policy, c("Deaths", "YLL", "Infections"))
dat$age_group <- factor(dat$age_group,c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 

dat_NPI <- dat
p_NPI <- ggplot(dat %>% filter(period == 3),
            aes(x = age_group, y = scenario, fill = 100*value))+
  theme_minimal()+
  geom_tile(height = 0.9)+
  facet_wrap(~Policy, ncol = 1)+
  scale_fill_viridis(name = "Perecent of group")+
  ggtitle("Effectiveness of NPI")+
  xlab("Demographic  group")+ 
  ylab("NPI effectiveness (repropductive number)")+
  theme(
    plot.title = element_text(size = 18, face="bold",family="Times New Roman"),
    strip.text = element_text(size=18, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=18, face="bold",family="Times New Roman"),
    axis.text.y = element_text(size=14,family="Times New Roman", color = "black"),
    axis.text.x = element_text(size=14,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=18, face="bold",family="Times New Roman"),
    legend.title = element_text(size=18, face="bold",family="Times New Roman"),
    legend.text = element_text(size=16,family="Times New Roman"),
    legend.position = "bottom")

ggsave(
  "figures/NPI_Heat_Map.png",
  plot = p_NPI,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 9,
  height = 7,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)












#####################################
#####################################
###                               ###                               
###   efficacy                    ###
###                               ###   
##################################### 
##################################### 


dat_scenarions <- data.frame(age_group = c("!"), Policy= c("!"), variable = c("!"), 
                             value = c(1), period = c(1), size = c(1), scenario = c("name"))


sc_names <- rev(c("40%",
              "55%",
              "70%",
              "85%",
              "`90%",
              "100%"))

fn <- rev(c("data_outputs/V_eff_04_policies.csv",
        "data_outputs/V_eff_055_policies.csv",
        "data_outputs/V_eff_07_policies.csv",
        "data_outputs/V_eff_085_policies.csv",
        "data_outputs/main_text_full_policies.csv",
        "data_outputs/V_eff_10_policies.csv"))



for( i in 1:length(fn)){
  ###-------------
  ### load data 
  ###-------------
  print(i)
  
  # full solution
  dat_full_sol <- read.csv(fn[i])
  
  
  
  ###--------------------------
  ### process point estimates
  ###--------------------------
  
  # add names and group labels to full solution
  names(dat_full_sol) <- c("Infections", "YLL", "Deaths") # label columns 
  dat_full_sol$constraint <- c("Full") # add column for optimization constraints
  dat_full_sol$col_num <- 1:48 # column number for age groups 
  
  N_groups <- 8
  dat_full_sol <- dat_full_sol %>% 
    reshape2::melt(id.var = c("constraint", "col_num")) %>% # reshape
    dplyr::mutate(age_group = col_num %% N_groups, # age groups 
                  period = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0))%>% # period 
    dplyr::select(-col_num) # remove extra column 
  dat_full_sol$age_group <- mapvalues(dat_full_sol$age_group, c(1:7,0), c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 
  dat_full_sol$age_group <- factor(dat_full_sol$age_group,c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 
  dat_full_sol$period <- mapvalues(dat_full_sol$period, c(0:5), 1:6) 
  
  
  
  ###--------------------------
  ### process cumulative estimates
  ###--------------------------
  
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
  
  
  
  ## load and merge pop sizes   
  
  bins <- read.csv("data_transformed/population.csv")
  bins <- bins %>% filter(ess_size == 0.4)
  bins$age_group <- c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")
  bins$size <- bins$size/sum(bins$size)
  bins <- bins %>% dplyr::select(age_group, size)
  
  data_cumulative <- merge(dat_full_sol_cumulative_melt, bins, by = "age_group") %>%
    dplyr::mutate(value = value/size)
  
  names(data_cumulative) <- c("age_group", "Policy", "variable", "value", "period", "size")
  
  
  acc <- c()
  
  for(j in 1:nrow(data_cumulative)){
    if(data_cumulative$value[j] > 1){
      acc <- append(acc, 1)
    }else{
      acc <- append(acc, data_cumulative$value[j])
    }
  }
  
  data_cumulative$value <- acc
  
  print(sc_names[i])
  print(i)
  data_cumulative$scenario <- sc_names[i]
  
  
  dat_scenarions <- rbind(dat_scenarions , data_cumulative)
  
}

dat <- dat_scenarions %>% filter(age_group != "!")


dat$scenario <- factor(dat$scenario, rev(sc_names))

# reorder outcomes
dat$Policy <- factor(dat$Policy, c("Deaths", "YLL", "Infections"))
dat$age_group <- factor(dat$age_group,c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 

dat_eff <- dat

p_eff <- ggplot(dat %>% filter(period == 3),
            aes(x = age_group, y = scenario, fill = 100*value))+
  theme_minimal()+
  geom_tile(height = 0.9)+
  facet_wrap(~Policy, ncol = 1)+
  scale_fill_viridis(name = "Perecent of group")+
  ggtitle("Vaccine effectiveness")+
  xlab("Demographic  group")+ 
  ylab("Vaccine effectiveness")+
  theme(
    plot.title = element_text(size = 18, face="bold",family="Times New Roman"),
    strip.text = element_text(size=18, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=18, face="bold",family="Times New Roman"),
    axis.text = element_text(size=14,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=18, face="bold",family="Times New Roman"),
    legend.title = element_text(size=18, face="bold",family="Times New Roman"),
    legend.text = element_text(size=16,family="Times New Roman"))

ggsave(
  "figures/V_eff_Heat_Map.png",
  plot = p_eff,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 9,
  height = 7,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)














#####################################
#####################################
###                               ###                               
###   initial infections          ###
###                               ###   
##################################### 
##################################### 


dat_scenarions <- data.frame(age_group = c("!"), Policy= c("!"), variable = c("!"), 
                             value = c(1), period = c(1), size = c(1), scenario = c("name"))


sc_names <- c("20",
              "10",
              "`5",
              "2.5",
              "1")
fn <- c("data_outputs/IC_tests_0_02_policies.csv",
        "data_outputs/IC_tests_0_01_policies.csv",
        "data_outputs/main_text_full_policies.csv",
        "data_outputs/IC_tests_0_0025_policies.csv",
        "data_outputs/IC_tests_0_001_policies.csv")



for( i in 1:length(fn)){
  ###-------------
  ### load data 
  ###-------------
  print(i)
  
  # full solution
  dat_full_sol <- read.csv(fn[i])
  
  
  
  ###--------------------------
  ### process point estimates
  ###--------------------------
  
  # add names and group labels to full solution
  names(dat_full_sol) <- c("Infections", "YLL", "Deaths") # label columns 
  dat_full_sol$constraint <- c("Full") # add column for optimization constraints
  dat_full_sol$col_num <- 1:48 # column number for age groups 
  
  N_groups <- 8
  dat_full_sol <- dat_full_sol %>% 
    reshape2::melt(id.var = c("constraint", "col_num")) %>% # reshape
    dplyr::mutate(age_group = col_num %% N_groups, # age groups 
                  period = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0))%>% # period 
    dplyr::select(-col_num) # remove extra column 
  dat_full_sol$age_group <- mapvalues(dat_full_sol$age_group, c(1:7,0), c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 
  dat_full_sol$age_group <- factor(dat_full_sol$age_group,c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 
  dat_full_sol$period <- mapvalues(dat_full_sol$period, c(0:5), 1:6) 
  
  
  
  ###--------------------------
  ### process cumulative estimates
  ###--------------------------
  
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
  
  
  
  ## load and merge pop sizes   
  
  bins <- read.csv("data_transformed/population.csv")
  bins <- bins %>% filter(ess_size == 0.4)
  bins$age_group <- c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")
  bins$size <- bins$size/sum(bins$size)
  bins <- bins %>% dplyr::select(age_group, size)
  
  data_cumulative <- merge(dat_full_sol_cumulative_melt, bins, by = "age_group") %>%
    dplyr::mutate(value = value/size)
  
  names(data_cumulative) <- c("age_group", "Policy", "variable", "value", "period", "size")
  
  
  acc <- c()
  
  for(j in 1:nrow(data_cumulative)){
    if(data_cumulative$value[j] > 1){
      acc <- append(acc, 1)
    }else{
      acc <- append(acc, data_cumulative$value[j])
    }
  }
  
  data_cumulative$value <- acc
  
  print(sc_names[i])
  print(i)
  data_cumulative$scenario <- sc_names[i]
  
  
  dat_scenarions <- rbind(dat_scenarions , data_cumulative)
  
}

dat <- dat_scenarions %>% filter(age_group != "!")


dat$scenario <- factor(dat$scenario, rev(sc_names))

# reorder outcomes
dat$Policy <- factor(dat$Policy, c("Deaths", "YLL", "Infections"))
dat$age_group <- factor(dat$age_group,c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 
dat_IC <- dat
p_IC <- ggplot(dat %>% filter(period == 3),
            aes(x = age_group, y = scenario, fill = 100*value))+
  theme_minimal()+
  geom_tile(height = 0.9)+
  facet_wrap(~Policy, ncol = 1)+
  scale_fill_viridis(name = "Perecent of group")+
  ggtitle("Initial infections")+
  xlab("Demographic  group")+ 
  ylab("Initial number of infections per 1000")+
  theme(
    plot.title = element_text(size = 18, face="bold",family="Times New Roman"),
    strip.text = element_text(size=18, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=18, face="bold",family="Times New Roman"),
    axis.text = element_text(size=14,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=18, face="bold",family="Times New Roman"),
    legend.title = element_text(size=18, face="bold",family="Times New Roman"),
    legend.text = element_text(size=14,family="Times New Roman"),
    legend.position = "bottom")

ggsave(
  "figures/IC_Heat_Map.png",
  plot = p_IC,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 9,
  height = 7,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)














#####################################
#####################################
###                               ###                               
###   Supply                      ###
###                               ###   
##################################### 
##################################### 


dat_scenarions <- data.frame(age_group = c("!"), Policy= c("!"), variable = c("!"), 
                             value = c(1), period = c(1), size = c(1), scenario = c("name"))


sc_names <- c("15%","`10%","7.5%","5.0%","3.75%")
fn <- c("data_outputs/supply_20_policies.csv",
        "data_outputs/main_text_full_policies.csv",
        "data_outputs/supply_40_policies.csv",
        "data_outputs/supply_60_policies.csv",
        "data_outputs/supply_80_policies.csv")



for( i in 1:length(fn)){
  ###-------------
  ### load data 
  ###-------------
  print(i)
  
  # full solution
  dat_full_sol <- read.csv(fn[i])
  
  
  
  ###--------------------------
  ### process point estimates
  ###--------------------------
  
  # add names and group labels to full solution
  names(dat_full_sol) <- c("Infections", "YLL", "Deaths") # label columns 
  dat_full_sol$constraint <- c("Full") # add column for optimization constraints
  dat_full_sol$col_num <- 1:48 # column number for age groups 
  
  N_groups <- 8
  dat_full_sol <- dat_full_sol %>% 
    reshape2::melt(id.var = c("constraint", "col_num")) %>% # reshape
    dplyr::mutate(age_group = col_num %% N_groups, # age groups 
                  period = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0))%>% # period 
    dplyr::select(-col_num) # remove extra column 
  dat_full_sol$age_group <- mapvalues(dat_full_sol$age_group, c(1:7,0), c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 
  dat_full_sol$age_group <- factor(dat_full_sol$age_group,c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 
  dat_full_sol$period <- mapvalues(dat_full_sol$period, c(0:5), 1:6) 
  
  
  
  ###--------------------------
  ### process cumulative estimates
  ###--------------------------
  
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
  
  
  
  ## load and merge pop sizes   
  
  bins <- read.csv("data_transformed/population.csv")
  bins <- bins %>% filter(ess_size == 0.4)
  bins$age_group <- c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")
  bins$size <- bins$size/sum(bins$size)
  bins <- bins %>% dplyr::select(age_group, size)
  
  data_cumulative <- merge(dat_full_sol_cumulative_melt, bins, by = "age_group") %>%
    dplyr::mutate(value = value/size)
  
  names(data_cumulative) <- c("age_group", "Policy", "variable", "value", "period", "size")
  
  
  acc <- c()
  
  for(j in 1:nrow(data_cumulative)){
    if(data_cumulative$value[j] > 1){
      acc <- append(acc, 1)
    }else{
      acc <- append(acc, data_cumulative$value[j])
    }
  }
  
  data_cumulative$value <- acc
  
  print(sc_names[i])
  print(i)
  data_cumulative$scenario <- sc_names[i]
  
  
  dat_scenarions <- rbind(dat_scenarions , data_cumulative)
  
}

dat <- dat_scenarions %>% filter(age_group != "!")


dat$scenario <- factor(dat$scenario, rev(sc_names))

# reorder outcomes
dat$Policy <- factor(dat$Policy, c("Deaths", "YLL", "Infections"))
dat$age_group <- factor(dat$age_group,c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 

dat_supply <- dat
p_Supply <- ggplot(dat %>% filter(period == 3),
            aes(x = age_group, y = scenario, fill = 100*value))+
  theme_minimal()+
  geom_tile(height = 0.9)+
  facet_wrap(~Policy, ncol = 1)+
  scale_fill_viridis(name = "Perecent of group")+
  ggtitle("Vaccine supply")+
  xlab("Demographic  group")+ 
  ylab("Percent vaccniated per month")+
  theme(
    plot.title = element_text(size = 18, face="bold",family="Times New Roman"),
    strip.text = element_text(size=18, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=18, face="bold",family="Times New Roman"),
    axis.text = element_text(size=14,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=18, face="bold",family="Times New Roman"),
    legend.title = element_text(size=18, face="bold",family="Times New Roman"),
    legend.text = element_text(size=14,family="Times New Roman"),
    legend.position = "bottom")

ggsave(
  "figures/Supply_Heat_Map.png",
  plot = p_Supply,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 9,
  height = 7,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)













#####################################
#####################################
###                               ###                               
###   work contacts               ###
###                               ###   
##################################### 
##################################### 


dat_scenarions <- data.frame(age_group = c("!"), Policy= c("!"), variable = c("!"), 
                             value = c(1), period = c(1), size = c(1), scenario = c("name"))


sc_names <- c("30% - 40%",
              "40% - 70%",
              "50% - 90%",
              "60% - 110%")
fn <- c("data_outputs/work_contacts_0304_policies.csv",
        "data_outputs/work_contacts_0407_policies.csv",
        "data_outputs/work_contacts_0509_policies.csv",
        "data_outputs/work_contacts_0611_policies.csv")



for( i in 1:length(fn)){
  ###-------------
  ### load data 
  ###-------------
  print(i)
  
  # full solution
  dat_full_sol <- read.csv(fn[i])
  
  
  
  ###--------------------------
  ### process point estimates
  ###--------------------------
  
  # add names and group labels to full solution
  names(dat_full_sol) <- c("Infections", "YLL", "Deaths") # label columns 
  dat_full_sol$constraint <- c("Full") # add column for optimization constraints
  dat_full_sol$col_num <- 1:48 # column number for age groups 
  
  N_groups <- 8
  dat_full_sol <- dat_full_sol %>% 
    reshape2::melt(id.var = c("constraint", "col_num")) %>% # reshape
    dplyr::mutate(age_group = col_num %% N_groups, # age groups 
                  period = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0))%>% # period 
    dplyr::select(-col_num) # remove extra column 
  dat_full_sol$age_group <- mapvalues(dat_full_sol$age_group, c(1:7,0), c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 
  dat_full_sol$age_group <- factor(dat_full_sol$age_group,c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 
  dat_full_sol$period <- mapvalues(dat_full_sol$period, c(0:5), 1:6) 
  
  
  
  ###--------------------------
  ### process cumulative estimates
  ###--------------------------
  
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
  
  
  
  ## load and merge pop sizes   
  
  bins <- read.csv("data_transformed/population.csv")
  bins <- bins %>% filter(ess_size == 0.4)
  bins$age_group <- c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")
  bins$size <- bins$size/sum(bins$size)
  bins <- bins %>% dplyr::select(age_group, size)
  
  data_cumulative <- merge(dat_full_sol_cumulative_melt, bins, by = "age_group") %>%
    dplyr::mutate(value = value/size)
  
  names(data_cumulative) <- c("age_group", "Policy", "variable", "value", "period", "size")
  
  
  acc <- c()
  
  for(j in 1:nrow(data_cumulative)){
    if(data_cumulative$value[j] > 1){
      acc <- append(acc, 1)
    }else{
      acc <- append(acc, data_cumulative$value[j])
    }
  }
  
  data_cumulative$value <- acc
  
  print(sc_names[i])
  print(i)
  data_cumulative$scenario <- sc_names[i]
  
  
  dat_scenarions <- rbind(dat_scenarions , data_cumulative)
  
}

dat <- dat_scenarions %>% filter(age_group != "!")


dat$scenario <- factor(dat$scenario, rev(sc_names))

# reorder outcomes
dat$Policy <- factor(dat$Policy, c("Deaths", "YLL", "Infections"))
dat$age_group <- factor(dat$age_group,c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 
p <- ggplot(dat %>% filter(period == 3),
            aes(x = age_group, y = scenario, fill = 100*value))+
  theme_minimal()+
  geom_tile(height = 0.9)+
  facet_wrap(~Policy, ncol = 1)+
  scale_fill_viridis(name = "Percent of group")+
  xlab("Demographic  group")+ 
  ylab("Work contact rates relative to pre-COVID-19 average")+
  theme(
    strip.text = element_text(size=18, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=18, face="bold",family="Times New Roman"),
    axis.text = element_text(size=14,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=18, face="bold",family="Times New Roman"),
    legend.title = element_text(size=18, face="bold",family="Times New Roman"),
    legend.text = element_text(size=18,family="Times New Roman"))

ggsave(
  "figures/Work_Heat_Map.png",
  plot = p,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 5.75,
  height = 4,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)















#####################################
#####################################
###                               ###                               
###   social contacts             ###
###                               ###   
##################################### 
##################################### 


dat_scenarions <- data.frame(age_group = c("!"), Policy= c("!"), variable = c("!"), 
                             value = c(1), period = c(1), size = c(1), scenario = c("name"))


sc_names <- c("20%",
              "30%",
              "40%",
              "50%",
              "60%")
fn <- c("data_outputs/social_contacts_20_policies.csv",
        "data_outputs/social_contacts_30_policies.csv",
        "data_outputs/social_contacts_40_policies.csv",
        "data_outputs/social_contacts_50_policies.csv",
        "data_outputs/social_contacts_60_policies.csv")



for( i in 1:length(fn)){
  ###-------------
  ### load data 
  ###-------------
  print(i)
  
  # full solution
  dat_full_sol <- read.csv(fn[i])
  
  
  
  ###--------------------------
  ### process point estimates
  ###--------------------------
  
  # add names and group labels to full solution
  names(dat_full_sol) <- c("Infections", "YLL", "Deaths") # label columns 
  dat_full_sol$constraint <- c("Full") # add column for optimization constraints
  dat_full_sol$col_num <- 1:48 # column number for age groups 
  
  N_groups <- 8
  dat_full_sol <- dat_full_sol %>% 
    reshape2::melt(id.var = c("constraint", "col_num")) %>% # reshape
    dplyr::mutate(age_group = col_num %% N_groups, # age groups 
                  period = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0))%>% # period 
    dplyr::select(-col_num) # remove extra column 
  dat_full_sol$age_group <- mapvalues(dat_full_sol$age_group, c(1:7,0), c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 
  dat_full_sol$age_group <- factor(dat_full_sol$age_group,c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 
  dat_full_sol$period <- mapvalues(dat_full_sol$period, c(0:5), 1:6) 
  
  
  
  ###--------------------------
  ### process cumulative estimates
  ###--------------------------
  
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
  
  
  
  ## load and merge pop sizes   
  
  bins <- read.csv("data_transformed/population.csv")
  bins <- bins %>% filter(ess_size == 0.4)
  bins$age_group <- c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")
  bins$size <- bins$size/sum(bins$size)
  bins <- bins %>% dplyr::select(age_group, size)
  
  data_cumulative <- merge(dat_full_sol_cumulative_melt, bins, by = "age_group") %>%
    dplyr::mutate(value = value/size)
  
  names(data_cumulative) <- c("age_group", "Policy", "variable", "value", "period", "size")
  
  
  acc <- c()
  
  for(j in 1:nrow(data_cumulative)){
    if(data_cumulative$value[j] > 1){
      acc <- append(acc, 1)
    }else{
      acc <- append(acc, data_cumulative$value[j])
    }
  }
  
  data_cumulative$value <- acc
  
  print(sc_names[i])
  print(i)
  data_cumulative$scenario <- sc_names[i]
  
  
  dat_scenarions <- rbind(dat_scenarions , data_cumulative)
  
}

dat <- dat_scenarions %>% filter(age_group != "!")


dat$scenario <- factor(dat$scenario, rev(sc_names))

# reorder outcomes
dat$Policy <- factor(dat$Policy, c("Deaths", "YLL", "Infections"))
dat$age_group <- factor(dat$age_group,c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 
p <- ggplot(dat %>% filter(period == 3),
            aes(x = age_group, y = scenario, fill = 100*value))+
  theme_minimal()+
  geom_tile(height = 0.9)+
  facet_wrap(~Policy, ncol = 1)+
  scale_fill_viridis(name = "Percent of group")+
  xlab("Demographic  group")+ 
  ylab("Social contact rates relative to pre-COVID-19 average")+
  theme(
    strip.text = element_text(size=12, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=12, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=12, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=12,family="Times New Roman"))

ggsave(
  "figures/social_Heat_Map.png",
  plot = p,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 5.75,
  height = 4,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)






### joint plot


p1 <- lemon::grid_arrange_shared_legend( p_NPI,p_IC, ncol=2)
p2 <- lemon::grid_arrange_shared_legend(p_Supply, p_eff, ncol=2)



ggsave(
  "figures/combined_map1.png",
  plot = p1,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 12,
  height = 6,
  units = c("in", "cm", "mm"),
  dpi = 300,
)

ggsave(
  "figures/combined_map2.png",
  plot = p2,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 12,
  height = 6,
  units = c("in", "cm", "mm"),
  dpi = 300,
)


p <- grid.arrange(
  p_Supply, p_NPI, p_eff, p_IC, ncol = 2, widths = c(2,2)
)



dat_supply$test <- c("supply")
dat_IC$test <- c("IC")
dat_NPI$test <- c("NPI")
dat_eff$test <- c("Eff")

dat <- rbind(dat_supply, dat_IC, dat_NPI, dat_eff)
