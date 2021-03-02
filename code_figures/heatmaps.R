
# make heat maps 

library(ggplot2)
library(viridis)
library(dplyr)
library(reshape2)
library(plyr)

library(viridis)
setwd("~/github/Vaccine_Allocation_revisions")

header.true <- function(df) {
  names(df) <- as.character(unlist(df[1,]))
  df[-1,]
}

process_figure_data_sol <- function(files, senario_names){
  df <- data.frame()
  for(i in 1:length(files)){
    
    dat_sol <- read.csv(files[i])
    
    dat_sol <- header.true(dat_sol)

    
    dat_sol <- dat_sol[1:144,]
    
    # order factor levels for clarity on plots 
    
    dat_sol$agebins <- factor(dat_sol$agebins, 
                              c("0-4", "5-19", "20-39 low", "20-39 high", "40-59 low", 
                                "40-59 high", "60 - 74", "75+"))
    
    #dat_sol$agebins <- mapvalues(dat_sol$agebins, 
    #                             
    #                             from = c("0-4", "5-19", "20-39 low", "20-39 high","40-59 low",
    #                                      "40-59 high", "60 - 80", "80+"), 
    #                             to = c("0-4", "5-19", "20-39", "20-39*","40-59",
    #                                    "40-59*", "60 - 74", "75+"))
    
    dat_sol$objective <- factor(dat_sol$objective, 
                                c("none", "deaths","YLL", "infections","unif"))
    
    
    dat_sol$objective<- mapvalues(dat_sol$objective, 
                                  from = c("deaths","YLL", "infections", "none", "unif"), 
                                  to = c("Min deaths","Min YLL","Min infections", "none",
                                         "uniform"))
    
    dat_sol$senario <- rep(senario_names[i], nrow(dat_sol))
    df <- rbind(df, dat_sol)
  }
  return(df)
}  





files <- c("data_outputs/weak_NPI_policies.csv", 
           "data_outputs/solution_beta01_alpha03_0000_40_init_090_001_008.csv",
           "data_outputs/solution_beta01_alpha03_0000_40_init_090_002_008.csv",
           "data_outputs/solution_beta01_alpha03_0000_40_init_090_004_008.csv")

senario_names <- c("0.5%", "1.0%","2%","4%")

df <- process_figure_data_sol(files, senario_names)

df$senario <- factor(df$senario , 
                     rev(c("0.5%", "1.0%","2%","4%")))

objective.labs <- c("Minimize deaths", 
                    "Minimize YLL", 
                    "Minimize infections")
names(objective.labs) <- c("Min deaths", "Min YLL", "Min infections")


p1 <- ggplot(df%>%filter(timeblocks == 6, objective %in% c("Min deaths", "Min YLL", "Min infections")), 
             aes(x = agebins, y = senario, fill = 100*as.numeric(cumulative)))+
  facet_wrap(~objective,ncol = 1,
             labeller = labeller(objective = objective.labs))+
  geom_tile(height = 0.9)+theme_minimal()+
  scale_fill_viridis(name = "Percent of group")+
  xlab("Demographic group")+
  ylab("")+ 
  
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.text.y = element_text(size=10,family="Times New Roman"),
    axis.title.y = element_text(size=10, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(1.25, "line")
  )

ggsave("figures/heatmap_month6_work_40_inits.jpg",
       p1,
       width = 6.75,
       height = 4.75,
       dpi = 300
)



p1 <- ggplot(df%>%filter(timeblocks == 3, objective %in% c("Min deaths", "Min YLL", "Min infections")), 
             aes(x = agebins, y = senario, fill = 100*as.numeric(cumulative)))+
  facet_wrap(~objective,ncol = 1,
             labeller = labeller(objective = objective.labs))+
  geom_tile(height = 0.9)+theme_minimal()+
  scale_fill_viridis(name = "Percent of group")+
  xlab("Demographic group")+
  ylab("")+ 
  
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.text.y = element_text(size=10,family="Times New Roman"),
    axis.title.y = element_text(size=10, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(1.25, "line")
  )

