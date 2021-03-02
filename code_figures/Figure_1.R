library(dplyr)
library(ggplot2)
library(reshape2)
library(viridis)

setwd("~/desktop/Dynamic_Vaccine_Allocation")


bins <- read.csv("data_transformed/population.csv")
bins <- bins %>% filter(ess_size == 0.4)
bins$age_group <- c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+")
bins$age_group <- factor(bins$age_group, c("0-4","5-19","20-39","20-39*","40-59","40-59*","60-74","75+"))
bins$size <- bins$size/sum(bins$size)
bins <- bins %>% dplyr::select(age_group, size)



# size of demographic groups 
p2 <- ggplot(bins,
             aes(x = age_group, y = size,))+
  geom_col(position = position_dodge(width = 0.85), 
           fill = "grey", color = "black")+
  theme_test()+
  xlab("Demographic group")+ 
  ylab("Portion of total popuatlion")+
  theme(
    strip.text = element_text(size=20, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=20, face="bold",family="Times New Roman"),
    axis.text = element_text(size=20,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=20, face="bold",family="Times New Roman"),
    legend.title = element_text(size=20, face="bold",family="Times New Roman"),
    legend.text = element_text(size=20,family="Times New Roman"),
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
  xlab("Demographic group")+ 
  ylab("Demographic group")+
  theme(
    strip.text = element_text(size=20, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=20, face="bold",family="Times New Roman"),
    axis.text = element_text(size=20,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=20, face="bold",family="Times New Roman"),
    legend.title = element_text(size=20, face="bold",family="Times New Roman"),
    legend.text = element_text(size=20,family="Times New Roman"))

ggsave(
  "figures/contacts.png",
  plot = p3,
  #device = NULL,
  #path = NULL,
  #scale = 1,
  width = 8.5,
  height = 7,
  units = c("in", "cm", "mm"),
  dpi = 300,
  
)