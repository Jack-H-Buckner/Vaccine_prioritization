library(ggplot2)
library(reshape2)
library(viridis)
library(plyr)
setwd("~/desktop/Dynamic_Vaccine_Allocation")

dat <- read.csv("data_outputs/static_comparison_data.csv")

dat1 <- dat[2:nrow(dat),]

# rename and order 
dat1$Policy <- plyr::mapvalues(dat1$Policy, 
                               c("Base scenario",  "Weak NPI", 
                                 "Strong NPI", "High init. infects." , "High sucept. ages < 20",
                                 "Low V eff. ages > 60", "Low eff", "Schools open", 
                                 "Low supply", "High contacts", "Ramp up" ),
                               
                               c("Base \n scenario",
                                 "Weak \n NPI",
                                 "Strong \n NPI",
                                 "High init. \n infect.",
                                 "Even \n suceptibility",
                                 "Weak \n vaccine 60+",
                                 "Weak \n vaccine",
                                 "Open \n Schools ",
                                 "Low \n supply",
                                 "High \n contacts",
                                 "Ramp \n up"))

dat1$Policy <- ordered(dat1$Policy, 
                       rev(c("Base \n scenario",
                             "High init. \n infect.",
                             "Strong \n NPI",
                             "Weak \n NPI",
                             "Weak \n vaccine",
                             "Weak \n vaccine 60+",
                             "Even \n suceptibility",
                             "Low \n supply",
                             "Open \n Schools ",
                             "Ramp \n up",
                             "High \n contacts"
                       )))


dat1$Params <- plyr::mapvalues(dat1$Params , 
                               c("Base scenario",  "Weak NPI", 
                                 "Strong NPI", "High init. infects." , "High sucept. ages < 20",
                                 "Low V eff. ages > 60", "Low eff", "Schools open", 
                                 "Low supply", "High contacts", "Ramp up" ),
                               
                               c("Base \n scenario",
                                 "Weak \n NPI",
                                 "Strong \n NPI",
                                 "High init. \n infect.",
                                 "Even \n suceptibility",
                                 "Weak \n vaccine 60+",
                                 "Weak \n vaccine",
                                 "Open \n Schools ",
                                 "Low \n supply",
                                 "High \n contacts",
                                 "Ramp \n up"))

dat1$Params  <- ordered(dat1$Params , 
                        c("Base \n scenario",
                              "High init. \n infect.",
                              "Strong \n NPI",
                              "Weak \n NPI",
                              "Weak \n vaccine",
                              "Weak \n vaccine 60+",
                              "Even \n suceptibility",
                              "Low \n supply",
                              "Open \n Schools ",
                              "Ramp \n up",
                              "High \n contacts"
                        ))







p <- ggplot(dat1 %>% 
              dplyr::filter(outcomes == "YLL") %>%
              dplyr::group_by(Params) %>%
              dplyr::mutate(min_value = min(value)) %>%
              dplyr::mutate(rel_value = min_value/value),
            aes(x = Params, y = Policy, fill = rel_value, 
                label = paste(round(100*(1/rel_value -1)),"%")))+
  geom_tile()+
  geom_text()+
  ggtitle("Years of life lost")+
  xlab("True scenario")+
  ylab("Policy applied")+
  theme_minimal()+
  theme(axis.text.x = element_text(family = "Times New Roman", size = 14, angle = 20),
        axis.text.y = element_text(family = "Times New Roman", size = 14),
        title = element_text(family = "Times New Roman", size = 14, face = "bold"),
        legend.position = "none")+
  scale_fill_viridis(name = "", option="viridis")








ggsave(
  "figures/static_Comparisons.png",
  plot = p,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 8.5,
  height = 8,
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
library(viridis)
###-------------
### set wd
###-------------

setwd("~/desktop/Dynamic_Vaccine_Allocation")



dat_scenarions <- data.frame(age_group = c("!"), Policy= c("!"), variable = c("!"), 
                             value = c(1),  size = c(1))


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

fn <- c("data_outputs/main_text_static_policies.csv",
        "data_outputs/static_high_initial_infections_policies.csv",
        "data_outputs/static_strong_NPI_policies.csv",
        "data_outputs/static_weak_NPI_policies.csv",
        "data_outputs/static_Low_effectiveness_policies.csv",
        "data_outputs/static_Low_effectiveness_60_policies.csv",
        "data_outputs/static_high_sucept_children_policies.csv",
        "data_outputs/static_low_supply_policies.csv",
        "data_outputs/static_Ramp_up_policies.csv",
        "data_outputs/static_schools_open_policies.csv",
        "data_outputs/static_high_contacts_social_policies.csv")



for( i in 1:length(fn)){
  ###-------------
  ### load data 
  ###-------------
  print(i)
  
  # full solution
  dat_full_sol <- read.csv(fn[i])
  
  names(dat_full_sol) <- c("Infections", "YLL", "Deaths")
  dat_full_sol$age_group <- c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")
  
  
  dat_full_sol <- dat_full_sol %>% reshape2::melt(id.var = "age_group")
  
  
  dat_full_sol$Policy <- c(sc_names[i])
  
  bins <- read.csv("data_transformed/population.csv")
  bins <- bins %>% filter(ess_size == 0.4)
  bins$age_group <- c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")
  bins$size <- bins$size/sum(bins$size)
  bins <- bins %>% dplyr::select(age_group, size)
  
  
  
  data_cumulative <- merge(dat_full_sol, bins, by = "age_group") %>%
    dplyr::mutate(value = value)
  
  
  print(data_cumulative)
  
  
  dat_scenarions <- rbind(dat_scenarions , data_cumulative)
  
}

dat <- dat_scenarions %>% filter(age_group != "!")




# reorder outcomes
dat$variable <- factor(dat$variable, c("Deaths", "YLL", "Infections"))
dat$age_group <- factor(dat$age_group,c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")) 

dat$Policy <- factor(dat$Policy, rev(sc_names))
p <- ggplot(dat ,
            aes(x = age_group, y = Policy, fill = 100*value))+
  theme_minimal()+
  geom_tile(height = 0.9)+
  facet_wrap(~variable, ncol = 1)+
  scale_fill_viridis(name = "Percent of inital supply")+
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
  "figures/static_Heat_Map.png",
  plot = p,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 8,
  height = 9,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)


























