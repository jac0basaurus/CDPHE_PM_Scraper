rm(list = ls())
library("rvest")
library("httr")

#Define function to get number of days
numberOfDays <- function(date) {
  m <- format(date, format="%m")
  while (format(date, format="%m") == m) {
    date <- date + 1
  }
  return(as.integer(format(date - 1, format="%d")))
}

#Get data from each month
pm25Data = ""
months = 1:10 #Month range (1 = January, 12 = December)
mos = c("ja","fe","ma","ap","my","jn","jl","ag","sp","oc","nv","dc") #List of short month names for filenaming
yrs = 2018 #Year to read data
params = c(88101, 81102)#86502=coarsePM, 88101=PM2.5, 81102=PM10 (From https://www.colorado.gov/airquality/report.aspx)

for (p in params){
  print(sprintf("Reading Parameter: %.0f",p))
  for(yr in yrs){
    for (m in months){
      date = as.Date(paste0(yr,"-", m, "-1"), "%Y-%m-%d")
      nd = numberOfDays(date)
      
      #Loop through each day in this month and request data
      for (d in 1:nd){
        print(sprintf("Reading: %s %.0f, %.0f",mos[m],d,yr))
        datepath <- paste0("https://www.colorado.gov/airquality/param_summary.aspx?parametercode=",p,"&seeddate=",m,"%2f",d,"%2f",yr,"&export=True")
        pth = datepath
        a<-read_html(pth)
        b=html_nodes(a, "#txbExport") 
        c=html_text(b)
        pm25Data=c(pm25Data,c)
        Sys.sleep(1)#Delay for 1 second to avoid getting blocked by firewall
      }
      
      #Save data for each month to avoid giant files (right now each month is ~0.1 MB)
      savepath = paste0(mos[m],sprintf("%.0f",yr),"_",p,"dat.txt")
      write.table(pm25Data, file = savepath, sep = "",row.names = FALSE)
      pm25Data = ""
    }
  }
}
