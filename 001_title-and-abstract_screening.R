###################################################################
# Author:
#
# Alfredo Sanchez-Tojar (alfredo.tojar@gmail.com)
#   Affiliation: Dept. Evolutionary Biology, Bielefeld University, Germany
#   Profile: https://scholar.google.de/citations?user=Sh-Rjq8AAAAJ&hl=de

# Script first created on the 30th of May 2019

###################################################################
# Description of script and Instructions
###################################################################

# This script is to format a reference dataset so that it can be
# imported into rayyan for title-and-abstract screening. This data 
# is part of the following study:

# Antica Culina, Ilona van den Berga, Simon Evans, Alfredo Sanchez-Tojar. 
# Low availability of code in ecology: a call for urgent action.


###################################################################
# Packages needed
##############################################################

pacman::p_load(revtools,plyr)

# Clear memory
rm(list=ls())


##############################################################
# Functions needed
##############################################################

# none


##############################################################
# Importing data
##############################################################

# importing .bib file
db.refs <- read_bibliography("screening_process/title-and-abstract_screening/random_200_2018_2019.bib")


# reducing fields to the fields required by rayyan
reducing.fields <- c("label","title","author","journal","issn",
                     "volume","number","pages","year","doi","abstract")


db.refs.red <- db.refs[,reducing.fields]


##############################################################
# Formatting data for RAYYAN QCRI
##############################################################

# choose only the fields needed for creating a .csv file importable by: https://rayyan.qcri.org

# example of a valid .csv file
rayyan.example <- read.table("screening_process/title-and-abstract_screening/rayyan_csv_example.csv",header=TRUE,sep=",")


# standardizing fields according to rayyan.example despite that some fields are missing from the wos output

# what's different between the two?
setdiff(names(rayyan.example),names(db.refs.red))
setdiff(names(db.refs.red),names(rayyan.example))


# rename columns in screening.ref.data so that they are as expected by rayyan
names(rayyan.example)
names(db.refs.red)

db.refs.rayyan <- plyr::rename(db.refs.red, 
                               c("label"="key", 
                                 "author"="authors", 
                                 "doi"="url",
                                 "number"="issue"))

db.refs.rayyan$publisher <- ""


# what's different now?
setdiff(names(rayyan.example),names(db.refs.rayyan))
setdiff(names(db.refs.rayyan),names(rayyan.example))


# reorder
db.refs.rayyan <- db.refs.rayyan[,names(rayyan.example)]


# finding authors with missing initial(s) as that causes an error when importing into rayyan
table(grepl(",  ",db.refs.rayyan$authors,fixed=T))

for(i in 1:nrow(db.refs.rayyan)){
  
  if(grepl(",  ",db.refs.rayyan$authors[i],fixed=T)){
    
    print(i)
  }
  
}


##############################################################
# Creating output
##############################################################

write.csv(db.refs.rayyan,
          "screening_process/title-and-abstract_screening/random_200_2018_2019_rayyan.csv",row.names=FALSE)

#remember to manually remove the quotes for the column names only in the .csv file, which is why we created the random_200_2018_2019_rayyan_edited.csv file

sink("screening_process/title-and-abstract_screening/screening_process_Rpackages_session.txt")
sessionInfo()
sink()
