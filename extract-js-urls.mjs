#!/usr/bin/env node

import https from 'https';
import { URL } from 'url';

const TARGET_URL = 'https://eero.com';

function fetchHTML(url) {
  return new Promise((resolve, reject) => {
    https.get(url, { 
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      }
    }, (res) => {
      if (res.statusCode !== 200) {
        reject(new Error(`Failed to fetch ${url}: ${res.statusCode}`));
        return;
      }

      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        resolve(data);
      });
    }).on('error', (err) => {
      reject(err);
    });
  });
}

function extractJavaScriptURLs(html, baseUrl) {
  const jsUrls = new Set();
  
  const scriptSrcRegex = /<script[^>]+src=["']([^"']+)["']/gi;
  let match;
  
  while ((match = scriptSrcRegex.exec(html)) !== null) {
    const url = match[1];
    const absoluteUrl = resolveUrl(url, baseUrl);
    if (absoluteUrl) {
      jsUrls.add(absoluteUrl);
    }
  }

  const inlineScriptRegex = /<script[^>]*>([\s\S]*?)<\/script>/gi;
  let inlineCount = 0;
  while ((match = inlineScriptRegex.exec(html)) !== null) {
    const scriptTag = match[0];
    if (!scriptTag.includes('src=')) {
      inlineCount++;
    }
  }

  return {
    externalUrls: Array.from(jsUrls).sort(),
    inlineScriptCount: inlineCount
  };
}

function resolveUrl(url, baseUrl) {
  try {
    if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('//')) {
      if (url.startsWith('//')) {
        return 'https:' + url;
      }
      return url;
    }
    
    const base = new URL(baseUrl);
    const resolved = new URL(url, base);
    return resolved.href;
  } catch (e) {
    console.error(`Error resolving URL: ${url}`, e.message);
    return null;
  }
}

async function main() {
  try {
    console.log(`Fetching HTML from ${TARGET_URL}...`);
    const html = await fetchHTML(TARGET_URL);
    
    console.log('Parsing HTML and extracting JavaScript URLs...\n');
    const { externalUrls, inlineScriptCount } = extractJavaScriptURLs(html, TARGET_URL);
    
    console.log('='.repeat(80));
    console.log('EXTERNAL JAVASCRIPT FILES');
    console.log('='.repeat(80));
    
    if (externalUrls.length === 0) {
      console.log('No external JavaScript files found.');
    } else {
      externalUrls.forEach((url, index) => {
        console.log(`${index + 1}. ${url}`);
      });
    }
    
    console.log('\n' + '='.repeat(80));
    console.log('SUMMARY');
    console.log('='.repeat(80));
    console.log(`Total external JavaScript files: ${externalUrls.length}`);
    console.log(`Total inline script blocks: ${inlineScriptCount}`);
    console.log('='.repeat(80));
    
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

main();
