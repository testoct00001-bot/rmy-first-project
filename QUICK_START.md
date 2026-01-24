# Subdomain Scanner - Quick Start Guide

## Quick Run

```bash
# Make the script executable (first time only)
chmod +x subdomain_scanner.sh

# Run the scanner
./subdomain_scanner.sh
```

## What Happens

1. ✅ Checks if Go is installed, installs it if needed
2. ✅ Checks if subfinder is installed, installs it if needed
3. ✅ Checks if httpx is installed, installs it if needed
4. ✅ Runs subfinder to find all subdomains of uber.com
5. ✅ Removes duplicates and saves to a file
6. ✅ Runs httpx to check which subdomains are live (HTTP/HTTPS)
7. ✅ Saves live subdomains with status codes
8. ✅ Generates a comprehensive summary report

## Output Files

All results are saved in `subdomain_scan_results/` directory:

- `uber.com_all_subdomains_TIMESTAMP.txt` - All discovered subdomains
- `uber.com_live_subdomains_TIMESTAMP.txt` - Live subdomains with status codes
- `uber.com_summary_TIMESTAMP.txt` - Detailed summary report

## Change Target Domain

Edit the script and change this line:

```bash
TARGET_DOMAIN="uber.com"  # Change to your target
```

## Requirements

- Linux or macOS
- Internet connection
- Sudo access (for Go installation on Linux)
- About 5-10 minutes for installation (first run only)

## Notes

- First run will install Go, subfinder, and httpx (takes a few minutes)
- Subsequent runs are much faster
- The script handles errors and provides clear feedback
- All output is color-coded for easy reading

## Troubleshooting

**Script won't run?**
```bash
chmod +x subdomain_scanner.sh
```

**Tools not found after installation?**
```bash
export PATH=$PATH:$(go env GOPATH)/bin
```

**Need to cancel?**
Press `Ctrl+C` at any time

---

For detailed documentation, see `SUBDOMAIN_SCANNER_README.md`
