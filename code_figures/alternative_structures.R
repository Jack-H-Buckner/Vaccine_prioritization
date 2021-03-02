
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
dat_full_sol <- read.csv("data_outputs/alt_20_policies.csv")



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
dat_full_sol$age_group <- mapvalues(dat_full_sol$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h")) 
dat_full_sol$period <- mapvalues(dat_full_sol$period, c(0:5), 1:6) 




p1 <- ggplot(
  dat_full_sol,
  aes(x = as.character(period), # aesthetics 
      fill = age_group, 
      y = 100*as.numeric(value)))+
  
  geom_bar(stat="identity", # use geom_bar with dodging to get grouped bar charts 
           position=position_dodge(width = 0.85), 
           width = 0.75,
           color = "black",
           size = 0.1)+
  geom_text(aes(label=age_group, y = 100*as.numeric(value)),  # place labels above each bar 
            position=position_dodge(width=0.85), 
            vjust=-0.75,
            family="Times New Roman",
            size = 2)+
  facet_wrap(~variable, ncol = 1)+
  theme_minimal()+
  scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                    name = "Age group",
                    labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", 
                               "e: 40-59 ", "f: 40-59*", "g: 60 - 74", "h: 75+"))+
  xlab("Decision period")+ # axis lables 
  ylab("Percent of vaccines")+
  ylim(0,110)+
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10,family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=10,family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(0.75, "line"),
    legend.position="bottom")








###--------------------------
### cumulative values
###--------------------------








# get group sizes 

bins <- read.csv("data_transformed/population.csv")
bins <- bins %>% filter(ess_size == 0.2)
bins$age_group <- c("a","b","c","d*","e","f*","g","h")
bins$size <- bins$size/sum(bins$size)
bins <- bins %>% dplyr::select(age_group, size)



# get cumulative for optima


dat_full_sol <- read.csv("data_outputs/alt_20_policies.csv")
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
dat_full_sol$age_group <- mapvalues(dat_full_sol$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h")) 
dat_full_sol$period <- mapvalues(dat_full_sol$period, c(0:5), 1:6) 


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

dat_full_sol_cumulative_melt <- merge(dat_full_sol_cumulative_melt, bins, by = "age_group")





dat_full_sol_cumulative_melt <- dat_full_sol_cumulative_melt %>% dplyr::mutate(value = as.numeric(value)/size)

acc <- c()

for(i in 1:nrow(dat_full_sol_cumulative_melt)){
  if(dat_full_sol_cumulative_melt$value[i] > 1){
    acc <- append(acc, 1)
  }else{
    acc <- append(acc, dat_full_sol_cumulative_melt$value[i])
  }
}

dat_full_sol_cumulative_melt$value <- acc

p2 <- ggplot(
  dat_full_sol_cumulative_melt,
  aes(x = as.factor(variable), # aesthetics 
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
            size = 4)+
  facet_wrap(~Policy, ncol = 1)+
  theme_minimal()+
  scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                    name = "Age group",
                    labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", 
                               "e: 40-59 ", "f: 40-59*", "g: 60 - 74", "h: 75+"))+
  xlab("Decision period (months)")+ 
  ylab("Percent of age group (cumulative)")+
  ylim(0,110)+
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

ggsave(
  "figures/alt_20_detailed_policy.png",
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
### load data 
###-------------

# full solution
dat_full_sol <- read.csv("data_outputs/alt_40_cl_policies.csv")



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
dat_full_sol$age_group <- mapvalues(dat_full_sol$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h")) 
dat_full_sol$period <- mapvalues(dat_full_sol$period, c(0:5), 1:6) 




p1 <- ggplot(
  dat_full_sol,
  aes(x = as.character(period), # aesthetics 
      fill = age_group, 
      y = 100*as.numeric(value)))+
  
  geom_bar(stat="identity", # use geom_bar with dodging to get grouped bar charts 
           position=position_dodge(width = 0.85), 
           width = 0.75,
           color = "black",
           size = 0.1)+
  geom_text(aes(label=age_group, y = 100*as.numeric(value)),  # place labels above each bar 
            position=position_dodge(width=0.85), 
            vjust=-0.75,
            family="Times New Roman",
            size = 2)+
  facet_wrap(~variable, ncol = 1)+
  theme_minimal()+
  scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                    name = "Age group",
                    labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", 
                               "e: 40-59 ", "f: 40-59*", "g: 60 - 74", "h: 75+"))+
  xlab("Decision period")+ # axis lables 
  ylab("Percent of vaccines")+
  ylim(0,110)+
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10,family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=10,family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(0.75, "line"),
    legend.position="bottom")








###--------------------------
### cumulative values
###--------------------------








# get group sizes 

bins <- read.csv("data_transformed/population.csv")
bins <- bins %>% filter(ess_size == 0.4)
bins$age_group <- c("a","b","c","d*","e","f*","g","h")
bins$size <- bins$size/sum(bins$size)
bins <- bins %>% dplyr::select(age_group, size)



# get cumulative for optima


