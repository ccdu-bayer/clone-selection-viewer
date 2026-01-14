# Cloning UI

R-based Shiny application to display nominated cloning data from Google Cloud BigQuery.

## Quick Start

### Prerequisites
- R (>= 4.5.1)
- RStudio Desktop
- Google Cloud Platform account with BigQuery access
- GCP service account key file (JSON)

### Setup

1. **Open the project in RStudio**
   - Open `cloning-ui.Rproj` in RStudio

2. **Install dependencies**
   ```r
   renv::restore()
   ```

3. **Configure GCP credentials**
   - Copy `.Renviron.template` to `.Renviron`
   - Update with your GCP project details and service account key path
   - Restart RStudio

4. **Test connection**
   ```r
   source("test_bigquery_connection.R")
   ```

5. **Run the app**
   ```r
   shiny::runApp()
   ```

## Documentation

See [SETUP.md](SETUP.md) for detailed setup instructions, including:
- Windows 11 RStudio environment configuration
- GCP service account creation
- BigQuery connection setup
- Troubleshooting guide

## Project Structure

- `app.R` - Main Shiny application
- `config.yml` - Application configuration
- `renv.lock` - R package dependencies
- `.Renviron.template` - Environment variable template
- `test_bigquery_connection.R` - Connection testing script

## Features

- Interactive dashboard for cloning data visualization
- Direct connection to Google BigQuery
- Configurable environments (development, production)
- Secure credential management
- Reproducible package management with renv

## Technology Stack

- **R 4.3.2+** - Programming language
- **Shiny** - Web application framework
- **shinydashboard** - Dashboard components
- **bigrquery** - BigQuery interface
- **DT** - Interactive tables
- **plotly** - Interactive visualizations
- **renv** - Dependency management

## License

[Add your license here]
