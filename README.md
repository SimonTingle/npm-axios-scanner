# NPM Axios Supply Chain Attack Scanner

A defensive security tool to detect indicators of compromise (IOCs) related to the March 2024 npm package supply chain incident affecting axios and plain-crypto-js.

## 🔍 What This Scans For

This scanner detects:
- **Compromised package versions**: `axios@1.14.1`, `axios@0.30.4`, `plain-crypto-js@4.2.1`
- **Known malicious file hashes**: Windows PowerShell stagers, Linux Python scripts, and macOS binaries
- **Suspicious references** in source code, lock files, and node_modules metadata

## 📖 Background

In March 2024, the axios npm package was compromised in a supply chain attack. Malicious versions were published to npm, affecting developers who installed these specific versions. See [the original security research](https://gist.github.com/silascutler/f6a709abf6a387deb0b0ac21c5f6c0b7) by Silas Cutler for full details.

**This scanner is read-only and safe to run in CI/CD pipelines. It performs no network requests and makes no modifications.**

## 🚀 Quick Start

### Local Usage

```bash
# Run in current directory
bash .github/scripts/npm-axios-scanner.sh

# Verbose output
bash .github/scripts/npm-axios-scanner.sh --verbose

# Scan specific directories
bash .github/scripts/npm-axios-scanner.sh /path/to/project --verbose

# Include system directories
bash .github/scripts/npm-axios-scanner.sh --system --verbose
```

### GitHub Actions Usage

This repository includes an automated workflow that runs:
- **On every push** to main/master
- **On every pull request**
- **Weekly** (Mondays at 09:00 UTC)

The workflow:
1. Checks out your code
2. Runs the scanner on your repository
3. Generates and uploads a timestamped report
4. Optionally fails the build if IOCs are detected (see workflow file)

**To add this scanner to your own repo:**

Copy `.github/workflows/npm-axios-scan.yml` to your repository's `.github/workflows/` directory and copy the scanner script to `.github/scripts/npm-axios-scanner.sh`.

## 📋 Output

The scanner generates a timestamped log file in `/tmp/` (or GitHub Actions artifact) with:
- **CRITICAL**: Definite matches (exact hash verification)
- **HIGH**: Strong indicators (version matches in lock files)
- **MEDIUM**: Suspicious patterns (source code references)
- File paths, detected versions, and hash values

## 🔒 Security Notes

- ✅ **Read-only**: No files are modified or deleted
- ✅ **No network**: Completely offline, no external API calls
- ✅ **CI/CD safe**: No assumptions about environment; works in GitHub Actions, GitLab CI, Jenkins, etc.
- ✅ **Permission-aware**: Gracefully handles permission denied errors
- ✅ **Selective scanning**: Choose which directories to scan

## 📦 Command-Line Options

```
--verbose              Show progress and detailed scanning activity
--system               Include common system directories (/home, /root, /etc, /opt, /srv, /usr/local, /var/www)
--all-mounts           Cross filesystem boundaries during scan
--max-hash-size-mb N   Only hash files up to N MB (default: 100)
<path>                 Custom target path(s) to scan (default: current directory)
```

## 📝 License

MIT License - See LICENSE file for details.

## 🤝 Contributing

This repository mirrors the original scanner logic. For issues or improvements to the core detection algorithm, please reference the [original gist](https://gist.github.com/silascutler/f6a709abf6a387deb0b0ac21c5f6c0b7).

## ⚠️ Disclaimer

This tool is provided as-is for security research and defensive purposes. Use responsibly. If you discover a compromised package in your supply chain, follow your organization's incident response procedures immediately.

---

**Last Updated**: 2024-03 | **Scanner Version**: 1.0