dat_full_sol <- read.csv("data_outputs/alt_40_cl_policies.csv")
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
dat_full_sol$age_group <- mapvalues(dat_full_sol$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h")) 
dat_full_sol$period <- mapvalues(dat_full_sol$period, c(0:5), 1:6) 


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

dat_full_sol_cumulative_melt <- merge(dat_full_sol_cumulative_melt, bins, by = "age_group")





dat_full_sol_cumulative_melt <- dat_full_sol_cumulative_melt %>% dplyr::mutate(value = as.numeric(value)/size)

acc <- c()

for(i in 1:nrow(dat_full_sol_cumulative_melt)){
  if(dat_full_sol_cumulative_melt$value[i] > 1){
    acc <- append(acc, 1)
  }else{
    acc <- append(acc, dat_full_sol_cumulative_melt$value[i])
  }
}

dat_full_sol_cumulative_melt$value <- acc

p2 <- ggplot(
  dat_full_sol_cumulative_melt,
  aes(x = as.factor(variable), # aesthetics 
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
            size = 4)+
  facet_wrap(~Policy, ncol = 1)+
  theme_minimal()+
  scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                    name = "Age group",
                    labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", 
                               "e: 40-59 ", "f: 40-59*", "g: 60 - 74", "h: 75+"))+
  xlab("Decision period (months)")+ 
  ylab("Percent of age group (cumulative)")+
  ylim(0,110)+
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

ggsave(
  "figures/alt_40_cl_detailed_policy.png",
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
### load data 
###-------------

# full solution
dat_full_sol <- read.csv("data_outputs/alt_leaky_policies.csv")



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
dat_full_sol$age_group <- mapvalues(dat_full_sol$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h")) 
dat_full_sol$period <- mapvalues(dat_full_sol$period, c(0:5), 1:6) 




p1 <- ggplot(
  dat_full_sol,
  aes(x = as.character(period), # aesthetics 
      fill = age_group, 
      y = 100*as.numeric(value)))+
  
  geom_bar(stat="identity", # use geom_bar with dodging to get grouped bar charts 
           position=position_dodge(width = 0.85), 
           width = 0.75,
           color = "black",
           size = 0.1)+
  geom_text(aes(label=age_group, y = 100*as.numeric(value)),  # place labels above each bar 
            position=position_dodge(width=0.85), 
            vjust=-0.75,
            family="Times New Roman",
            size = 2)+
  facet_wrap(~variable, ncol = 1)+
  theme_minimal()+
  scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                    name = "Age group",
                    labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", 
                               "e: 40-59 ", "f: 40-59*", "g: 60 - 74", "h: 75+"))+
  xlab("Decision period")+ # axis lables 
  ylab("Percent of vaccines")+
  ylim(0,110)+
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10,family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=10,family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(0.75, "line"),
    legend.position="bottom")








###--------------------------
### cumulative values
###--------------------------








# get group sizes 

bins <- read.csv("data_transformed/population.csv")
bins <- bins %>% filter(ess_size == 0.4)
bins$age_group <- c("a","b","c","d*","e","f*","g","h")
bins$size <- bins$size/sum(bins$size)
bins <- bins %>% dplyr::select(age_group, size)



# get cumulative for optima


dat_full_sol <- read.csv("data_outputs/alt_leaky_policies.csv")
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
dat_full_sol$age_group <- mapvalues(dat_full_sol$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h")) 
dat_full_sol$period <- mapvalues(dat_full_sol$period, c(0:5), 1:6) 


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

dat_full_sol_cumulative_melt <- merge(dat_full_sol_cumulative_melt, bins, by = "age_group")





dat_full_sol_cumulative_melt <- dat_full_sol_cumulative_melt %>% dplyr::mutate(value = as.numeric(value)/size)

acc <- c()

for(i in 1:nrow(dat_full_sol_cumulative_melt)){
  if(dat_full_sol_cumulative_melt$value[i] > 1){
    acc <- append(acc, 1)
  }else{
    acc <- append(acc, dat_full_sol_cumulative_melt$value[i])
  }
}

dat_full_sol_cumulative_melt$value <- acc

p2 <- ggplot(
  dat_full_sol_cumulative_melt,
  aes(x = as.factor(variable), # aesthetics 
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
            size = 4)+
  facet_wrap(~Policy, ncol = 1)+
  theme_minimal()+
  scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                    name = "Age group",
                    labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", 
                               "e: 40-59 ", "f: 40-59*", "g: 60 - 74", "h: 75+"))+
  xlab("Decision period (months)")+ 
  ylab("Percent of age group (cumulative)")+
  ylim(0,110)+
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

ggsave(
  "figures/alt_leaky_detailed_policy.png",
  plot = p,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 10,
  height = 6.5,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)














### heat maps



dat_scenarions <- data.frame(age_group = c("!"), Policy= c("!"), variable = c("!"), 
                             value = c(1), period = c(1), size = c(1), scenario = c("name"))


sc_names <- c("Base scenario",
              "Clustered workers",
              "Leaky vaccine 1",
              "Leaky vaccine 2",
              "20% essential workers")

ess_size_ls <- c(0.4,0.4,0.4,0.4,0.2)

fn <- c("data_outputs/main_text_full_policies_1.csv",
        "data_outputs/alt_40_cl_policies.csv",
        "data_outputs/alt_leaky_policies.csv",
        "data_outputs/alt_leaky_sucept_only_policies.csv",
        "data_outputs/alt_20_policies.csv")



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
  print(ess_size_ls[i])
  bins <- read.csv("data_transformed/population.csv")
  bins <- bins %>% filter(ess_size == ess_size_ls[i])
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
    strip.text = element_text(size=16, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=16, face="bold",family="Times New Roman"),
    axis.text = element_text(size=16,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=16, face="bold",family="Times New Roman"),
    legend.title = element_text(size=16, face="bold",family="Times New Roman"),
    legend.text = element_text(size=16,family="Times New Roman"),
    legend.position = "bottom")

ggsave(
  "figures/alt_Heat_Map.png",
  plot = p,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 8,
  height = 6,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)





