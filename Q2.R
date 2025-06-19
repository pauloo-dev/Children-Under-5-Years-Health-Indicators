# Load necessary libraries
library(dplyr)
library(tidyr)
library(ggplot2)
library(gridExtra)

# Read the dataset from the specified path
data <- read.csv("Reference/DataSets/THERAPY.csv")

# Data preprocessing
#data$ID <- NULL  # Remove the ID column
data$drug <- factor(data$drug, levels = c("No", "Yes"))  # Convert drug to a factor
data$treatment <- factor(data$treatment, levels = c("TAU", "BtheB"))  # Convert treatment to a factor

# Reshape the data into long format
data_long <- data %>%
  pivot_longer(cols = starts_with("bdi."), names_to = "Month_Bdi", values_to = "BDI_Score")

# Create a new "Month_Num" column with numeric values
data_long$Month_Num <- ifelse(data_long$Month_Bdi == "bdi.pre", 0,
                              ifelse(data_long$Month_Bdi == "bdi.2m", 2,
                                     ifelse(data_long$Month_Bdi == "bdi.4m", 4,
                                            ifelse(data_long$Month_Bdi == "bdi.6m", 6,
                                                   ifelse(data_long$Month_Bdi == "bdi.8m", 8, NA)))))

# Convert the "Month_Num" column to numeric
data_long$Month_Num <- as.numeric(data_long$Month_Num)


# Summary statistics
summary(data_long)

# Check for missing values
sapply(data_long, function(x) sum(is.na(x)))

# Box plot of BDI scores by treatment and drug use
ggplot(data_long, aes(x = Month_Num, y = BDI_Score, fill = interaction(drug, treatment))) +
  geom_boxplot() +
  labs(x = "Months", y = "BDI Score") +
  scale_fill_manual(name = "Treatment and Drug", values = c("No.TAU" = "blue", "No.BtheB" = "green", "Yes.TAU" = "red", "Yes.BtheB" = "purple")) +
  theme_minimal()




# Calculate mean BDI scores for each combination of "Treatment" and "Drug" at each "Month_Num"
means <- data_long %>%
  group_by(treatment, drug, Month_Num) %>%
  summarize(Mean_BDI_Score = mean(BDI_Score, na.rm = TRUE))


# Create the first trace plot
plot1 <- ggplot(means, aes(x = Month_Num, y = Mean_BDI_Score, group = interaction(drug, treatment), color = interaction(drug, treatment))) +
  geom_line() +
  geom_point() +  # Add points
  labs(x = "Month", y = "BDI_Score") +
  theme_bw()

plot2 <- ggplot(means, aes(x = Month_Num, y = Mean_BDI_Score, group = drug, color = drug)) +
  geom_line() +
  geom_point() +  # Add points
  labs(x = "Month", y = "BDI_Score") +
  facet_wrap(~treatment, scales = "free_y") +
  theme_bw()

plot3 <- ggplot(means, aes(x = Month_Num, y = Mean_BDI_Score, group = treatment, color = treatment)) +
  geom_line() +
  geom_point() +  # Add points
  labs(x = "Month", y = "BDI_Score") +
  facet_wrap(~drug, scales = "free_y") +
  theme_bw()


# Arrange the plots using gridExtra
grid.arrange(plot1, plot2, plot3, ncol = 2)



# Fit a linear mixed-effects model with a random intercept only
lmm_model <- lmer(BDI_Score ~ treatment * drug * Month_Num + (1 | ID), data = data_long)

# Summarize the model
summary(lmm_model)
