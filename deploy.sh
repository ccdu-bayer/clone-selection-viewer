#!/bin/bash

# Deployment script for Cloning UI RShiny Dashboard
# This script helps deploy the application to various environments

set -e

echo "========================================="
echo "Cloning UI - Deployment Script"
echo "========================================="
echo ""

# Check if R is installed
if ! command -v R &> /dev/null; then
    echo "Error: R is not installed. Please install R first."
    exit 1
fi

echo "✓ R is installed"

# Check if required environment variables are set
if [ -z "$GCP_PROJECT_ID" ]; then
    echo "Warning: GCP_PROJECT_ID environment variable is not set"
    echo "The app will run in demo mode"
fi

# Install required packages
echo ""
echo "Installing required R packages..."
Rscript install.R

# Check if config.R exists
if [ ! -f "config.R" ] && [ -f "config.example.R" ]; then
    echo ""
    echo "Notice: config.R not found"
    echo "Please create config.R from config.example.R or set environment variables"
fi

echo ""
echo "========================================="
echo "Deployment Complete"
echo "========================================="
echo ""
echo "To run the application:"
echo "  Rscript -e \"shiny::runApp(port=3838, host='0.0.0.0')\""
echo ""
echo "Or for development:"
echo "  Rscript -e \"shiny::runApp()\""
echo ""
