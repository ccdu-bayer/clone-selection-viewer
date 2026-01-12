# Test BigQuery Connection Script
# This script tests the connection to Google Cloud Platform BigQuery
# Run this script after setting up your .Renviron file with GCP credentials

# Load required libraries
library(bigrquery)
library(DBI)
library(config)

# Load configuration
cfg <- config::get()

cat("========================================\n")
cat("Testing BigQuery Connection\n")
cat("========================================\n\n")

# Check environment variables
cat("1. Checking environment variables...\n")
gcp_project <- Sys.getenv("GCP_PROJECT_ID")
gcp_auth_file <- Sys.getenv("GCP_AUTH_FILE")
bigquery_dataset <- Sys.getenv("BIGQUERY_DATASET")

if (gcp_project == "" || gcp_auth_file == "") {
  stop("ERROR: Environment variables not set. Please check your .Renviron file.")
}

cat("   Project ID:", gcp_project, "\n")
cat("   Auth File:", gcp_auth_file, "\n")
cat("   Dataset:", bigquery_dataset, "\n\n")

# Authenticate with GCP
cat("2. Authenticating with GCP...\n")
tryCatch({
  bq_auth(path = gcp_auth_file)
  cat("   Authentication successful!\n\n")
}, error = function(e) {
  stop("ERROR: Authentication failed. Check your service account key file.\n", e$message)
})

# Test connection by listing datasets
cat("3. Testing connection - listing datasets...\n")
tryCatch({
  datasets <- bq_project_datasets(gcp_project)
  cat("   Found", length(datasets), "dataset(s) in project\n")
  
  if (length(datasets) > 0) {
    cat("   Datasets:\n")
    for (ds in datasets) {
      cat("   -", ds$dataset, "\n")
    }
  }
  cat("\n")
}, error = function(e) {
  warning("WARNING: Could not list datasets. This may be a permissions issue.\n", e$message, "\n\n")
})

# Test querying capability
cat("4. Testing query capability...\n")
tryCatch({
  # Simple test query
  sql <- "SELECT 1 as test_value"
  
  result <- bq_project_query(
    x = gcp_project,
    query = sql
  )
  
  df <- bq_table_download(result)
  
  cat("   Test query successful!\n")
  cat("   Result:", df$test_value, "\n\n")
}, error = function(e) {
  stop("ERROR: Query test failed.\n", e$message)
})

# Test DBI connection
cat("5. Testing DBI connection...\n")
tryCatch({
  con <- dbConnect(
    bigrquery::bigquery(),
    project = gcp_project,
    dataset = bigquery_dataset,
    billing = gcp_project
  )
  
  cat("   DBI connection established!\n")
  
  # List tables if dataset exists
  if (bigquery_dataset != "") {
    tables <- dbListTables(con)
    cat("   Found", length(tables), "table(s) in dataset '", bigquery_dataset, "'\n")
    if (length(tables) > 0) {
      cat("   Tables:\n")
      for (tbl in head(tables, 10)) {
        cat("   -", tbl, "\n")
      }
    }
  }
  
  dbDisconnect(con)
  cat("\n")
}, error = function(e) {
  warning("WARNING: DBI connection test failed.\n", e$message, "\n\n")
})

cat("========================================\n")
cat("BigQuery Connection Test Complete!\n")
cat("========================================\n")
cat("\nYou are ready to develop the cloning data UI!\n")