ggsave("figures/heatmap_month3_work_40_inits.jpg",
       p1,
       width = 6.75,
       height = 4.75,
       dpi = 300
)










files <- c("data_outputs/solution_beta01_alpha04_0000_40_inits_075_002_022.csv", 
           "data_outputs/solution_beta01_alpha04_0000_40_inits_080_002_017.csv",
           "data_outputs/solution_beta01_alpha04_0000_40_inits_085_002_012.csv",
           "data_outputs/solution_beta01_alpha04_0000_40_init_090_002_008.csv")

senario_names <- c("75%","80%","85%","90%")

df <- process_figure_data_sol(files, senario_names)

df$senario <- factor(df$senario , 
                     rev(c("75%","80%","85%","90%")))

objective.labs <- c("Minimize deaths", 
                    "Minimize YLL", 
                    "Minimize infections")
names(objective.labs) <- c("Min deaths", "Min YLL", "Min infections")


p1 <- ggplot(df%>%filter(timeblocks == 6, objective %in% c("Min deaths", "Min YLL", "Min infections")), 
             aes(x = agebins, y = senario, fill = 100*as.numeric(cumulative)))+
  facet_wrap(~objective,ncol = 1,
             labeller = labeller(objective = objective.labs))+
  geom_tile(height = 0.9)+theme_minimal()+
  scale_fill_viridis(name = "Percent of group")+
  xlab("Demographic group")+
  ylab("")+ 
  
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.text.y = element_text(size=10,family="Times New Roman"),
    axis.title.y = element_text(size=10, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(1.25, "line")
  )

ggsave("figures/heatmap_month6_work_40_sucpts.jpg",
       p1,
       width = 6.75,
       height = 4.75,
       dpi = 300
)



p1 <- ggplot(df%>%filter(timeblocks == 3, objective %in% c("Min deaths", "Min YLL", "Min infections")), 
             aes(x = agebins, y = senario, fill = 100*as.numeric(cumulative)))+
  facet_wrap(~objective,ncol = 1,
             labeller = labeller(objective = objective.labs))+
  geom_tile(height = 0.9)+theme_minimal()+
  scale_fill_viridis(name = "Percent of group")+
  xlab("Demographic group")+
  ylab("")+ 
  
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.text.y = element_text(size=10,family="Times New Roman"),
    axis.title.y = element_text(size=10, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(1.25, "line")
  )

ggsave("figures/heatmap_month3_work_40_sucpts.jpg",
       p1,
       width = 6.75,
       height = 4.75,
       dpi = 300
)











files <- c("data_outputs/solution_beta01_alpha04_0000_40_20_days.csv", 
           "data_outputs/solution_beta01_alpha04_0000_40_30_days.csv",
           "data_outputs/solution_beta01_alpha04_0000_40_40_days.csv",
           "data_outputs/solution_beta01_alpha04_0000_40_50_days.csv",
           "data_outputs/solution_beta01_alpha04_0000_40_60_days.csv")

senario_names <- c("20 days","30 days", "40 days", "50 days", "60 days")

df <- process_figure_data_sol(files, senario_names)

df$senario <- factor(df$senario , 
                     rev(c("20 days","30 days", "40 days", "50 days", "60 days")))

objective.labs <- c("Minimize deaths", 
                    "Minimize YLL", 
                    "Minimize infections")
names(objective.labs) <- c("Min deaths", "Min YLL", "Min infections")


p1 <- ggplot(df%>%filter(timeblocks == 6, objective %in% c("Min deaths", "Min YLL", "Min infections")), 
             aes(x = agebins, y = senario, fill = 100*as.numeric(cumulative)))+
  facet_wrap(~objective,ncol = 1,
             labeller = labeller(objective = objective.labs))+
  geom_tile(height = 0.9)+theme_minimal()+
  scale_fill_viridis(name = "Percent of group")+
  xlab("Demographic group")+
  ylab("")+ 
  
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.text.y = element_text(size=10,family="Times New Roman"),
    axis.title.y = element_text(size=10, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(1.25, "line")
  )

