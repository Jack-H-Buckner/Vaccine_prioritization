library(patternplot)
library(plyr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(gridExtra)
# load data files 
setwd("~/github/Vaccine_Allocation_revisions")



header.true <- function(df) {
  names(df) <- as.character(unlist(df[1,]))
  df[-1,]
}



process_sol_file <- function(fn){
  
  d <- read.csv(fn)
  
  d <- d %>% header.true()
  
  d$static <- c(rep(0,48*3),rep(1,nrow(d)-48*3))
  
  
  d_dynamic <- d %>% dplyr::filter(static == 0)
  
  d_static <- d %>% dplyr::filter(static == 1)
  
  d_static <- d_static[1:24,]
  
  return(list(dynamic_sols = d_dynamic, static_sols = d_static))
}




make_fig_dynamic <- function(fn){
  data <- process_sol_file(fn)

  dat_sol <- data$dynamic_sols

  # order factor levels for clarity on plots 
  dat_sol$agebins <- factor(dat_sol$agebins, 
                          c("0-4", "5-19", "20-39 low", "20-39 high", "40-59 low", "40-59 high", "60 - 74", "75+"))
  dat_sol$agebins <- mapvalues(dat_sol$agebins, 
                             from = c("0-4", "5-19", "20-39 low", "20-39 high", "40-59 low", "40-59 high", "60 - 74", "75+"), 
                             to = c("a","b","c","d*","e","f*","g","h"))



  dat_sol$objective <- factor(dat_sol$objective, 
                            c("none", "deaths","YLL", "infections","unif"))


  # rename facotrs for plots 

  dat_sol$objective<- mapvalues(dat_sol$objective, 
                              from = c("deaths","YLL", "infections", "none", "unif"), 
                              to = c("Min deaths","Min YLL","Min infections", "none", "Uniform"))

  p11 <- ggplot(
  
    dat_sol%>% # filter data to only include main objectives 
      filter(objective %in% c("Min deaths", "Min infections", "Min YLL")),
  
    aes(x = timeblocks, # aesthetics 
        fill = agebins, 
        y = 100*as.numeric(mu)))+
  
    facet_wrap(~objective , ncol = 1, # use facet wrap to get a panel for each objective
               labeller = labeller(objective = objective.labs))+
  
  
    geom_bar(stat="identity", # use geom_bar with dodging to get grouped bar charts 
             position=position_dodge(width = 0.85), 
             width = 0.75,
             color = "black",
             size = 0.1)+
    
    geom_text(aes(label=agebins),  # place labels above each bar 
              position=position_dodge(width=0.85), 
              vjust=-0.75,
              family="Times New Roman",
              size = 2)+
    
    theme_minimal()+
    
    
    scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                      name = "Age group",
                      labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", 
                                 "e: 40-59 ", "f: 40-59*", "g: 60 - 74", "h: 75+"))+
    
    xlab("Decision period (months)")+ # axis lables 
    ylab("Percent of vaccines")+
  
    ylim(0,100)+ 
  
    theme(
      strip.text = element_text(size=10, face="bold",family="Times New Roman"),
      axis.title.x = element_text(size=10,family="Times New Roman"),
      axis.text = element_text(size=10,family="Times New Roman", color = "black"),
      axis.title.y = element_text(size=10,family="Times New Roman"),
      legend.title = element_text(size=10, face="bold",family="Times New Roman"),
      legend.text = element_text(size=10,family="Times New Roman"),
      legend.key.size = unit(0.75, "line"),
      legend.position="bottom"
    )





  # set facet labels to blank 
  objective.labs <- c("  ", " ", " ")
  names(objective.labs) <- c("Min deaths", "Min YLL", "Min infections")


  p21 <- ggplot(
  
    dat_sol%>% # select cumulative data at time six 
      filter(objective %in% c("Min deaths", "Min infections", "Min YLL"))%>%
      filter( timeblocks == 6 ),
  
  
    aes(x = timeblocks, # aesthetics 
        fill = agebins, 
        y = 100*as.numeric(cumulative)))+
  
    facet_wrap(~objective , ncol = 1, # facets 
             labeller = labeller(objective = objective.labs))+
  
    geom_bar(stat="identity", 
             position=position_dodge(width = 0.85), 
             width = 0.75,
             color = "black",
             size = 0.1)+
  
    geom_text(aes(label=agebins), 
              position=position_dodge(width=0.85), 
              vjust=-0.75,
              family="Times New Roman",
              size = 2)+
    
    theme_minimal()+
  
    scale_x_discrete(breaks = 6, labels = c("% group"))+
  
    scale_fill_brewer(palette="Accent", 
                      name = "Age group",
                      labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", "e: 40-59 ", 
                                 "f: 40-59*", "g: 60 - 74", "h: 75+"))+
    xlab(" ")+
    ylab("Percent of demographic group (period 6)")+
    ylim(0,100)+
      
    theme(
      strip.text = element_text(size=10, face="bold",family="Times New Roman"),
      axis.title.x = element_text(size=10,family="Times New Roman"),
      axis.text.x = element_text(size=10, family="Times New Roman", color = "black"),
      axis.text.y = element_blank(),
      axis.title.y = element_text(size=10,family="Times New Roman", color = "black"),
      legend.title = element_text(size=10, face="bold",family="Times New Roman"),
      legend.text = element_text(size=10,family="Times New Roman"),
      legend.key.size = unit(0.75, "line"),
      legend.position="bottom"
    )



  p31 <- ggplot(
    
    dat_sol%>% # select cumulative data at time six 
      filter(objective %in% c("Min deaths", "Min infections", "Min YLL"))%>%
      filter( timeblocks == 3),
    
    
    aes(x = timeblocks, # aesthetics 
        fill = agebins, 
        y = 100*as.numeric(cumulative)))+
    
    facet_wrap(~objective , ncol = 1, # facets 
               labeller = labeller(objective = objective.labs))+
    
    geom_bar(stat="identity", 
             position=position_dodge(width = 0.85), 
             width = 0.75,
             color = "black",
             size = 0.1)+
    
    geom_text(aes(label=agebins), 
              position=position_dodge(width=0.85), 
              vjust=-0.75,
              family="Times New Roman",
              size = 2)+
    
    theme_minimal()+
    
    scale_x_discrete(breaks = 6, labels = c("% group"))+
    
    scale_fill_brewer(palette="Accent", 
                      name = "Age group",
                      labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", "e: 40-59 ", 
                                 "f: 40-59*", "g: 60 - 74", "h: 75+"))+
    xlab(" ")+
    ylab("Percent of demographic group (period 3)")+
    ylim(0,100)+
    
    theme(
      strip.text = element_text(size=10, face="bold",family="Times New Roman"),
      axis.title.x = element_text(size=10,family="Times New Roman"),
      axis.text.x = element_text(size=10, family="Times New Roman", color = "black"),
      axis.text.y = element_blank(),
      axis.title.y = element_text(size=10,family="Times New Roman", color = "black"),
      legend.title = element_text(size=10, face="bold",family="Times New Roman"),
      legend.text = element_text(size=10,family="Times New Roman"),
      legend.key.size = unit(0.75, "line"),
      legend.position="bottom"
    )
  

  lemon::grid_arrange_shared_legend(p11, p31, p21, ncol=3, nrow=1, widths = c(5,1,1.25))
}

