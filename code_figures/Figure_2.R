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
dat_full_errors <- read.csv("data_outputs/main_text_full_0.005_samples.csv")


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


# errors
dat_full_errors_summary <- dat_full_errors %>% melt(id.var = c("Column49"))

N_groups <- 8
N_periods <- 6

quantile_10 <- function(x){quantile(x,10)}
quantile_90 <- function(x){quantile(x,90)}

quantile_25 <- function(x){quantile(x,10)}
quantile_75 <- function(x){quantile(x,90)}

dat_full_errors_summary <- dat_full_errors_summary %>% 
  dplyr::mutate(col_num = as.numeric(gsub("Column", "", variable))) %>%
  dplyr::mutate(age_group = col_num %% N_groups,
                period = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0)) %>%
  dplyr::filter(value != 0)%>%
  dplyr::group_by(age_group, period, Column49)%>%
  dplyr::summarize(min = min(value),
                   max = max(value))

dat_full_errors_summary %>% group_by(variable) %>% dplyr::summarize(n = n())

dat_full_errors_summary$age_group <- plyr::mapvalues(dat_full_errors_summary$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h")) 
dat_full_errors_summary$period <- mapvalues(dat_full_errors_summary$period, c(0:5), 1:6) 

names(dat_full_errors_summary) <- c("age_group", "period", "objective", "min", "max")



names(dat_full_sol) <- c("constraint", "objective","value","age_group","period") 

dat_full_sol <- dat_full_sol %>% dplyr::select(-constraint)

dat_full_sol <- merge(dat_full_sol, dat_full_errors_summary, by = c("objective", "age_group","period" ))





###########        plot 1               ##############





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
  geom_text(aes(label=age_group, y = 100*max),  # place labels above each bar 
            position=position_dodge(width=0.85), 
            vjust=-0.5,
            family="Times New Roman",
            size = 4)+
  geom_errorbar(aes(ymin = 100*min, ymax = 100*max),
                position=position_dodge(width = 0.85))+
  facet_wrap(~objective, ncol = 1)+
  theme_minimal()+
  scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                    name = "Demographic group",
                    labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", 
                               "e: 40-59 ", "f: 40-59*", "g: 60 - 74", "h: 75+"))+
  xlab("Decision period (30 days)")+ # axis lables 
  ylab("Percent of vaccines")+
  ylim(0,110)+
  theme(
    strip.text = element_text(size=16, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=16,family="Times New Roman"),
    axis.text = element_text(size=16,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=16,family="Times New Roman"),
    legend.title = element_text(size=16, face="bold",family="Times New Roman"),
    legend.text = element_text(size=16,family="Times New Roman"),
    legend.key.size = unit(1.0, "line"),
    legend.position="bottom")







###########        plot 1               ##############








###--------------------------
### cumulative values
###--------------------------

names(dat_full_errors_summary) <- c("age_group", "period", "objective", "min", "max")


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



# reshape cumulative errors
dat_cumulative_errors_melt <- dat_cumulative_errors %>%
  reshape2::melt(id.vars = c("age_group" , "Policy", "size"))

dat_cumulative_errors_melt$period<- c(rep(3, 48),rep(6, 48)) 
dat_cumulative_errors_melt$min_max<- c(rep("min", 24),rep("max", 24),
                                       rep("min", 24),rep("max", 24)) 

dat_cumulative_errors_melt <- dcast(dat_cumulative_errors_melt, 
                                    age_group + Policy+ size + period ~ min_max)




# get cumulative for optima


dat_full_sol <- read.csv("data_outputs/main_text_full_policies_1.csv")
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





data_cumulative <- merge(dat_full_sol_cumulative_melt,dat_cumulative_errors_melt,
                         by = c("age_group","Policy","period")) %>%
  dplyr::mutate(value = value/size)

names(data_cumulative) <- c("age_group", "objective", "period", "variable", "value", "size", "max", "min")





acc <- c()
acc2 <- c()
for(i in 1:nrow(data_cumulative)){
  if(data_cumulative$max[i] > 1){
    acc <- append(acc, 1)
  }else{
    acc <- append(acc, data_cumulative$max[i])
  }
  if(data_cumulative$value[i] > 1){
    acc2 <- append(acc2, 1)
  }else{
    acc2 <- append(acc2, data_cumulative$value[i])
  }
}

data_cumulative$max <- acc
data_cumulative$value <- acc2







###########        plot 2               ##############








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
  geom_text(aes(label=age_group, y = 100*max),  # place labels above each bar 
            position=position_dodge(width=0.85), 
            vjust=-0.5,
            family="Times New Roman",
            size = 4)+
  geom_errorbar(aes(ymin = 100*min, ymax = 100*max),
                position=position_dodge(width = 0.85),
                size = 0.5)+
  facet_wrap(~objective, ncol = 1)+
  theme_minimal()+
  scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                    name = "Demographic group",
                    labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", 
                               "e: 40-59 ", "f: 40-59*", "g: 60 - 74", "h: 75+"))+
  xlab("Decision period (30 days)")+ 
  ylab("Percent of demographic group (cumulative)")+
  ylim(0,110)+
  theme(
    strip.text = element_text(size=16, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=16,family="Times New Roman"),
    axis.text = element_text(size=16,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=16,family="Times New Roman"),
    legend.title = element_text(size=16, face="bold",family="Times New Roman"),
    legend.text = element_text(size=16,family="Times New Roman"),
    legend.key.size = unit(1.0, "line"),
    legend.position="bottom")



