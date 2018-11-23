

#activity of lantus
act <- c(0,0.9,1.5,1.15,1,1,1,1,0.75,0.7,0.6,0.5,0.4)
hours <- c(0,2,4,6,8,10,12, 14, 16, 18, 20, 22, 24)
u <- 1

iso_date <- ISOdatetime(2018, 11, 23, 07, 00, 00)
timeline <- iso_date + (hours * 3600)
timeline




iso_date

date <- as.Date('2018-11-23', tz="CET")
daten <- as.Date.numeric(x=date, origin = "1970-01-01")
date
daten
plot(x=timeline, y=u*act, type="b")