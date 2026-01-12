# Development Environment Setup Guide

This guide will help you set up the development environment for the Cloning UI application in RStudio on Windows 11.

## Prerequisites

### 1. Install R and RStudio

- Download and install R (version 4.3.2 or higher) from [CRAN](https://cran.r-project.org/)
- Download and install RStudio Desktop from [Posit](https://posit.co/download/rstudio-desktop/)

### 2. Google Cloud Platform (GCP) Setup

Before you begin, you need:
- A GCP project with BigQuery enabled
- A service account with appropriate permissions
- A service account key file (JSON format)

#### Creating a GCP Service Account:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **IAM & Admin** > **Service Accounts**
3. Click **Create Service Account**
4. Give it a name (e.g., "bigquery-reader")
5. Grant the following roles:
   - **BigQuery Data Viewer** (to read data)
   - **BigQuery Job User** (to run queries)
   - **BigQuery User** (optional, for broader access)
6. Click **Done**
7. Click on the created service account
8. Go to **Keys** tab > **Add Key** > **Create New Key**
9. Choose **JSON** format
10. Save the downloaded JSON file securely (e.g., `C:\Users\YourName\Documents\gcp-credentials\cloning-ui-key.json`)

**IMPORTANT:** Never commit this JSON file to version control!

## Project Setup in RStudio

### Step 1: Clone or Open the Project

1. Open RStudio
2. Go to **File** > **Open Project**
3. Navigate to the cloning-ui directory
4. Open `cloning-ui.Rproj`

### Step 2: Install renv and Restore Packages

When you first open the project, renv should automatically initialize. If not:

```r
# Install renv if not already installed
install.packages("renv")

# Restore project dependencies
renv::restore()
```

This will install all required packages:
- `shiny` - Web application framework
- `shinydashboard` - Dashboard UI components
- `bigrquery` - BigQuery interface
- `DBI` - Database interface
- `dplyr` - Data manipulation
- `tidyr` - Data tidying
- `DT` - Interactive data tables
- `plotly` - Interactive visualizations
- `lubridate` - Date/time handling
- `config` - Configuration management

**Note:** Package installation may take 10-30 minutes depending on your internet connection.

### Step 3: Configure Environment Variables

1. Copy `.Renviron.template` to `.Renviron`:
   ```r
   file.copy(".Renviron.template", ".Renviron")
   ```

2. Open `.Renviron` in RStudio (or any text editor)

3. Update the following values with your actual GCP information:
   ```
   GCP_PROJECT_ID=your-actual-project-id
   GCP_AUTH_FILE=C:/Users/YourName/Documents/gcp-credentials/cloning-ui-key.json
   BIGQUERY_DATASET=your-dataset-name
   BIGQUERY_BILLING_PROJECT=your-actual-project-id
   BIGQUERY_LOCATION=US
   ```

   **Windows Path Note:** Use forward slashes (`/`) or double backslashes (`\\`) in paths:
   - Good: `C:/Users/YourName/Documents/gcp-credentials/key.json`
   - Good: `C:\\Users\\YourName\\Documents\\gcp-credentials\\key.json`
   - Bad: `C:\Users\YourName\Documents\gcp-credentials\key.json`

4. **Restart RStudio** for the environment variables to take effect

### Step 4: Update Configuration

1. Open `config.yml` in RStudio

2. Verify the configuration settings. The file uses environment variables, so you typically don't need to change it unless you want to modify app settings like the title or debug mode.

### Step 5: Test BigQuery Connection

1. Run the test script to verify your setup:
   ```r
   source("test_bigquery_connection.R")
   ```

2. If successful, you should see output like:
   ```
   ========================================
   Testing BigQuery Connection
   ========================================
   
   1. Checking environment variables...
      Project ID: your-project-id
      Auth File: C:/path/to/your/key.json
      Dataset: your-dataset
   
   2. Authenticating with GCP...
      Authentication successful!
   
   3. Testing connection - listing datasets...
      Found X dataset(s) in project
   
   4. Testing query capability...
      Test query successful!
      Result: 1
   
   5. Testing DBI connection...
      DBI connection established!
   
   ========================================
   BigQuery Connection Test Complete!
   ========================================
   ```

### Step 6: Run the Application

1. Open `app.R` in RStudio

2. Click the **Run App** button in RStudio, or run:
   ```r
   shiny::runApp()
   ```

3. The application should open in your default web browser or RStudio Viewer

## Troubleshooting

### Issue: renv packages not installing

**Solution:**
```r
# Try installing packages manually
install.packages(c("shiny", "bigrquery", "DBI", "dplyr", "config", "DT", "shinydashboard", "plotly", "lubridate", "tidyr"))

# Then snapshot the environment
renv::snapshot()
```

### Issue: Authentication failed

**Possible causes:**
1. Service account key file path is incorrect
2. Service account doesn't have proper permissions
3. Path uses backslashes instead of forward slashes (Windows)

**Solution:**
- Verify the path to your JSON key file
- Check that the file exists and is readable
- Ensure you've restarted RStudio after modifying `.Renviron`
- Try using the full absolute path

### Issue: Can't connect to BigQuery

**Possible causes:**
1. GCP_PROJECT_ID is incorrect
2. Service account lacks BigQuery permissions
3. BigQuery API not enabled for project

**Solution:**
- Verify project ID in GCP Console
- Check service account roles in IAM
- Enable BigQuery API at: https://console.cloud.google.com/apis/library/bigquery.googleapis.com

### Issue: Dataset not found

**Possible causes:**
1. Dataset name is incorrect
2. Dataset is in a different project
3. Service account doesn't have access to the dataset

**Solution:**
- Verify dataset name in BigQuery Console
- Check dataset permissions
- Grant service account access to the dataset

### Issue: "Error in loadNamespace" or package loading errors

**Solution:**
```r
# Clear package cache and reinstall
renv::clean()
renv::restore()

# If that doesn't work, rebuild the library
renv::rebuild()
```

## Development Workflow

### Daily Workflow

1. Open `cloning-ui.Rproj` in RStudio
2. Make your code changes
3. Test with `shiny::runApp()`
4. Commit changes to version control

### Adding New Packages

```r
# Install the package
install.packages("packagename")

# Update the lockfile
renv::snapshot()
```

### Updating Existing Packages

```r
# Update a specific package
renv::update("packagename")

# Update all packages
renv::update()

# Save the new versions
renv::snapshot()
```

## Security Best Practices

1. **Never commit `.Renviron`** - It's already in `.gitignore`
2. **Never commit GCP service account keys** - Keep them outside the project directory
3. **Use environment-specific configurations** - Utilize the `config.yml` environments (development, production)
4. **Rotate service account keys regularly** - Every 90 days is recommended
5. **Use least privilege** - Only grant necessary BigQuery permissions

## Project Structure

```
cloning-ui/
├── .gitignore              # Git ignore file
├── .Rprofile               # R startup configuration
├── .Renviron.template      # Template for environment variables
├── .Renviron               # Your local environment variables (not committed)
├── cloning-ui.Rproj        # RStudio project file
├── config.yml              # Application configuration
├── renv.lock               # Package dependency lockfile
├── renv/                   # renv infrastructure
│   └── activate.R          # renv activation script
├── app.R                   # Main Shiny application
├── test_bigquery_connection.R  # Connection test script
├── SETUP.md               # This file
└── README.md              # Project overview
```

## Next Steps

1. Customize `app.R` with your specific BigQuery tables and queries
2. Add additional UI components as needed
3. Implement data visualizations with plotly
4. Add data filtering and search functionality
5. Deploy to Shiny Server or ShinyApps.io when ready

## Additional Resources

- [Shiny Documentation](https://shiny.rstudio.com/)
- [bigrquery Package](https://bigrquery.r-dbi.org/)
- [renv Documentation](https://rstudio.github.io/renv/)
- [Google Cloud BigQuery](https://cloud.google.com/bigquery/docs)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review BigQuery and Shiny documentation
3. Contact the development team

---

**Last Updated:** January 2026
