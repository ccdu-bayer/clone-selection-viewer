# Quick Start Guide for Windows 11

This is a streamlined guide to get you up and running quickly. For detailed information, see [SETUP.md](SETUP.md).

## 5-Minute Setup

### 1. Prerequisites
- [ ] R installed (4.3.2+)
- [ ] RStudio Desktop installed
- [ ] GCP service account JSON key file downloaded

### 2. Open Project
1. Double-click `cloning-ui.Rproj` to open in RStudio

### 3. Install Packages (first time only)
Run in R console:
```r
renv::restore()
```
⏱️ This takes ~15-30 minutes

### 4. Configure GCP
1. Copy `.Renviron.template` to `.Renviron`
2. Edit `.Renviron` with your values:
   ```
   GCP_PROJECT_ID=your-project-id
   GCP_AUTH_FILE=C:/path/to/your/service-account-key.json
   BIGQUERY_DATASET=your-dataset-name
   BIGQUERY_BILLING_PROJECT=your-project-id
   ```
3. **Restart RStudio** (File > Quit Session)

### 5. Test Connection
```r
source("test_bigquery_connection.R")
```

### 6. Run App
Click **Run App** button in RStudio, or:
```r
shiny::runApp()
```

## Common Issues

### "Object not found" errors
→ Restart RStudio after editing `.Renviron`

### "Authentication failed"
→ Check your JSON key file path uses forward slashes: `C:/Users/...`

### "Package installation failed"
→ Try: `install.packages("renv")` then `renv::restore()`

## What Was Set Up

✅ RStudio project configuration  
✅ Package dependency management (renv)  
✅ 11 essential R packages for data & visualization  
✅ GCP BigQuery connection setup  
✅ Sample Shiny dashboard app  
✅ Connection testing script  
✅ Comprehensive documentation  

## Files You Need to Know

- **app.R** - Main application (customize this)
- **.Renviron** - Your local credentials (YOU create this)
- **config.yml** - App configuration
- **SETUP.md** - Detailed setup guide

## Next Steps

1. Customize `app.R` with your BigQuery tables
2. Update the SQL queries for your data
3. Add visualizations and features
4. Deploy when ready

Need help? See [SETUP.md](SETUP.md) for detailed troubleshooting.
