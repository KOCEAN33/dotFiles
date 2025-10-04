#!/bin/bash

# Zsh configuration automation script
# Adds import statements to existing ~/.zshrc for dotFiles

set -e  # Exit on error

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Simplified log functions
log_info() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Script directory path setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_ZSH_FILE="$HOME/.zshrc"
IMPORT_MARKER="# DotFiles Import - DO NOT REMOVE THIS LINE"

log_info "Starting Zsh configuration setup..."

# Check DotFiles zsh directory
if [ ! -d "$SCRIPT_DIR" ]; then
    log_error "DotFiles zsh directory not found: $SCRIPT_DIR"
    exit 1
fi

# Check .zsh files count
ZSH_FILES_COUNT=$(find "$SCRIPT_DIR" -maxdepth 1 -name "*.zsh" -type f | wc -l)
if [ "$ZSH_FILES_COUNT" -eq 0 ]; then
    log_warning "No .zsh files found in DotFiles zsh directory"
fi

# Handle existing ~/.zshrc file
if [ -f "$TARGET_ZSH_FILE" ]; then
    # Check if import statement already exists
    if grep -q "$IMPORT_MARKER" "$TARGET_ZSH_FILE"; then
        log_warning "DotFiles import statement already exists"

        # Update existing import statement
        log_info "Updating existing import statement..."

        # Replace existing DotFiles import section
        sed -i.bak "/$IMPORT_MARKER/,/^$/c\\
$IMPORT_MARKER\\
# DotFiles configuration loading\\
# Automatically load all .zsh files\\
if [ -d \"$SCRIPT_DIR\" ]; then\\
    while IFS= read -r -d '' zsh_file; do\\
        source \"\$zsh_file\"\\
    done < <(find \"$SCRIPT_DIR\" -maxdepth 1 -name \"*.zsh\" -type f -print0 2>/dev/null)\\
else\\
    echo \"Warning: DotFiles zsh directory not found at $SCRIPT_DIR\"\\
fi" "$TARGET_ZSH_FILE"

        rm -f "$TARGET_ZSH_FILE.bak"
        log_info "Import statement updated successfully!"
        exit 0
    fi
else
    # Create basic ~/.zshrc file if it doesn't exist
    log_info "Creating basic ~/.zshrc file"
    cat > "$TARGET_ZSH_FILE" << 'EOF'
# Basic zsh configuration
export PATH="$HOME/bin:$PATH"

EOF
    log_info "Basic ~/.zshrc file created"
fi

# Add DotFiles import statement
log_info "Adding DotFiles import statement..."
cat >> "$TARGET_ZSH_FILE" << EOF

$IMPORT_MARKER
# DotFiles configuration loading
# Automatically load all .zsh files
if [ -d "$SCRIPT_DIR" ]; then
    while IFS= read -r -d '' zsh_file; do
        source "\$zsh_file"
    done < <(find "$SCRIPT_DIR" -maxdepth 1 -name "*.zsh" -type f -print0 2>/dev/null)
else
    echo "Warning: DotFiles zsh directory not found at $SCRIPT_DIR"
fi
EOF

if [ $? -eq 0 ]; then
    log_info "DotFiles import statement added successfully!"
else
    log_error "Failed to add DotFiles import statement"
    exit 1
fi

echo ""
log_info "Zsh configuration completed!"
log_info "Run 'source ~/.zshrc' or open a new terminal to apply changes."
