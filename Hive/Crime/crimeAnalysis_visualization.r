# Impala ODBC Driver + R
conn <- odbcConnect("Impala")
crime <- sqlQuery(conn,
                  "select substring(reportdatetime,1,4) as year, substring(reportdatetime,6,2) as month, 
                          method,offense, count(1) as frequency 
                   from crime_incident 
                   group by substring(reportdatetime,1,4),substring(reportdatetime,6,2),method,offense 
                   order by 1,2")
# ggplot2 packages 
install.packages("ggplot2")
library(ggplot2)

# (1) Bar Chart
pl <- ggplot(crime,aes(y=frequency, x=year,fill=method))
pl + geom_bar(stat="identity")

