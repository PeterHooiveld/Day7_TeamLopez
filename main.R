### Team Lopez members: Bart Driessen & Peter Hooiveld
### January 13, 2015

### Setting global settings:
library(raster)
library(rgdal)
library(pls)

### Step 1: Getting all the right data.
filelist <- list.files("data/bands/", full.names = T)
for (i in 1:length(filelist)){
  load(filelist[i])
} 
gewata <- brick(GewataB1,GewataB2,GewataB3,GewataB4,GewataB5,GewataB7)
### Step 2: Demonstate the relationships between landsatbands and VCF tree cover.
pairs(gewata)
#B4 has a very low correlation, so this one is omitted from the covs.

vcfGewata[vcfGewata > 100] <- NA
ndvi <- overlay(GewataB4, GewataB3, fun=function(x,y){(x-y)/(x+y)})

covs <- addLayer(gewata,vcfGewata,ndvi)
covs <- dropLayer(covs,"gewataB4")
names(covs) <- c("band1","band2","band3","band5","band7","vcf","ndvi")

### What can you conclude? ###
#That Band 7 has the highest correlation, than band 3 followed by band 5, 2 and 1.

### Step 3: Create a liniear model of the model object.
# load the training polygons
load("data/trainingPoly.rda")
# we can convert to integer by using the as.numeric() function, 
# which takes the factor levels
trainingPoly@data$Code <- as.numeric(trainingPoly@data$Class)
# assign 'Code' values to raster cells (where they overlap)
classes <- rasterize(trainingPoly, ndvi, field='Code')
# define a colour scale for the classes (as above)
# corresponding to: cropland, forest, wetland
cols <- c("orange", "dark green", "light blue")
plot(classes, col=cols, legend=FALSE)
legend("topright", legend=c("cropland", "forest", "wetland"), fill=cols, bg="white")

covmasked <- mask(covs, classes)

# combine this new brick with the classes layer to make our input training dataset
names(classes) <- "class"
trainingbrick <- addLayer(covmasked, classes)
plot(trainingbrick)

# extract all values into a matrix
valuetable <- getValues(trainingbrick)
valuetable <- na.omit(valuetable)
valuetable <- as.data.frame(valuetable)

# Building a linear model.
modelLM <- lm(vcf~band1+band2+band3+band5+band7+ndvi,data=valuetable)
predLM <- predict(covs, model=modelLM, na.rm=TRUE)
predLM@data@values[predLM@data@values < 0] <- 0
predLM@data@values[predLM@data@values > 100] <- 100

plot(predLM)
summary(modelLM)

### Which bands are most important? ###
# The ones we used are all very important (but keep in mind that we threw out band 4 at the beginning 
# because we already figured that it would be useless due to the outcome of pairs())

### Step 4: Plot the predicted tree cover raster and original VCF raster.
par(mfrow=c(1, 2))
plot(covs$vcf,main="The forest cover from the Vegetation Continuous Field (VCF) product (left) and the forest cover predicted (right)")
plot(predLM)
par(mfrow=c(1, 1))


### Step 5: Calculate RSME between predicted and VCF raster.
rmse = sqrt(mean((predLM@data@values - covs$vcf@data@values)^2, na.rm = TRUE))
sprintf('The RMSE is %f',rmse)

### Step 6: Calculate RSME for different training areas.
rmsepzone <- as.data.frame(zonal((predLM - covs$vcf)^2,classes))
names(rmsepzone)[2] <- 'rmse'
for(i in 1:3){
  rmsepzone$rmse[i] <- sqrt(rmsepzone$rmse[i])
}
sprintf('The RMSE per zone is: zone 1: %f, zone 2: %f, zone 3: %f',rmsepzone$rmse[1], rmsepzone$rmse[2], rmsepzone$rmse[3])

