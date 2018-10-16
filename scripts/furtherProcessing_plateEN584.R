#further processing for EN584 plate reader (all 8 stns)

######################## bulk ##########################
bulk <- read.csv("Plate_RatesBulk_EN584.csv",header=TRUE,row.names=1)
#subset impt columns
bulk_factors <- data.frame(row.names=rownames(bulk),"max_rate"=bulk$max_mean, "max_sd"=bulk$max_sd,"max_timepoint_id"=bulk$max_timepoint_id,"avg_potential_rate"=bulk$avg_potential_rate,"avg_sd"=bulk$potential_sd)
#if rate is below 0, change to zero
for (row in 1:nrow(bulk_factors)) { 
    if (bulk_factors[row,"max_rate"]<0) {
        bulk_factors[row,"max_rate"] = 0
        bulk_factors[row,"max_sd"] = 0
    }
    if (bulk_factors[row,"avg_potential_rate"]<0) {
        bulk_factors[row,"avg_potential_rate"] = 0
        bulk_factors[row,"avg_sd"] = 0
    }
}
#add factors
bulk_factors$stn <- gsub(pattern="stn([0-9a-z]+)-d([0-9A-Za-z])-([A-Za-z0-9]+)-([a-zA-Z0-9]+)",replacement="stn\\1",x=rownames(bulk))
bulk_factors$depthid <- gsub(pattern="stn([0-9a-z]+)-d([0-9A-Za-z])-([A-Za-z0-9]+)-([a-zA-Z0-9]+)",replacement="d\\2",x=rownames(bulk))
bulk_factors$substrate <- gsub(pattern="stn([0-9a-z]+)-d([0-9A-Za-z])-([A-Za-z0-9]+)-([a-zA-Z0-9]+)",replacement="\\4",x=rownames(bulk))
bulk_factors$site <- gsub(pattern="stn([0-9a-z]+)-d([0-9A-Za-z])-([A-Za-z0-9]+)-([a-zA-Z0-9]+)",replacement="stn\\1.d\\2",x=rownames(bulk))
#save as factorsbulk
write.csv(bulk_factors, "plate_RatesWithFactorsBulk_EN584.csv",row.names=TRUE)

######################## free living ##########################
free <- read.csv("Plate_RatesFree_EN584.csv",header=TRUE,row.names=1)
#subset impt columns
free_factors <- data.frame(row.names=rownames(free),"max_rate"=free$max_mean, "max_sd"=free$max_sd,"max_timepoint_id"=free$max_timepoint_id,"avg_potential_rate"=free$avg_potential_rate,"avg_sd"=free$potential_sd)
#if rate is below 0, change to zero
for (row in 1:nrow(free_factors)) { 
    if (free_factors[row,"max_rate"]<0) {
        free_factors[row,"max_rate"] = 0
        free_factors[row,"max_sd"] = 0
    }
    if (free_factors[row,"avg_potential_rate"]<0) {
        free_factors[row,"avg_potential_rate"] = 0
        free_factors[row,"avg_sd"] = 0
    }
}
#add factors
free_factors$stn <- gsub(pattern="stn([0-9a-z]+)-d([0-9A-Za-z])-([A-Za-z0-9]+)-([a-zA-Z0-9]+)",replacement="stn\\1",x=rownames(free))
free_factors$depthid <- gsub(pattern="stn([0-9a-z]+)-d([0-9A-Za-z])-([A-Za-z0-9]+)-([a-zA-Z0-9]+)",replacement="d\\2",x=rownames(free))
free_factors$substrate <- gsub(pattern="stn([0-9a-z]+)-d([0-9A-Za-z])-([A-Za-z0-9]+)-([a-zA-Z0-9]+)",replacement="\\4",x=rownames(free))
free_factors$site <- gsub(pattern="stn([0-9a-z]+)-d([0-9A-Za-z])-([A-Za-z0-9]+)-([a-zA-Z0-9]+)",replacement="stn\\1.d\\2",x=rownames(free))
#save as factorsbulk
write.csv(free_factors, "plate_RatesWithFactorsFree_EN584.csv",row.names=TRUE)

