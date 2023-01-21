cat("\014")  # ctrl+L, clear console
rm(list = ls()) #clear environment
dev.off(dev.list()["RStudioGD"]) #clear all plots
library(plyr)
library(tidyverse)
library(caret)
library(car)
setwd("~/Desktop/ResidentialBuilding/Git_stat/estate_sales_prices_estimation")
Constructions<-read.csv("Constructions.csv")

View(Constructions)
ColNames<-colnames(Constructions)
attach(Constructions)
mean(SalesPrices)
median(SalesPrices)
sd(SalesPrices)

##Put in indexes5 just the index columns of market index at sale moment"
j=1;
indexes5<-0;
for (i in 1:length(ColNames)){
  if(grepl('_5', ColNames[i])){indexes5[j]<-i; j<-j+1;}
}
rm(j)
rm(i)
###

##Look at strange values##
means<-colMeans(Constructions)
View(rbind(Constructions[c(1,365),],means))
#######
##Best four index5##
l<-1
minimum<-Inf
indexex<-seq(0,3)
aic<-rep(NULL,19**4)
for(i in indexes5){for(j in indexes5){ for(k in indexes5){ for(m in indexes5){
  if(j>i & k>j & m>k){
aic[l]<-glm.nb(as.formula(paste("SalesPrices~", ColNames[i],"+", ColNames[j],"+", ColNames[k], "+", ColNames[m], "+
                                      PriceAtBeginning+ as.factor(BuildingZIPCode) + BuildingFloorArea+ LotArea")), data=Constructions)$aic
if(minimum>aic[l]){minimum<-aic[l]; indexex[1]<-i; indexex[2]<-j; indexex[3]<-k; indexex[4]<-m}
l<-l+1;}
}}}}
indexex
which.min(aic)
min(aic)
ColNames[indexex[1]]
ColNames[indexex[2]]
ColNames[indexex[3]]
ColNames[indexex[4]]
cor(Constructions[,c(indexex[1],indexex[2],indexex[3],indexex[4])])
#######

"StartYear" "CompletionYear" "BuildingZIPCode" "BuildingFloorArea" "LotArea"                       
"TotEstConstructionCost" "EstConstructionCost"  "EstConstructionCostBaseYear"    "ConstructionDuration"          
 "PriceAtBeginning"
 SalesPrices~ StartYear+CompletionYear+BuildingZIPCode
 +BuildingFloorArea+LotArea+ TotEstConstructionCost
 +EstConstructionCost+EstConstructionCostBaseYear+
   ConstructionDuration+PriceAtBeginning
 
all_index<-c(2:11,indexes5)
all_index_noZIP<-c(2,3,5:11,indexes5)
library(car)
max_mod_NegBin <-glm.nb(as.formula(paste("SalesPrices~factor(NewBuildingZIPCode)+", paste(ColNames[all_index], collapse="+"))), link="identity")
min_mod_NegBin <-glm.nb(SalesPrices~ PriceAtBeginning, link="identity")
fit.best<-step(min_mod, scope=list(lower=min_mod, upper=max_mod), direction = "both")
fit.best$coefficients
fit.best$terms
fit.best$aic
vif(fit.best)

termplot(max_mod_NegBin, partial.resid = TRUE)


max_mod_Gamma <-glm(as.formula(paste("SalesPrices~factor(NewBuildingZIPCode)+", paste(ColNames[all_index], collapse="+"))), family=Gamma(link="identity"))
min_mod_Gamma <-glm(SalesPrices~ PriceAtBeginning, family=Gamma(link="identity"))
fit_best_Gamma<-step(min_mod, scope=list(lower=min_mod, upper=max_mod), direction = "both")
fit_best_Gamma$aic
termplot(max_mod_Gamma, partial.resid = TRUE)
plot()


library(caret)
#specify the cross-validation method
ctrl<-trainControl(method="CV", number="10")
#fit a regression model and use LOOCV to evaluate performance
fit_best_all_CV<-train(SalesPrices ~ PriceAtBeginning + ConstructionDuration + LoansExtendedAmount_3 + 
                         PrivateSectorInvestment_4 + LoansExtendedNo_1 + LandPriceIndexBaseYear_4 + 
                         GoldPriceOnce_1 + OfficialExcangeRateUSD_5 + BuildingPermitsNo_4 + 
                         BuildingPermitsFloorArea_2 + ConstructionCostAtBeginning_1 + 
                         InterestRate_3 + LandPriceIndexBaseYear_3 + ConstructionCostAtCompletion_2 + 
                         CPIFornituresBaseYear_1 + WPI_2 + StreetMarketExcangeRateUSD_4 + 
                         factor(BuildingZIPCode) + GoldPriceOnce_5 + BuildingPermitsNo_2 + 
                         LandPriceIndexBaseYear_5, method="gamma", trControl=ctrl, data=Constructions)


fit_best_CV<-train( SalesPrices ~ PriceAtBeginning + ConstructionDuration + CPIFornituresBaseYear_5 + 
                      LandPriceIndexBaseYear_5 + OfficialExcangeRateUSD_5 + GoldPriceOnce_5 + 
                      CPIBaseYear_5 + StartYear + CumulativeLiquidity_5 + LoansExtendedNo_5 + 
                      BSI_5 + CityPopulation_5 + WPI_5 + InterestRate_5 + factor(NewBuildingZIPCode) + 
                      TotEstConstructionCost, method="gamma", trControl=ctrl, data=Constructions)
#view summary of CV
print(fit_best_CV)
print(fit_best_all_CV)


```{r}
plot(as.factor(BuildingZIPCode), SalesPrices)
```
It seems reasonably to use the ZIP code as predictor. Let's add it:

```{r}
##Create NewBuildingZIPCode
`%notin%` <- Negate(`%in%`)
NewBuildingZIPCode=seq(1, length(BuildingZIPCode))
for (j in 1:length(BuildingZIPCode)){
  if(BuildingZIPCode[j] %notin% c(1,3,6)){
NewBuildingZIPCode[j]<-21;}
  else {NewBuildingZIPCode[j]<-BuildingZIPCode[j]}
}
rm(j)
##
##Binding it at the dataframe
Constructions<-cbind(Constructions, NewBuildingZIPCode)
```

library(MASS)
# Tuning parameter = 0 implies least square estimates
# select lambda by GCV in the model with logLDC
grid.ridge<-lm.ridge(as.formula(paste("SalesPrices~", paste(ColNames[indexes5], collapse="+"))), 
                     lambda=seq(0.1,10,0.001))

lambda_selected<-grid.ridge$lambda[which(grid.ridge$GCV==min(grid.ridge$GCV))]

# or see the lambda in the last line of the following 
# select(lm.ridge(log_time ~ log_dist + log_climb + logLDC, 
#       lambda=seq(0.1,10,0.001), data=nihills))

lm_ridge_GCV <- lm.ridge(as.formula(paste("SalesPrices~", paste(ColNames[indexes5], collapse="+"))), 
                         lambda=lambda_selected)

coef(lm_ridge_GCV)
lm_ridge<- lm.ridge(as.formula(paste("SalesPrices~", paste(ColNames[indexes5], collapse="+"))) , lambda=0)