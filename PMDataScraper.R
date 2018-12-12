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
yr = 2018 #Year to read data
for (i in months){
  date = as.Date(paste0(yr,"-", i, "-23"), "%Y-%m-%d")
  nd = numberOfDays(date)
  print(sprintf("Total days: %.0f",nd))
  
  #Loop through each day in that month and request data
  for (j in 1:nd){
    print(sprintf("Reading Day: = %.0f",j))
    datepath <- paste0("https://www.colorado.gov/airquality/param_summary.aspx?parametercode=88101&seeddate=",i,"%2f",j,"%2f",yr,"&export=True")
    pth = datepath
    a<-read_html(pth)
    b=html_nodes(a, "#txbExport") 
    c=html_text(b)
    pm25Data=c(pm25Data,c)
    Sys.sleep(1)#Delay for 1 second to avoid getting blocked by firewall
  }
  
  #Save data for each month to avoid giant files (right now each month is ~0.1 MB)
  write.table(pm25Data, file = paste0(mos[i],sprintf("%.0f",yr),"_pmdat.txt"), sep = "",row.names = FALSE)
  pm25Data = ""
}
