##rawToRatesLV

#takes .raw LV files from plate reader, processes them to plot FL change over time (saves as png), 
#calculates rate and stores in plateRatesMasterLV/.csv

#Where are your data files
RawDir <- "raw-for-rates"
#what do you want your filename for your rate calcs to be
master <- "Plate_RatesLV_EN584.csv"
#where is your time sampled/elapsed time info stored?
timesheet <- "PlateTimesheet_EN584.csv"
#name of folder you want your output visualizations to be in
pngDir <- "flvstime-png"
#do you want to output a visualization of fluorescence over time for each plate? (it will take longer to run but is still reasonably fast)
savepng=TRUE
#slopes from std curves (done manually); 
m.mca=1.044
m.muf=0.907
#vector of which fluorophores used for diff substrates
stdslopes <- c("a"=m.muf,"b"=m.muf,"L"=m.mca,"p1"=m.mca,"p2"=m.mca,"p3"=m.mca,"p4"=m.mca)

library(ggplot2)
library(reshape2)
library(plyr)
library(RColorBrewer)
library(XLConnect)
#define color palette for flvstime plots
substrateColors <- brewer.pal(n=7,name="Dark2")

if (file.exists(pngDir)) {
} else {
    dir.create(pngDir)
}

#Read in PlateMaster and PlateTimesheet need to record calculations and calculate rates, etc.
#Define colClasses to be TimeSampled=POSIXct and ElapsedTime=numeric(?); may need use strptime
Time <- read.csv(timesheet, header=TRUE, row.names=1,stringsAsFactors=FALSE)
Time$TimeSampled <- strptime(x=Time$TimeSampled,tz="EST",format="%Y-%m-%d %H:%M:%S")
Time$TimeSampled <- as.POSIXct(Time$TimeSampled, tz="EST")

#create empty dataframe to store rates in
plateMasterLV <- data.frame()

ExptList <- list()
RawNameList = list.files(path=RawDir, pattern="*.xlsx")
#sort only LV files into useful hierarchies
RawNameListLV <- RawNameList[grep(pattern="*LV",RawNameList)]

for (file in RawNameListLV) {
    #Takes the name of each raw file in your folder and defines the PartialName and FullName
    #partial=stn#-d#-bulk, full=stn#-d#-bulk-t#  
    PartialName <- sub("stn([0-9a-z]+)-d([0-9A-Za-z])-([A-Za-z]+)-subt([0-9])-([a-z0-9]+)-t([0-9]+).xlsx","stn\\1-d\\2-\\3",file)
    TreatName <- sub("stn([0-9a-z]+)-d([0-9A-Za-z])-([A-Za-z]+)-subt([0-9])-([a-z0-9]+)-t([0-9]+).xlsx","stn\\1-d\\2-\\3-\\5",file)
    SubTName <- sub("stn([0-9a-z]+)-d([0-9A-Za-z])-([A-Za-z]+)-subt([0-9])-([a-z0-9]+)-t([0-9]+).xlsx","stn\\1-d\\2-\\3-subt\\4-\\5",file)
    FullName <- sub("stn([0-9a-z]+)-d([0-9A-Za-z])-([A-Za-z]+)-subt([0-9])-([a-z0-9]+)-t([0-9]+).xlsx","stn\\1-d\\2-\\3-subt\\4-\\5-t\\6",file)
    
    #arranges files into useful hierarchy (all timepoints from one expt together), 
    #and reads in file, only columns 1-7 rows A-F, and renaming the columns/rows
    #a list of a list of a list of a list of data frames 
    table = readWorksheetFromFile(paste(RawDir,file,sep="/"), sheet=1, startRow=29,endRow=35,startCol=2,endCol=8)
    colnames(table) = c("a","b","L","p1","p2","p3","p4")
    ExptList[[PartialName]][[TreatName]][[SubTName]][[FullName]] = table
}

#calculate change in fluorescence over time for each substrate, plot and save as png in pngDir
#and calculate rate and save in plateMasterLV.csv

