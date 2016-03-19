setwd("C:/Users/TomHeslop/Desktop/cheltenham-festival-2016-twitter/R")
library(streamR)
library(magrittr)
library(timeformR)

readRenviron("~/.Renviron") # slightly curious why I needed to do this?
load("../data/my_auth.RData")

# login in
tf <- timeform(usr = Sys.getenv("TF_USR"),
               pwd = Sys.getenv("TF_PWD"))
# todays date to get todays entries
today <- Sys.Date()
# retrieve entries
entries <- tf$entries(tf_filter("meetingDate", today),
                      tf_filter("courseId", 10),
                      tf_filter("statusId", 21))
# select races/runners to keep
if(today == "2016-03-15") races <- c(1,2,4,5)
if(today == "2016-03-16") races <- c(1,2,4)
if(today == "2016-03-17") races <- c(1,3,4)
if(today == "2016-03-18") races <- c(1,3,4)

# create logical to test by
test <- sapply(1:length(entries), function(i) {
    entries[[i]]$raceNumber %in% races
})
# filter entries
entries <- entries[test]
# retrieve runners
runners <- sapply(1:length(entries), function(i) entries[[i]]$horseName)
# clean runner names of country suffixes, convert to lower case and add additional search terms
runners <- runners %>%
    tolower() %>%
    gsub(" \\([[:alpha:]]+\\)", "", .)
runners <- c(runners, "cheltenham", "cheltfest", "ladbrokes", "paddypower",
             "willhill", "betvictor", "coral", "betfair", "timeform")

################################################################################
# collect tweets
# create file name
file_name <- paste0("../data/", today, ".json")
current_time <- Sys.time()
end_time <- current_time + 25200
while(current_time <= end_time) {
    seconds <- as.numeric(end_time - current_time) * 60
    filterStream(file.name = file_name,
                 track = runners,
                 timeout = seconds,
                 oauth = my_oauth)
    current_time <- Sys.time()
}