make_fig_dynamic("data_outputs/solution_beta01_alpha06_0000_40.csv")






make_fig_static <- function(fn){

  data <- process_sol_file(fn)



  #dat_sol <- header.true(data$static_sols)


  dat_sol <- data$static_sols

  # order factor levels for clarity on plots 
  dat_sol$agebins <- factor(dat_sol$agebins, 
                          c("0-4", "5-19", "20-39 low", "20-39 high", "40-59 low", "40-59 high", "60 - 74", "75+"))

  dat_sol$agebins <- mapvalues(dat_sol$agebins, 
                             from = c("0-4", "5-19", "20-39 low", "20-39 high", "40-59 low", "40-59 high", "60 - 74", "75+"), 
                             to = c("a","b","c","d*","e","f*","g","h"))



  dat_sol$objective <- factor(dat_sol$objective, 
                            c("none", "deaths","YLL", "infections","unif"))


  # rename facotrs for plots 

  dat_sol$objective<- mapvalues(dat_sol$objective, 
                              from = c("deaths","YLL", "infections", "none", "unif"), 
                              to = c("Min deaths","Min YLL","Min infections", "none", "Uniform"))


  ggplot(
  
    dat_sol%>% # filter data to only include main objectives 
      filter(objective %in% c("Min deaths", "Min infections", "Min YLL")),
  
    aes(x = timeblocks, # aesthetics 
        fill = agebins, 
        y = 100*as.numeric(mu)))+
  
    facet_wrap(~objective , ncol = 1, # use facet wrap to get a panel for each objective
               labeller = labeller(objective = objective.labs))+
  
  
    geom_bar(stat="identity", # use geom_bar with dodging to get grouped bar charts 
             position=position_dodge(width = 0.85), 
             width = 0.75,
             color = "black",
             size = 0.1)+
  
    geom_text(aes(label=agebins),  # place labels above each bar 
              position=position_dodge(width=0.85), 
              vjust=-0.75,
              family="Times New Roman",
              size = 2)+
    
    theme_minimal()+
    
    
    scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                      name = "Age group",
                      labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", 
                                 "e: 40-59 ", "f: 40-59*", "g: 60 - 74", "h: 75+"))+
    
    xlab("Decision period (months)")+ # axis lables 
    ylab("Percent of vaccines")+
    
    ylim(0,100)+ 
    
    theme(
      strip.text = element_text(size=10, face="bold",family="Times New Roman"),
      axis.title.x = element_text(size=10,family="Times New Roman"),
      axis.text = element_text(size=10,family="Times New Roman", color = "black"),
      axis.title.y = element_text(size=10,family="Times New Roman"),
      legend.title = element_text(size=10, face="bold",family="Times New Roman"),
      legend.text = element_text(size=10,family="Times New Roman"),
      legend.key.size = unit(0.75, "line"),
      legend.position="bottom"
    )


}


