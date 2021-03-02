
library(patternplot)
library(plyr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(gridExtra)

setwd("~/github/Vaccine_Allocation_cleaned")


header.true <- function(df) {
  names(df) <- as.character(unlist(df[1,]))
  df[-1,]
}


dat_sol_rep0 <- read.csv("data_outputs/solution_base.csv") %>%header.true()
dat_sol_rep1 <- read.csv("data_outputs/solution_base_0.csv")%>%header.true()
dat_sol_rep2 <- read.csv("data_outputs/solution_base_1.csv")%>%header.true()
dat_sol_rep3 <- read.csv("data_outputs/solution_base_3.csv")%>%header.true()
dat_sol_rep4 <- read.csv("data_outputs/solution_base_4.csv")%>%header.true()


dat_sol_rep0$trial = 0 
dat_sol_rep1$trial = 1 
dat_sol_rep2$trial = 2 
dat_sol_rep3$trial = 3
dat_sol_rep4$trial = 4 

 
dat_sol_rep1$dif_mu =  as.numeric(dat_sol_rep1$mu) - as.numeric(dat_sol_rep0$mu)
dat_sol_rep2$dif_mu =  as.numeric(dat_sol_rep2$mu) - as.numeric(dat_sol_rep0$mu)
dat_sol_rep3$dif_mu =  as.numeric(dat_sol_rep3$mu) - as.numeric(dat_sol_rep0$mu)
dat_sol_rep4$dif_mu =  as.numeric(dat_sol_rep4$mu) - as.numeric(dat_sol_rep0$mu)

dat_dif_sol = rbind(dat_sol_rep1,dat_sol_rep2,dat_sol_rep3,dat_sol_rep4)

ggplot(dat_dif_sol%>%filter(objective %in% c("YLL", "deaths", "infections")), 
       aes(x = jitter(as.numeric(timeblocks)), y = dif_mu*100, shape = as.factor(trial), color = objective))+
  geom_point(alpha = 0.5)+theme_minimal() + ylab("differnce in alocations (percent)")

ggplot(dat_dif_sol%>%filter(objective %in% c("YLL", "deaths", "infections")), 
       aes(x = as.factor(timeblocks), y = dif_mu))+
  geom_violin()+theme_minimal() 






dat_out_rep0 <- read.csv("data_outputs/outcomes_base.csv") %>%header.true()
dat_out_rep1 <- read.csv("data_outputs/outcomes_base_0.csv")%>%header.true()
dat_out_rep2 <- read.csv("data_outputs/outcomes_base_1.csv")%>%header.true()
dat_out_rep3 <- read.csv("data_outputs/outcomes_base_3.csv")%>%header.true()
dat_out_rep4 <- read.csv("data_outputs/outcomes_base_4.csv")%>%header.true()

dat_out_rep0$trial = 0
dat_out_rep1$trial = 1
dat_out_rep2$trial = 2
dat_out_rep3$trial = 3
dat_out_rep4$trial = 4

all_out = rbind(dat_out_rep0, dat_out_rep1, dat_out_rep2, dat_out_rep3, dat_out_rep4)
names(all_out) <- c("policy", "outcome", "value", "trial")



ggplot(all_out,
       aes(x = outcome, y = as.numeric(value), shape = as.factor(trial), color = policy))+
  geom_point(alpha = 0.6) + theme_minimal()


all_out = all_out%>%filter(policy == outcome)

all_out = all_out%>%
  dplyr::group_by(policy)%>%
  dplyr::mutate(m = mean(as.numeric(value)))%>%
  dplyr::mutate(value = as.numeric(value) - m)
  

ggplot(all_out,
       aes(x = outcome, y = as.numeric(value)*100, shape = as.factor(trial), color = policy))+
  geom_point(alpha = 0.6) + theme_minimal() + geom_hline(aes(yintercept = 0))+ylab("differnce from mean performance (percent)")















setwd("~/github/Vaccine_Allocation_cleaned")


header.true <- function(df) {
  names(df) <- as.character(unlist(df[1,]))
  df[-1,]
}


dat_sol_rep0 <- read.csv("data_outputs/solution_tuning_0.csv") %>%header.true()
dat_sol_rep1 <- read.csv("data_outputs/solution_tuning_1.csv")%>%header.true()
dat_sol_rep2 <- read.csv("data_outputs/solution_tuning_2.csv")%>%header.true()
dat_sol_rep3 <- read.csv("data_outputs/solution_tuning_3.csv")%>%header.true()



dat_sol_rep0$trial = 0 
dat_sol_rep1$trial = 1 
dat_sol_rep2$trial = 2 
dat_sol_rep3$trial = 3
dat_sol_rep4$trial = 4 


dat_sol_rep1$dif_mu =  as.numeric(dat_sol_rep1$mu) - as.numeric(dat_sol_rep0$mu)
dat_sol_rep2$dif_mu =  as.numeric(dat_sol_rep2$mu) - as.numeric(dat_sol_rep0$mu)
dat_sol_rep3$dif_mu =  as.numeric(dat_sol_rep3$mu) - as.numeric(dat_sol_rep0$mu)
dat_sol_rep4$dif_mu =  as.numeric(dat_sol_rep4$mu) - as.numeric(dat_sol_rep0$mu)

dat_dif_sol = rbind(dat_sol_rep1,dat_sol_rep2,dat_sol_rep3,dat_sol_rep4)

ggplot(dat_dif_sol%>%filter(objective %in% c("YLL", "deaths", "infections")), 
       aes(x = jitter(as.numeric(timeblocks)), y = dif_mu*100, shape = as.factor(trial), color = objective))+
  geom_point(alpha = 0.5)+theme_minimal() + ylab("differnce in alocations (percent)")

ggplot(dat_dif_sol%>%filter(objective %in% c("YLL", "deaths", "infections")), 
       aes(x = as.factor(timeblocks), y = dif_mu))+
  geom_violin()+theme_minimal() 






dat_out_rep0 <- read.csv("data_outputs/outcomes_tuning_0.csv") %>%header.true()
dat_out_rep1 <- read.csv("data_outputs/outcomes_tuning_1.csv")%>%header.true()
dat_out_rep2 <- read.csv("data_outputs/outcomes_tuning_2.csv")%>%header.true()
dat_out_rep3 <- read.csv("data_outputs/outcomes_tuning_3.csv")%>%header.true()


dat_out_rep0$trial = 0
dat_out_rep1$trial = 1
dat_out_rep2$trial = 2
dat_out_rep3$trial = 3
dat_out_rep4$trial = 4

all_out = rbind(dat_out_rep0, dat_out_rep1, dat_out_rep2, dat_out_rep3, dat_out_rep4)
names(all_out) <- c("policy", "outcome", "value", "trial")



ggplot(all_out,
       aes(x = outcome, y = as.numeric(value), shape = as.factor(trial), color = policy))+
  geom_point(alpha = 0.6) + theme_minimal()


all_out = all_out%>%filter(policy == outcome)

all_out = all_out%>%
  dplyr::group_by(policy)%>%
  dplyr::mutate(m = mean(as.numeric(value)))%>%
  dplyr::mutate(value = as.numeric(value) - m)


ggplot(all_out,
       aes(x = outcome, y = as.numeric(value)*100, shape = as.factor(trial), color = policy))+
  geom_point(alpha = 0.6) + theme_minimal() + geom_hline(aes(yintercept = 0))+ylab("differnce from mean performance (percent)")










