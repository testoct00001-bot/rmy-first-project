#!/bin/bash

# Script to fetch eero.com HTML and extract all JavaScript file URLs
# Usage: ./find-js-files.sh or bash find-js-files.sh

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Target URL
URL="https://eero.com"

echo -e "${GREEN}Fetching HTML from ${URL}...${NC}"

# Fetch the HTML content using curl
# -s: silent mode
# -L: follow redirects
# -f: fail silently on HTTP errors
# --max-time 30: timeout after 30 seconds
HTML=$(curl -s -L -f --max-time 30 "$URL") || {
    echo -e "${RED}Error: Failed to fetch HTML from ${URL}${NC}" >&2
    exit 1
}

echo -e "${GREEN}Parsing JavaScript file references...${NC}"
echo ""

# Temporary file to store unique URLs
TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" EXIT

# Extract external JavaScript file URLs from <script src="..."> tags
echo "$HTML" | grep -oP '<script[^>]*\ssrc=["'\'']\K[^"'\'']+(?=["'\''])' >> "$TEMP_FILE" 2>/dev/null || true

# Extract JavaScript files referenced in <link rel="preload" as="script"> tags
echo "$HTML" | grep -oP '<link[^>]*\sas=["'\'']script["'\''][^>]*\shref=["'\'']\K[^"'\'']+(?=["'\''])' >> "$TEMP_FILE" 2>/dev/null || true
echo "$HTML" | grep -oP '<link[^>]*\shref=["'\'']\K[^"'\'']+(?=["'\''][^>]*\sas=["'\'']script["'\''])' >> "$TEMP_FILE" 2>/dev/null || true

# Extract JavaScript files referenced in <link rel="modulepreload"> tags
echo "$HTML" | grep -oP '<link[^>]*\srel=["'\'']modulepreload["'\''][^>]*\shref=["'\'']\K[^"'\'']+(?=["'\''])' >> "$TEMP_FILE" 2>/dev/null || true
echo "$HTML" | grep -oP '<link[^>]*\shref=["'\'']\K[^"'\'']+(?=["'\''][^>]*\srel=["'\'']modulepreload["'\''])' >> "$TEMP_FILE" 2>/dev/null || true

# Process the URLs: convert relative URLs to absolute and remove duplicates
sort -u "$TEMP_FILE" | while IFS= read -r url; do
    # Skip empty lines
    [ -z "$url" ] && continue
    
    # Convert relative URLs to absolute URLs
    if [[ "$url" =~ ^https?:// ]]; then
        # Already an absolute URL
        echo "$url"
    elif [[ "$url" =~ ^// ]]; then
        # Protocol-relative URL
        echo "https:$url"
    elif [[ "$url" =~ ^/ ]]; then
        # Absolute path
        echo "${URL}${url}"
    else
        # Relative path
        echo "${URL}/${url}"
    fi
done | sort -u

# Count the number of JavaScript files found
COUNT=$(sort -u "$TEMP_FILE" | wc -l)
echo ""
echo -e "${YELLOW}Total JavaScript files found: ${COUNT}${NC}"
