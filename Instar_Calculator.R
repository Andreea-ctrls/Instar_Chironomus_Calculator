library(dplyr)
library(openxlsx)

#   Measurements Guide 
#   Input data structure:
# - Each row represents a unique larva identified by its ID.
# - Columns contain morphological measurements of larval body parts.
#   Measurement codes:
#   - VL: Ventral length of the head capsule (in micrometers or specified unit)
#   - LA: Length of the antennae
#   - LM: Length of the mandibles
#   - LMe: Length of the mentum
#   - LVP: Length of the ventromental plates

# Instar Classification Workflow
# Objective:
# 1. Use Richardi et al. (2013) reference size ranges to assign each larval measurement to an instar stage.
# 2. Calculate a mean instar classification per larva by averaging instar assignments across all measurements.
# 3. Provide instar classifications both as Roman numerals and as numeric values for flexible downstream analyses.

######################################################### GLOBAL VARIABLES #########################################################

  # Input dataframe
  input_dataframe_name <- "yourdata"  # Replace the "yourdata" with your actual data frame variable name
  # Output file excel
  output_excel_filename <- "yourdata_with_instars.xlsx"  # Change the "yourdata_with_instars.xlsx" as desired

####################################################################################################################################


# Reference instar size ranges for each measurement type based on Richardi et al. (2013)
# Each row specifies:
# - Code: The measurement type
# - Instar: The instar stage label (I-IV)
# - Min and Max: The minimum and maximum measurement values for that instar

Richardi_Instar <- data.frame(
  Code = c("VL", "VL", "VL", "VL", "LA", "LA", "LA", "LA", "LM", "LM", "LM", "LM", "LMe", "LMe", "LMe", "LMe", "LVP", "LVP", "LVP", "LVP"),
  Instar = c("I", "II", "III", "IV", "I", "II", "III", "IV", "I", "II", "III", "IV", "I", "II", "III", "IV", "I", "II", "III", "IV"),
  Min = c(61, 90, 159, 260, 37, 55, 92, 135, 44, 75, 119, 190, 35, 50, 92, 167, 28, 51, 92, 167),
  Max = c(66, 112, 192, 340, 44, 65, 112, 220, 51, 85, 145, 265, 40, 60, 112, 220, 33, 58, 124, 235)
)

# Verify that the input dataframe exists in the current R environment
if (!exists(input_dataframe_name)) {
  stop(paste("Error: The input data frame", input_dataframe_name, "does not exist. Please load your data before running the script."))
}
# Retrieve the dataframe object by its name
input_data <- get(input_dataframe_name)
# Check if all required measurement columns are present in the input data
missing_cols <- setdiff(measurement_columns, colnames(input_data))
if (length(missing_cols) > 0) {
  warning(paste("Warning: The following measurement columns are missing from your data:", paste(missing_cols, collapse = ", ")))
}

# Function: Convert instar label (including ranges like "I-II", "II-III" or "III-IV") to numeric average value
# Purpose: Enables quantitative averaging of instar assignments for multiple measurements
instar_to_num <- function(instar_label) {
  base_map <- c("I"=1, "II"=2, "III"=3, "IV"=4)
  if (is.na(instar_label)) return(NA)
  if (grepl("-", instar_label)) {  # If label is a range
    parts <- unlist(strsplit(instar_label, "-"))
    mean_val <- mean(sapply(parts, function(x) base_map[x]))
    return(mean_val)
  } else {
    return(base_map[instar_label])
  }
}

# Function: Determine the instar classification for a single measurement value
# Inputs:
# - value: numeric measurement value to classify
# - code: measurement type (e.g., "VL", "LA")
# - reference_df: dataframe containing reference size ranges for all instars and codes
# Logic:
# - Check if the value falls within any instar range (Min-Max)
# - If smaller than smallest Min, assign instar I (youngest)
# - If larger than largest Max, assign instar IV (oldest)
# - If between ranges, assign a range label (e.g. "II-III")
# Returns: instar label as string or NA if classification fails
determine_instar <- function(value, code, reference_df) {
  code_data <- reference_df %>%
    filter(Code == code) %>%
    arrange(factor(Instar, levels = c("I", "II", "III", "IV")))
  
  instar_row <- code_data %>% filter(Min <= value, value <= Max)
  
  if (nrow(instar_row) == 1) {
    return(instar_row$Instar)
  }
  if (!is.na(value) && value < code_data$Min[1]) {
    return("I")
  }
  if (!is.na(value) && value > code_data$Max[nrow(code_data)]) {
    return("IV")
  }
  # Check for values falling between instar ranges and assign range labels
  for (i in 1:(nrow(code_data) - 1)) {
    max_current <- code_data$Max[i]
    min_next <- code_data$Min[i + 1]
    if (value > max_current && value < min_next) {
      return(paste0(code_data$Instar[i], "-", code_data$Instar[i + 1]))
    }
  }
  return(NA)  # Return NA if value cannot be classified
}

# Function: Convert a numeric mean instar value back to a Roman numeral instar label
# This function accounts for intermediate numeric values by assigning range labels
num_to_instar <- function(num) {
  if (is.na(num)) {
    return(NA)
  } else if (num >= 1.0 && num <= 1.3) {
    return("I")
  } else if (num > 1.3 && num <= 1.6) {
    return("I-II")
  } else if (num > 1.6 && num <= 2.3) {
    return("II")
  } else if (num > 2.3 && num <= 2.6) {
    return("II-III")
  } else if (num > 2.6 && num <= 3.3) {
    return("III")
  } else if (num > 3.3 && num <= 3.6) {
    return("III-IV")
  } else if (num > 3.6) {
    return("IV")
  } else {
    return(NA)
  }
}

# Main loop: For each morphological measurement column,
# classify each measurement value into an instar stage
for (col in measurement_columns) {
  if (col %in% colnames(input_data)) {
    instar_col_name <- paste0(col, "_Instar")
    input_data[[instar_col_name]] <- sapply(input_data[[col]], function(value) {
      if (!is.na(value) && is.numeric(value)) {
        determine_instar(value, col, Richardi_Instar)
      } else {
        NA  # Assign NA if measurement is missing or non-numeric
      }
    })
    message(paste("Column", instar_col_name, "successfully created."))
  } else {
    warning(paste("Column", col, "not found in data. Skipping this measurement."))
  }
}

# Convert all instar labels for each measurement column into numeric values
# to enable calculation of the mean instar per larva
numeric_instars_matrix <- sapply(measurement_columns, function(col) {
  instar_col <- paste0(col, "_Instar")
  if (instar_col %in% colnames(input_data)) {
    sapply(input_data[[instar_col]], function(x) if (!is.na(x)) instar_to_num(x) else NA)
  } else {
    rep(NA, nrow(input_data))  # If instar column missing, fill with NA
  }
})

# Calculate the mean numeric instar value per larva, ignoring missing values
input_data$Mean_Instar_Numeric <- rowMeans(numeric_instars_matrix, na.rm = TRUE)

# Convert the numeric mean instar back to a Roman numeral instar label,
# which may include ranges to reflect intermediate instars
input_data$Mean_Instar_Roman <- sapply(input_data$Mean_Instar_Numeric, num_to_instar)

message("Mean instar calculation completed.")

# Export the enriched dataset, including original measurements and instar assignments, to an Excel file
tryCatch({
  write.xlsx(input_data, file = output_excel_filename)
  message(paste("File successfully exported:", output_excel_filename))
}, error = function(e) {
  warning(paste("Error during export:", e$message))
})
