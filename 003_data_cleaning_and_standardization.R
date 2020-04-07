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

# This script is to import and clean the sheets with data extracted 
# from the references included in a review for the following study:

# Antica Culina, Ilona van den Berga, Simon Evans, Alfredo Sanchez-Tojar. 
# Low availability of code in ecology: a call for urgent action.

# The are many lines of commented code that were used simply to
# peform checks throughout the dataset. Any typo was then corrected
# in the original dataset, which, together with having two observers
# working on this via email, explains why the version of the dataset
# imported is V8.

###################################################################
# Packages needed
##############################################################

pacman::p_load(stringr,openxlsx,dplyr)

# Clear memory
rm(list=ls())


##############################################################
# Functions needed
##############################################################

# none


##############################################################
# Importing data
##############################################################

# importing data for 2015-2016
db.2015.16 <- read.xlsx("data/Data_Feb_2020_V8.xlsx",
                        colNames = T,sheet = 1)

# importing data for 2018-2019
db.2018.19 <- read.xlsx("data/Data_Feb_2020_V8.xlsx",
                        colNames = T ,sheet = 2)


##############################################################
# Standardizing databases
##############################################################

# are the variable names the same?
setdiff(names(db.2015.16),names(db.2018.19))
setdiff(names(db.2018.19),names(db.2015.16))

# changing name of a variable to standardize across datasets
db.2015.16 <- rename(db.2015.16, BreafDescription = "BreafDescription/Howto")

# are the variable names the same? Yes
setdiff(names(db.2015.16),names(db.2018.19))
setdiff(names(db.2018.19),names(db.2015.16))

# putting both databases together
db.full <- rbind(db.2015.16,db.2018.19)

# exploring database
summary(db.full)

# transforming some variables to factor
cols.factor <- c("fulltextID", "Journal", "Excluded.abstract.screening", "statistical.analysis.or/and.simulations",
                 "bioinformatic.analysis", "Stat_analysis_software", "CodePublished", "CodeMentioned", "Location_CodeMentioned",
                 "LocationShared", "Repository", "FreeSoftware", "DataUsed", "DataShared", "BreafDescription",
                 "InlineComments")

db.full[cols.factor] <- lapply(db.full[cols.factor], factor)

# exploring the database further
summary(db.full)
names(db.full)


#############################################################################################
# exploring each variable and cleaning and standardizing if necessary
#############################################################################################


###############################
# Journal
sort(table(db.full$Journal))
sum(table(db.full$Journal))

# visualizing where the NA's are, if any: none, all fixed
db.full[is.na(db.full$Journal),]


###############################
# Publication_year
table(db.full$Publication_year)

# check if there are NA's: none, all fixed
db.full[is.na(db.full$Publication_year),]

# we are creating a variable with two levels to properly label the two 
# period of times that we sampled (we did not concieved it as 4 years, but rather as 2 time points)
db.full$Publication_year.2 <- ifelse(db.full$Publication_year < 2017,
                                     "2015-2016",
                                     "2018-2019")

db.full$Publication_year.2 <- as.factor(db.full$Publication_year.2)
table(db.full$Publication_year.2)


###############################
# Excluded.abstract.screening
table(db.full$Excluded.abstract.screening)

# some yes's need to be standardized
yes.conditionals <- db.full[!(db.full$Excluded.abstract.screening %in% c("yes","no")),"Excluded.abstract.screening"]

# extracting the exclusion reasons of those yes's to add them to the additional.comment.on.analysis variable
db.full[!(db.full$Excluded.abstract.screening %in% c("yes","no")),"additional.comment.on.analysis"] <- str_extract(yes.conditionals, "[:alpha:]+$")
db.full[!(db.full$Excluded.abstract.screening %in% c("yes","no")),"Excluded.abstract.screening"] <- "yes"

#restarting factor levels to remove the old ones
db.full$Excluded.abstract.screening <- factor(db.full$Excluded.abstract.screening)
table(db.full$Excluded.abstract.screening) # everything looks good now


###############################
# statistical.analysis.or/and.simulations

