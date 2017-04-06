source("data-raw/noaa/header.R")

html <- "https://tidesandcurrents.noaa.gov/noaatidepredictions/viewDailyPredictions.jsp?bmon=07&bday=13&byear=2016&timelength=daily&timeZone=2&dataUnits=0&datum=MLLW&timeUnits=2&interval=highlow&Threshold=greaterthanequal&thresholdvalue=&format=Submit&Stationid=8555889"

table <- read_html(html) %>% html_table(fill = TRUE)

table <- table[[3]]

table <- table[,c(1,3,4)]
names(table) <- c("Date", "Time", "TideHeight")
table$Year <- "2016"

table %<>% unite(DateTime, Date, Year, Time, sep = " ")

table %<>% mutate(Station = "8555889",
                  DateTime = parse_date_time(DateTime, "mdy HM Op!*", tz = "EST5EDT"))

table$TideHeight %<>% str_replace("\n.*", "") %>% as.numeric()

brandywine <- select(table, Station, DateTime, TideHeight)

use_data(brandywine, overwrite = TRUE)
