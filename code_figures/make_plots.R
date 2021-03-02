
library(patternplot)
library(plyr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(gridExtra)



# load data files 
setwd("~/github/Vaccine_Allocation_cleaned")

make_plots <- function(fn){ 
  dat_sol <- read.csv(fn[2])
  
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
    #ggtitle("a")+
    theme(
      #title = element_text(size=12,family="Times New Roman"),
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
    ylab("Outcome compared to proportional")+ # label y axis
    #ggtitle("b")+
    theme( # change fonts 
      #title = element_text(size=12,family="Times New Roman"),
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
make_plots(c("data_outputs/time_alt_70.csv",
             "data_outputs/solution_alt_70.csv",
             "data_outputs/outcomes_alt_70.csv",
             "figures/solutions_alt_70.jpg", 
             "figures/outcomes_alt_70.jpg"))
make_plots(c("data_outputs/time_alt_60.csv",
             "data_outputs/solution_alt_60.csv",
             "data_outputs/outcomes_alt_60.csv",
             "figures/solutions_alt_60.jpg", 
             "figures/outcomes_alt_60.jpg"))
make_plots(c("data_outputs/time_alt_80.csv",
             "data_outputs/solution_alt_80.csv",
             "data_outputs/outcomes_alt_80.csv",
             "figures/solutions_alt_80.jpg", 
             "figures/outcomes_alt_80.jpg"))


make_plots(c("data_outputs/time_base_1.csv",
             "data_outputs/solution_base_1.csv",
             "data_outputs/outcomes_base_1.csv",
             "figures/solutions_base_1.jpg", 
             "figures/outcomes_base_1.jpg"))


make_plots(c("data_outputs/time_eff2_1.csv",
             "data_outputs/solution_eff2_1.csv",
             "data_outputs/outcomes_eff2_1.csv",
             "figures/solutions_eff2_1.jpg", 
             "figures/outcomes_eff2_1.jpg"))

make_plots(c("data_outputs/time_eff4_1.csv",
             "data_outputs/solution_eff4_1.csv",
             "data_outputs/outcomes_eff4_1.csv",
             "figures/solutions_eff4_1.jpg", 
             "figures/outcomes_eff4_1.jpg"))

make_plots(c("data_outputs/time_rampup_1.csv",
             "data_outputs/solution_rampup_1.csv",
             "data_outputs/outcomes_rampup_1.csv",
             "figures/solutions_rampup_1.jpg", 
             "figures/outcomes_rampup_1.jpg"))

make_plots(c("data_outputs/time_schools_1.csv",
             "data_outputs/solution_schools_1.csv",
             "data_outputs/outcomes_schools_1.csv",
             "figures/solutions_schools_1.jpg", 
             "figures/outcomes_schools_1.jpg"))

make_plots(c("data_outputs/time_strong_NPI_1.csv",
             "data_outputs/solution_strong_NPI_1.csv",
             "data_outputs/outcomes_strong_NPI_1.csv",
             "figures/solutions_strong_NPI_1.jpg", 
             "figures/outcomes_strong_NPI_1.jpg"))

make_plots(c("data_outputs/time_weak_NPI_1.csv",
             "data_outputs/solution_weak_NPI_1.csv",
             "data_outputs/outcomes_weak_NPI_1.csv",
             "figures/solutions_weak_NPI_1.jpg", 
             "figures/outcomes_weak_NPI_1.jpg"))

make_plots(c("data_outputs/time_sucept2_1.csv",
             "data_outputs/solution_sucept2_1.csv",
             "data_outputs/outcomes_sucept2_1.csv",
             "figures/solutions_sucept2_1.jpg", 
             "figures/outcomes_sucept2_1.jpg"))

make_plots(c("data_outputs/time_sucept3_1.csv",
             "data_outputs/solution_sucept3_1.csv",
             "data_outputs/outcomes_sucept3_1.csv",
             "figures/solutions_sucept3_1.jpg", 
             "figures/outcomes_sucept3_1.jpg"))

make_plots(c("data_outputs/time_base_VE65.csv",
             "data_outputs/solution_base_VE65.csv",
             "data_outputs/outcomes_base_VE65.csv",
             "figures/solutions_base_VE65.jpg", 
             "figures/outcomes_base_VE65.jpg"))


make_plots(c("data_outputs/time_base_VE6500.csv",
             "data_outputs/solution_base_VE6500.csv",
             "data_outputs/outcomes_base_VE6500.csv",
             "figures/solutions_base_VE6500.jpg", 
             "figures/outcomes_base_VE6500.jpg"))




make_plots(c("data_outputs/time_return_to_school_1.csv",
             "data_outputs/solution_return_to_school_1.csv",
             "data_outputs/outcomes_return_to_school_1.csv",
             "figures/solutions_return_to_school.jpg", 
             "figures/outcomes_return_to_school.jpg"))


make_plots(c("data_outputs/time_base_VE9010.csv",
             "data_outputs/solution_base_VE9010.csv",
             "data_outputs/outcomes_base_VE9010.csv",
             "figures/solutions_base_VE9010.jpg", 
             "figures/outcomes_base_VE9010.jpg"))


make_plots(c("data_outputs/time_base_VE7030.csv",
             "data_outputs/solution_base_VE7030.csv",
             "data_outputs/outcomes_base_VE7030.csv",
             "figures/solutions_base_VE7030.jpg", 
             "figures/outcomes_base_VE7030.jpg"))


make_plots(c("data_outputs/time_base_VE6040.csv",
             "data_outputs/solution_base_VE6040.csv",
             "data_outputs/outcomes_base_VE6040.csv",
             "figures/solutions_base_VE6040.jpg", 
             "figures/outcomes_base_VE6040.jpg"))


# make heat maps 



library(reshape2)
library(plyr)

library(viridis)


header.true <- function(df) {
  names(df) <- as.character(unlist(df[1,]))
  df[-1,]
}

process_figure_data_sol <- function(files, senario_names){
  df <- data.frame()
  for(i in 1:length(files)){
    
    dat_sol <- read.csv(files[i])
    
    dat_sol <- header.true(dat_sol)
    
    # order factor levels for clarity on plots 
    
    dat_sol$agebins <- factor(dat_sol$agebins, 
                              c("0-4", "5-19", "20-39 low", "20-39 high", "40-59 low", 
                                "40-59 high", "60 - 74", "75+"))
    
    dat_sol$agebins <- mapvalues(dat_sol$agebins, 
                                 
                                 from = c("0-4", "5-19", "20-39 low", "20-39 high", "40-59 low", 
                                          "40-59 high", "60 - 74", "75+"), 
                                 to = c("0-4", "5-19", "20-39", "20-39*","40-59",
                                        "40-59*", "60 - 74", "75+"))
    
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




## deal with age only model

process_figure_data_sol_with_age_only <- function(files, age_only, senario_names){
  df <- data.frame()
  for(i in 1:length(files)){
    if(age_only[i] == 0){
      dat_sol <- read.csv(files[i])
    
      dat_sol <- header.true(dat_sol)
    
      # order factor levels for clarity on plots 
    
      dat_sol$agebins <- factor(dat_sol$agebins, 
                              c("0-4", "5-19", "20-39 low", "20-39 high", "40-59 low", 
                                "40-59 high", "60 - 74", "75+"))
      
      dat_sol$agebins <- mapvalues(dat_sol$agebins, 
                                 
                                 from = c("0-4", "5-19", "20-39 low", "20-39 high", "40-59 low", 
                                          "40-59 high", "60 - 74", "75+"), 
                                 to = c("0-4", "5-19", "20-39", "20-39*","40-59",
                                        "40-59*", "60 - 74", "75+"))
    
      dat_sol$objective <- factor(dat_sol$objective, 
                                c("none", "deaths","YLL", "infections","unif"))
    
    
      dat_sol$objective<- mapvalues(dat_sol$objective, 
                                  from = c("deaths","YLL", "infections", "none", "unif"), 
                                  to = c("Min deaths","Min YLL","Min infections", "none",
                                         "uniform"))
    
      dat_sol$senario <- rep(senario_names[i], nrow(dat_sol))
      df <- rbind(df, dat_sol)
    }else{
      
      dat_sol <- read.csv(files[i])
      
      dat_sol <- header.true(dat_sol)
      
      
      for(j in 1:nrow(dat_sol)){
        if(dat_sol$agebins[j] == "20-39"){
          row <- dat_sol[j,]
          print(row)
          print(head(dat_sol))
          row$agebins <- "20-39*"
          dat_sol <- rbind(dat_sol, row)
        } 
        
        if(dat_sol$agebins[j] == "40-59"){
          row <- dat_sol[j,]
          print(row)
          print(head(dat_sol))
          row$agebins <- "40-59*"
          dat_sol <- rbind(dat_sol, row)
        } 
      }
      
      
      dat_sol$agebins <- factor(dat_sol$agebins, 
                                c("0-4", "5-19", "20-39", "20-39*", "40-59", 
                                  "40-59*", "60 - 74", "75+"))
      
      dat_sol$objective <- factor(dat_sol$objective, 
                                  c("none", "deaths","YLL", "infections","unif"))
      
      
      dat_sol$objective<- mapvalues(dat_sol$objective, 
                                    from = c("deaths","YLL", "infections", "none", "unif"), 
                                    to = c("Min deaths","Min YLL","Min infections", "none",
                                           "uniform"))
      
      dat_sol$senario <- rep(senario_names[i], nrow(dat_sol))
      df <- rbind(df, dat_sol)
      
      
    }
  }
  return(df)
}  








setwd("~/github/Vaccine_Allocation_cleaned")



files <- c("data_outputs/solution_base_1.csv", 
           "data_outputs/solution_base_age_1.csv",
           "data_outputs/solution_strong_NPI_1.csv",
           "data_outputs/solution_weak_NPI_1.csv",
           "data_outputs/solution_sucept2_1.csv",
           "data_outputs/solution_sucept3_1.csv",
           "data_outputs/solution_eff2_1.csv",
           "data_outputs/solution_eff3_1.csv",
           "data_outputs/solution_rampup_1.csv",
           "data_outputs/solution_schools_1.csv")

senario_names <- c("Base", "Age-only", "Strong NPI", "Weak NPI", 
                   "Low suscept., ages < 20", "Even suscept.",
                  "Weak vaccine", "Weak vaccine, ages 60+",
                   "Ramp up", "Open schools"
                   
)


bool_ls <- c(0,1,0,0,0,0,0,0,0,0)

df <- process_figure_data_sol_with_age_only(files, bool_ls, senario_names)

df$senario <- factor(df$senario , 
                     rev(c("Base", "Age only", "Strong NPI", "Weak NPI", 
                   "Low suscept., ages < 20", "Even suscept.",
                  "Weak vaccine", "Weak vaccine, ages 60+",
                   "Ramp up", "Open schools"
                     )))



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
    #title = element_text(size=10, family="Times New Roman"), 
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.text.y = element_text(size=10,family="Times New Roman"),
    axis.title.y = element_text(size=10, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(1.25, "line")
  )

ggsave("figures/heatmap_month6.jpg",
       p1,
       width = 6.75,
       height = 6.75,
       dpi = 300
)



p2 <- ggplot(df%>%filter(timeblocks == 3, 
                         objective %in% c("Min deaths", "Min YLL", "Min infections")), 
            aes(x = agebins, y = senario, fill = 100*as.numeric(cumulative)))+
  facet_wrap(~objective,ncol = 1,
             labeller = labeller(objective = objective.labs))+
  geom_tile(height = 0.9)+
  theme_minimal()+
  scale_fill_viridis(name = "Percent of group")+
  xlab("Demographic group")+
  ylab("")+
  #ggtitle("a")+
  theme(
    #title = element_text(size=10, family="Times New Roman"), 
    strip.text = element_text(size=10, face="bold",family="Times New Roman"),
    axis.title.x = element_text(size=10, face="bold",family="Times New Roman"),
    axis.text = element_text(size=10,family="Times New Roman", color = "black"),
    axis.text.y = element_text(size=10,family="Times New Roman"),
    axis.title.y = element_text(size=10, face="bold",family="Times New Roman"),
    legend.title = element_text(size=10, face="bold",family="Times New Roman"),
    legend.text = element_text(size=10,family="Times New Roman"),
    legend.key.size = unit(1.25, "line")
  )

ggsave("figures/heatmap_month3.jpg",
       p2,
       width = 6.75,
       height = 6.75,
       dpi = 300
)




p1 <- ggplot(df%>%filter(timeblocks == 4, objective %in% c("Min deaths", "Min YLL", "Min infections")), 
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

ggsave("figures/heatmap_month4.jpg",
       p1,
       width = 6.75,
       height = 4.75,
       dpi = 300
)







# heat map alt vaccine eff






setwd("~/github/Vaccine_Allocation_cleaned")



files <- c("data_outputs/solution_base_1.csv", 
           "data_outputs/solution_base_VE65.csv",
           "data_outputs/solution_base_VE7030.csv",
           "data_outputs/solution_base_VE9010.csv")

senario_names <- c("Base", "All 65%", "70% - 30%", "90% - 10%"
                   
)


bool_ls <- c(0,0,0,0)

df <- process_figure_data_sol_with_age_only(files, bool_ls, senario_names)

df$senario <- factor(df$senario , 
                     rev(c("Base", "All 65%", "70% - 30%", "90% - 10%"
                     )))



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

ggsave("figures/heatmap_month6_VE.jpg",
       p1,
       width = 6.75,
       height = 3.75,
       dpi = 300
)



p2 <- ggplot(df%>%filter(timeblocks == 3, 
                         objective %in% c("Min deaths", "Min YLL", "Min infections")), 
             aes(x = agebins, y = senario, fill = 100*as.numeric(cumulative)))+
  facet_wrap(~objective,ncol = 1,
             labeller = labeller(objective = objective.labs))+
  geom_tile(height = 0.9)+
  theme_minimal()+
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

ggsave("figures/heatmap_month3_VE.jpg",
       p2,
       width = 6.75,
       height = 3.75,
       dpi = 300
)








# age only model plots 






make_plots_age <- function(fn){ 
  dat_sol <- read.csv(fn[2])
  
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
                            c("0-4", "5-19", "20-39", "40-59", "60 - 74", "75+"))
  dat_sol$agebins <- mapvalues(dat_sol$agebins, 
                               from = c("0-4", "5-19", "20-39", "40-59",  "60 - 74", "75+"), 
                               to = c("a","b","c","d","e","f"))
  
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
                            c("0-4", "5-19", "20-39", "40-59", "60 - 74", "75+"))
  dat_sol$agebins <- mapvalues(dat_sol$agebins, 
                               from = c("0-4", "5-19", "20-39" , "40-59", "60 - 74", "75+"), 
                               to = c("a","b","c","d","e","f"))
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
                      labels = c("a 0-4", "b: 5-19", "c: 20-39 ", 
                                 "d: 40-59 ",  "e: 60 - 74", "f: 75+"))+
    
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
                      labels = c("a 0-4", "b: 5-19", "c: 20-39 ", "d: 40-59 ", 
                                  "e: 60 - 74", "f: 75+"))+
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
                      labels = c("a 0-4", "b: 5-19", "d: 20-39 ", "d: 40-59 ",  "f: 60 - 74", "g: 75+"))+
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
make_plots_age(c("data_outputs/time_base_age_1.csv",
             "data_outputs/solution_base_age_1.csv",
             "data_outputs/outcomes_base_age_1.csv",
             "figures/solutions_base_age_1.jpg", 
             "figures/outcomes_base_age_1.jpg"))


































