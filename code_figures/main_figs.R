
library(patternplot)
library(plyr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(gridExtra)
# load data files 
setwd("~/github/Vaccine_Allocation_revisions")

make_plots <- function(fn){ 
  dat_sol <- read.csv(fn[2])
  print(dat_sol)
  dat_time <- read.csv(fn[1])
  
  dat_outcome <- read.csv(fn[3])
  
  
  # change files headers to columnnames 
  
  header.true <- function(df) {
    names(df) <- as.character(unlist(df[1,]))
    df[-1,]
  }
  
  dat_sol <- header.true(dat_sol)
  dat_time <- header.true(dat_time)
  dat_outcome <- header.true(dat_outcome)
  names(dat_outcome) <- c("objective", "outcome", "value")
  
  
  
  # order factor levels for clarity on plots 
  dat_sol$agebins <- factor(dat_sol$agebins, 
                            c("0-4", "5-19", "20-39 low", "20-39 high", "40-59 low", "40-59 high", "60 - 74", "75+"))
  dat_sol$agebins <- mapvalues(dat_sol$agebins, 
                               from = c("0-4", "5-19", "20-39 low", "20-39 high", "40-59 low", "40-59 high", "60 - 74", "75+"), 
                               to = c("a","b","c","d*","e","f*","g","h"))
  
  dat_time$objective <- factor(dat_time$objective, 
                               c("none", "unif","deaths","YLL", "infections"))
  dat_sol$objective <- factor(dat_sol$objective, 
                              c("none", "deaths","YLL", "infections","unif"))
  dat_outcome$objective <- factor(dat_outcome$objective, 
                                  c("deaths","YLL", "infections"))
  dat_outcome$outcome <- factor(dat_outcome$outcome, 
                                c("deaths","YLL", "infections"))
  
  
  # rename facotrs for plots 
  dat_outcome$objective<- mapvalues(dat_outcome$objective, 
                                    from = c("deaths","YLL", "infections"), 
                                    to = c("D","Y","I"))
  dat_outcome$outcome<- mapvalues(dat_outcome$outcome, 
                                  from = c("deaths","YLL", "infections"), 
                                  to = c("Deaths","YLL", "Infections"))
  dat_sol$objective<- mapvalues(dat_sol$objective, 
                                from = c("deaths","YLL", "infections", "none", "unif"), 
                                to = c("Min deaths","Min YLL","Min infections", "none", "Uniform"))
  dat_time$objective<- mapvalues(dat_time$objective, 
                                 from = c("deaths","YLL", "infections", "none", "unif"), 
                                 to = c("Deaths","YLL","Infections", "none", "Uniform"))
  
  
  
  
  
  
  
  
  # plot time series 
  p1 <- ggplot(dat_time,
               aes(x = as.numeric(time), 
                   y = 1000*as.numeric(infections), 
                   color = objective,
                   linetype = objective))+
    geom_line()+
    theme_minimal()+
    scale_color_brewer(palette="Dark2", 
                       name = "Policy", 
                       labels = c("No vaccines", "Proportional", "Min death", "Min YLL", "Min infection"))+ 
    scale_linetype_manual( values = c("solid", "dotted", "12345678", "dotdash", "longdash"),
                           name = "Policy", 
                           labels = c("No vaccines", "Proportional", "Min death", "Min YLL", "Min infection"))+
    xlab("Time (days)")+
    ylab("Infections per 1000")+
    theme(
      axis.title.x = element_text(size=12,family="Times New Roman"),
      axis.title.y = element_text(size=12,family="Times New Roman"),
      axis.text = element_text(size=12,family="Times New Roman"),
      legend.text = element_text(size=12,family="Times New Roman"),
      legend.title = element_text(size=12, face="bold",family="Times New Roman"),
      legend.key.size = unit(1.75, "line")
    )
  
  
  
  
  
  # plot solution 
  
  
  
  dat_sol <- read.csv(fn[2])
  dat_sol <- header.true(dat_sol)
  
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
  # define the labels for the facets - the spaces here are a bit of a hack
  # to center the facet labels between the three sets of plots
  objective.labs <- c("                                                        Minimize deaths", 
                      "                                                        Minimize YLL", 
                      "                                                        Minimize infections")
  names(objective.labs) <- c("Min deaths", "Min YLL", "Min infections")
  
  
  p11 <- ggplot(
    
    dat_sol%>% # filter data to only include main objectives 
      filter(objective %in% c("Min deaths", "Min infections", "Min YLL")),
    
    aes(x = timeblocks, # aesthetics 
        fill = agebins, 
        y = 100*as.numeric(mu))
  )+
    
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
        y = 100*as.numeric(cumulative))
  )+
    
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
    ylab("Percent of demographic group")+
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
  
  
  
  p31 <- ggplot(dat_sol%>%
                  dplyr::group_by(objective, agebins)%>%
                  dplyr::mutate(s = sum(100*as.numeric(mu))/6)%>%
                  dplyr::filter(objective %in% c("Min deaths", "Min YLL", "Min infections"),
                                timeblocks == 6),
                aes(x = timeblocks, 
                    fill = agebins, 
                    y = s))+
    facet_wrap(~objective , ncol = 1,
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
    scale_x_discrete(breaks = 6, labels = c("% vaccine"))+
    scale_fill_brewer(palette="Accent", 
                      name = "Age group",
                      labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 20-39*", "e: 40-59 ", "f: 40-59*", "g: 60 - 74", "h: 75+"))+
    xlab("                          Cumulative after period 6")+
    #ylab("Percent of demographic group")+
    ylim(0,100)+
    theme(
      strip.text = element_text(size=10, face="bold",family="Times New Roman"),
      axis.title.x = element_text(size=10, family="Times New Roman"),
      axis.text.x = element_text(size=10, family="Times New Roman", color = "black"),
      axis.text.y = element_blank(),
      axis.title.y = element_blank(),
      legend.title = element_text(size=10, face="bold",family="Times New Roman"),
      legend.text = element_text(size=10,family="Times New Roman"),
      legend.key.size = unit(0.75, "line"),
      legend.position="bottom"
    )
  
  p2 <- lemon::grid_arrange_shared_legend(p11, p31, p21, ncol=3, nrow=1, widths = c(5,1,1.25))
  
  
  
  # plot outcomes 
  
  p3 <- ggplot(dat_outcome, # data 
               aes(x = outcome,  # aesthetics
                   fill = objective, 
                   y = 100*as.numeric(value)))+
    geom_bar(stat="identity", # make bar plot
             position=position_dodge(width = 0.7),
             width = 0.5, 
             color = "black")+
    coord_cartesian(ylim=c(60,125))+ # set yliits
    geom_hline(aes(yintercept = 100), linetype = "dashed")+ # add line at 100%
    geom_text(aes(y = 57, label=objective),  # add labels to bars
              position=position_dodge(width=0.7), 
              vjust=-1,
              family="Times New Roman",
              size = 3)+
    theme_minimal()+ # cahnge theme
    scale_fill_brewer(palette="Accent",  # set bar colors 
                      name = "Policy", 
                      labels = c("Min deaths", "Min YLL", "Min infections"))+
    xlab("Outcome")+ # label x axis
    ylab("Outcome compared to proporitonal")+ # label y axis
    theme( # change fonts 
      axis.title.x = element_text(size=12,family="Times New Roman"),
      axis.title.y = element_text(size=12,family="Times New Roman"),
      axis.text = element_text(size=12,family="Times New Roman"),
      legend.text = element_text(size=12,family="Times New Roman"),
      legend.title = element_text(size=12, face="bold",family="Times New Roman"),
      legend.key.size = unit(0.75, "line")
    )
  
  
  
  
  
  # save figures 
  ggsave(  fn[4],
           p2,
           width = 5.75,
           height = 4.25,
           dpi = 300
  )
  
  
  
  ggsave(  fn[5],
           grid.arrange(p1,p3, ncol = 2),
           width = 10.0,
           height = 2.75,
           dpi = 300
  )
  
  
}




# Base senario
make_plots(c("data_outputs/time_beta01_alpha04_0000_40_init_090_001_008.csv",
             "data_outputs/solution_beta01_alpha04_0000_40_init_090_001_008.csv",
             "data_outputs/outcomes_beta01_alpha04_0000_40_init_090_001_008.csv",
             "figures/solutions_test.jpg", 
             "figures/outcomes_test.jpg"))
