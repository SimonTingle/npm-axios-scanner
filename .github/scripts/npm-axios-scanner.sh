#!/bin/bash

################################################################################
# NPM Axios Supply Chain Attack Scanner
# Original: https://gist.github.com/silascutler/f6a709abf6a387deb0b0ac21c5f6c0b7
# Author: Silas Cutler
#
# This script detects indicators of compromise (IOCs) related to the March 2024
# npm package supply chain incident affecting axios and plain-crypto-js.
#
# Adaptation Notes:
# - Shebang added for CI/CD compatibility
# - Script logic preserved exactly from original
# - Safe for read-only scanning in GitHub Actions and other CI systems
################################################################################

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/tmp/npm-axios-scan_${TIMESTAMP}.log"

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Known malicious hashes (sha256) - placeholder values
MALICIOUS_HASHES=(
    "WINDOWS_POWERSHELL_HASH_IOC"
    "LINUX_PYTHON_HASH_IOC"
    "MACOS_BINARY_HASH_IOC_1"
    "MACOS_BINARY_HASH_IOC_2"
)

# Vulnerable package versions
VULNERABLE_PACKAGES=(
    "axios@1.14.1"
    "axios@0.30.4"
    "plain-crypto-js@4.2.1"
)

# Flags
VERBOSE=0
SCAN_SYSTEM=0
CROSS_MOUNTS=0
MAX_HASH_SIZE_MB=100
SCAN_PATHS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose|-v)
            VERBOSE=1
            shift
            ;;
        --system)
            SCAN_SYSTEM=1
            shift
            ;;
        --all-mounts)
            CROSS_MOUNTS=1
            shift
            ;;
        --max-hash-size-mb)
            MAX_HASH_SIZE_MB="$2"
            shift 2
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            SCAN_PATHS+=("$1")
            shift
            ;;
    esac
done

# Set default scan path if none provided
if [[ ${#SCAN_PATHS[@]} -eq 0 ]]; then
    SCAN_PATHS=(".")
fi

# Logging function
log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case "$level" in
        CRITICAL)
            echo -e "${RED}[${timestamp}] [CRITICAL] ${message}${NC}" | tee -a "$LOG_FILE"
            ;;
        HIGH)
            echo -e "${YELLOW}[${timestamp}] [HIGH] ${message}${NC}" | tee -a "$LOG_FILE"
            ;;
        MEDIUM)
            echo -e "${BLUE}[${timestamp}] [MEDIUM] ${message}${NC}" | tee -a "$LOG_FILE"
            ;;
        INFO)
            echo -e "${GREEN}[${timestamp}] [INFO] ${message}${NC}" | tee -a "$LOG_FILE"
            ;;
        DEBUG)
            if [[ $VERBOSE -eq 1 ]]; then
                echo "[${timestamp}] [DEBUG] ${message}" | tee -a "$LOG_FILE"
            else
                echo "[${timestamp}] [DEBUG] ${message}" >> "$LOG_FILE"
            fi
            ;;
    esac
}

# Initialize log
log INFO "Starting NPM Axios Supply Chain Attack Scanner"
log INFO "Scan timestamp: $TIMESTAMP"
log INFO "Log file: $LOG_FILE"
log DEBUG "Scan paths: ${SCAN_PATHS[*]}"

# Function to check package.json files
check_package_json() {
    local path="$1"
    log DEBUG "Checking package.json: $path"

    if [[ ! -f "$path" ]]; then
        return 0
    fi

    for pkg in "${VULNERABLE_PACKAGES[@]}"; do
        if grep -q "$pkg" "$path" 2>/dev/null; then
            log HIGH "Found vulnerable package reference: $pkg in $path"
            echo "$pkg" >> "$LOG_FILE"
        fi
    done
}

# Function to check lock files
check_lock_files() {
    local search_path="$1"
    log DEBUG "Scanning lock files in: $search_path"

    # Search for vulnerable packages in various lock files
    for pattern in "${VULNERABLE_PACKAGES[@]}"; do
        find "$search_path" -type f \( -name "package-lock.json" -o -name "yarn.lock" -o -name "pnpm-lock.yaml" \) 2>/dev/null | while read -r file; do
            if grep -q "$pattern" "$file" 2>/dev/null; then
                log HIGH "Found vulnerable package in lock file: $pattern in $file"
                echo "$pattern found in $file" >> "$LOG_FILE"
            fi
        done
    done
}

# Function to check source code
check_source_code() {
    local search_path="$1"
    log DEBUG "Scanning source code in: $search_path"

    # Search for suspicious imports in JS/TS files
    find "$search_path" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) 2>/dev/null | while read -r file; do
        for pattern in "${VULNERABLE_PACKAGES[@]}"; do
            if grep -q "$pattern" "$file" 2>/dev/null; then
                log MEDIUM "Found suspicious package reference in source: $pattern in $file"
                echo "$pattern referenced in $file" >> "$LOG_FILE"
            fi
        done
    done
}

# Function to check file hashes
check_file_hashes() {
    local search_path="$1"
    log DEBUG "Scanning file hashes in: $search_path"

    # Find files up to size limit and compute hashes
    find "$search_path" -type f -size -${MAX_HASH_SIZE_MB}M 2>/dev/null | while read -r file; do
        local file_hash
        file_hash=$(shasum -a 256 "$file" 2>/dev/null | awk '{print $1}')

        for hash in "${MALICIOUS_HASHES[@]}"; do
            if [[ "$file_hash" == "$hash" ]]; then
                log CRITICAL "Found malicious file hash match: $file"
                echo "CRITICAL: Hash match - $file ($file_hash)" >> "$LOG_FILE"
            fi
        done
    done
}

# Function to check node_modules
check_node_modules() {
    local search_path="$1"
    log DEBUG "Checking node_modules in: $search_path"

    if [[ -d "$search_path/node_modules/.package-lock.json" ]]; then
        if grep -q "axios" "$search_path/node_modules/.package-lock.json" 2>/dev/null; then
            log DEBUG "Found axios references in node_modules metadata"
        fi
    fi
}

# Main scanning loop
log INFO "Beginning scan of ${#SCAN_PATHS[@]} location(s)..."

for scan_path in "${SCAN_PATHS[@]}"; do
    if [[ ! -d "$scan_path" && ! -f "$scan_path" ]]; then
        log HIGH "Scan path does not exist: $scan_path"
        continue
    fi

    log INFO "Scanning: $scan_path"

    check_package_json "$scan_path/package.json"
    check_lock_files "$scan_path"
    check_source_code "$scan_path"
    check_file_hashes "$scan_path"
    check_node_modules "$scan_path"
done

log INFO "Scan complete. Results saved to: $LOG_FILE"
log INFO "To review findings, run: cat $LOG_FILE"

# Exit with appropriate code
if grep -q "CRITICAL\|HIGH" "$LOG_FILE" 2>/dev/null; then
    log CRITICAL "Indicators of compromise detected!"
    exit 1
else
    log INFO "No indicators of compromise detected."
    exit 0
fi
