

###-------------
### libraries
###-------------
library(dplyr)
library(plyr)
library(ggplot2)
library(reshape2)
library(ggpattern)
library(viridis)
###-------------
### set wd
###-------------

setwd("~/desktop/Dynamic_Vaccine_Allocation")



dat_scenarions <- data.frame(age_group = c("!"), Policy= c("!"), variable = c("!"), 
                             value = c(1), period = c(1), size = c(1), scenario = c("name"))


sc_names <- c("Base scenario",
              "High init. infect.",
              "Strong NPI",
              "Weak NPI",
              "Weak vaccine",
              "Weak vaccine 60+",
              "Even suceptibility",
              "Low supply",
              "Ramp up",
              "Open Schools ",
              "High contacts")

fn <- c("data_outputs/main_text_full_policies_1.csv",
        "data_outputs/high_initial_infections_policies.csv",
        "data_outputs/strong_NPI_policies.csv",
        "data_outputs/weak_NPI_policies.csv",
        "data_outputs/Low_effectiveness_policies.csv",
        "data_outputs/Low_effectiveness_60_policies.csv",
        "data_outputs/high_sucept_children_policies.csv",
        "data_outputs/low_supply_policies.csv",
        "data_outputs/Ramp_up_policies.csv",
        "data_outputs/schools_open_policies.csv",
        "data_outputs/high_contacts_social_policies.csv")



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
  ylab("Alternative scenario")+
  theme(
    strip.text = element_text(size=24, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=24, face="bold",family="Times New Roman"),
    axis.text.y = element_text(size=14,family="Times New Roman", color = "black"),
    axis.text.x = element_text(size=16,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=24, face="bold",family="Times New Roman"),
    legend.title = element_text(size=22, face="bold",family="Times New Roman"),
    legend.text = element_text(size=18,family="Times New Roman"),
    legend.position = "bottom")

ggsave(
  "figures/Heat_Map.png",
  plot = p,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 7.75,
  height = 9,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)













