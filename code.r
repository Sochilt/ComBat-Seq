library(readr)
library(sva)
library(plotly)

# Load batch 1 and batch 2 data
batch1 <- read_csv("/research/labs/hematology/braggio-slager/m215200/RNAseq/Mich1RNA.csv")
batch2 <- read_csv("/research/labs/hematology/braggio-slager/m215200/RNAseq/Mich2RNA.csv")

# Merge data by gene names
combined_data <- merge(batch1, batch2, by = "Gene", all = TRUE)
combined_data <- combined_data[!is.na(combined_data$Gene), ]
combined_data$Gene <- make.unique(as.character(combined_data$Gene))

# Extract and store sample names
sample_names <- colnames(combined_data)[-1]

# Set rownames to genes and remove Gene column
rownames(combined_data) <- combined_data$Gene
combined_data <- combined_data[, -1]

# Convert to matrix
count_matrix <- as.matrix(combined_data)

# Define batch info (adjust if actual sample counts differ)
batch <- c(rep(1, ncol(batch1) - 1), rep(2, ncol(batch2) - 1))

# Apply ComBat-seq
combat_seq_corrected <- ComBat_seq(count_matrix, batch = batch)

# Transpose for PCA (samples as rows)
corrected_data_transposed <- t(combat_seq_corrected)

# Filter out genes with NA, Inf, or zero variance
valid_cols <- apply(corrected_data_transposed, 2, function(x) all(is.finite(x)) && var(x) > 0)
corrected_data_transposed <- corrected_data_transposed[, valid_cols]

# Run PCA
pca_result <- prcomp(corrected_data_transposed, scale. = TRUE)
pca_data <- as.data.frame(pca_result$x)

# Add sample names and batch info
pca_data$Sample <- sample_names
pca_data$Batch <- factor(batch, labels = c("Batch 1", "Batch 2"))

# Plot PCA with sample labels and batch coloring
p <- plot_ly(data = pca_data,
             x = ~PC1, y = ~PC2, z = ~PC3,
             type = 'scatter3d', mode = 'markers+text',
             text = ~Sample,
             marker = list(size = 5, color = ~as.numeric(Batch), colorscale = 'Portland'),
             textposition = 'top center') %>%
  layout(title = '3D PCA Plot Colored by Batch with Sample Labels',
         scene = list(
           xaxis = list(title = 'PC1'),
           yaxis = list(title = 'PC2'),
           zaxis = list(title = 'PC3')
         ))

# Show plot
p
