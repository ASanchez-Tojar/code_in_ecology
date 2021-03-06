###################################################################
# Author:
#
# Alfredo Sanchez-Tojar (alfredo.tojar@gmail.com)
#   Affiliation: Dept. Evolutionary Biology, Bielefeld University, Germany
#   Profile: https://scholar.google.de/citations?user=Sh-Rjq8AAAAJ&hl=de

# Script first created on the 4th of Feb 2020

###################################################################
# Description of script and Instructions
###################################################################

# This script is to create Figure 1 and 2 for the following study:

# Antica Culina, Ilona van den Berga, Simon Evans, Alfredo Sanchez-Tojar. 
# Low availability of code in ecology: a call for urgent action.


###################################################################
# Packages needed
##############################################################

pacman::p_load(stringr,openxlsx,dplyr,ggplot2)

# Clear memory
rm(list=ls())


##############################################################
# Functions needed
##############################################################

# none


##############################################################
# Figure 1
##############################################################

##############################################################
# Importing data
##############################################################

# importing all clean data
db.full <- read.table("data/code_availability_full_and_clean.csv",header=T,sep=",")


##############################################################
# Code availability figure
##############################################################

# calculating number of studies that published at least some code
some.published <- db.full %>% 
  filter(!(is.na(Publication_year.2)), !(is.na(CodePublished.2))) %>% 
  group_by(Publication_year.2) %>% 
  summarise(codepublished = sum(CodePublished.2 == "some"))


# calculating number of studies that published seemingly all code
all.published <- db.full %>% 
  filter(!(is.na(Publication_year.2)), !(is.na(CodePublished.2))) %>% 
  group_by(Publication_year.2) %>% 
  summarise(codepublished = sum(CodePublished.2 == "yes"))


# calculating number of studies that did not publish any code
none.published <- db.full %>% 
  filter(!(is.na(Publication_year.2)), !(is.na(CodePublished.3))) %>% 
  group_by(Publication_year.2) %>% 
  summarise(codepublished = sum(CodePublished.3 == "no"))


# calculating number of eligible articles (after title-and-abstract and fulltext screening)
total <- db.full %>% 
  filter(!(is.na(Publication_year.2)), !(is.na(CodePublished.2)), statistical.analysis.and.or.simulations.2=="yes") %>% 
  group_by(Publication_year.2) %>% 
  summarise(n = n())


# making them all data frames
some.published <- as.data.frame(some.published)
all.published <- as.data.frame(all.published)
none.published <- as.data.frame(none.published)
total <- as.data.frame(total)


# adding total sample size
full.summary.1 <- merge(some.published,total)
full.summary.2 <- merge(all.published,total)
full.summary.3 <- merge(none.published,total)


# creating new variable to identify each value
full.summary.1$type <- "Some"
full.summary.2$type <- "All"
full.summary.3$type <- "None"

# stacking them all: for real
full.summary <- rbind(full.summary.1,full.summary.2,full.summary.3)

# estimating percentages
full.summary$percentage <- (full.summary$codepublished/full.summary$n)*100


# choosing colours manually
fill <- c("grey98", "grey35","grey5")


# Stacked barplot with multiple groups
figure1a <- full.summary %>% 
  mutate(type = factor(type, levels = c("None",
                                        "Some",
                                        "All"))) %>% 
  ggplot() + 
  geom_bar(aes(y = percentage, x = Publication_year.2, fill = type), stat="identity",colour="black") +
  labs(y="Percentage (%) of articles", fill="Published code ") +
  scale_fill_manual(values=fill) +
  scale_y_continuous(breaks = seq(0,100,20),expand = expand_scale(mult = c(0, 0.05))) +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text.x = element_text(size = 10),
        axis.text.y = element_text(size = 10),
        axis.title.y = element_text(size = 14),
        axis.title.x=element_blank())


##############################################################
# Data availability figure
##############################################################

# calculating number of studies that published at least some data
some.data.published <- db.full %>% 
  filter(!(is.na(Publication_year.2)), !(is.na(DataShared.2))) %>% 
  group_by(Publication_year.2) %>% 
  summarise(datapublished = sum(DataShared.2 == "partially"))


# calculating number of studies that published seemingly all data
all.data.published <- db.full %>% 
  filter(!(is.na(Publication_year.2)), !(is.na(DataShared.2))) %>% 
  group_by(Publication_year.2) %>% 
  summarise(datapublished = sum(DataShared.2 == "yes"))


# calculating number of studies that did not publish any data
none.data.published <- db.full %>% 
  filter(!(is.na(Publication_year.2)), !(is.na(DataShared.2))) %>% 
  group_by(Publication_year.2) %>% 
  summarise(datapublished = sum(DataShared.2 == "no"))


# calculating number of eligible articles (after title-and-abstract and fulltext screening)
total.data <- db.full %>%
  filter(!(is.na(Publication_year.2)), !(is.na(DataShared.2)), statistical.analysis.and.or.simulations.2=="yes") %>%
  group_by(Publication_year.2) %>%
  summarise(n = n())


# making them all data frames
some.data.published <- as.data.frame(some.data.published)
all.data.published <- as.data.frame(all.data.published)
none.data.published <- as.data.frame(none.data.published)
total.data <- as.data.frame(total.data)


# adding total sample size
full.data.summary.1 <- merge(some.data.published,total.data)
full.data.summary.2 <- merge(all.data.published,total.data)
full.data.summary.3 <- merge(none.data.published,total.data)


# creating new variable to identify each value
full.data.summary.1$type <- "Some"
full.data.summary.2$type <- "All"
full.data.summary.3$type <- "None"