# first name needs to be modified to make it easy to handle: get rid of the "/"
names(db.full)[8] <- "statistical.analysis.and.or.simulations"

table(db.full$statistical.analysis.and.or.simulations)

# for those named as "yes, implement a model" we are going rename them as "yes, simulation" 
# (but the information will still be available in the additional.comment.on.analysis as seen 
# in the following check)
# db.full[!(is.na(db.full$statistical.analysis.and.or.simulations)) &
#           db.full$statistical.analysis.and.or.simulations=="yes, implement a model",]

# standardizing
db.full$statistical.analysis.and.or.simulations <- recode(db.full$statistical.analysis.and.or.simulations,
                                                          "yes, simulations" = "yes, simulation",
                                                          "yes, statistical and simulations" = "yes, statistical and simulation",
                                                          "yes, implement a model" = "yes, simulation",
                                                          "yes, methodological and statistical" = "yes, statistical and methodological",
                                                          .default = levels(db.full$statistical.analysis.and.or.simulations))

table(db.full$statistical.analysis.and.or.simulations)

# creating a new variable with simply yes or no to make subsetting easier, also, becuase some 
# papers are dificult to label (e.g. simulation vs. model), and we are not interesting in strictly 
# labelling them per se, just to know if they provide some stats or simulations for which analytical
# code should hopefully be available.
db.full$statistical.analysis.and.or.simulations.2 <- as.factor(ifelse(as.character(db.full$statistical.analysis.and.or.simulations)=="no",
                                                                      "no",
                                                                      "yes"))

table(db.full$statistical.analysis.and.or.simulations.2)

# checking consistency in data collection. For those papers that we reviewed,
# if statistical.analysis.and.or.simulations.2 == "no", there should not be data collected 
# summary(db.full[db.full$Excluded.abstract.screening=="no" &
#                   db.full$statistical.analysis.and.or.simulations.2 == "no",]) #all good!


###############################
# bioinformatic.analysis: keep in mind that it was sometimes tricky to label some papers as
# bioinformatic or no. We reviewed and discussed many cases among observers before final
# decisions.
table(db.full$bioinformatic.analysis)


###############################
# Stat_analysis_software
table(db.full$Stat_analysis_software)

# standardizing terminology: first, substituting ',' by 'and'
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, ",", " and")

# function obtained from: https://rstudio-pubs-static.s3.amazonaws.com/408658_512da947714740b99253228f084a08a9.html
# this function makes the first letter of a word capital to keep everything tidy and consistent
CapStr <- function(y) {
  c <- strsplit(y, " ")[[1]]
  paste(toupper(substring(c, 1,1)), substring(c, 2),
        sep="", collapse=" ")
}

db.full$Stat_analysis_software <- sapply(as.character(db.full$Stat_analysis_software), CapStr)

# reformatting NA's
db.full$Stat_analysis_software <- as.factor(db.full$Stat_analysis_software)
levels(db.full$Stat_analysis_software)[levels(db.full$Stat_analysis_software)=='NANA'] <- NA

# a bunch of manual formatting for standardization
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "And", "and")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "Stata", "STATA")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "SigmaPlot For Windows", "Sigmaplot")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "OpenBUGS", "Openbugs")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "C Compiler", "C")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "Hyperniche Version 2.0 and Other", "Hyperniche")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "JAGS Software Via The R2jags In R", "R and JAGS")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "Matlab", "MATLAB")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "MATLAB and Maybe Other", "MATLAB")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "Minitab and Other?", "Minitab")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "Minitab\\?", "Minitab")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "Not Mentioned But Seems To Be Python", "Not Stated")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "GraphPad Prism", "Prism")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software,"\\Ibm\\X+","IBM ILOG CPLEX")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software,"R and Bug","R and Bugs")

db.full$Stat_analysis_software <- factor(db.full$Stat_analysis_software)

table(db.full$Stat_analysis_software)

# checking software and freeness consistency
# db.full[order(db.full$Stat_analysis_software),c("Stat_analysis_software","FreeSoftware")] #all good

# counting articles using R and other software
table(str_detect(db.full$Stat_analysis_software, "R "))

