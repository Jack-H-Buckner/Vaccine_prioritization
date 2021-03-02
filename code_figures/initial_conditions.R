library(dplyr)
library(ggplot2)

setwd("~/desktop/Dynamic_Vaccine_Allocation")



dat<- read.csv("data_outputs/main_text_age_only_states.csv")


dat$time <- rep(1:t,3)
dat$objective <- c(rep("Infections",t), rep("YLL",t), rep("Deaths",t))

dat <- dat %>% melt(id.vars = c("time", "objective"))

dat <- dat %>% 
  dplyr::mutate(col_num = as.numeric(gsub("Column", "", variable))) %>%
  dplyr::mutate(age_group = col_num %% N_groups,
                state_var = col_num %/% N_groups - as.numeric(col_num %% N_groups == 0)) 






dat$age_group <- mapvalues(dat$age_group, c(1:7,0), c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+"))
dat$state_var <- mapvalues(dat$state_var, 
                           0:8, 
                           c("S", "P", "F", "E", "I_pre", "I_asy", "I_sym", "D", "R"))

dat <- dat %>% dplyr::select(-col_num)


bins <- read.csv("data_transformed/population.csv")
bins <- bins %>% filter(ess_size == 0.4)
bins$age_group <- c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")
bins$size <- bins$size/sum(bins$size)
bins <- bins %>% dplyr::select(age_group, size)

dat1 <- merge(dat, bins, by = "age_group") %>%
  dplyr::mutate(value = value/size)

dat1$age_group <- factor(dat1$age_group, c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+"))





p1 <- ggplot(dat1 %>% dplyr::filter(time == 1, state_var %in% c("I_sym")),
       aes(x = age_group, y = value, fill = age_group))+
  geom_col(position = position_dodge(width = 0.85))+
  scale_fill_brewer(palette = "Accent", name = "Age group")+
  theme_test()+
  xlab("Demographic group")+ 
  ylab("Portion infected")+
  theme(
    strip.text = element_text(size=20, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=20, face="bold",family="Times New Roman"),
    axis.text = element_text(size=20,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=20, face="bold",family="Times New Roman"),
    legend.title = element_text(size=20, face="bold",family="Times New Roman"),
    legend.text = element_text(size=20,family="Times New Roman"),
    legend.position="bottom")



ggsave(
  "figures/initial_infections.png",
  plot = p1,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 10,
  height = 7,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)

# size of demographic groups 
p2 <- ggplot(dat1 %>% dplyr::filter(time == 1, state_var %in% c("I_sym")),
       aes(x = age_group, y = size,))+
  geom_col(position = position_dodge(width = 0.85), 
           fill = "grey", color = "black")+
  theme_test()+
  xlab("Demographic group")+ 
  ylab("Portion of total popuatlion")+
  theme(
    strip.text = element_text(size=12, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=12, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=12, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=12,family="Times New Roman"),
    legend.position="bottom")


ggsave(
  "figures/pop_sizes.png",
  plot = p2,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 10,
  height = 7,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)
# contact rate heat map

dat <- read.csv("data_outputs/contact_matrix_main_text.csv")

names(dat) <- c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")
dat$age_group <- c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")

dat <- dat%>%melt(id.var = "age_group")


dat$age_group <- factor(dat$age_group,c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+") )
dat$variable <- factor(dat$variable,c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+") )



p3 <- ggplot(dat,
       aes(x = variable, y = age_group, fill = value))+
  geom_tile()+
  scale_fill_viridis()+
  theme_test()+
  xlab("Age group")+ 
  ylab("Age group")+
  theme(
    strip.text = element_text(size=12, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=12, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=12, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=12,family="Times New Roman"),
    legend.position= "none")

ggsave(
  "figures/contacts.png",
  plot = p3,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 7,
  height = 7,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)






###### initial deaths #####


deaths <- read.csv("data_outputs/inital_deaths_cal2.csv")

deaths$group <- c("0-4","5-19","20-39","20-39+","40-59","40-59+","60-74","75+")
deaths$group <- ordered(deaths$group, c("0-4","5-19","20-39","20-39+","40-59","40-59+","60-74","75+"))
names(deaths) <- c("deaths", "group")
  
ggplot(deaths, aes(x = group, y = 1000*deaths, fill = group))+
  geom_bar(stat = "identity",color = "black")+
  theme_test()+
  scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                  name = "Demographic group")+
  xlab("Demogrphic group")+
  ylab("Initial deaths per 1000")+
  theme(axis.title.x = element_text(size=20, face="bold",family="Times New Roman"),
        axis.text = element_text(size=20,family="Times New Roman", color = "black"),
        axis.title.y = element_text(size=20, face="bold",family="Times New Roman"),
        legend.title = element_text(size=20, face="bold",family="Times New Roman"),
        legend.text = element_text(size=20,family="Times New Roman"))
  