# stacking them all: for real
full.data.summary <- rbind(full.data.summary.1,full.data.summary.2,full.data.summary.3)

# estimating percentages
full.data.summary$percentage <- (full.data.summary$datapublished/full.data.summary$n)*100


# choosing colours manually
fill <- c("grey98", "grey35","grey5")


# Stacked barplot with multiple groups
figure1b <- full.data.summary %>% 
  mutate(type = factor(type, levels = c("None",
                                        "Some",
                                        "All"))) %>% 
  ggplot() + 
  geom_bar(aes(y = percentage, x = Publication_year.2, fill = type), stat="identity",colour="black") +
  labs(y="Percentage (%) of articles", fill="Published data ") +
  scale_fill_manual(values=fill) +
  scale_y_continuous(breaks = seq(0,100,20),expand = expand_scale(mult = c(0, 0.05))) +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text.x = element_text(size = 10),
        axis.text.y = element_text(size = 10),
        axis.title.y = element_text(size = 14),
        axis.title.x=element_blank())


##############################################################
# Location code figure
##############################################################

# calculating number of studies that published code in a repository
repository <- db.full %>% 
  filter(!(is.na(Publication_year.2)), !(is.na(LocationShared.2))) %>% 
  group_by(Publication_year.2) %>% 
  summarise(location = sum(LocationShared.2 == "repository"))


# calculating number of studies that published code as supplementary file
supplementary <- db.full %>% 
  filter(!(is.na(Publication_year.2)), !(is.na(LocationShared.2))) %>% 
  group_by(Publication_year.2) %>% 
  summarise(location = sum(LocationShared.2 == "supplementary file"))


# calculating number of studies that published code in a webpage
webpage <- db.full %>% 
  filter(!(is.na(Publication_year.2)), !(is.na(LocationShared.2))) %>% 
  group_by(Publication_year.2) %>% 
  summarise(location = sum(LocationShared.2 == "webpage"))


# calculating number of eligible articles, i.e. those with code
total.location <- db.full %>% 
  filter(!(is.na(Publication_year.2)), !(is.na(LocationShared.2)), statistical.analysis.and.or.simulations.2=="yes") %>% 
  group_by(Publication_year.2) %>% 
  summarise(n = n())


# making them all data frames
repository <- as.data.frame(repository)
supplementary <- as.data.frame(supplementary)
webpage <- as.data.frame(webpage)
total.location <- as.data.frame(total.location)


# adding total sample size
full.location.summary.1 <- merge(repository,total.location)
full.location.summary.2 <- merge(supplementary,total.location)
full.location.summary.3 <- merge(webpage,total.location)


# creating new variable to identify each value
full.location.summary.1$type <- "Repository"
full.location.summary.2$type <- "Supplements"
full.location.summary.3$type <- "Webpage"

# stacking them all: for real
full.location.summary <- rbind(full.location.summary.1,full.location.summary.2,full.location.summary.3)

# estimating percentages
full.location.summary$percentage <- (full.location.summary$location/full.location.summary$n)*100


# choosing colours manually
fill <- c("grey98", "grey35","grey5")


# Stacked barplot with multiple groups
figure1c <- full.location.summary %>% 
  mutate(type = factor(type, levels = c("Supplements",
                                        "Webpage",
                                        "Repository"))) %>% 
  ggplot() + 
  geom_bar(aes(y = percentage, x = Publication_year.2, fill = type), stat="identity",colour="black") +
  labs(y="Percentage (%) of articles", fill="Code location") +
  scale_fill_manual(values=fill) +
  scale_y_continuous(breaks = seq(0,100,20),expand = expand_scale(mult = c(0, 0.05))) +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"),
        axis.text.x = element_text(size = 10),
        axis.text.y = element_text(size = 10),
        axis.title.y = element_text(size = 14),
        axis.title.x=element_blank())




##############################################################
# Figure 2
##############################################################

library(ggpubr)

# import journal information and abbreviations
journal.info <- read.table("data/journals_info_v2.csv",header=T,sep=",")
full.journal <- read.table("data/journal_percentages.csv",header=T,sep=",")

# merging journal info to percentages
full.journal.info <- merge(full.journal,journal.info)

# creating figure 2
figure2 <- ggdotchart(full.journal.info, x = "abbreviations", y = "percentage",
                       color = "Policy",
                       palette = c("#00AFBB", "#E7B800", "#FC4E07"),
                       sorting = "descending",
                       add = "segments",
                       rotate = TRUE,
                       group = "Policy",
                       xlab = "",
                       ylab = "Percentage (%) of articles publishing some code",
                       dot.size = 8,
                       label = paste0(round(full.journal.info$codepublished,0),"/",round(full.journal.info$total,0)),
                       font.label = list(color = "black", size = 7,vjust = 0.5),
                       ggtheme = theme_pubr())

figure2 <- ggpar(figure2,legend.title = "Code-sharing policy")


##############################################################
# Exporting figures
##############################################################

# exporting figure 1
tiff("plots/Figure1.tiff",
     height=12, width=28,
     units='cm', compression="lzw", res=600)

# multipannel plot
ggarrange(figure1a, figure1b, figure1c,
          labels = c("a)","b)","c)"),
          ncol = 3, nrow = 1)

dev.off()

# exporting figure 2
ggexport(figure2,
         plotlist = NULL,
         filename = "plots/Figure2.tiff",
         ncol = NULL,
         nrow = NULL,
         width = 2400,
         height = 1450,
         pointsize = 1,
         res = 300,
         verbose = TRUE
)
