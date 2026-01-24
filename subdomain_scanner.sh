#!/bin/bash

# Subdomain Scanner Script
# Enumerates subdomains and checks for live HTTP/HTTPS services
# Target: uber.com

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TARGET_DOMAIN="uber.com"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="subdomain_scan_results"
ALL_SUBDOMAINS_FILE="${OUTPUT_DIR}/${TARGET_DOMAIN}_all_subdomains_${TIMESTAMP}.txt"
LIVE_SUBDOMAINS_FILE="${OUTPUT_DIR}/${TARGET_DOMAIN}_live_subdomains_${TIMESTAMP}.txt"
SUMMARY_FILE="${OUTPUT_DIR}/${TARGET_DOMAIN}_summary_${TIMESTAMP}.txt"

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo ""
    echo -e "${GREEN}==>${NC} $1"
    echo "================================"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Go (required for subfinder and httpx)
install_go() {
    print_step "Installing Go (required for subfinder and httpx)"
    
    if command_exists go; then
        print_success "Go is already installed: $(go version)"
        return 0
    fi
    
    print_info "Installing Go..."
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        GO_VERSION="1.21.5"
        wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go.tar.gz
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
        
        # Add Go to PATH
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        export PATH=$PATH:/usr/local/go/bin
        
        print_success "Go installed successfully"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command_exists brew; then
            brew install go
            print_success "Go installed via Homebrew"
        else
            print_error "Homebrew not found. Please install Go manually: https://go.dev/doc/install"
            exit 1
        fi
    else
        print_error "Unsupported OS. Please install Go manually: https://go.dev/doc/install"
        exit 1
    fi
}

# Function to install subfinder
install_subfinder() {
    if command_exists subfinder; then
        print_success "subfinder is already installed: $(subfinder -version 2>&1 | head -1)"
        return 0
    fi
    
    print_step "Installing subfinder"
    print_info "subfinder not found. Installing..."
    
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    
    # Add Go binaries to PATH if not already there
    if ! command_exists subfinder; then
        export PATH=$PATH:$(go env GOPATH)/bin
        echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc
    fi
    
    print_success "subfinder installed successfully"
}

# Function to install httpx
install_httpx() {
    if command_exists httpx; then
        print_success "httpx is already installed: $(httpx -version 2>&1 | head -1)"
        return 0
    fi
    
    print_step "Installing httpx"
    print_info "httpx not found. Installing..."
    
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
    
    # Add Go binaries to PATH if not already there
    if ! command_exists httpx; then
        export PATH=$PATH:$(go env GOPATH)/bin
    fi
    
    print_success "httpx installed successfully"
}

# Function to enumerate subdomains
enumerate_subdomains() {
    print_step "Enumerating subdomains for ${TARGET_DOMAIN}"
    print_info "Running subfinder..."
    
    # Run subfinder and save raw output
    subfinder -d "${TARGET_DOMAIN}" -silent | sort -u > "${ALL_SUBDOMAINS_FILE}"
    
    # Count subdomains
    TOTAL_SUBDOMAINS=$(wc -l < "${ALL_SUBDOMAINS_FILE}")
    
    print_success "Found ${TOTAL_SUBDOMAINS} unique subdomains"
    print_info "Saved to: ${ALL_SUBDOMAINS_FILE}"
    
    # Display first few subdomains
    echo ""
    print_info "Sample of discovered subdomains:"
    head -10 "${ALL_SUBDOMAINS_FILE}" | while read -r subdomain; do
        echo "  - ${subdomain}"
    done
    
    if [ "${TOTAL_SUBDOMAINS}" -gt 10 ]; then
        echo "  ... and $((TOTAL_SUBDOMAINS - 10)) more"
    fi
}

# Function to check for live subdomains
check_live_subdomains() {
    print_step "Checking for live subdomains (HTTP/HTTPS)"
    print_info "Running httpx to probe discovered subdomains..."
    print_info "This may take a while depending on the number of subdomains..."
    
    # Run httpx with various flags
    # -silent: Only show URLs
    # -sc: Show status codes
    # -title: Show page titles
    # -status-code: Filter by status codes
    # -threads: Use multiple threads for speed
    httpx -l "${ALL_SUBDOMAINS_FILE}" \
        -silent \
        -sc \
        -title \
        -status-code \
        -threads 50 \
        -timeout 10 \
        -retries 2 \
        > "${LIVE_SUBDOMAINS_FILE}" 2>&1
    
    # Count live subdomains
    if [ -s "${LIVE_SUBDOMAINS_FILE}" ]; then
        LIVE_SUBDOMAINS=$(wc -l < "${LIVE_SUBDOMAINS_FILE}")
        print_success "Found ${LIVE_SUBDOMAINS} live subdomains"
        print_info "Saved to: ${LIVE_SUBDOMAINS_FILE}"
    else
        print_warning "No live subdomains found or httpx encountered an error"
        LIVE_SUBDOMAINS=0
    fi
    
    # Display first few live subdomains
    if [ "${LIVE_SUBDOMAINS}" -gt 0 ]; then
        echo ""
        print_info "Sample of live subdomains:"
        head -10 "${LIVE_SUBDOMAINS_FILE}" | while read -r line; do
            echo "  ${line}"
        done
        
        if [ "${LIVE_SUBDOMAINS}" -gt 10 ]; then
            echo "  ... and $((LIVE_SUBDOMAINS - 10)) more"
        fi
    fi
}

