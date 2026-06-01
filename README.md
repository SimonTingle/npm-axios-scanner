# NPM Axios Supply Chain Attack Scanner

<div align="center">

[![Workflow Status](https://img.shields.io/github/actions/workflow/status/simontingle/npm-axios-scanner/npm-axios-scan.yml?branch=main&style=flat-square&logo=github&logoColor=white)](https://github.com/simontingle/npm-axios-scanner/actions/workflows/npm-axios-scan.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Security: Read-Only](https://img.shields.io/badge/Security-Read--Only-brightgreen?style=flat-square&logo=shield)](##-security-notes)
[![Maintenance: Active](https://img.shields.io/badge/Maintenance-Active-brightgreen?style=flat-square)](https://github.com/simontingle/npm-axios-scanner/commits/main)
[![Platform: Linux|macOS|Windows](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-blue?style=flat-square&logo=linux)](##-quick-start)
[![Latest Release](https://img.shields.io/github/v/release/simontingle/npm-axios-scanner?include_prereleases&style=flat-square)](https://github.com/simontingle/npm-axios-scanner/releases)

A defensive security tool to detect indicators of compromise (IOCs) related to the March 2024 npm package supply chain incident affecting axios and plain-crypto-js.

</div>

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

This repository includes an automated **supply chain security workflow** ([`npm-axios-scan.yml`](./.github/workflows/npm-axios-scan.yml)) that runs:

| Trigger | Schedule | Status |
|---------|----------|--------|
| **Push** | Every push to main/master | [![Push Scans](https://img.shields.io/github/actions/workflow/status/simontingle/npm-axios-scanner/npm-axios-scan.yml?branch=main&label=Push%20Scans&style=flat-square)](https://github.com/simontingle/npm-axios-scanner/actions/workflows/npm-axios-scan.yml) |
| **Pull Requests** | All PRs against main/master | [![PR Scans](https://img.shields.io/github/actions/workflow/status/simontingle/npm-axios-scanner/npm-axios-scan.yml?branch=main&label=PR%20Scans&style=flat-square)](https://github.com/simontingle/npm-axios-scanner/actions/workflows/npm-axios-scan.yml) |
| **Schedule** | Weekly (Mondays 09:00 UTC) | [![Scheduled Scans](https://img.shields.io/badge/Scheduled-Weekly-blue?style=flat-square)](https://github.com/simontingle/npm-axios-scanner/blob/main/.github/workflows/npm-axios-scan.yml#L14) |
| **Manual** | Workflow dispatch | [![Manual Trigger](https://img.shields.io/badge/Manual-Enabled-brightgreen?style=flat-square)](https://github.com/simontingle/npm-axios-scanner/actions/workflows/npm-axios-scan.yml) |

#### Workflow Features

The automated workflow includes:
- ✅ Automated code checkout via [`actions/checkout@v4`](https://github.com/actions/checkout)
- ✅ Supply chain scanner execution with verbose logging
- ✅ Timestamped artifact generation and upload ([`actions/upload-artifact@v4`](https://github.com/actions/upload-artifact))
- ✅ Automated PR comments via [`actions/github-script@v7`](https://github.com/actions/github-script)
- ✅ Security summary report generation
- ✅ Configurable fail-on-IOC policy (optional, currently disabled)

#### GitHub Actions Configuration

**Version Strategy:** All GitHub Actions use automatic updates within major versions for continuous security patches:
- `actions/checkout@v4` - Auto-updates within v4.x
- `actions/upload-artifact@v4` - Auto-updates within v4.x
- `actions/github-script@v7` - Auto-updates within v7.x (v9+ has breaking changes)

**Permissions:** Minimal required permissions:
- `contents: read` - Repository read access
- `actions: read` - Workflow read access  
- `security-events: write` - Security event reporting

#### Adding to Your Repository

Copy the scanner to your own repository:

```bash
# Copy workflow file
mkdir -p .github/workflows
cp .github/workflows/npm-axios-scan.yml <your-repo>/.github/workflows/

# Copy scanner script
mkdir -p .github/scripts
cp .github/scripts/npm-axios-scanner.sh <your-repo>/.github/scripts/
```

**Requirements:**
- GitHub repository with Actions enabled
- No additional dependencies required (pure Bash + standard Unix tools)

## 📋 Output

The scanner generates a timestamped log file in `/tmp/` (or GitHub Actions artifact) with:
- **CRITICAL**: Definite matches (exact hash verification)
- **HIGH**: Strong indicators (version matches in lock files)
- **MEDIUM**: Suspicious patterns (source code references)
- File paths, detected versions, and hash values

## 🔒 Security Notes

| Feature | Status | Details |
|---------|--------|---------|
| **Read-Only Mode** | ✅ Enabled | No files are modified, deleted, or overwritten |
| **Network Access** | ✅ Disabled | Completely offline, no external API calls |
| **CI/CD Compatibility** | ✅ Universal | Works in GitHub Actions, GitLab CI, Jenkins, CircleCI, etc. |
| **Permission Handling** | ✅ Graceful | Handles permission denied errors without crashing |
| **Selective Scanning** | ✅ Supported | Choose specific directories to scan |
| **Artifact Retention** | ✅ Configured | 30-day retention for scan reports |
| **GitHub Actions Security** | ✅ Optimized | Auto-updating major version tags + minimal permissions |

### Supply Chain Security Best Practices

This tool implements GitHub's recommended security practices:

- **Automatic Updates**: Uses major version tags for Actions to receive security patches automatically
- **Minimal Permissions**: Only requests necessary GitHub API permissions
- **Audit Trail**: Timestamped logs enable audit and compliance reporting
- **Safe by Default**: Read-only scanning prevents accidental modifications
- **Transparent Reporting**: Clear severity levels (CRITICAL, HIGH, MEDIUM) for findings

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

## 📊 Repository Status

<div align="center">

| Metric | Status |
|--------|--------|
| **Build Health** | [![Build](https://img.shields.io/github/actions/workflow/status/simontingle/npm-axios-scanner/npm-axios-scan.yml?branch=main&style=flat-square)](https://github.com/simontingle/npm-axios-scanner/actions/workflows/npm-axios-scan.yml) |
| **Last Commit** | [![Last Commit](https://img.shields.io/github/last-commit/simontingle/npm-axios-scanner/main?style=flat-square)](https://github.com/simontingle/npm-axios-scanner/commits/main) |
| **Commit Activity** | [![Commit Activity](https://img.shields.io/github/commit-activity/m/simontingle/npm-axios-scanner?style=flat-square)](https://github.com/simontingle/npm-axios-scanner) |
| **Languages** | [![Languages](https://img.shields.io/github/languages/top/simontingle/npm-axios-scanner?style=flat-square)](https://github.com/simontingle/npm-axios-scanner) |
| **Code Size** | [![Code Size](https://img.shields.io/github/languages/code-size/simontingle/npm-axios-scanner?style=flat-square)](https://github.com/simontingle/npm-axios-scanner) |
| **Repository Size** | [![Repo Size](https://img.shields.io/github/repo-size/simontingle/npm-axios-scanner?style=flat-square)](https://github.com/simontingle/npm-axios-scanner) |

</div>

## 🤝 Contributing

This repository mirrors the original scanner logic. For issues or improvements to the core detection algorithm, please reference the [original gist](https://gist.github.com/silascutler/f6a709abf6a387deb0b0ac21c5f6c0b7).

## ⚠️ Disclaimer

This tool is provided as-is for security research and defensive purposes. Use responsibly. If you discover a compromised package in your supply chain, follow your organization's incident response procedures immediately.

## 📋 Version History

| Version | Release Date | Changes |
|---------|--------------|---------|
| **1.1** | 2025-06 | GitHub Actions auto-update strategy, comprehensive documentation |
| **1.0** | 2024-03 | Initial public release, scanner for March 2024 npm incident |

---

<div align="center">

**Last Updated**: June 2025 | **Status**: [![Active Development](https://img.shields.io/badge/Status-Active%20Development-brightgreen?style=flat-square)](https://github.com/simontingle/npm-axios-scanner)

**Questions?** [Open an issue](https://github.com/simontingle/npm-axios-scanner/issues) | **Security Report?** [GitHub Security Advisory](https://github.com/simontingle/npm-axios-scanner/security)

</div>
