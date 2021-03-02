# make plots with error bars 

library(dplyr)
library(plyr)
library(reshape2)
library(ggplot2)
setwd("~/desktop/Dynamic_Vaccine_Allocation")

make_main_plot <- function(fn){ 
  
  
  dat_sol <- read.csv(fn[2])
  
  
  dat_samples <- read.csv(fn[4])
  
  print(dat_samples[1:6,1:48])
  
  
  # change files headers to columnnames 
  
  header.true <- function(df) {
    names(df) <- as.character(unlist(df[1,]))
    df[-1,]
  }
  
  dat_sol <- header.true(dat_sol)
  
  
  
  
  
  # order factor levels for clarity on plots 
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
  
  
  
  
  
  
  
  nms <- c()
  for(i in 1:48) {
    nms <- append(nms, paste("value", i))
  }
  
  nms <- append(nms, "outcome")
  names(dat_samples) <- nms
  
  
  n1 <- nrow(dat_samples%>%filter(outcome == "deaths"))
  n2 <- nrow(dat_samples%>%filter(outcome == "YLL"))
  n3 <- nrow(dat_samples%>%filter(outcome == "infections"))
  
  dat_samples$sample_num <- c(1:n1, 1:n2, 1:n3)
  

  df <- melt(dat_samples, id.var = c("sample_num","outcome"))
  
  
  
  
  df <- melt(dat_samples,id.var = "outcome")%>%
    group_by(outcome, variable)%>%
    dplyr::summarize(v_min = min(value),
                     v_max = max(value))%>%
    dplyr::filter(substr(variable,1,1) == "v")
  
  
  df$num = rep(1:48,3)
  
  df$agebins <- rep(rep(c("a", "b", "c", "d*", 
                          "e", "f*", "g", "h"),6),3)
  
  
  df$agebins <- factor(df$agebins, c("a", "b", "c", "d*", 
                                     "e", "f*", "g", "h"))
  df$outcome <- factor(df$outcome, c("deaths", "YLL", "infections"))
  df$outcome  <- mapvalues(df$outcome , 
                           from = c("deaths","YLL", "infections"), 
                           to = c("Min deaths","Min YLL","Min infections"))
  
  
  df$timeblocks <- rep(c(rep(1,8), rep(2,8), rep(3,8), rep(4,8), rep(5,8), rep(6,8)), 3)
  
  
  
  
  
  
  
  
  
  
  
  
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
  
  df <- df%>%dplyr::mutate(id = paste(outcome, timeblocks, agebins))
  
  df <- df%>%dplyr::select(id, v_min, v_max)
  
  dat_sol <-  dat_sol%>%dplyr::mutate(id = paste(objective,  timeblocks, agebins))
  print(df)
  print(dat_sol)
  print(merge(dat_sol, df, by = "id"))
  
  p11 <- ggplot(
    
    merge(dat_sol, df, by = "id")%>% # filter data to only include main objectives 
      filter(objective %in% c("Min deaths", "Min infections", "Min YLL")),
    
    aes(x = timeblocks, # aesthetics 
        fill = agebins, 
        y = 100*as.numeric(mu),
        ymin = 100*v_min,
        ymax = 100*v_max)
  )+
    
    facet_wrap(~objective , ncol = 1, # use facet wrap to get a panel for each objective
               labeller = labeller(objective = objective.labs))+
    
    
    geom_bar(stat="identity", # use geom_bar with dodging to get grouped bar charts 
             position=position_dodge(width = 0.85), 
             width = 0.75,
             color = "black",
             size = 0.1)+
    
    geom_errorbar( # use geom_bar with dodging to get grouped bar charts 
      position=position_dodge(width = 0.85), 
      #width = 0.75,
      color = "black",
      size = 0.1)+
    
    geom_text(aes(label=agebins, y = 100*v_max),  # place labels above each bar 
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
    )+ylim(0,110)
  
  
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
              vjust= -0.75,
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
    )+ylim(0,110)
  
  
  
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
    )+ylim(0,110)
  
  p2 <- lemon::grid_arrange_shared_legend(p11, p31, p21, ncol=3, nrow=1, widths = c(5,1,1.25))
  
  
  
  
  
  # save figures
  ggsave(  fn[5],
           p2,
           width = 5.75,
           height = 4.25,
           dpi = 300
  )
  

  
  return(p2)
}




make_main_plot(c("data_outputs/time_base_1.csv",
                 "data_outputs/solution_base_1.csv",
                 "data_outputs/outcomes_base_1.csv",
                 "data_outputs/samples_base_1.csv", 
                 "figures/solutions_base_error_bar.jpg"))


















make_main_plot(c("data_outputs/time_weak_NPI_1.csv",
                 "data_outputs/solution_weak_NPI_1.csv",
                 "data_outputs/outcomes_weak_NPI_1.csv",
                 "data_outputs/samples_weak_NPI_1.csv", 
                 "figures/solutions_weak_NPI_error_bar.jpg"))








