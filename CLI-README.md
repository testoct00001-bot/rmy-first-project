# JavaScript URL Extractor CLI Tool

A standalone Node.js CLI tool that fetches HTML content from eero.com and extracts all JavaScript file URLs.

## Features

- Fetches HTML content from eero.com using Node.js HTTPS module
- Parses HTML and extracts JavaScript URLs from `<script src="...">` tags
- Handles both absolute and relative URLs (converts relative to absolute)
- Counts inline script blocks
- Outputs clean, formatted results with unique URLs sorted alphabetically

## Usage

### Direct execution with Node.js:
```bash
node extract-js-urls.mjs
```

### Or make it executable and run directly:
```bash
chmod +x extract-js-urls.mjs
./extract-js-urls.mjs
```

### Using npm script:
```bash
npm run extract-js
```

## Output

The tool outputs:
1. A numbered list of all external JavaScript file URLs found on the page
2. A summary showing:
   - Total count of external JavaScript files
   - Total count of inline script blocks

## Example Output

```
Fetching HTML from https://eero.com...
Parsing HTML and extracting JavaScript URLs...

================================================================================
EXTERNAL JAVASCRIPT FILES
================================================================================
1. https://assets.prod.eero.com/2026.1.23/_next/static/chunks/10875-0014ab45819d0a57.js
2. https://assets.prod.eero.com/2026.1.23/_next/static/chunks/12299-22c654ae7d3919b1.js
...

================================================================================
SUMMARY
================================================================================
Total external JavaScript files: 46
Total inline script blocks: 46
================================================================================
```

## Implementation Details

- Uses Node.js built-in `https` module (no external dependencies required)
- Regex-based HTML parsing for extracting script tags
- URL resolution using Node.js `URL` API
- Includes User-Agent header to avoid potential blocking
- Deduplicates URLs using a Set
- Sorts output alphabetically for easy reading
