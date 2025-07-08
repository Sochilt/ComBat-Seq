# Set your working directory to the location of your data files. I am using this wd
setwd("C:/Users/m123412/Desktop/Sochilt")

# Load and preprocess data for Batch 1
exprsMatrix_batch1 <- read.csv("Batch1.csv", header = TRUE, row.names = 1)
batchVector_batch1 <- read.csv("Batch1_batch_info.csv", header = TRUE)$Batch

# Load and preprocess data for Batch 2
exprsMatrix_batch2 <- read.csv("Batch2.csv", header = TRUE, row.names = 1)
batchVector_batch2 <- read.csv("Batch2_batch_info.csv", header = TRUE)$Batch

# Combine the preprocessed data from Batch 1 and Batch 2 based on genes (columns)
combined_data <- cbind(exprsMatrix_batch1, exprsMatrix_batch2)
combined_batchVector <- c(batchVector_batch1, batchVector_batch2)

# Specify the file path where you want to save the combined data
output_file <- "combined_expression.csv"
# Write the combined expression data to a CSV file
write.csv(combined_data, file = output_file)
# Load required libraries
library(ggplot2)
library(sva)

# Read the data from a CSV file with row names and column names
data <- read.csv("combined_expression.csv", row.names = 1, header = TRUE, sep = ",")

# Define the number of samples in each group
n_group1 <- 24
n_group2 <- 6

# Create the sample_groups vector
sample_groups <- c(rep("Group 1", n_group1), rep("Group 2", n_group2))

# Calculate the mean or median expression for each sample
sample_means <- colMeans(data)  # Use colMeans for mean expression, or colMedians for median

# Perform PCA on the summary data (sample_means)
pca_result_before <- prcomp(data, center = TRUE, scale = TRUE)

# Extract the principal components
pc_data_before <- as.data.frame(pca_result_before$x)

# Create a vector of sample group labels based on your sample_groups
sample_group_labels <- rep(sample_groups, each = nrow(pc_data_before) / length(sample_groups))

# Trim the sample_group_labels to match the number of rows in pc_data_before
sample_group_labels <- sample_group_labels[1:nrow(pc_data_before)]

# Combine PCA results with sample group information
pca_data_with_groups_before <- data.frame(PC1 = pc_data_before$PC1, PC2 = pc_data_before$PC2, SampleGroup = sample_group_labels)

# Filter out rows with "NA" in the SampleGroup column (incase there is problem with the data)
pca_data_with_groups_before <- pca_data_with_groups_before[!is.na(pca_data_with_groups_before$SampleGroup), ]


# Create a PCA plot before batch correction
pca_plot_before <- ggplot(pca_data_with_groups_before, aes(x = PC1, y = PC2, color = SampleGroup)) +
  geom_point() +
  labs(x = "PC1", y = "PC2") +
  ggtitle("PCA Plot (Before Batch Correction)")

# Display the PCA plot before batch correction
print(pca_plot_before)

# Perform batch correction using ComBat
combat_result <- ComBat(dat = data, batch = sample_groups)

# Write the batch-corrected expression data to a CSV file
output_file <- "batch_corrected_expression.csv"
write.csv(combat_result, file = output_file)

# Perform PCA on the batch-corrected data
pca_result_after <- prcomp(combat_result, center = TRUE, scale = TRUE)

# Extract the principal components
pc_data_after <- as.data.frame(pca_result_after$x)

# Combine PCA results with sample group information
pca_data_with_groups_after <- data.frame(PC1 = pc_data_after$PC1, PC2 = pc_data_after$PC2, SampleGroup = sample_group_labels)

# Filter out rows with "NA" in the SampleGroup column (incase there is problem with the data)
pca_data_with_groups_after <- pca_data_with_groups_after[!is.na(pca_data_with_groups_after$SampleGroup), ]
# Create a PCA plot after batch correction
pca_plot_after <- ggplot(pca_data_with_groups_after, aes(x = PC1, y = PC2, color = SampleGroup)) +
  geom_point() +
  labs(x = "PC1", y = "PC2") +
  ggtitle("PCA Plot (After Batch Correction)")

# Display the PCA plot after batch correction
print(pca_plot_after)