make_main_plot(c("data_outputs/time_strong_NPI_1.csv",
                 "data_outputs/solution_strong_NPI_1.csv",
                 "data_outputs/outcomes_strong_NPI_1.csv",
                 "data_outputs/samples_strong_NPI_1.csv", 
                 "figures/solutions_strong_NPI_error_bar.jpg"))



make_main_plot(c("data_outputs/time_eff4_1.csv",
                 "data_outputs/solution_eff4_1.csv",
                 "data_outputs/outcomes_eff4_1.csv",
                 "data_outputs/samples_eff4_1.csv", 
                 "figures/solutions_eff4_error_bar.jpg"))




make_main_plot(c("data_outputs/time_sucept2_1.csv",
                 "data_outputs/solution_sucept2_1.csv",
                 "data_outputs/outcomes_sucept2_1.csv",
                 "data_outputs/samples_sucept2_1.csv", 
                 "figures/solutions_sucept2_error_bar.jpg"))



make_main_plot(c("data_outputs/time_eff2_1.csv",
                 "data_outputs/solution_eff2_1.csv",
                 "data_outputs/outcomes_eff2_1.csv",
                 "data_outputs/samples_eff2_1.csv", 
                 "figures/solutions_eff2_error_bar.jpg"))


make_main_plot(c("data_outputs/time_rampup_1.csv",
                 "data_outputs/solution_rampup_1.csv",
                 "data_outputs/outcomes_rampup_1.csv",
                 "data_outputs/samples_rampup_1.csv", 
                 "figures/solutions_rampup_error_bar.jpg"))


make_main_plot(c("data_outputs/time_sucept3_1.csv",
                 "data_outputs/solution_sucept3_1.csv",
                 "data_outputs/outcomes_sucept3_1.csv",
                 "data_outputs/samples_sucept3_1.csv", 
                 "figures/solutions_sucept3_error_bar.jpg"))


make_main_plot(c("data_outputs/time_schools_1.csv",
                 "data_outputs/solution_schools_1.csv",
                 "data_outputs/outcomes_schools_1.csv",
                 "data_outputs/samples_schools_1.csv", 
                 "figures/solutions_schools_error_bar.jpg"))


make_main_plot(c("data_outputs/time_schools_1.csv",
                 "data_outputs/solution_schools_1.csv",
                 "data_outputs/outcomes_schools_1.csv",
                 "data_outputs/samples_schools_1.csv", 
                 "figures/solutions_schools_error_bar.jpg"))


make_main_plot(c("data_outputs/time_base_VE65.csv",
             "data_outputs/solution_base_VE65.csv",
             "data_outputs/outcomes_base_VE65.csv",
             "data_outputs/samples_base_VE65.csv",
             "figures/solutions_VE65_eror_bar.jpg"))

make_main_plot(c("data_outputs/time_base_VE9010.csv",
                 "data_outputs/solution_base_VE9010.csv",
                 "data_outputs/outcomes_base_VE9010.csv",
                 "data_outputs/samples_base_VE9010.csv",
                 "figures/solutions_VE9010_eror_bar.jpg"))


make_main_plot(c("data_outputs/time_base_VE7030.csv",
                 "data_outputs/solution_base_VE7030.csv",
                 "data_outputs/outcomes_base_VE7030.csv",
                 "data_outputs/samples_base_VE7030.csv",
                 "figures/solutions_VE7030_eror_bar.jpg"))