# counting articles using exclusively R
nrow(db.full[db.full$Stat_analysis_software=="R" & !(is.na(db.full$Stat_analysis_software)),])


###############################
# CodePublished
table(db.full$CodePublished)

# convert all to lower case
db.full$CodePublished <- str_to_lower(db.full$CodePublished, locale = "en")

# creating new variable where embargoed is counted as simply yes
db.full$CodePublished.2 <- recode(db.full$CodePublished,
                                  "yes, but embargoed" = "yes",
                                  #"some" = "yes",
                                  .default = levels(db.full$CodePublished))

db.full$CodePublished <- factor(db.full$CodePublished)
db.full$CodePublished.2 <- factor(db.full$CodePublished.2)
table(db.full$CodePublished.2)

# checking consistency in data collection. For those papers with some code published,
# there should be data collected about the code 
# summary(db.full[!(is.na(db.full$CodePublished.2)) & 
#                   db.full$CodePublished.2=="yes",]) # found a couple of inconsistencies that are now fixed

# db.full[!(is.na(db.full$CodePublished.2)) &
#           db.full$CodePublished.2=="yes" &
#           is.na(db.full$bioinformatic.analysis),]

# this is an interesting case where code is provided only as an R package, 
# but not the code to reproduce the simulation, so we have decided to call it
# CodePublished="no", and we are going to make CodeMentioned and 
# Location_CodeMentioned as NA to keep things simple
db.full[db.full$CodePublished=="no" & 
          !(is.na(db.full$CodeMentioned)),
        c("CodeMentioned","Location_CodeMentioned")] <- NA

# creating new variable where some is counted simply as yes
db.full$CodePublished.3 <- recode(db.full$CodePublished.2,
                                  "some" = "yes",
                                  .default = levels(db.full$CodePublished.2))

db.full$CodePublished.3 <- factor(db.full$CodePublished.3)
table(db.full$CodePublished.3)

# some number checking
table(db.full[db.full$Publication_year.2=="2015-2016","CodePublished.2"])
table(db.full[db.full$Publication_year.2=="2018-2019","CodePublished.2"])

# doing some countings
# number of journals covered each year
db.full %>% group_by(Publication_year.2,Journal) %>% summarise(count = n_distinct(CodePublished.2)) %>% summarise(n = n())

# counting number of articles per year per journal
articles.per.journal <- as.data.frame(db.full %>% group_by(Journal) %>% summarise(n = n()))

# number of journals covered each year
code.published.per.journal <- as.data.frame(db.full %>% filter(CodePublished.2=="yes") %>% group_by(Journal) %>% summarise(total = n()))

as.data.frame(cbind(as.character(articles.per.journal$Journal),as.integer(round((code.published.per.journal$total/articles.per.journal$n)*100,0))))

# number of journals covered each year (at least some code)
code.published.per.journal.some <- as.data.frame(db.full %>% filter(CodePublished.3=="yes") %>% group_by(Journal) %>% summarise(total = n()))

as.data.frame(cbind(as.character(articles.per.journal$Journal),as.integer(round((code.published.per.journal.some$total/articles.per.journal$n)*100,0))))
summary(as.numeric(as.character(as.data.frame(cbind(as.character(articles.per.journal$Journal),as.integer(round((code.published.per.journal.some$total/articles.per.journal$n)*100,0))))$V2)))


###############################
# CodeMentioned
table(db.full$CodeMentioned)

# standardizing
db.full$CodeMentioned <- recode(db.full$CodeMentioned,
                                "yes, script and code" = "yes, code and script",
                                "yes, but only as \"simulation is available in\"" = "yes, simulation",
                                "none" = "no",
                                .default = levels(db.full$CodeMentioned))

# creating a new binary variable to know whether code was mentioned in the text or not
db.full$CodeMentioned.2 <- as.factor(ifelse(as.character(db.full$CodeMentioned)=="no",
                                            "no",
                                            "yes"))

table(db.full$CodeMentioned.2)


###############################
# Location_CodeMentioned
table(db.full$Location_CodeMentioned)

