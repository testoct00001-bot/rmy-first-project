This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.

## JavaScript File Extraction Script

This repository includes a bash script (`find-js-files.sh`) that fetches HTML from eero.com and extracts all JavaScript file URLs.

### Features

- Uses `curl` to fetch HTML content from eero.com
- Parses `<script>` tags with `src` attributes
- Extracts JavaScript files from `<link rel="preload" as="script">` tags
- Extracts JavaScript files from `<link rel="modulepreload">` tags
- Converts relative URLs to absolute URLs automatically
- Removes duplicate entries
- Provides colored output and error handling

### Usage

Run the script from the terminal:

```bash
# Make the script executable (already done)
chmod +x find-js-files.sh

# Run the script
./find-js-files.sh

# Or run with bash directly
bash find-js-files.sh
```

### Output

The script will:
1. Fetch the HTML from https://eero.com
2. Extract all JavaScript file references
3. Output each unique JavaScript file URL on a separate line
4. Display the total count of JavaScript files found

### Requirements

- `bash` shell
- `curl` command-line tool
- Standard Unix utilities: `grep`, `sort`, `mktemp`

These tools are typically pre-installed on macOS and Linux systems.
