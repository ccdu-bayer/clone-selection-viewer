FROM rocker/shiny:4.3.2

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'DT', 'ggplot2', 'dplyr', 'bigrquery'), repos='https://cran.r-project.org/')"

# Create app directory
RUN mkdir -p /srv/shiny-server/cloning-ui

# Copy application files
COPY app.R /srv/shiny-server/cloning-ui/
COPY config.example.R /srv/shiny-server/cloning-ui/

# Set working directory
WORKDIR /srv/shiny-server/cloning-ui

# Expose port
EXPOSE 3838

# Run the application
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/cloning-ui', host='0.0.0.0', port=3838)"]