######################## gf ##########################
gf <- read.csv("Plate_RatesGF_EN584.csv",row.names=1)
#subset impt columns
gf_factors <- data.frame(row.names=rownames(gf),"max_rate"=gf$max_mean, "max_sd"=gf$max_sd,"max_timepoint_id"=gf$max_timepoint_id,"avg_potential_rate"=gf$avg_potential_rate,"avg_sd"=gf$potential_sd)
#if rate below zero, change to zero
for (row in 1:nrow(gf_factors)) { 
    if (gf_factors[row,"max_rate"]<0) {
        gf_factors[row,"max_rate"] = 0
        gf_factors[row,"max_sd"] = 0
    }
    if (gf_factors[row,"avg_potential_rate"]<0) {
        gf_factors[row,"avg_potential_rate"] = 0
        gf_factors[row,"avg_sd"] = 0
    }
}
#add factors
gf_factors$stn <- gsub(pattern="stn([0-9])-d([0-9])-GF-([a-zA-Z0-9]+)",replacement="stn\\1",x=rownames(gf))
gf_factors$depthid <- gsub(pattern="stn([0-9])-d([0-9])-GF-([a-zA-Z0-9]+)",replacement="d\\2",x=rownames(gf))
gf_factors$substrate <- gsub(pattern="stn([0-9])-d([0-9])-GF-([a-zA-Z0-9]+)",replacement="\\3",x=rownames(gf))
gf_factors$site <- gsub(pattern="stn([0-9])-d([0-9])-GF-([a-zA-Z0-9]+)",replacement="stn\\1.d\\2",x=rownames(gf))
##save as factorsgf
write.csv(gf_factors, "plate_RatesWithFactorsGF_EN584.csv",row.names=TRUE)

######################## lv ##########################
lv <- read.csv("Plate_RatesLV_EN584.csv",row.names=1)
#subset impt columns
lv_factors <- data.frame(row.names=rownames(lv),"max_rate"=lv$max_mean, "max_sd"=lv$max_sd,"max_timepoint_id"=lv$max_timepoint_id,"avg_potential_rate"=lv$avg_potential_rate,"avg_sd"=lv$potential_sd)
#if rate below zero, change to zero
for (row in 1:nrow(lv_factors)) { 
    if (lv_factors[row,"max_rate"]<0) {
        lv_factors[row,"max_rate"] = 0
        lv_factors[row,"max_sd"] = 0
    }
    if (lv_factors[row,"avg_potential_rate"]<0) {
        lv_factors[row,"avg_potential_rate"] = 0
        lv_factors[row,"avg_sd"] = 0
    }
}
#add factors
lv_factors$stn <- gsub(pattern="stn([0-9a-z]+)-d([0-9A-Za-z])-LV-subt([0-9])-([a-z0-9]+)-([a-zA-Z0-9]+)",replacement="stn\\1",x=rownames(lv))
lv_factors$depthid <- gsub(pattern="stn([0-9a-z]+)-d([0-9A-Za-z])-LV-subt([0-9])-([a-z0-9]+)-([a-zA-Z0-9]+)",replacement="d\\2",x=rownames(lv))
lv_factors$treatment <- gsub(pattern="stn([0-9a-z]+)-d([0-9A-Za-z])-LV-subt([0-9])-([a-z0-9]+)-([a-zA-Z0-9]+)",replacement="\\4",x=rownames(lv))
lv_factors$subt <- gsub(pattern="stn([0-9a-z]+)-d([0-9A-Za-z])-LV-subt([0-9])-([a-z0-9]+)-([a-zA-Z0-9]+)",replacement="subt\\3",x=rownames(lv))
lv_factors$substrate <- gsub(pattern="stn([0-9a-z]+)-d([0-9A-Za-z])-LV-subt([0-9])-([a-z0-9]+)-([a-zA-Z0-9]+)",replacement="\\5",x=rownames(lv))
lv_factors$site <- gsub(pattern="stn([0-9a-z]+)-d([0-9A-Za-z])-LV-subt([0-9])-([a-z0-9]+)-([a-zA-Z0-9]+)",replacement="stn\\1.d\\2",x=rownames(lv))

#save as factorslv
write.csv(lv_factors, "plate_RatesWithFactorsLV_EN584.csv",row.names=TRUE)

#create summary for amend and unamend at each site
#summary <- matrix(dimnames=list(NULL,c("mean","sd",colnames(subsub[,6:11]))),ncol=8)
#for (site in levels(as.factor(lv$site))) {
#    sitesub <- lv[lv$site==site,]
#    for (subtime in levels(as.factor(lv$subt))) {
#        subtsub <- sitesub[sitesub$subt==subtime,]
#        for (sub in levels(as.factor(lv$substrate))) {
#            subsub <- subtsub[subtsub$substrate==sub,]
#            #take new average and mean and insert that in new df
#                
#            }
#        }
#    }
#}
