#update PlateTimesheet
#put files want process in RawDir folder
#make sure to set your working directory to the correct parent directory, the folder containing the RawDir folder

library(reshape2)
library(XLConnect)

#Define the name of the folder where your .raw files are. 
RawDir <- "raw-for-rates"
#Define the name of your timesheet
timesheet <- "PlateTimesheet_EN584.csv"
#what timezone is the plate reader computer set on?
timezone <- "EST"

#if your timesheet already exists, load it in; if it doesn't, create a new data frame
if(file.exists(timesheet)) {
   Time <- read.csv(timesheet, header=TRUE, row.names=1,stringsAsFactors=FALSE)
   Time$TimeSampled <- strptime(x=Time$TimeSampled,tz=timezone,format="%Y-%m-%d %H:%M:%S")
   Time$TimeSampled <- as.POSIXct(Time$TimeSampled, tz=timezone)
} else {
    Time <- data.frame(TimeSampled=as.POSIXct(character(),tz=timezone),ElapsedTime=numeric())
}

#sort files in 'raw for rates' folder into useful hierarchies
ExptList <- list()
RawNameList <- list.files(path=RawDir, pattern="*.xlsx",all.files=FALSE) #make sure excel is closed when you do this so no hidden files get read in
RawNameListBulkFreeGF <- RawNameList[grep(pattern="*GF|*bulk|*free",RawNameList)]
RawNameListLV <- RawNameList[grep(pattern="*LV",RawNameList)]
for (file in RawNameListBulkFreeGF) {
    #Takes the name of each raw file in your folder and defines the PartialName and FullName
    #partial=stn#-d#-bulk, full=stn#-d#-bulk-t#  
    PartialName <- sub("stn([0-9a-z]+)-d([0-9A-Za-z])-([A-Za-z0-9]+)-t([0-9]+).xlsx","stn\\1-d\\2-\\3",file)
    FullName <- sub("stn([0-9]+)-d([0-9A-Za-z])-([A-Za-z0-9]+)-t([0-9]+).xlsx","stn\\1-d\\2-\\3-t\\4",file)
    
    #arranges files into useful hierarchy (all timepoints from one expt together), 
    #and reads in file, only columns 1-7 rows A-F, and renaming the columns/rows
    #a list of a list of data frames 
    ExptList[[PartialName]][[FullName]] = readWorksheetFromFile(paste(RawDir,file,sep="/"), sheet=1, startRow=29,endRow=35,startCol=2,endCol=8)
    
    #insert TimeSampled into timesheet from file info of time modified (should be time created since we never change the .raw data)
    time <- colnames(readWorksheetFromFile(paste(RawDir,file,sep="/"), sheet=1, startRow=41,endRow=41,startCol=2,endCol=2))
    time <- substr(time,2,nchar(time))
    time <- as.POSIXct(strptime(time,tz=timezone,format="%m.%d.%Y.%I.%M.%S.%p"))
    Time[FullName,"TimeSampled"] <- time
}
#update timesheet for LV .raw files
for (lv_file in RawNameListLV) {
    #Takes the name of each raw file in your folder and defines the PartialName and FullName
    #partial=stn#-d#-bulk, full=stn#-d#-bulk-t#  
    PartialName <- sub("stn([0-9a-z]+)-d([0-9A-Za-z])-([A-Za-z]+)-subt([0-9])-([a-z0-9]+)-t([0-9]+).xlsx","stn\\1-d\\2-\\3-subt\\4-\\5",lv_file)
    FullName <- sub("stn([0-9a-z]+)-d([0-9A-Za-z])-([A-Za-z]+)-subt([0-9])-([a-z0-9]+)-t([0-9]+).xlsx","stn\\1-d\\2-\\3-subt\\4-\\5-t\\6",lv_file)
    
    #arranges files into useful hierarchy (all timepoints from one expt together), 
    #and reads in file, only columns 1-7 rows A-F, and renaming the columns/rows
    #a list of a list of data frames 
    ExptList[[PartialName]][[FullName]] = readWorksheetFromFile(paste(RawDir,lv_file,sep="/"), sheet=1, startRow=29,endRow=35,startCol=2,endCol=8)
    
    #insert TimeSampled into timesheet from file info of time modified (should be time created since we never change the .raw data)
    time <- colnames(readWorksheetFromFile(paste(RawDir,lv_file,sep="/"), sheet=1, startRow=41,endRow=41,startCol=2,endCol=2))
    time <- substr(time,2,nchar(time))
    time <- as.POSIXct(strptime(time,tz=timezone,format="%m.%d.%Y.%I.%M.%S.%p"))
    Time[FullName,"TimeSampled"] <- time
}


#Calculate Elapsed Time on PlateTimesheet.csv
#Loop through each ExptList[[PartialName]] grouping (all timepoints for one incubation set),
#Extract TimeSampled from each timepoint and subtract t0 TimeSampled from each
for (inc_ix in 1:length(ExptList)) {
    #find TimeSampled from t0 row in PlateTimesheet
    t0Name <- names(ExptList[[inc_ix]][grep("*-t0",names(ExptList[[inc_ix]]))])
    t0time <- Time[t0Name,"TimeSampled"]
    #Subtract t0 TimeSampled from each timepoint TimeSampled and insert into PlateTimesheet
    for (p in 1:length(ExptList[[inc_ix]])) {
        #find timepoint TimeSampled
        name <- names(ExptList[[inc_ix]][p])
        time <- Time[name,"TimeSampled"]
        #calculate elapsed time and insert into PlateTimesheet
        elapsed <- as.numeric(difftime(time, t0time, units="hours"))
        Time[name,"ElapsedTime"] <- elapsed
    }
}

#save new PlateTimesheet
write.csv(Time,file=timesheet)