###########        plot 2               ##############





















#####################################################



### update error bars 


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
dat_full_errors <- read.csv("data_outputs/main_text_full_0.005_bounds_refined_2.csv")


###--------------------------
### process point estimates
###--------------------------

# add names and group labels to full solution
names(dat_full_sol) <- c("Infections", "YLL", "Deaths") # label columns 
dat_full_sol$col_num <- 1:48

names(dat_full_errors) <- c("row", "variable", "col", "min","max","col_num","r_min","r_max")

N_groups <- 8
dat_full_sol <- dat_full_sol %>% 
  reshape2::melt(id.var = c("col_num"))#%>% # reshape

dat_full <- merge(dat_full_sol, dat_full_errors, by = c( "variable","col_num"))

dat_full <- dat_full %>%
  dplyr::mutate(age_group = col_num %% N_groups, # age groups 
                period = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0)) %>% # period 
  dplyr::select(-col_num) # remove extra column 

dat_full$age_group <- plyr::mapvalues(dat_full$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h")) 
dat_full$period <- plyr::mapvalues(dat_full$period, c(0:5), 1:6) 



N_groups <- 8
N_periods <- 6


###########        plot 1               ##############





p1 <- ggplot(
  dat_full,
  aes(x = as.character(period), # aesthetics 
      fill = age_group, 
      y = 100*as.numeric(value)))+
  
  geom_bar(stat="identity", # use geom_bar with dodging to get grouped bar charts 
           position=position_dodge(width = 0.85), 
           width = 0.75,
           color = "black",
           size = 0.1)+
  geom_text(aes(label=age_group, y = 100*max),  # place labels above each bar 
            position=position_dodge(width=0.85), 
            vjust=-0.5,
            family="Times New Roman",
            size = 4)+
  geom_errorbar(aes(ymin = 100*min, ymax = 100*max),
                position=position_dodge(width = 0.85))+
  facet_wrap(~variable, ncol = 1)+
  theme_minimal()+
  scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                    name = "Demographic group",
                    labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", 
                               "e: 40-59 ", "f: 40-59*", "g: 60 - 74", "h: 75+"))+
  xlab("Decision period (30 days)")+ # axis lables 
  ylab("Percent of vaccines")+
  ylim(0,110)+
  theme(
    strip.text = element_text(size=16, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=16,family="Times New Roman"),
    axis.text = element_text(size=16,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=16,family="Times New Roman"),
    legend.title = element_text(size=16, face="bold",family="Times New Roman"),
    legend.text = element_text(size=16,family="Times New Roman"),
    legend.key.size = unit(1.0, "line"),
    legend.position="bottom")






p <- lemon::grid_arrange_shared_legend(p1, p2, ncol=2, widths = c(5,2.0))

ggsave(
  "figures/detailed_policy.png",
  plot = p,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 10,
  height = 6.5,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)














#####################################################



###-------------
### load data 
###-------------

# full solution
dat_full_sol <- read.csv("data_outputs/main_text_full_re_policies_1.csv")
dat_full_errors <- read.csv("data_outputs/main_text_re_full_samples.csv")


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


# errors
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
  geom_text(aes(label=age_group, y = 100*max),  # place labels above each bar 
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

names(dat_full_errors_summary) <- c("age_group", "period", "objective", "min", "max")


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



# reshape cumulative errors
dat_cumulative_errors_melt <- dat_cumulative_errors %>%
  reshape2::melt(id.vars = c("age_group" , "Policy", "size"))

dat_cumulative_errors_melt$period<- c(rep(3, 48),rep(6, 48)) 
dat_cumulative_errors_melt$min_max<- c(rep("min", 24),rep("max", 24),
                                       rep("min", 24),rep("max", 24)) 

dat_cumulative_errors_melt <- dcast(dat_cumulative_errors_melt, 
                                    age_group + Policy+ size + period ~ min_max)




# get cumulative for optima


dat_full_sol <- read.csv("data_outputs/main_text_full_policies_1.csv")
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





data_cumulative <- merge(dat_full_sol_cumulative_melt,dat_cumulative_errors_melt,
                         by = c("age_group","Policy","period")) %>%
  dplyr::mutate(value = value/size)

names(data_cumulative) <- c("age_group", "objective", "period", "variable", "value", "size", "max", "min")





acc <- c()
acc2 <- c()
for(i in 1:nrow(data_cumulative)){
  if(data_cumulative$max[i] > 1){
    acc <- append(acc, 1)
  }else{
    acc <- append(acc, data_cumulative$max[i])
  }
  if(data_cumulative$value[i] > 1){
    acc2 <- append(acc2, 1)
  }else{
    acc2 <- append(acc2, data_cumulative$value[i])
  }
}

data_cumulative$max <- acc
data_cumulative$value <- acc2





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
  geom_text(aes(label=age_group, y = 100*max),  # place labels above each bar 
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
  "figures/detailed_policy_re.png",
  plot = p,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 10,
  height = 6.5,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)