make_fig_static("data_outputs/solution_beta01_alpha06_0000_40.csv")














d <- read.csv("data_outputs/solution_range_test.csv")

df <- d %>% 
  melt(id.var = "Column49") %>%
  group_by(Column49, variable) %>%
  summarize(min = min(value),
            max = max(value))

df$timeblocks <- rep(c(rep(1,8),rep(2,8),rep(3,8),rep(4,8),rep(5,8),rep(6,8)),3)
df$agebins<- rep(rep(c("a","b","c","d*","e","f*","g","h"),6),3)



d_cu <- read.csv("data_outputs/solution_cumulative_range_test.csv")

df_cu <- d_cu %>% 
  melt(id.var = "Column49") %>%
  group_by(Column49, variable) %>%
  summarize(min_cu = min(value),
            max_cu = max(value))

df_cu$timeblocks <- rep(c(rep(1,8),rep(2,8),rep(3,8),rep(4,8),rep(5,8),rep(6,8)),3)
df_cu$agebins<- rep(rep(c("a","b","c","d*","e","f*","g","h"),6),3)


d <- read.csv("data_outputs/solution_beta01_alpha04_0000_40_re.csv")

dat_sol <- d %>% dplyr::filter(objective %in% c("deaths","infections", "YLL"))


dat_sol$agebins <- factor(dat_sol$agebins, 
                          c("0-4", "5-19", "20-39 low", "20-39 high", "40-59 low", "40-59 high", "60 - 74", "75+"))