ggsave("figures/heatmap_month6_work_40_supply.jpg",
       p1,
       width = 6.75,
       height = 4.75,
       dpi = 300
)



p1 <- ggplot(df%>%filter(timeblocks == 3, objective %in% c("Min deaths", "Min YLL", "Min infections")), 
             aes(x = agebins, y = senario, fill = 100*as.numeric(cumulative)))+
  facet_wrap(~objective,ncol = 1,
             labeller = labeller(objective = objective.labs))+
  geom_tile(height = 0.9)+theme_minimal()+
  scale_fill_viridis(name = "Percent of group")+
  xlab("Demographic group")+
  ylab("")+ 
  
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.text.y = element_text(size=10,family="Times New Roman"),
    axis.title.y = element_text(size=10, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(1.25, "line")
  )

ggsave("figures/heatmap_month3_work_40_supply.jpg",
       p1,
       width = 6.75,
       height = 4.75,
       dpi = 300
)










files <- c("data_outputs/solution_beta01_alpha03_0000_40.csv", 
           "data_outputs/solution_beta01_alpha04_0000_40.csv",
           "data_outputs/solution_beta01_alpha05_0000_40.csv",
           "data_outputs/solution_beta01_alpha06_0000_40.csv")

senario_names <- c("30%","40%", "50%","60%")

df <- process_figure_data_sol(files, senario_names)

df$senario <- factor(df$senario , 
                     rev(c("30%","40%", "50%","60%")))

objective.labs <- c("Minimize deaths", 
                    "Minimize YLL", 
                    "Minimize infections")
names(objective.labs) <- c("Min deaths", "Min YLL", "Min infections")


p1 <- ggplot(df%>%filter(timeblocks == 6, objective %in% c("Min deaths", "Min YLL", "Min infections")), 
             aes(x = agebins, y = senario, fill = 100*as.numeric(cumulative)))+
  facet_wrap(~objective,ncol = 1,
             labeller = labeller(objective = objective.labs))+
  geom_tile(height = 0.9)+theme_minimal()+
  scale_fill_viridis(name = "Percent of group")+
  xlab("Demographic group")+
  ylab("")+ 
  
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.text.y = element_text(size=10,family="Times New Roman"),
    axis.title.y = element_text(size=10, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(1.25, "line")
  )

ggsave("figures/heatmap_month6_work_40_social.jpg",
       p1,
       width = 6.75,
       height = 4.75,
       dpi = 300
)



p1 <- ggplot(df%>%filter(timeblocks == 3, objective %in% c("Min deaths", "Min YLL", "Min infections")), 
             aes(x = agebins, y = senario, fill = 100*as.numeric(cumulative)))+
  facet_wrap(~objective,ncol = 1,
             labeller = labeller(objective = objective.labs))+
  geom_tile(height = 0.9)+theme_minimal()+
  scale_fill_viridis(name = "Percent of group")+
  xlab("Demographic group")+
  ylab("")+ 
  
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.text.y = element_text(size=10,family="Times New Roman"),
    axis.title.y = element_text(size=10, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(1.25, "line")
  )

ggsave("figures/heatmap_month3_work_40_social.jpg",
       p1,
       width = 6.75,
       height = 4.75,
       dpi = 300
)









files <- c("data_outputs/solution_beta01_alpha04_0304_40.csv", 
           "data_outputs/solution_beta01_alpha04_0407_40.csv",
           "data_outputs/solution_beta01_alpha04_0509_40.csv",
           "data_outputs/solution_beta01_alpha04_0611_40.csv")

senario_names <- c("30% - 40%","40% 70%", "50% 90%","60% 110%")

df <- process_figure_data_sol(files, senario_names)

df$senario <- factor(df$senario , 
                     rev(c("30% - 40%","40% 70%", "50% 90%","60% 110%")))

objective.labs <- c("Minimize deaths", 
                    "Minimize YLL", 
                    "Minimize infections")