#for each partial name list in ExptList, 
for (inc in 1:length(ExptList)) {
    for (treat in 1:length(ExptList[[inc]])) {
        for (subt in 1:length(ExptList[[inc]][[treat]])) {
            #define fl.list which contains fl.change matrix for each substrate in partial name
            mat <- matrix(nrow=10,ncol=7,dimnames=list(c("t0","t1","t2","t3","t4","t5","t6","t7","t8","t9"),c("hr","x1","x2","x3","live1","live2","live3")))
            fl.list <- list("a"=mat,"b"=mat,"L"=mat,"p1"=mat,"p2"=mat,"p3"=mat,"p4"=mat)
            flchange.list <- list("a"=data.frame(),"b"=data.frame(),"L"=data.frame(),"p1"=data.frame(),"p2"=data.frame(),"p3"=data.frame(),"p4"=data.frame())
            
            #loop through each data frame (timepoint), 
            for (timepoint in 1:length(ExptList[[inc]][[treat]][[subt]])) {
                #loop through each column (substrate) 
                for (column in 1:length(ExptList[[inc]][[treat]][[subt]][[timepoint]])) {
                    #remove data from table and insert into correct fl.change matrix in fl.list in correct timepoint row
                    fl.list[[names(ExptList[[inc]][[treat]][[subt]][[timepoint]][column])]][timepoint,2:7] <- ExptList[[inc]][[treat]][[subt]][[timepoint]][[column]]
                    #insert timepoint into correct row also
                    fl.list[[names(ExptList[[inc]][[treat]][[subt]][[timepoint]][column])]][timepoint,"hr"] <- Time[names(ExptList[[inc]][[treat]][[subt]][timepoint]),"ElapsedTime"]
                }
            }
            #now for a particular stn-depth, you have a list of matrices, one for each substrate, that has the 
            #fluorescence reads for each kill and live rep over time for that substrate
            
            #now you can calculate rates for each substrate for that site and insert them into mastersheet
            for (substrate in names(fl.list)) {
                fl.change <- fl.list[[substrate]]
                fl.change <- as.data.frame(fl.change)
                #remove any rows with ALL NA (leaves any with one or two NAs) (e.g. if there are less than 10 timepoints)
                NArows <- apply(fl.change, 1, function(x) all(is.na(x)))
                fl.change <- fl.change[!NArows,]
                #change any "NA" or "LOW" to 0
                fl.change[is.na(fl.change)] <- 0
                #if any of the fluorescence columns have values below 20 (no fluorophore), or NA/LOW, remove
                fl.change <- fl.change[!c("hr"=0,colMeans(fl.change[2:ncol(fl.change)]<20))==TRUE]
                #take mean all kill reps, subtract from live reps to get kill corrected fluorescence
                fl.change$xmean <- rowMeans(fl.change[,grep("x",colnames(fl.change))])
                fl.change.kc <- fl.change[,grep("live",colnames(fl.change))]-fl.change$xmean
                fl.change.kc <- data.frame(hr=fl.change$hr,fl.change.kc)
                
                #for each live rep, find slope of increase in FL for each timepoint 
                #name of slope object should be...
                title <- paste(names(ExptList[[inc]][[treat]][subt]),names(fl.list[substrate]),sep="-")
                #create data frame to store maximum slopes in
                slopedf <- data.frame()
                #for each column (rep) in fl.change (skip hr column), slide frame, find max slope and record in slopedf
                for (tp in 2:nrow(fl.change.kc)) {
                    changeFL <- (fl.change.kc[tp,]-fl.change.kc[1,])[,2:ncol(fl.change.kc)]
                    hr <- fl.change.kc[tp,"hr"]
                    mean_slope <- rowMeans(changeFL/hr)
                    sd_slope <- sd(changeFL/hr)
                    timep <- names(mean_slope)
                    
                    #add to slopedf dataframe
                    slopedf[title,paste(timep,"rate",sep="_")] <- mean_slope
                    slopedf[title,paste(timep,"sd",sep="_")] <- sd_slope
                }
                #divide max slopes by m.muf or m.mca (depending on substrate) to get rates
                m.fluorophore <- stdslopes[[names(fl.list[substrate])]]
                ratesdf <- slopedf/m.fluorophore
                
                #any rates below zero change to zero
                ratesdf[ratesdf<0]=0
                
                #find mean rate of all timepoints, record as avg_potential_rate; potential_sd
                avg <- rowMeans(ratesdf[title,grep("rate",colnames(ratesdf))])
                avg_sd <- sd(ratesdf[title,grep("rate",colnames(ratesdf))])
                
                #find max rate timepoint, record as max_mean and max_sd, and record which tp is max_timepoint
                max_rate <- max(ratesdf[title,grep("rate",colnames(ratesdf))])
                tp_id <- substr(names(ratesdf[match(ratesdf,max_rate,nomatch=0)==1])[1],1,2)
                max_sd <- ratesdf[,paste(tp_id,"sd",sep="_")]
                
                ratesdf[title,"max_mean"] <- max_rate
                ratesdf[title,"max_sd"] <- max_sd
                ratesdf[title,"max_timepoint_id"] <- tp_id
                ratesdf[title,"avg_potential_rate"] <- avg
                ratesdf[title,"potential_sd"] <- avg_sd
                
                #add rowname column so can write to csv later
                ratesdf$rowname <- title
                
                #insert rates into master sheet
                plateMasterLV <- rbind.fill(plateMasterLV,ratesdf)
                
                #insert fl.change.kc into flchange.list so can plot 
                fl.change.kc$mean <- rowMeans(fl.change.kc[,grep("live",colnames(fl.change.kc))])
                fl.change.kc$sd <- apply(fl.change.kc[,grep("live",colnames(fl.change.kc))],1,sd)
                flchange.list[[substrate]] <- fl.change.kc
            }
            if (savepng==TRUE) {
                #plot fl change over time and save as png
                flvstime <- melt(flchange.list,measure.vars="mean")
                flvstime$substrate <- flvstime$L1
                png(filename=paste(pngDir,"/",names(ExptList[[inc]][[treat]][subt]),".png",sep=""))
                plot <- ggplot(flvstime,aes(x=hr,y=value)) + geom_point(aes(color=substrate),size=5,alpha=0.7) + scale_color_manual(name=substrate,values=substrateColors) + geom_errorbar(aes(ymin=value-sd,ymax=value+sd,color=substrate),width=3,alpha=0.7) + geom_path(aes(color=substrate)) + geom_line(y=0,color="grey39") + xlab("Time (hr)") + ylab("Kill Corrected Fluorescence") + ggtitle(substr(title,1,nchar(title)-3)) + theme(axis.title=element_text(size=20),plot.title=element_text(size=24),axis.text=element_text(size=15),legend.text=element_text(size=14),legend.title=element_text(size=14)) 
                print(plot)
                dev.off()
            }
            
        }
    }
}

#write new plateMasterLV to new csv
write.csv(plateMasterLV[!colnames(plateMasterLV)%in%"rowname"],file=master,row.names=plateMasterLV$rowname)
print(paste("Your output file", master, "looks like this:"))
print(head(plateMasterLV))
