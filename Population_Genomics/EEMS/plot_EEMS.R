## EEMS - Plotting:

# Install rEEMSplots:
install.packages("/Users/corey/Desktop/rEEMSplots", repos = NULL, type = "source")

## Libraries:
library(raster)
library(rEEMSplots)
library(rworldmap)
library(rworldxtra)
library(rgdal)

mcmcpath = c("output1/", "output2/", "output3/")
plotpath = "plotting/"

projection_none <- "+proj=longlat +datum=WGS84"
projection_mercator <- "+proj=merc +datum=WGS84"

eems.plots(mcmcpath, plotpath, longlat = FALSE, add.grid = TRUE, add.demes = TRUE, add.map = TRUE, projection.in = projection_none, projection.out = projection_mercator, lwd.map = 1, out.png = FALSE, plot.height = 8, plot.width = 10)