names(objective.labs) <- c("Min deaths", "Min YLL", "Min infections")


p1 <- ggplot(df%>%filter(timeblocks == 6, objective %in% c("Min deaths", "Min YLL", "Min infections")), 
             aes(x = agebins, y = senario, fill = 100*as.numeric(cumulative)))+
  facet_wrap(~objective,ncol = 1,
             labeller = labeller(objective = objective.labs))+
  geom_tile(height = 0.9)+theme_minimal()+
  scale_fill_viridis(name = "Percent of group")+
  xlab("Demographic group")+
  ylab("")+ 
  
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.text.y = element_text(size=10,family="Times New Roman"),
    axis.title.y = element_text(size=10, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(1.25, "line")
  )

ggsave("figures/heatmap_month6_work_40_work.jpg",
       p1,
       width = 6.75,
       height = 4.75,
       dpi = 300
)



p1 <- ggplot(df%>%filter(timeblocks == 3, objective %in% c("Min deaths", "Min YLL", "Min infections")), 
             aes(x = agebins, y = senario, fill = 100*as.numeric(cumulative)))+
  facet_wrap(~objective,ncol = 1,
             labeller = labeller(objective = objective.labs))+
  geom_tile(height = 0.9)+theme_minimal()+
  scale_fill_viridis(name = "Percent of group")+
  xlab("Demographic group")+
  ylab("")+ 
  
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.text.y = element_text(size=10,family="Times New Roman"),
    axis.title.y = element_text(size=10, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(1.25, "line")
  )

ggsave("figures/heatmap_month3_work_40_work.jpg",
       p1,
       width = 6.75,
       height = 4.75,
       dpi = 300
)







files <- c("data_outputs/solution_beta01_alpha03_0000_20.csv", 
           "data_outputs/solution_beta01_alpha04_cl_20.csv",
           "data_outputs/solution_beta01_alpha03_0000_40.csv",
           "data_outputs/solution_beta01_alpha04_cl_40.csv")

senario_names <- c("20%", "20% cl", "40%", "40% cl" )

df <- process_figure_data_sol(files, senario_names)

df$senario <- factor(df$senario , 
                     rev(c("20%", "20% cl", "40%", "40% cl" )))

objective.labs <- c("Minimize deaths", 
                    "Minimize YLL", 
                    "Minimize infections")
names(objective.labs) <- c("Min deaths", "Min YLL", "Min infections")


p1 <- ggplot(df%>%filter(timeblocks == 6, objective %in% c("Min deaths", "Min YLL", "Min infections")), 
             aes(x = agebins, y = senario, fill = 100*as.numeric(cumulative)))+
  facet_wrap(~objective,ncol = 1,
             labeller = labeller(objective = objective.labs))+
  geom_tile(height = 0.9)+theme_minimal()+
  scale_fill_viridis(name = "Percent of group")+
  xlab("Demographic group")+
  ylab("")+ 
  
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.text.y = element_text(size=10,family="Times New Roman"),
    axis.title.y = element_text(size=10, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(1.25, "line")
  )

ggsave("figures/heatmap_month6_alt_structure.jpg",
       p1,
       width = 6.75,
       height = 4.75,
       dpi = 300
)



p1 <- ggplot(df%>%filter(timeblocks == 3, objective %in% c("Min deaths", "Min YLL", "Min infections")), 
             aes(x = agebins, y = senario, fill = 100*as.numeric(cumulative)))+
  facet_wrap(~objective,ncol = 1,
             labeller = labeller(objective = objective.labs))+
  geom_tile(height = 0.9)+theme_minimal()+
  scale_fill_viridis(name = "Percent of group")+
  xlab("Demographic group")+
  ylab("")+ 
  
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.text.y = element_text(size=10,family="Times New Roman"),
    axis.title.y = element_text(size=10, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(1.25, "line")
  )

ggsave("figures/heatmap_month3_alt_structure.jpg",
       p1,
       width = 6.75,
       height = 4.75,
       dpi = 300
)

