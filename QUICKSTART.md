# Quick Start Guide

This guide will help you get the Cloning UI dashboard up and running quickly.

## Step 1: Install R and Required Packages

### Install R
- Download and install R from [CRAN](https://cran.r-project.org/)
- Recommended version: R 4.0 or higher

### Install Required Packages
Run the installation script:
```bash
Rscript install.R
```

Or manually install packages in R:
```r
install.packages(c("shiny", "shinydashboard", "DT", "ggplot2", "dplyr", "bigrquery"))
```

## Step 2: Set Up GCP Credentials

### Option A: Using config.R (Recommended for Development)
1. Copy the example configuration:
   ```bash
   cp config.example.R config.R
   ```

2. Edit `config.R` with your details:
   ```r
   GCP_PROJECT_ID <- "your-project-id"
   BQ_DATASET <- "your-dataset"
   BQ_TABLE <- "your-table"
   GCP_KEY_PATH <- "path/to/your-key.json"
   ```

### Option B: Using Environment Variables (Recommended for Production)
```bash
export GCP_PROJECT_ID="your-project-id"
export BQ_DATASET="your-dataset"
export BQ_TABLE="your-table"
export GCP_KEY_PATH="/path/to/your-key.json"
```

### Get Your GCP Service Account Key
1. Go to [GCP Console](https://console.cloud.google.com/)
2. Navigate to IAM & Admin → Service Accounts
3. Create a service account or select an existing one
4. Add roles: "BigQuery Data Viewer" and "BigQuery Job User"
5. Click "Add Key" → "Create new key" → "JSON"
6. Save the downloaded JSON file securely

## Step 3: Run the Application

### From RStudio
1. Open `app.R` in RStudio
2. Click the "Run App" button

### From R Console
```r
shiny::runApp()
```

### From Command Line
```bash
Rscript -e "shiny::runApp()"
```

The dashboard will open in your default browser at `http://127.0.0.1:XXXX`

## Step 4: Explore the Dashboard

The dashboard has four main sections:

1. **Dashboard** - Overview with key metrics and visualizations
2. **Data Table** - Browse and filter your data
3. **Statistics** - Detailed data summary
4. **About** - Information about the dashboard

Use the **Refresh Data** button to reload data from BigQuery.

## Demo Mode

If you want to test the UI without BigQuery access, simply run the app without configuring credentials. It will automatically use sample data.

## Troubleshooting

### Package Installation Issues
If a package fails to install, try:
```r
install.packages("package_name", dependencies = TRUE)
```

### Authentication Errors
- Verify your service account JSON key path is correct
- Ensure the service account has BigQuery permissions
- Check that your GCP project has billing enabled

### Connection Issues
- Verify your dataset and table names are correct
- Test your BigQuery access in the GCP Console
- Check your network firewall settings

## Next Steps

- Customize the dashboard by editing `app.R`
- Modify the SQL query to fetch specific data
- Add new visualizations and metrics
- Deploy to shinyapps.io or Shiny Server for sharing

## Support

For issues and questions, please refer to the main README.md file.
