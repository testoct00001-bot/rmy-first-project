# Subdomain Scanner Script

A comprehensive bash script for subdomain enumeration and live HTTP/HTTPS checking.

## Features

- **Automatic Installation**: Automatically installs required tools (Go, subfinder, httpx)
- **Subdomain Enumeration**: Uses `subfinder` to discover all subdomains of a target domain
- **Live Checking**: Uses `httpx` to probe HTTP/HTTPS services on discovered subdomains
- **Deduplication**: Automatically filters and removes duplicate subdomains
- **Status Code Detection**: Identifies live subdomains by checking HTTP response codes (200, 301, 302, etc.)
- **Organized Output**: Saves results to timestamped files with:
  - All discovered subdomains
  - Live subdomains with status codes and page titles
  - Comprehensive summary report
- **Error Handling**: Includes proper error handling and progress indicators
- **Colored Output**: Clean, color-coded terminal output for easy reading

## Prerequisites

- Linux or macOS operating system
- Internet connection
- Sudo access (for installing Go on Linux)
- `wget` (for Go installation on Linux)

## Installation

The script is self-contained and will automatically install all required dependencies. Simply make the script executable:

```bash
chmod +x subdomain_scanner.sh
```

## Usage

Run the script from your terminal:

```bash
./subdomain_scanner.sh
```

## Output Files

The script creates a `subdomain_scan_results` directory with the following files:

1. **uber.com_all_subdomains_TIMESTAMP.txt** - List of all discovered subdomains
2. **uber.com_live_subdomains_TIMESTAMP.txt** - Live subdomains with status codes and titles
3. **uber.com_summary_TIMESTAMP.txt** - Comprehensive summary report with statistics

Example output filenames:
- `subdomain_scan_results/uber.com_all_subdomains_20240124_153045.txt`
- `subdomain_scan_results/uber.com_live_subdomains_20240124_153045.txt`
- `subdomain_scan_results/uber.com_summary_20240124_153045.txt`

## Script Configuration

You can modify the following variables in the script to change the target domain:

```bash
TARGET_DOMAIN="uber.com"  # Change this to your target domain
```

## Tools Used

- **subfinder**: Fast subdomain enumeration tool
  - GitHub: https://github.com/projectdiscovery/subfinder
  
- **httpx**: HTTP/HTTPS probing tool
  - GitHub: https://github.com/projectdiscovery/httpx

## Output Format

### All Subdomains File
Plain text list of unique subdomains:
```
api.uber.com
auth.uber.com
blog.uber.com
...
```

### Live Subdomains File
Live subdomains with status codes and titles:
```
https://api.uber.com [200] API Platform
https://auth.uber.com [301] Moved Permanently
https://blog.uber.com [200] Uber Blog
...
```

### Summary File
Comprehensive report including:
- Scan timestamp and duration
- Total subdomains discovered
- Live subdomains count and success rate
- Status code distribution
- Sample results
- Tool version information

## Example Output

```
================================================================================
                    SUBDOMAIN ENUMERATION SUMMARY REPORT
================================================================================

Target Domain: uber.com
Scan Date: Thu Jan 24 15:30:45 UTC 2024

--------------------------------------------------------------------------------
RESULTS OVERVIEW
--------------------------------------------------------------------------------

Total Unique Subdomains Discovered: 847
Total Live Subdomains (HTTP/HTTPS): 312
Success Rate: 36.83%

--------------------------------------------------------------------------------
STATUS CODE DISTRIBUTION
--------------------------------------------------------------------------------

    212 [200]
     75 [301]
     18 [302]
      5 [403]
      2 [404]

--------------------------------------------------------------------------------
```

## Customization

### Change Target Domain

Edit the script and modify the `TARGET_DOMAIN` variable:

```bash
TARGET_DOMAIN="example.com"
```

### Adjust httpx Parameters

Modify the `httpx` command in the `check_live_subdomains` function:

```bash
httpx -l "${ALL_SUBDOMAINS_FILE}" \
    -silent \
    -sc \
    -title \
    -status-code \
    -threads 100 \      # Increase threads for faster scanning
    -timeout 5 \        # Reduce timeout for faster scanning
    -retries 1          # Reduce retries for faster scanning
```

### Filter by Status Codes

To only save specific status codes (e.g., only 200 responses):

```bash
httpx -l "${ALL_SUBDOMAINS_FILE}" \
    -silent \
    -sc \
    -mc 200 \           # Only save 200 status codes
    -threads 50 \
    -timeout 10
```

## Troubleshooting

### Go Installation Fails

If the automatic Go installation fails, install Go manually:
- Linux: https://go.dev/doc/install
- macOS: `brew install go`

### Permission Denied Error

Make sure the script is executable:
```bash
chmod +x subdomain_scanner.sh
```

### subfinder/httpx Not Found After Installation

Add Go binaries to your PATH:
```bash
export PATH=$PATH:$(go env GOPATH)/bin
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc
```

### No Subdomains Found

- Check your internet connection
- Verify the target domain is correct
- Some domains may have very few subdomains

### No Live Subdomains Found

- Check if subdomains were discovered
- Verify network connectivity
- Some subdomains may only respond to specific ports or protocols

## Security Considerations

- Always obtain proper authorization before scanning domains you don't own
- Respect rate limits and avoid overloading target servers
- This script is intended for authorized security testing and reconnaissance

## License

This script is provided as-is for educational and authorized security testing purposes.

## Contributing

Feel free to modify and improve the script for your specific needs.
