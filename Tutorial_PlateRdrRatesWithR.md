To follow this tutorial, go to the url: https://github.com/ahoarfrost/ArnostiLab-RScript-Demo-PlateRdr; click "Clone or download" in the top right, and click "Download ZIP".

Unzip this, and you will see a folder called ArnostiLab-RScript-Demo-PlateRdr-master. Put this wherever you want on your computer. 

Open RStudio and create a new project (File -> 'New Project'). Associate this project with the folder you just downloaded by navigating to its location on your computer. 

The scripts I'm using in this tutorial I wrote for the EN584 cruise, which was the first cruise where we used the new plate reader that outputs excel .xslx files. These scripts generally translate easily to other projects as long as you use the lab file naming scheme, though. 

# Organizing your files

Put your files you want to calculate rates for into a folder. I call this folder 'raw-for-rates' and have preloaded this tutorial with some samples for you. 

## Naming your files

Like with the FLA rates, you need to make sure you're using the lab standard file naming scheme. For bulk, GF, or free-living type experiments, this is something like:

**stn#-d#-[bulk/free/GF EXPTTYPE]-t#.xlsx**

* **stn##**: the station number. You must have the string 'stn' followed by any number, e.g. stn1, stn4, stn36. You cannot use letters for station names.

* **d##**: The depth label sampled. You must have the string 'd' followed by any number, letter, or capital letter, e.g. d0, d12, dA, dX, dy. 

* **EXPTTYPE**: This is a fixed value and should generally be "bulk", "GF", or "free" to reference the type of experiment being measured. There is a different script for running gravity filtration (GF) or free-living (LV) incubations. In this tutorial, we are looking at bulk water incubations and this value should be 'bulk'. The others are run using the same process. 

* **t##**: The timepoint sampled. This should be the lower case letter "t" followed by any integer, e.g. t0, t1, t10.

For LV experiments, there is a different style naming scheme reflecting the types of plates you have to set up. This looks like:

**stn#-d#-LV-subt#-[AMENDMENT]-t#.xlsx**

* **stn##**: the station number. You must have the string 'stn' followed by any number, e.g. stn1, stn4, stn36. You cannot use letters for station names.

* **d##**: The depth label sampled. You must have the string 'd' followed by any number, letter, or capital letter, e.g. d0, d12, dA, dX, dy. 

* **LV**: The LV experiment type. 

* **subt#**: The subsampling timepoint from which you took a subsample from the carboys. This should be the string 'subt' followed by any single integer, e.g. subt3, subt0. 

* **AMENDMENT**: Whether this was one of the amendment LV incubations or the unamended. This should be some combination of lower case letters and numbers, typically I use a1, a2, a3, and u to indicate 'amended1, amended2, amended3, or unamended'. 

* **t#**: The timepoint the plate was read. This should be the lower case letter "t" followed by any integer, e.g. t0, t8, t13.

# Creating the plate reader timesheet

We can do this automatically from the timestamps of the plate reader output files! We will use the script "Plate_UpdateTimesheet_EN584.R" for this. 

### Adjust the header on scripts/Plate_UpdateTimesheet_EN584.R

**Adjust lines 8-13**

* Line 9: the relative path of the folder where your plate reader files to process are 

* Line 11: the name of your timesheet (this can already exist or not). This can be whatever name you want, but should be a .csv file. 

* Line 13: the name of the timezone of the timestamp on your raw plate reader files. This will be whatever timezone the plate reader computer is set to. This is usually "EST" for us. 

### Run the script!

You can press the "Source" button in RStudio, or run the following line in the RStudio console:

```
source("scripts/Plate_UpdateTimesheet_EN584.R")
```

This script sometimes prints a warning, you don't have to worry about it. 

# Calculating rates for bulk incubations

### Adjust the header on scripts/rawToRatesEN584_bulk.R

**Adjust lines 6-20**

* Line 7: name of the folder where your raw plate reader output files you want to process are. 

* Line 9: the name of the output rate file. This can be whatever you want but should be a .csv file. 

* Line 11: The name of the timesheet for your plate reader samples. This is whatever you named your output file when you ran the "Plate_UpdateTimesheet_EN584.R" script. 

* Line 13: name of the folder where you want to store fluorescence-over-time plots for each incubation. This folder can exist already or not.

* Line 15: a boolean whether you want to save the fluorescence-vs-time plots or not. This is TRUE by default. 

* Line 17: The slope of your MCA fluorophore standard curve. You will have done this manually from your standard curve incubations, copy the slope of that linear regression to this here. 

* Line 18: The slope of your MUF fluorophore standard curve. This will also be calculated manually, copy it here. 

* Line 20: The fluorophore associated with each substrate (some are bound to muf and some to mca)

### Run the script!

You can press the "Source" button in RStudio, or run the following line in the RStudio console:

```
source("scripts/rawToRatesEN584_bulk.R")
```
