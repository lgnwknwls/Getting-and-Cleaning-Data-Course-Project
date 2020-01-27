library(dplyr)

#download data
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if (!file.exists("./UCI HAR Dataset")) {
  #don't redownload/extract if data already exists
  download.file(fileurl,'./uciDataset.zip', mode = 'wb')
  unzip("uciDataset.zip", exdir = getwd())
}
  
#import data into R
featuresList <- read.csv("./UCI HAR Dataset/features.txt",header = FALSE, sep = " ")
featuresList <- as.character(featuresList[,2])
activityList <- read.csv("UCI HAR Dataset/activity_labels.txt", header = FALSE, sep = " ")
activityList <- as.character(activityList[,2])

trainX <- read.table("./UCI HAR Dataset/train/X_train.txt", col.names=featuresList)
trainY <- read.table("./UCI HAR Dataset/train/y_train.txt",header = FALSE, sep = " ",col.names = "Activity")
trainSubject <- read.table("./UCI HAR Dataset/train/subject_train.txt",header = FALSE, sep = " ", col.names="Subject")

testX <- read.table("./UCI HAR Dataset/test/X_test.txt",col.names=featuresList)
testY <- read.table("./UCI HAR Dataset/test/y_test.txt",header = FALSE, sep = " ",col.names = "Activity")
testSubject <- read.table("./UCI HAR Dataset/test/subject_test.txt",header = FALSE, sep = " ", col.names="Subject")

#merge data sets
X <- rbind(testX,trainX)
Y <- rbind(testY,trainY)
Subject <- rbind(testSubject, trainSubject)
data <- cbind(Subject,Y,X)

#get mean and stddev columns only
mean_stddev_data <- data %>% select(Subject, Activity, contains("mean"), contains("std"))

##Create Tidy Data
#replace activity number with english name
tidy_mean_stddev_data <- mean_stddev_data
tidy_mean_stddev_data$Activity <- activityList[tidy_mean_stddev_data$Activity]

#make column names human readable, capitilizing for keep camel caps
names(tidy_mean_stddev_data)<-gsub("Acc", "Accelerometer", names(tidy_mean_stddev_data))
names(tidy_mean_stddev_data)<-gsub("Gyro", "Gyroscope", names(tidy_mean_stddev_data))
names(tidy_mean_stddev_data)<-gsub("BodyBody", "Body", names(tidy_mean_stddev_data))
names(tidy_mean_stddev_data)<-gsub("Mag", "Magnitude", names(tidy_mean_stddev_data))
names(tidy_mean_stddev_data)<-gsub("^t", "Time", names(tidy_mean_stddev_data))
names(tidy_mean_stddev_data)<-gsub("^f", "Frequency", names(tidy_mean_stddev_data))
names(tidy_mean_stddev_data)<-gsub("tBody", "TimeBody", names(tidy_mean_stddev_data))
names(tidy_mean_stddev_data)<-gsub(".mean()", "Mean", names(tidy_mean_stddev_data), ignore.case = TRUE)
names(tidy_mean_stddev_data)<-gsub(".std()", "STD", names(tidy_mean_stddev_data), ignore.case = TRUE)
names(tidy_mean_stddev_data)<-gsub(".freq()", "Frequency", names(tidy_mean_stddev_data), ignore.case = TRUE)
names(tidy_mean_stddev_data)<-gsub("angle", "Angle", names(tidy_mean_stddev_data))
names(tidy_mean_stddev_data)<-gsub("gravity", "Gravity", names(tidy_mean_stddev_data))
names(tidy_mean_stddev_data)<-gsub("\\.","", names(tidy_mean_stddev_data))

##Organize/Calculate averages for each column for each subject and activity pair
tidy_averages_data <- tidy_mean_stddev_data
tidy_averages_data <- tidy_averages_data %>% group_by(Subject, Activity) %>% summarise_all(mean)

#export this final data set
write.table(tidy_averages_data, file="Averages of Subject and Activity.txt", row.names = FALSE) # row.names removes row numbers so no index column needs to be added