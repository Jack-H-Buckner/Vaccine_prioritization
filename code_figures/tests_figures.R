
library(plyr)
library(dplyr)
library(ggplot2)

setwd("~/desktop/Dynamic_Vaccine_Allocation")


process_data <- function(fn, num){
  dat1 <- read.csv(fn)
  N_groups <- 8
  dat1 <- as.data.frame(dat1)
  dat1$col_num <- as.numeric(rownames(dat1))

  dat1 <- dat1 %>%
   dplyr::mutate(age_group = col_num %% N_groups,
                period = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0)) 

  dat1$age_group <- mapvalues(dat1$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h")) 

  dat1 <- dat1%>% dplyr::select(-col_num)
  names(dat1) <- c("opt", "age_group", "period")

  dat1$trial <- num
  return(dat1)
}

dat1 <- process_data("data_outputs/test_opt1_policies.csv", "one")
dat2 <- process_data("data_outputs/test_opt1_re_policies.csv", "one re")
dat3 <- process_data("data_outputs/test_opt2_policies.csv", "two ")
dat4 <- process_data("data_outputs/test_opt3_policies.csv", "three")
dat5 <- process_data("data_outputs/test_opt4_policies.csv", "four")
dat6 <- process_data("data_outputs/test_opt5_policies.csv", "five")
dat <- rbind(dat1,dat2,dat3,dat4,dat5,dat6)



ggplot(dat, aes(x = period, y = opt, fill = as.factor(age_group)))+
  facet_wrap(~trial, ncol = 1)+
  geom_bar(stat = "identity", position=position_dodge(width = 0.85), color = "black")+
  theme_test()+
  scale_fill_brewer(palette = "Accent")



## plot cumulative



process_data_cu <- function(fn, num){
  dat1 <- read.csv(fn)
  N_groups <- 8
  dat1 <- as.data.frame(dat1)
  dat1$col_num <- as.numeric(rownames(dat1))
  
  dat1 <- dat1 %>%
    dplyr::mutate(age_group = col_num %% N_groups,
                  period = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0)) 
  
  dat1$age_group <- mapvalues(dat1$age_group, c(1:7,0), c("a", "b", "c", "d*","e","f*","g", "h")) 
  
  dat1 <- dat1%>% dplyr::select(-col_num)
  names(dat1) <- c("opt", "age_group", "period")
  
  dat1$trial <- num
  
  print(dat1)
  
  dat6 <- dat1 %>% 
    dplyr::group_by(age_group, trial) %>%
    dplyr::summarize(value = sum(opt))
  dat6$month <- rep(6, nrow(dat6))

  
  dat3 <- dat1 %>% 
    dplyr::filter(period < 3) %>%
    dplyr::group_by(age_group, trial) %>%
    dplyr::summarize(value = sum(opt))
  
  
  dat3$month <- rep(3, nrow(dat3))
  
  dat <- rbind(dat3,dat6)
    
  return(dat)
}




dat1 <- process_data_cu("data_outputs/test_opt1_policies.csv", "one")
dat2 <- process_data_cu("data_outputs/test_opt1_re_policies.csv", "one re")
dat3 <- process_data_cu("data_outputs/test_opt2_policies.csv", "two ")
dat4 <- process_data_cu("data_outputs/test_opt3_policies.csv", "three")
dat5 <- process_data_cu("data_outputs/test_opt4_policies.csv", "four")
dat6 <- process_data_cu("data_outputs/test_opt5_policies.csv", "five")
dat <- rbind(dat1,dat2,dat3,dat4,dat5,dat6)



ggplot(dat, aes(x = month, y = value, fill = as.factor(age_group)))+
  facet_wrap(~trial, ncol = 1)+
  geom_bar(stat = "identity", position=position_dodge(width = 1.5),
           width = 0.8)+
  theme_test()+
  scale_fill_brewer(palette = "Accent")




### plot differences ###







dat1 <- process_data("data_outputs/test_full_policies.csv", "one")
dat2 <- process_data("data_outputs/test_fixed_5_policies.csv", "two")


dat <- rbind(dat1,dat2)


ggplot(dat, aes(x = period, y = opt, fill = as.factor(age_group)))+
  facet_wrap(~trial, ncol = 1)+
  geom_bar(stat = "identity", position=position_dodge(width = 0.85), color = "black")+
  theme_test()+
  scale_fill_brewer(palette = "Accent")