table(db.full[db.full$Publication_year.2=="2015-2016","Location_CodeMentioned"])
table(db.full[db.full$Publication_year.2=="2018-2019","Location_CodeMentioned"])


###############################
# LocationShared
table(db.full$LocationShared)

# creating new, recoded variable
db.full$LocationShared.2 <- recode(db.full$LocationShared,
                                   "link in the article" = "supplementary file",
                                   "repository and supplementary file" = "repository",
                                   "webpage (govermental)" = "webpage",
                                   .default = levels(db.full$LocationShared))

table(db.full$LocationShared.2)
table(db.full[db.full$Publication_year.2=="2015-2016","LocationShared.2"])
table(db.full[db.full$Publication_year.2=="2018-2019","LocationShared.2"])


###############################
# Repository
table(db.full$Repository)

# some manual editing to standardize
db.full$Repository <- str_replace_all(db.full$Repository, "dryad", "Dryad")
db.full$Repository <- str_replace_all(db.full$Repository, "FigShare", "Figshare")
db.full$Repository <- str_replace_all(db.full$Repository, "Github", "GitHub")
db.full$Repository <- str_replace_all(db.full$Repository, "GitHub and Zenodo", "Zenodo and GitHub")
db.full$Repository <- str_replace_all(db.full$Repository, "GitHub \\+ Dryad", "Dryad and GitHub")
db.full$Repository <- str_replace_all(db.full$Repository, "Zenodo \\+ GitHub", "Zenodo and GitHub")

table(db.full$Repository)


###############################
# FreeSoftware
table(db.full$FreeSoftware)

# standardizing
db.full$FreeSoftware <- recode(db.full$FreeSoftware,
                               "some" = "partially",
                               "unknown" = "NA",
                               .default = levels(db.full$FreeSoftware))

levels(db.full$FreeSoftware)[levels(db.full$FreeSoftware)=='NA'] <- NA


# creating new, recoded variable were for those for which at least some software is free, we label them as FreeSoftware=="yes"
db.full$FreeSoftware.2 <- recode(db.full$FreeSoftware,
                                 "partially" = "yes",
                                 .default = levels(db.full$FreeSoftware))

table(db.full$FreeSoftware.2)
sum(table(db.full$FreeSoftware.2))# makes sense because there are 32 articles where software was not stated
table(db.full[db.full$CodePublished.3=="yes" & !(is.na(db.full$CodePublished.3)),"FreeSoftware.2"]) #one article provides code, but does not state the software, and we could not figure it out


###############################
# DataUsed
table(db.full$DataUsed)


###############################
# DataShared
table(db.full$DataShared)


# creating new, recoded variable
db.full$DataShared.2 <- recode(db.full$DataShared,
                               "yes, but embargoed" = "yes",
                               "some" = "partially",
                               "link broken" = "no",
                               "yes, but in a repository that requires log in, which seems to be free" = "yes",
                               "yes, but in another publication" = "yes",
                               "yes, but it consists of means and SEs only, so not really the data" = "no",
                               "yes, but one dataset embargoed" = "yes",
                               "yes, but only sequencing and geographical data" = "partially",
                               "yes, but only sequencing data" = "partially",
                               "yes, but only SNP data" = "partially",
                               "yes, but only some" = "partially",
                               "yes, mostly, but for some of the data one has to ask a govermental department" = "yes",
                               .default = levels(db.full$DataShared))

table(db.full$DataShared.2)

# checking number of papers with all code and all data
#summary(db.full[(db.full$CodePublished.2=="yes" & !(is.na(db.full$CodePublished.2))) & (db.full$DataShared.2=="yes" | is.na(db.full$DataShared.2)),])

# creating new binary variable
db.full$DataShared.3 <- recode(db.full$DataShared.2,
                               "partially" = "yes",
                               .default = levels(db.full$DataShared.2))

