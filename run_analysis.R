getwd()
setwd("C:/Users/Nishant")

#############################################################################################################################
## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#############################################################################################################################
#Check if the package exists & if not install the same

if (!require("data.table")) {
  install.packages("data.table")
}
if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

if(!file.exists("UCI HAR Dataset")){
  dir.create("UCI HAR Dataset")
}

  zipFile <- "C:/Users/Nishant/UCI HAR Dataset/UCI_HAR_data.zip"
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl, destfile=zipFile)
  unzip(zipFile)
  
#Setup data directories 
main_directory <- "./UCI HAR Dataset/"
test_directory <- "./UCI HAR Dataset/test/"
train_directory <- "./UCI HAR Dataset/train/"

# Reading activity labels
activity_labels <- read.table(paste0(main_directory, "activity_labels.txt"))[,2]
# Reading features
features <- read.table(paste0(main_directory, "features.txt"))[,2]
# Extract only the measurements on the mean and standard deviation for each measurement.
extract_features <- grepl("mean|std", features)

#########################################################################################
# Processing X_test & y_test files
#########################################################################################
#Reading subject test data
subject_test_data <- read.table(paste0(test_directory, "subject_test.txt"))
#Reading X_test data
x_test_data <- read.table(paste0(test_directory, "X_test.txt"))
#Reading y_test data
y_test_data <- read.table(paste0(test_directory, "y_test.txt"))

names(x_test_data) = features

## Extracts only the measurements on the mean and standard deviation for each measurement.
x_test_data = x_test_data[,extract_features]
# Load activity labels
y_test_data[,2] = activity_labels[y_test_data[,1]]
names(y_test_data) = c("activity_id", "activity_label")
names(subject_test_data) = "subject"
# Bind x_test_data , y_test_data, subject_test_data
all_test_data <- cbind(as.data.table(subject_test_data), y_test_data, x_test_data)

#########################################################################################
# Processing X_train & y_train files
#########################################################################################
subject_train_data <- read.table(paste0(train_directory, "subject_train.txt"))
x_train_data <- read.table(paste0(train_directory, "X_train.txt"))
y_train_data <- read.table(paste0(train_directory, "y_train.txt"))

names(x_train_data) = features
# Extract only the measurements on the mean and standard deviation for each measurement.
x_train_data = x_train_data[,extract_features]
# Load activity data
y_train_data[,2] = activity_labels[y_train_data[,1]]
names(y_train_data) = c("activity_id", "activity_label")
names(subject_train_data) = "subject"
# Bind data
all_train_data <- cbind(as.data.table(subject_train_data), y_train_data, x_train_data)

#########################################################################################
## Merging the training and the test sets to create one data set.
#########################################################################################

all_data = rbind(all_test_data, all_train_data)
id_labels = c("subject", "activity_id", "activity_label")
data_labels = setdiff(colnames(all_data), id_labels)
melt_data = melt(all_data, id = c("activity_label", "subject"), measure.vars = data_labels)

#########################################################################################
# Apply mean function to dataset using dcast function
#########################################################################################
tidy_data = dcast(melt_data, subject + activity_label ~ variable, mean)
write.table(tidy_data, file = "./peer_project/tidy_data.txt", row.names=FALSE)


