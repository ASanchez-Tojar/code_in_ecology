###################################################################
# Author:
#
# Alfredo Sanchez-Tojar (alfredo.tojar@gmail.com)
#   Affiliation: Dept. Evolutionary Biology, Bielefeld University, Germany
#   Profile: https://scholar.google.de/citations?user=Sh-Rjq8AAAAJ&hl=de

# Script first created on the 19th of June 2019

###################################################################
# Description of script and Instructions
###################################################################

# This script is to subset a reference dataset after title-and-
# abstract screening was performed in rayyan. This data  is part of
# the following study:

# Antica Culina, Ilona van den Berga, Simon Evans, Alfredo Sanchez-Tojar. 
# Low availability of code in ecology: a call for urgent action.


###################################################################
# Packages needed
##############################################################

pacman::p_load(stringr,openxlsx)

# Clear memory
rm(list=ls())


##############################################################
# Functions needed
##############################################################

# none


##############################################################
# Importing data
##############################################################

# importing t-and-a-screened references
db.refs <- read.table("screening_process/fulltext_screening/random_200_2018_2019_rayyan_edited_t-and-a_decisions.csv",
                      header=T,sep=",",quote="\"") #ignoring single painful quotes


##############################################################
# Subsetting data: INCLUDED
##############################################################

# excluding the excluded studies
db.refs.included <- db.refs[grepl("Included",db.refs$notes),]


# sorting database by title
db.refs.included <- db.refs.included[order(db.refs.included$title),]


# generating a unique ID for each of the included references
db.refs.included$fulltextID <- paste0("CAE",str_pad(c(1:nrow(db.refs.included)), 3, pad = "0"))



##############################################################
# Formating dataset: fulltext screening + data extraction
##############################################################

data.extraction.template <- read.xlsx("screening_process/fulltext_screening/Code_evaluation_v2.xlsx",
                                      colNames=T,sheet = 1)


# creating a database with the same number of rows as the
# number of references that need to be fulltext-screened
# and the same number of columns as our data extraction template
db.refs.fulltext <- data.frame(matrix(NA, nrow=nrow(db.refs.included), ncol=ncol(data.extraction.template)))
names(db.refs.fulltext) <- names(data.extraction.template)


# adding the unique ID for each of the included references
db.refs.fulltext$fulltextID <- db.refs.included$fulltextID


# extracting information from the previous database to this one 
db.refs.fulltext$Authors <- db.refs.included$authors
db.refs.fulltext$Title <- db.refs.included$title
db.refs.fulltext$Journal <- db.refs.included$journal
db.refs.fulltext$Publication_year <- db.refs.included$year


# cleaning the Authors variable
db.refs.fulltext$Authors <- str_remove(as.character(db.refs.fulltext$Authors), 
                                       regex(" month = ...."))

# cleaning the Title variable
db.refs.fulltext$Title <- str_remove(as.character(db.refs.fulltext$Title), 
                                     regex("\\{"))


db.refs.fulltext$Title <- str_remove(as.character(db.refs.fulltext$Title), 
                                     regex("\\}"))


# adding impact factor from previous dataset
dataset.1 <- read.xlsx("data/Code_data_table_19_03_2018.xlsx",
                       colNames=T,sheet = 1)

JIF <- unique(dataset.1[,c("Journal","Imact_Factor")])
JIF <- JIF[order(JIF$Journal),]
JIF <- JIF[!(is.na(JIF$Journal)),]


db.refs.fulltext <- merge(db.refs.fulltext,JIF,by="Journal",all.x=T)
db.refs.fulltext$Impact_Factor <- NULL
names(db.refs.fulltext)[names(db.refs.fulltext) == "Imact_Factor"] <- "Impact_Factor"

##############################################################
# Saving dataset for: fulltext screening + data extraction
##############################################################

write.xlsx(db.refs.fulltext[,c("fulltextID",names(data.extraction.template))],
           "screening_process/fulltext_screening/Code_data_table_2019.xlsx",
           sheetName="Sheet1",col.names=TRUE, row.names=F,
           append=FALSE, showNA=TRUE, password=NULL)


# saving session information with all packages versions for reproducibility purposes
sink("screening_process/fulltext_screening/fulltext_screening_process_Rpackages_session.txt")
sessionInfo()
sink()