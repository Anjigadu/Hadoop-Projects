## Impala ODBC Driver + R
conn <- odbcConnect("Impala")
## Query 1. Summary between year 2010 and year 2016
crime <- sqlQuery(conn,
                  "select substring(reportdatetime,1,4) as year, substring(reportdatetime,6,2) as month, 
                          method,offense, count(1) as frequency 
                   from crime_incident 
                   group by substring(reportdatetime,1,4),substring(reportdatetime,6,2),method,offense 
                   order by 1,2")
# ggplot2 packages 
install.packages("ggplot2")
library(ggplot2)

# Bar Chart
pl <- ggplot(crime,aes(y=frequency, x=year,fill=method))
pl + geom_bar(stat="identity")

## Query 2. 
offense <- sqlQuery(conn,"
select substring(reportdatetime,1,4) year,offense,count(offense) frequency 
from crime_incident 
where substring(reportdatetime,1,4) between '2010' and '2016'
group by substring(reportdatetime,1,4),offense")

ggplot(offense, aes(x = year,fill=offense)) 
+ geom_line(aes(y = frequency), colour="grey") 
+ ylab(label="Number of Event Occurred") 
+ xlab("year")
+ geom_point()
                     
                    
    values=c(gg_color_hue(length(unique(dfr$group))),
