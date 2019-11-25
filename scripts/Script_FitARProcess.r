# Prepare working environment
rm(list = ls())
setwd("/home/drtea/Research/Projects/CO2policy/PEDAC/")

# install required packages
install.packages('car')

# load required packages
library("car")

# constant to transform C into CO2
C2CO2 = 3.664

# read data from global carbon project
# Le Quéré et al: Global Carbon Budget 2018, Earth Syst. Sci. Data, 2018b.
#                 https://doi.org/10.5194/essd-10-2141-2018
GCP <- read.csv(file="data/GCP_recent.csv", header=TRUE, sep=",")



# Get indices for the considered time period
Ia = which( GCP$Year==1959 ) 
Ie = which( GCP$Year==2014 )

# atmospheric growth in gtC/year
years =  GCP$Year[ Ia:Ie ]
growthRateObs = GCP$atmospheric.growth[ Ia:Ie ]
growthRateRec = growthRateObs + GCP$budget.imbalance[ Ia:Ie ]

# plot the reconstruction and the atmospheric CO2
plot( NULL,
      xlim = range(years),
      xlab = "year",
      ylim = c(0,8),
      ylab = "GtC"
      )
lines(years, growthRateObs, col=1)
lines(years, growthRateRec, col=2)

# Define the imbalance process to fit an AR model, to model the error process
# between reconstruction and measurements
imbalance = ( growthRateObs - growthRateRec ) * C2CO2
n = length(imbalance)

# compute statistical descriptors
mean_imba = mean( imbalance )
sd_imba   = sd( imbalance )

# AR modeling
acf( imbalance )
pacf( imbalance )
mle = ar.mle( imbalance, aic = TRUE, order.max = NULL, demean = FALSE, intercept = FALSE)
mle$aic
mle
sqrt( mle$asy.var.coef )
sqrt( mle$var.pred )

ols = ar.ols( imbalance, aic = FALSE, order.max = 1, demean = FALSE, intercept = FALSE)
ols
acf( ols$resid[2:n] )
qqPlot( ols$resid[2:n], add.line = TRUE )

# rho = 0.44, sd = 3 in CO2, sd =  0.82 in C (0.386 in ppm)

acf(imbalance)
k = 0:17
lines(k, mle$ar^k, col='red')

mean( imbalance )
sd( imbalance )/sqrt(n*(1 - ols$ar[1]))

# Plots
png(filename = paste(figpath, "/imbalance_qqplot.png", sep=''), width = wd, height = ht)
par(cex = cex)
qqPlot(ols$resid[2:n], xlab='normal quantlies', ylab = 'sample quantiles')
dev.off()

png(filename = paste(figpath, "/imbalance_acf.png", sep=''), width = wd, height = ht)
par(cex = cex)
acf( imbalance )
k = 0:17; lines(k, mle$ar^k, col='red')
dev.off()

png(filename = paste(figpath, "/imbalance_pacf.png", sep=''), width = wd, height = ht)
par(cex = cex)
pacf( imbalance )
dev.off()