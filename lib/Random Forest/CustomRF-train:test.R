train_test<-function(feature_file,way="readcsv",header_TF=FALSE,best_ntree,best_mtry){
  setwd("/Users/JHY/Documents/2018SpringCourse/Applied Data Science/Spring2018-Project3-Group1")
  if(way=="readcsv"){
    feature<-read.csv(feature_file,header = header_TF)
  }
  if(way=="load"){
    load(feature_file)
    feature<-dat
    colnames(feature)<-as.character(c(1:ncol(feature)))
  }
  if(feature_file==".output/features/SIFT_train.csv"){
    feature<-feature[,2:ncol(feature)]
  }
  label<-read.csv("./data/train/label_train.csv")
  test_index<-read.table("./data/train/TEST-NUMBER.txt")
  test_index<-as.vector(t(test_index))
  train_data<-feature[-test_index,]
  train_label<-label[-test_index,]$label
  train_data<-feature[-test_index,]
  train_label<-label[-test_index,]$label
  test_data<-feature[test_index,]
  test_label<-label[test_index,]$label
  train_time<-system.time(model<-randomForest(train_data,as.factor(train_label),ntree=best_ntree,mtry = best_mtry))
  print(train_time)
  test_time<-system.time(pred<-predict(model,test_data,type="class"))
  test_error<-mean(pred != test_label)
  print(test_error)
}
train_test(".output/features/lbp/lbp.csv",best_ntree=500,best_mtry=7)
train_test(".output/features/HOG.RData",way="load",best_ntree=1500,best_mtry=10)
