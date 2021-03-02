library(ggplot2)
library(reshape2)
library(viridis)
library(plyr)
setwd("~/desktop/Dynamic_Vaccine_Allocation")

dat <- read.csv("data_outputs/comparison_data.csv")

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








#ggsave(
  #"figures/Comparisons.png",
  #plot = p,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  #width = 8.5,
  #height = 8,
  #units = c("in", "cm", "mm"),
  #dpi = 300)

p <- ggplot(dat1 %>% 
         dplyr::filter(outcomes == "Infecitons") %>%
         dplyr::group_by(Params) %>%
         dplyr::mutate(min_value = min(value)) %>%
         dplyr::mutate(rel_value = min_value/value),
       aes(x = Params, y = Policy, fill = rel_value, 
           label = paste(round(100*(1/rel_value -1)),"%")))+
  geom_tile()+
  geom_text()+
  ggtitle("Infections")+
  xlab("True scenario")+
  ylab("Policy applied")+
  theme_minimal()+
  theme(axis.text.x = element_text(family = "Times New Roman", size = 15.5, angle = 45 ,hjust = 1),
        axis.text.y = element_text(family = "Times New Roman", size = 15.5),
        axis.title.y = element_text(size=30, face="bold",family="Times New Roman"),
        axis.title.x = element_text(size=30, face="bold",family="Times New Roman"),
        plot.title = element_text(family = "Times New Roman", size = 30, face = "bold"),
        legend.position = "none")+
  scale_fill_viridis(name = "", option="viridis")

ggsave(
  "figures/infections_Comparisons.png",
  plot = p,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 8.5,
  height = 8,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)





p <- ggplot(dat1 %>% 
              dplyr::filter(outcomes == "Deaths") %>%
              dplyr::group_by(Params) %>%
              dplyr::mutate(min_value = min(value)) %>%
              dplyr::mutate(rel_value = min_value/value),
            aes(x = Params, y = Policy, fill = rel_value, 
                label = paste(round(100*(1/rel_value -1)),"%")))+
  geom_tile()+
  geom_text()+
  ggtitle("Deaths")+
  xlab("True scenario")+
  ylab("Policy applied")+
  theme_minimal()+
  theme(axis.text.x = element_text(family = "Times New Roman", size = 15.5, angle = 45 ,hjust = 1),
        axis.text.y = element_text(family = "Times New Roman", size = 15.5),
        axis.title.y = element_text(size=30, face="bold",family="Times New Roman"),
        axis.title.x = element_text(size=30, face="bold",family="Times New Roman"),
        plot.title = element_text(family = "Times New Roman", size = 30, face = "bold"),
        legend.position = "none")+
  scale_fill_viridis(name = "", option="viridis")

ggsave(
  "figures/deaths_Comparisons.png",
  plot = p,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 8.5,
  height = 8,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)
