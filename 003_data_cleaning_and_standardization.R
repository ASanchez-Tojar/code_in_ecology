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

# This script is to import the sheets with data extracted from the
# references include in a review for the following study:

# Antica Culina, Ilona van den Berga, Simon Evans, Alfredo Sanchez-Tojar. 
# Low availability of code in ecology: a call for urgent action.


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

# importing data for 2016-2017
db.2016.17 <- read.xlsx("data/Data_Feb_2020_V2.xlsx",
                        colNames = T,sheet = 1)

# importing data for 2016-2017
db.2018.19 <- read.xlsx("data/Data_Feb_2020_V2.xlsx",
                        colNames = T ,sheet = 2)


##############################################################
# Standardizing databases
##############################################################

# are the variable names the same?
setdiff(names(db.2016.17),names(db.2018.19))
setdiff(names(db.2018.19),names(db.2016.17))

# changing name of a variable to standardize across datasets
db.2016.17 <- rename(db.2016.17, BreafDescription = "BreafDescription/Howto")

# are the variable names the same? Yes
setdiff(names(db.2016.17),names(db.2018.19))
setdiff(names(db.2018.19),names(db.2016.17))

# putting both databases together
db.full <- rbind(db.2016.17,db.2018.19)

# exploring database
summary(db.full)

# transforming variables to their right type
cols.factor <- c("fulltextID", "Journal", "Excluded.abstract.screening", "statistical.analysis.or/and.simulations",
                 "bioinformatic.analysis", "Stat_analysis_software", "CodePublished", "CodeMentioned", "Location_CodeMentioned",
                 "LocationShared", "Repository", "FreeSoftware", "DataUsed", "DataShared", "BreafDescription",
                 "InlineComments")
db.full[cols.factor] <- lapply(db.full[cols.factor], factor)  ## as.factor() could also be used

# exploring database
summary(db.full)
names(db.full)

#############################################################################################
# exploring each variable and cleaning and standardizing if necessary
#############################################################################################

###############################
# Journal
table(db.full$Journal)


###############################
# Excluded.abstract.screening
table(db.full$Excluded.abstract.screening)

# found some yes that need to be standardized
yes.conditionals <- db.full[!(db.full$Excluded.abstract.screening %in% c("yes","no")),"Excluded.abstract.screening"]

# extracting the exclusion reasons to add them to the additional.comment.on.analysis variable
db.full[!(db.full$Excluded.abstract.screening %in% c("yes","no")),"additional.comment.on.analysis"] <- str_extract(yes.conditionals, "[:alpha:]+$")
db.full[!(db.full$Excluded.abstract.screening %in% c("yes","no")),"Excluded.abstract.screening"] <- "yes"

#restarting factor levels to remove the old ones
db.full$Excluded.abstract.screening <- factor(db.full$Excluded.abstract.screening)
table(db.full$Excluded.abstract.screening) # everything looks good now


###############################
# statistical.analysis.or/and.simulations

# first name needs to be modified to make it easy to handle
names(db.full)[8] <- "statistical.analysis.and.or.simulations"

table(db.full$statistical.analysis.and.or.simulations)

# standardizing: singular and plural
db.full$statistical.analysis.and.or.simulations <- recode(db.full$statistical.analysis.and.or.simulations,
                                                          "yes, simulations" = "yes, simulation",
                                                          "yes, statistical and simulations" = "yes, statistical and simulation",
                                                          .default = levels(db.full$statistical.analysis.and.or.simulations))


# creating a new variable with simply yes or no to make subsetting easier
db.full$statistical.analysis.and.or.simulations.2 <- as.factor(ifelse(as.character(db.full$statistical.analysis.and.or.simulations)=="no",
                                                                      "no",
                                                                      "yes"))
###############################
# bioinformatic.analysis
table(db.full$bioinformatic.analysis)


###############################
# Stat_analysis_software
table(db.full$Stat_analysis_software)

# standardizing terminology
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, ",", " and")

# from: https://rstudio-pubs-static.s3.amazonaws.com/408658_512da947714740b99253228f084a08a9.html
# making all first letters capital
CapStr <- function(y) {
  c <- strsplit(y, " ")[[1]]
  paste(toupper(substring(c, 1,1)), substring(c, 2),
        sep="", collapse=" ")
}

db.full$Stat_analysis_software <- sapply(as.character(db.full$Stat_analysis_software), CapStr)

# reformatting NA's
db.full$Stat_analysis_software <- recode(db.full$Stat_analysis_software,
                                         "NANA" = "NA",
                                         .default = levels(db.full$Stat_analysis_software))

levels(db.full$Stat_analysis_software)[levels(db.full$Stat_analysis_software)=='NA'] <- NA


db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "And", "and")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "Stata", "STATA")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "SigmaPlot for Windows", "Sigmaplot")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "OpenBUGS", "Openbugs")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "C Compiler", "C")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "Hyperniche Version 2.0 and Other", "Hyperniche")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "JAGS Software Via The R2jags In R", "R and JAGS")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "Matlab", "MATLAB")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "MATLAB and Maybe Other", "MATLAB")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "Minitab and Other?", "Minitab")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "Minitab?", "Minitab")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "Not Mentioned But Seems To Be Python", "Not Stated")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software, "GraphPad Prism", "Prism")
db.full$Stat_analysis_software <- str_replace_all(db.full$Stat_analysis_software,"\\Ibm\\X+","IBM ILOG CPLEX")


###############################
# CodePublished
table(db.full$CodePublished)

# convert all to lower case
db.full$CodePublished <- str_to_lower(db.full$CodePublished, locale = "en")

# creating new variable where embargoed is counted as yes, and partially counted as yes too
db.full$CodePublished.2 <- recode(db.full$CodePublished,
                                  "yes, but embargoed" = "yes",
                                  "some" = "yes",
                                  .default = levels(db.full$CodePublished))

table(db.full$CodePublished.2)


###############################
# CodePublished
table(db.full$CodeMentioned)

# standardizing
db.full$CodeMentioned <- recode(db.full$CodeMentioned,
                                "yes, script and code" = "yes, code and script",
                                "yes, but only as \"simulation is available in\"" = "yes, simulation",
                                "none" = "no",
                                .default = levels(db.full$CodePublished))


###############################
# Location_CodeMentioned
table(db.full$Location_CodeMentioned)


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


###############################
# Repository
table(db.full$Repository)

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


# creating new, recoded variable
db.full$FreeSoftware.2 <- recode(db.full$FreeSoftware,
                                 "partially" = "yes",
                                 .default = levels(db.full$FreeSoftware))

table(db.full$FreeSoftware.2)


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

# creating new binary variable
db.full$DataShared.3 <- recode(db.full$DataShared.2,
                               "partially" = "yes",
                               .default = levels(db.full$DataShared.2))

table(db.full$DataShared.3)


###############################
# Second_screener
table(db.full$Second_screener)


###############################
# exporting clean dataset
write.csv(db.full,"data/code_availability_full_and_clean.csv",
          row.names=FALSE)



# checking papers for which only simulations where run to see if CodePublished DataUsed and DataShared agree
db.full[!(is.na(db.full$statistical.analysis.and.or.simulations)) & 
          db.full$statistical.analysis.and.or.simulations=="yes, simulation",
        c("fulltextID","Authors","Publication_year","CodePublished","DataUsed","DataShared","Second_screener")]


