setwd("/Users/JHY/Documents/2018SpringCourse/Applied Data Science/Spring2018-Project3-Group1/data/train")
test_index<-read.table("TEST-NUMBER.txt")
test_index<-as.vector(t(test_index))
feature_SIFT<-read.csv("SIFT_train.csv",header = FALSE)
feature_SIFT<-feature_SIFT[,-1]
label<-read.csv("label_train.csv")
train_data<-feature_SIFT[-test_index,]
train_label<-label[-test_index,]$label
test_data<-feature_SIFT[test_index,]
test_label<-label[test_index,]$label

if(!require("randomForest")){
  install.packages("randomForest")
}
if(!require("caret")){
  install.packages("caret")
}
if(!require("e1071")){
  install.packages("e1071")
}
if(!require("ggplot2")){ 
}
library(randomForest)
library(caret)
library(e1071)
library(knitr)
library(ggplot2)

K<-5
set.seed(24)
cv_index <- sample(1:K,2700,replace=TRUE,prob=rep(1/K,K))
n_trees <- seq(0,1000,50)
cv_error<-c()
cv_error_min<-c()
tune_mtry<-c()
best_mtry<-c()
for(tree in 1:length(n_trees)){
  for(k in 1:K){
    train.data <- train_data[cv_index != k,]
    train.label <- train_label[cv_index != k]
    validation.data <- train_data[cv_index == k,]
    validation.label <- train_label[cv_index == k]
    rf_model <- tuneRF(train.data, as.factor(train.label), mtreeTry = n_trees[tree], stepFactor=1.5, improve=1e-5,doBest = TRUE)
    tune_mtry[k]<-rf_model$mtry
    model_pred<-predict(rf_model,validation.data)
    cv_error[k]<-mean(model_pred!=validation.label)
  }
  cv_error_min[tree]<-min(cv_error)
  best_mtry[tree]<-tune_mtry[which.min(cv_error)]
}
best_n_trees_index<-which.min(cv_error_min)
best_n_trees<-n_trees[best_n_trees_index]
best_parameter<-best_mtry[best_n_trees_index]


train_time<-system.time(rf_model_best<-randomForest(train_data,as.factor(train_label),mtry=best_parameter,ntree=best_n_trees))
train_error <- mean(rf_model_best$predicted != train_label)
train_error#0.2896
save(rf_model_best, file="../../output/RFmodel_SIFT.RData")

test_time<-system.time(pred <- predict(rf_model_best,test_data))
test_error <- mean(pred != test_label)
test_error#0.27
save(test_error, file="../../output/RFmodel_SIFT_TestError.RData")