# Function to generate summary report
generate_summary() {
    print_step "Generating summary report"
    
    # Count subdomains by status code
    if [ "${LIVE_SUBDOMAINS}" -gt 0 ]; then
        STATUS_CODES=$(grep -oP '\[\K[0-9]+' "${LIVE_SUBDOMAINS_FILE}" | sort | uniq -c | sort -rn)
    else
        STATUS_CODES="None"
    fi
    
    # Create summary file
    cat > "${SUMMARY_FILE}" <<EOF
================================================================================
                    SUBDOMAIN ENUMERATION SUMMARY REPORT
================================================================================

Target Domain: ${TARGET_DOMAIN}
Scan Date: $(date)
Scan Duration: Started at $(date -d "${START_TIME}" +"%Y-%m-%d %H:%M:%S")

--------------------------------------------------------------------------------
RESULTS OVERVIEW
--------------------------------------------------------------------------------

Total Unique Subdomains Discovered: ${TOTAL_SUBDOMAINS}
Total Live Subdomains (HTTP/HTTPS): ${LIVE_SUBDOMAINS}
Success Rate: $(awk "BEGIN {printf \"%.2f\", (${LIVE_SUBDOMAINS}/${TOTAL_SUBDOMAINS})*100}")%

Output Files:
  - All Subdomains: ${ALL_SUBDOMAINS_FILE}
  - Live Subdomains: ${LIVE_SUBDOMAINS_FILE}
  - This Summary: ${SUMMARY_FILE}

--------------------------------------------------------------------------------
STATUS CODE DISTRIBUTION
--------------------------------------------------------------------------------

${STATUS_CODES}

--------------------------------------------------------------------------------
TOOLS USED
--------------------------------------------------------------------------------

- subfinder: $(subfinder -version 2>&1 | head -1 || echo "version info unavailable")
- httpx: $(httpx -version 2>&1 | head -1 || echo "version info unavailable")

--------------------------------------------------------------------------------
SAMPLE OF ALL DISCOVERED SUBDOMAINS
--------------------------------------------------------------------------------

$(head -20 "${ALL_SUBDOMAINS_FILE}" | sed 's/^/  /')

$(if [ "${TOTAL_SUBDOMAINS}" -gt 20 ]; then echo "  ... and $((TOTAL_SUBDOMAINS - 20)) more subdomains"; fi)

--------------------------------------------------------------------------------
SAMPLE OF LIVE SUBDOMAINS (HTTP/HTTPS)
--------------------------------------------------------------------------------

$(head -20 "${LIVE_SUBDOMAINS_FILE}" | sed 's/^/  /')

$(if [ "${LIVE_SUBDOMAINS}" -gt 20 ]; then echo "  ... and $((LIVE_SUBDOMAINS - 20)) more live subdomains"; fi)

================================================================================
                            END OF REPORT
================================================================================
EOF
    
    print_success "Summary report generated: ${SUMMARY_FILE}"
}

# Function to display final summary
display_final_summary() {
    echo ""
    echo "================================================================================"
    echo "                          SCAN COMPLETE"
    echo "================================================================================"
    echo ""
    echo "Target: ${TARGET_DOMAIN}"
    echo "Total Subdomains Found: ${TOTAL_SUBDOMAINS}"
    echo "Live Subdomains: ${LIVE_SUBDOMAINS}"
    echo ""
    echo "Output Files:"
    echo "  1. All Subdomains:     ${ALL_SUBDOMAINS_FILE}"
    echo "  2. Live Subdomains:    ${LIVE_SUBDOMAINS_FILE}"
    echo "  3. Summary Report:     ${SUMMARY_FILE}"
    echo ""
    echo "================================================================================"
    echo ""
    print_success "Scan completed successfully!"
}

# Main execution
main() {
    echo ""
    echo "================================================================================"
    echo "                    SUBDOMAIN ENUMERATION & LIVE CHECK"
    echo "================================================================================"
    echo ""
    
    START_TIME=$(date)
    
    # Check and install dependencies
    install_go
    install_subfinder
    install_httpx
    
    # Ensure PATH includes Go binaries
    export PATH=$PATH:$(go env GOPATH)/bin
    
    # Run enumeration and checks
    enumerate_subdomains
    check_live_subdomains
    generate_summary
    display_final_summary
}

# Handle script interruption
trap 'print_error "Script interrupted by user"; exit 1' INT

# Run main function
main "$@"