table(db.full$DataShared.3)
# table(db.full[db.full$statistical.analysis.and.or.simulations.2=="yes" & !(is.na(db.full$statistical.analysis.and.or.simulations.2)),"DataShared.3"])
# nrow(db.full[db.full$statistical.analysis.and.or.simulations.2=="yes" & !(is.na(db.full$statistical.analysis.and.or.simulations.2)) & is.na(db.full$DataShared.3),])
# table(db.full[db.full$statistical.analysis.and.or.simulations.2=="yes" & !(is.na(db.full$statistical.analysis.and.or.simulations.2)) & is.na(db.full$DataShared.3),"DataUsed"])


###############################
# Second_screener
table(db.full$Second_screener)


###############################
# adding doi's
# from the title and abstract screening database
doi.2018.19 <- read.table("screening_process/title-and-abstract_screening/random_200_2018_2019_rayyan.csv",header=T,sep=",")

# reducing database
doi.2018.19.red <- doi.2018.19[,c("title","url")]
names(doi.2018.19.red) <- c("Title","doi")

# removing {} to make matchin easier
doi.2018.19.red$Title <- str_remove_all(doi.2018.19.red$Title, "[{}]")
db.full$Title <- str_remove_all(db.full$Title, "[{}]")


# adding dois by merging by title
# first, are the titles the same (i.e. format is the same, no need to worry)
setdiff(db.full[db.full$Publication_year>2017,"Title"],doi.2018.19.red$Title)
setdiff(doi.2018.19.red$Title,db.full[db.full$Publication_year>2017,"Title"])

# everything matches, therefore I can add dois to the database
db.full.doi <- merge(db.full,doi.2018.19.red,by="Title",all.x=T)

# adding a missing doi manually
db.full.doi$doi <- as.character(db.full.doi$doi)
db.full.doi[db.full.doi$fulltextID=="CAE168" & !(is.na(db.full.doi$fulltextID)),"doi"]<-"10.1002/ecy.2191"

# adding doi's from before 2017
db.full.doi$fulltextID <- as.character(db.full.doi$fulltextID)
db.full.doi$doi <- ifelse(is.na(db.full.doi$doi),
                          db.full.doi$fulltextID,
                          db.full.doi$doi)

db.full.doi$doi <- as.factor(db.full.doi$doi)
summary(db.full.doi)


###############################
# exporting clean dataset

db.full.doi.reduced <- db.full.doi[,c("doi","Journal","Publication_year","Publication_year.2",
                                      "Excluded.abstract.screening","statistical.analysis.and.or.simulations.2",
                                      "bioinformatic.analysis","additional.comment.on.analysis",
                                      "Stat_analysis_software","CodePublished","CodePublished.2","CodePublished.3","LinktoCode",
                                      "BreafDescription","InlineComments",
                                      "CodeMentioned","CodeMentioned.2","Location_CodeMentioned","LocationShared","LocationShared.2",
                                      "Repository","FreeSoftware","DataUsed","DataShared.2","DataShared.3",
                                      "ExtraComments","Second_screener","Changes_after_second_screening",
                                      "Remarks_on_decisions")]

write.csv(db.full.doi.reduced,"data/code_availability_full_and_clean.csv",
          row.names=FALSE)


# Some extra checks:
# double checking consistency for those studies with simulations and code, data should be at least partially shared (depends, though, think about it) (if the code provided generates the data)
# db.full[db.full$statistical.analysis.and.or.simulations=="yes, simulation" & 
#           !(is.na(db.full$statistical.analysis.and.or.simulations)) & 
#           db.full$CodePublished=="yes" & db.full$DataUsed=="yes",
#         c("statistical.analysis.and.or.simulations","CodePublished","DataUsed","DataShared")]
# db.full[db.full$statistical.analysis.and.or.simulations=="yes, statistical and simulation" & 
#           !(is.na(db.full$statistical.analysis.and.or.simulations)) &
#           db.full$CodePublished!="no",
#         c("statistical.analysis.and.or.simulations","CodePublished","DataUsed","DataShared")]


# # checking papers for which only simulations where run to see if CodePublished DataUsed and DataShared agree
# db.full[!(is.na(db.full$statistical.analysis.and.or.simulations)) & 
#           db.full$statistical.analysis.and.or.simulations=="yes, simulation",
#         c("fulltextID","Authors","Publication_year","CodePublished","DataUsed","DataShared","Second_screener")]
