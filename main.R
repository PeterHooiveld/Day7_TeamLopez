### Team Lopez members: Bart Driessen & Peter Hooiveld
### January 13, 2015

### Setting global settings:
library(raster)
library(randomForest)
library(rgdal)

### Step 1: Getting all the right data.
filelist <- list.files("data/bands/", full.names = T)
for (i in 1:length(filelist)){
  load(filelist[i])
} 
gewata <- brick(GewataB1,GewataB2,GewataB3,GewataB4,GewataB5,GewataB7,vcfGewata)
### Step 2: Demonstate the relationships between landsatbands and VCF tree cover.
pairs(gewata)
### What can you conclude? ###
#That Band 7 has the highest correlation, than band 3 followed by band 5, 2 and 1.

### Step 3: Create a liniear model of the model object.
model <- lm()
### Which bands are most important? ###

### Step 4: Plot the predicted tree cover raster and original VCF raster.

### Step 5: Calculate RSME between predicted and VCF raster.

### Step 6: Not totally clear to me...