make_age_plot <- function(fn){ 
  
  
  dat_sol <- read.csv(fn[2])
  
  
  dat_samples <- read.csv(fn[4])
  
  
  # change files headers to columnnames 
  
  header.true <- function(df) {
    names(df) <- as.character(unlist(df[1,]))
    df[-1,]
  }
  
  dat_sol <- header.true(dat_sol)
  
  
  
  
  
  # order factor levels for clarity on plots 
  dat_sol$agebins <- factor(dat_sol$agebins, 
                            c("0-4", "5-19", "20-39", "40-59", "60 - 74", "75+"))
  dat_sol$agebins <- mapvalues(dat_sol$agebins, 
                               from = c("0-4", "5-19", "20-39", "40-59", "60 - 74", "75+"), 
                               to = c("a","b","c","d","e","f"))
  
  
  print(dat_sol)
  
  dat_sol$objective <- factor(dat_sol$objective, 
                              c("none", "deaths","YLL", "infections","unif"))
  
  
  
  
  dat_sol$objective<- mapvalues(dat_sol$objective, 
                                from = c("deaths","YLL", "infections", "none", "unif"), 
                                to = c("Min deaths","Min YLL","Min infections", "none", "Uniform"))
  
  
  
  
  
  
  
  nms <- c()
  for(i in 1:36) {
    nms <- append(nms, paste("value", i))
  }
  
  nms <- append(nms, "outcome")
  names(dat_samples) <- nms
  
  
  dat_samples$sample_num <- c(1:nrow(dat_samples%>%filter(outcome == "deaths")), 
                              1:nrow(dat_samples%>%filter(outcome == "YLL")),
                              1:nrow(dat_samples%>%filter(outcome == "infections")))
  
  
  df <- melt(dat_samples, id.var = c("sample_num","outcome"))
  
  
  
  
  
  df <- melt(dat_samples,id.var = "outcome")%>%
    group_by(outcome, variable)%>%
    dplyr::summarize(v_min = min(value),
                     v_max = max(value))%>%
    dplyr::filter(substr(variable,1,1) == "v")
  

  df$num = rep(1:36,3)
  
  df$agebins <- rep(rep(c("a", "b", "c", "d", 
                          "e", "f"),6),3)
  
  
  df$agebins <- factor(df$agebins, c("a", "b", "c", "d", 
                                     "e", "f"))
  df$outcome <- factor(df$outcome, c("deaths", "YLL", "infections"))
  df$outcome  <- mapvalues(df$outcome , 
                           from = c("deaths","YLL", "infections"), 
                           to = c("Min deaths","Min YLL","Min infections"))
  
  
  df$timeblocks <- rep(c(rep(1,6), rep(2,6), rep(3,6), rep(4,6), rep(5,6), rep(6,6)), 3)
  
  
  
  
  
  
  
  
  
  
  
  
  dat_sol <- read.csv(fn[2])
  dat_sol <- header.true(dat_sol)
  
  dat_sol$agebins <- factor(dat_sol$agebins, 
                            c("0-4", "5-19", "20-39", "40-59", "60 - 74", "75+"))
  dat_sol$agebins <- mapvalues(dat_sol$agebins, 
                               from = c("0-4", "5-19", "20-39", "40-59", "60 - 74", "75+"), 
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
  
  df <- df%>%dplyr::mutate(id = paste(outcome, timeblocks, agebins))
  
  df <- df%>%dplyr::select(id, v_min, v_max)
  
  dat_sol <-  dat_sol%>%dplyr::mutate(id = paste(objective,  timeblocks, agebins))
  print(df)
  print(dat_sol)
  print(merge(dat_sol, df, by = "id"))
  
  p11 <- ggplot(
    
    merge(dat_sol, df, by = "id")%>% # filter data to only include main objectives 
      filter(objective %in% c("Min deaths", "Min infections", "Min YLL")),
    
    aes(x = timeblocks, # aesthetics 
        fill = agebins, 
        y = 100*as.numeric(mu),
        ymin = 100*v_min,
        ymax = 100*v_max)
  )+
    
    facet_wrap(~objective , ncol = 1, # use facet wrap to get a panel for each objective
               labeller = labeller(objective = objective.labs))+
    
    
    geom_bar(stat="identity", # use geom_bar with dodging to get grouped bar charts 
             position=position_dodge(width = 0.85), 
             width = 0.75,
             color = "black",
             size = 0.1)+
    
    geom_errorbar( # use geom_bar with dodging to get grouped bar charts 
      position=position_dodge(width = 0.85), 
      #width = 0.75,
      color = "black",
      size = 0.1)+
    
    geom_text(aes(label=agebins, y = 100*v_max),  # place labels above each bar 
              position=position_dodge(width=0.85), 
              vjust=-0.75,
              family="Times New Roman",
              size = 2)+
    
    theme_minimal()+
    
    
    scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                      name = "Age group",
                      labels = c("a 0-4", "b: 5-19", "c: 20-39 ", 
                                 "d: 40-59 ", "e: 60 - 74", "f: 75+"))+
    
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
    )+ylim(0,110)
  
  
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
              vjust= -0.75,
              family="Times New Roman",
              size = 2)+
    
    theme_minimal()+
    
    scale_x_discrete(breaks = 6, labels = c("% group"))+
    
    scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                      name = "Age group",
                      labels = c("a 0-4", "b: 5-19", "c: 20-39 ", 
                                 "d: 40-59 ", "e: 60 - 74", "f: 75+"))+
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
    )+ylim(0,110)
  
  
  
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
    scale_fill_brewer(palette="Accent", # labels for fill colors and color scheme 
                      name = "Age group",
                      labels = c("a 0-4", "b: 5-19", "c: 20-39 ", 
                                 "d: 40-59 ", "e: 60 - 74", "f: 75+"))+
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
    )+ylim(0,110)
  
  p2 <- lemon::grid_arrange_shared_legend(p11, p31, p21, ncol=3, nrow=1, widths = c(5,1,1.25))
  
  
  
  
  
  # save figures
  ggsave(  fn[5],
           p2,
           width = 5.75,
           height = 4.25,
           dpi = 300
  )
  
  
  
  return(p2)
}







make_age_plot(c("data_outputs/time_base_age_1.csv",
                 "data_outputs/solution_base_age_1.csv",
                 "data_outputs/outcomes_base_age_1.csv",
                 "data_outputs/samples_base_age_1.csv", 
                 "figures/solutions__base_age_error_bar.jpg"))











