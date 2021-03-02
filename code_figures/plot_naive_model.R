library(dplyr)
library(ggplot2)
library(reshape2)
library(RColorBrewer)
setwd("~/github/Vaccine_Allocation_cleaned")

series_work <- read.csv("data_outputs/naive_model_run_work.csv")
names(series_work) <- c("0-4", "5-19", "20-39", "20-39*",
                        "40-59", "40-59*", "60-69", "70+", "state_varaible")
series_work$time <- rep(1:350,4)

series_work <- reshape2::melt(series_work, id.var = c("time", "state_varaible"))

p <- ggplot(series_work,
       aes(x = time, y = 100*value, color = variable)) + 
  geom_line()+
  facet_wrap(~state_varaible, ncol = 2, scales = "free")+
  scale_color_brewer(palette = "Dark2", name = "Age group")+
  xlab("Time")+
  ylab("Percent of age group")+
  theme_minimal()+
  theme(text = element_text("Times New Roman"))


ggsave(
  "figures/attack_rate_series_work.jpg",
  p,
  width = 8.5,
  height = 4.25,
  dpi = 300
)


series_work <- read.csv("data_outputs/naive_model_run_age.csv")
names(series_work) <- c("0-4", "5-19", "20-39", 
                        "40-59", "60-74", "75+", "state_varaible")
series_work$time <- rep(1:350,4)

series_work <- reshape2::melt(series_work, id.var = c("time", "state_varaible"))

p <- ggplot(series_work,
       aes(x = time, y = 100*value, color = variable)) + 
  geom_line()+
  facet_wrap(~state_varaible, ncol = 2, scales = "free")+
  scale_color_brewer(palette = "Dark2", name = "Age group")+
  xlab("Time")+
  ylab("Percent of age group")+
  theme_minimal()+
  theme(text = element_text("Times New Roman"))


ggsave(
  "figures/attack_rate_series_age.jpg",
  p,
  width = 8.5,
  height = 4.25,
  dpi = 300
)


### plot attack rates 


attack_rates <- read.csv("data_outputs/attack_rate_work.csv")
names(attack_rates) <- c("Recovered", "Dead", "total", "susceptibles")
attack_rates <- attack_rates %>% tibble::add_column(age = c("0-4","5-19","20-39","20-39*",
                                                            "40-59", "40-59*",  "60-74", "75+"))
attack_rates$age <- factor(attack_rates$age,  c("0-4","5-19","20-39","20-39*",
                                                "40-59", "40-59*", "60-74", "75+")) 
p <- ggplot(melt(attack_rates, id.var = "age") %>% dplyr::filter(variable %in% c("Recovered", "Dead")),
       aes(x = age, y = 100*value, fill = variable))+
  geom_bar(stat = "identity", color = "black") +
  scale_fill_brewer(palette = "Dark2", name = "State")+
  theme_minimal()+
  ylab("Percent of demographic group")+
  ylim(0,100)+
  xlab("Demographic group")+
  theme(text = element_text(family = "Times New Roman"))


ggsave(
  "figures/attack_rate_work.jpg",
  p,
  width = 5.5,
  height = 4.25,
  dpi = 300
)





attack_rates <- read.csv("data_outputs/attack_rate_age.csv")
names(attack_rates) <- c("Recovered", "Dead", "total", "susceptible")
attack_rates <- attack_rates %>% tibble::add_column(age = c("0-4","5-19","20-39",
                                                            "40-59",   "60-74", "75+"))
attack_rates$age <- factor(attack_rates$age,  c("0-4","5-19","20-39",
                                                "40-59", "60-74", "75+")) 
p <- ggplot(melt(attack_rates, id.var = "age") %>% dplyr::filter(variable %in% c("Recovered", "Dead")),
            aes(x = age, y = 100*value, fill = variable))+
  geom_bar(stat = "identity", color = "black") +
  scale_fill_brewer(palette = "Dark2", name = "State")+
  theme_minimal()+
  ylab("Percent of demographic group")+
  ylim(0,100)+
  xlab("Demographic group")+
  theme(text = element_text(family = "Times New Roman"))


ggsave(
  "figures/attack_rate_age.jpg",
  p,
  width = 5.5,
  height = 4.25,
  dpi = 300
)










