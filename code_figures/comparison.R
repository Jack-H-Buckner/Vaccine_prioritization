library(ggplot2)
library(viridis)
library(dplyr)
library(gridExtra)
setwd("~/github/Vaccine_Allocation_cleaned")

header.true <- function(df) {
  names(df) <- as.character(unlist(df[1,]))
  df[-1,]
}



## compare outcomes 



df <- read.csv("data_outputs/outcomes_base_compare.csv")




df <- df %>% header.true()
names(df) <- c("objective_target", "objective_test", "value")



df_age <- read.csv("data_outputs/outcomes_base_compare_age_only.csv")

df_age <- df_age %>% header.true()
names(df_age) <- c("objective_target", "objective_test", "value")
df_age$objective_test <- sub(" age only", "",df_age$objective_test)
df_age <- filter(df_age, objective_target ==  objective_test)

df_age <- df_age %>% mutate(objective_target = "age")

df_age$static <- 0

df <- df %>% filter(objective_target != "none")


df$static <- c(rep(0,9), rep(1,9), rep(2,3))

df <- rbind(df, df_age)

df <- df %>% filter(static != 1| objective_target ==objective_test) %>%
  mutate(objective = paste(objective_target, static, sep = "_"))



df$objective_target[10:12] <- c("static","static","static")


unif <- df %>% filter(objective_target == "unif")
names(unif) <- c("objective_target_1", "objective_test",  "unif", "static", "objective")
df <- merge(df, unif, by = "objective_test")


df <- df %>% mutate(value = as.numeric(value)/as.numeric(unif))%>%
  filter(objective_target != "unif")





df$objective_target <- factor(df$objective_target, 
                             c("age", "static","deaths","YLL", "infections"))

df$objective_target <- mapvalues(df$objective_target, 
                               from = c("age", "static", "deaths","YLL", "infections"), 
                               to = c("Age only", "Static", "Deaths","YLL","Infections"))



df <- df %>% mutate(lab = substr(objective_target,1,1))


p1 <- ggplot(df, aes(x =  objective_test, y = as.numeric(value), fill = objective_target))+
  geom_bar(stat = "identity", # make bar plot
            position=position_dodge(width = 0.7),
            width = 0.5, 
            color = "black")+
  theme_minimal()+

  geom_text(aes(y = 0.5, label=lab),  # add labels to bars
            position=position_dodge(width=0.7), 
            vjust=-1,
            family="Times New Roman",
            size = 3)+
  ylab("Reletive performance")+
  xlab("Test objective")+
  coord_cartesian(ylim = c(0.5, 1.2))+
  geom_hline(aes(yintercept = 1),linetype = "dashed")+ # add line at 100%

  scale_fill_brewer(palette="Accent",  # set bar colors 
                    name = "Policy",
                    labels = c("Age only", "Static" ,"Min deaths", "Min YLL", "Min infections"))+
  theme( # change fonts 
    axis.title.x = element_text(size=10,family="Times New Roman"),
    axis.title.y = element_text(size=10,family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.key.size = unit(0.75, "line"),
    strip.text = element_text(size = 10, face="bold",family="Times New Roman")
  )
















dat_time <- read.csv("data_outputs/time_base_compare.csv")
dat_time <- dat_time %>% header.true()


dat_time$static <- c(
  rep(rep(0, length(table(dat_time$time))), 3),
  rep(rep(1, length(table(dat_time$time))), 3),
  rep(rep(0, length(table(dat_time$time))), 2)                   
  )

dat_time <- dplyr::filter(dat_time, static == 0)


dat_time$objective <- factor(dat_time$objective, 
                             c("none", "unif","deaths","YLL", "infections"))
dat_time$objective<- mapvalues(dat_time$objective, 
                               from = c("deaths","YLL", "infections", "none", "unif"), 
                               to = c("Deaths","YLL","Infections", "none", "Uniform"))

#
p2 <- ggplot(dat_time,
       aes(x = as.numeric(time), 
           y = 1000*as.numeric(infections), 
           color = objective,
           linetype = objective))+
  geom_line()+
  theme_minimal()+
  scale_color_brewer(palette="Dark2", 
                     name = "Policy", 
                     labels = c("No vaccines", "Proportional","Min death", "Min YLL", "Min infection"))+ 
  scale_linetype_manual( values = c("solid", "dotted", "12345678", "dotdash", "longdash", "dotdash"),
                         name = "Policy", 
                         labels = c("No vaccines", "Proportional","Min death", "Min YLL", "Min infection"))+
  xlab("Time (days)")+
  ylab("Infections per 1000")+
  theme(
    axis.title.x = element_text(size=10,family="Times New Roman"),
    axis.title.y = element_text(size=10,family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.key.size = unit(1.75, "line")
  )




ggsave(  "figures/fig_base_compare.jpg",
         grid.arrange(p2,p1, ncol = 2),
         width = 12.0,
         height = 3.5,
         dpi = 300
)




## plot static policies


dat_sol <- read.csv("data_outputs/solution_base_compare.csv")

dat_sol <-dat_sol %>% header.true()

dat_sol$agebins <- factor(dat_sol$agebins, 
                          c("0-4", "5-19", "20-39 low", "20-39 high", "40-59 low", "40-59 high", "60 - 74", "75+"))
dat_sol$agebins <- mapvalues(dat_sol$agebins, 
                             from = c("0-4", "5-19", "20-39 low", "20-39 high", "40-59 low", "40-59 high", "60 - 74", "75+"), 
                             to = c("a","b","c","d*","e","f*","g","h"))


dat_sol$objective <- factor(dat_sol$objective, 
                            c("none", "deaths","YLL", "infections","unif"))

dat_sol$objective<- mapvalues(dat_sol$objective, 
                              from = c("deaths","YLL", "infections", "none", "unif"), 
                              to = c("Min deaths","Min YLL","Min infections", "none", "Uniform"))

p3 <-ggplot(dat_sol[(3*48+1):(3*48+24),],
       aes(x = objective, y = 100*as.numeric(mu), fill = agebins))+
  geom_bar(stat = "identity", # make bar plot
           position=position_dodge(width = 0.7),
           width = 0.5, 
           color = "black")+
  
  theme_minimal()+
  
  
  scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                    name = "Age group",
                    labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", 
                               "e: 40-59 ", "f: 40-59*", "g: 60 - 74", "h: 75+"))+

  ylab("Percent of vaccines")+
  ylim(0,50)+ 
  theme(
    strip.text = element_text(size=12, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=12,family="Times New Roman"),
    axis.text = element_text(size=12,family="Times New Roman", color = "black"),
    axis.title.y = element_text(size=12,family="Times New Roman"),
    legend.title = element_text(size=12, face="bold",family="Times New Roman"),
    legend.text = element_text(size=12,family="Times New Roman"),
    legend.key.size = unit(0.75, "line"),
    legend.position="bottom"
  )


ggsave(  "figures/solution_base_static.jpg",
         p3,
         width = 7.0,
         height = 4.0,
         dpi = 300
)