dat_sol$agebins <- mapvalues(dat_sol$agebins, 
                             from = c("0-4", "5-19", "20-39 low", "20-39 high", "40-59 low", "40-59 high", "60 - 74", "75+"), 
                             to = c("a","b","c","d*","e","f*","g","h"))



names(df) <- c("objective", "variable", "min", "max", "timeblocks","agebins")

df <- df %>% dplyr::select(min,max,objective, timeblocks, agebins)


names(df_cu) <- c("objective", "variable", "min_cu", "max_cu", "timeblocks","agebins")

df_cu <- df_cu %>% dplyr::select(min_cu,max_cu,objective, timeblocks, agebins)



df_plot <- merge(dat_sol, df, by = c("objective","timeblocks","agebins"))
df_plot <- merge(df_plot, df_cu, by = c("objective","timeblocks","agebins"))















ggplot(
  
  df_plot%>% # select cumulative data at time six 
    filter(objective %in% c("deaths", "infections", "YLL")),
  
  
  aes(x = timeblocks, # aesthetics 
      fill = agebins,
      ymin = 100*min,
      ymax = 100*max,
      y = 100*as.numeric(mu)))+
  
  facet_wrap(~objective , ncol = 1, # facets 
             labeller = labeller(objective = objective.labs))+
  
  geom_bar(stat="identity", 
           position=position_dodge(width = 0.85), 
           width = 0.75,
           color = "black",
           size = 0.1)+
  
  geom_errorbar(position=position_dodge(width = 0.85)
           )+
  
  geom_text(aes(label=agebins), 
            position=position_dodge(width=0.85), 
            vjust=-0.75,
            family="Times New Roman",
            size = 2)+
  
  theme_minimal()+
  
  scale_x_discrete(breaks = 6, labels = c("% group"))+
  
  scale_fill_brewer(palette="Accent", 
                    name = "Age group",
                    labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", "e: 40-59 ", 
                               "f: 40-59*", "g: 60 - 74", "h: 75+"))+
  xlab(" ")+
  ylab("Percent of demographic group (period 3)")+
  ylim(0,100)+
  
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10,family="Times New Roman"),
    axis.text.x = element_text(size=10, family="Times New Roman", color = "black"),
    axis.text.y = element_blank(),
    axis.title.y = element_text(size=10,family="Times New Roman", color = "black"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(0.75, "line"),
    legend.position="bottom"
  )






ggplot(
  
  df_plot%>% # select cumulative data at time six 
    filter(objective %in% c("deaths", "infections", "YLL"),
           timeblocks ==3),
  
  
  aes(x = timeblocks, # aesthetics 
      fill = agebins,
      ymin = 100*min_cu,
      ymax = 100*max_cu,
      y = 100*as.numeric(cumulative)))+
  
  facet_wrap(~objective , ncol = 1, # facets 
             labeller = labeller(objective = objective.labs))+
  
  geom_bar(stat="identity", 
           position=position_dodge(width = 0.85), 
           width = 0.75,
           color = "black",
           size = 0.1)+
  
  geom_errorbar(position=position_dodge(width = 0.85)
  )+
  
  geom_text(aes(label=agebins), 
            position=position_dodge(width=0.85), 
            vjust=-0.75,
            family="Times New Roman",
            size = 2)+
  
  theme_minimal()+
  
  scale_x_discrete(breaks = 6, labels = c("% group"))+
  
  scale_fill_brewer(palette="Accent", 
                    name = "Age group",
                    labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", "e: 40-59 ", 
                               "f: 40-59*", "g: 60 - 74", "h: 75+"))+
  xlab(" ")+
  ylab("Percent of demographic group (period 3)")+
  ylim(0,100)+
  
  theme(
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10,family="Times New Roman"),
    axis.text.x = element_text(size=10, family="Times New Roman", color = "black"),
    axis.text.y = element_blank(),
    axis.title.y = element_text(size=10,family="Times New Roman", color = "black"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(0.75, "line"),
    legend.position="bottom"
  )


