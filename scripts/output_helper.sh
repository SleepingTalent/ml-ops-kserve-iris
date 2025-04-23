#!/bin/bash

# Define color codes
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No color

print_header() {
    echo -e "${BLUE}===================$1===================${NC}"
}

# Function to print information messages (blue)
print_info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Function to print warning messages (yellow)
print_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Function to print error messages (red)
print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}
