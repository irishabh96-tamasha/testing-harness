#!/usr/bin/env bash

# Script to generalize onboarding documentation
# Replaces hardcoded references with placeholders

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Generalizing onboarding documentation...${NC}"

# Backup files first
echo -e "${YELLOW}Creating backups...${NC}"
for file in docs/onboarding/{DAY-1-CHECKLIST,SOCIAL-MEDIA-SETUP,AGENT-SETUP-GUIDE,META-PROMPTS-FOR-USERS,USER-JOURNEY-VALIDATION-REPORT}.md; do
  if [ -f "$file" ]; then
    cp "$file" "$file.bak"
    echo "  - Backed up: $file"
  fi
done

echo -e "${YELLOW}Applying changes...${NC}"

# Function to update a file
update_file() {
  local file=$1
  local description=$2

  if [ ! -f "$file" ]; then
    echo -e "${RED}  ✗ File not found: $file${NC}"
    return 1
  fi

  echo "  - Updating: $description"

  # Replace MOB SAFe with SAFe (but keep SAFe Multi-Agent Development)
  sed -i 's/MOB SAFe Multi-Agent Development/SAFe Multi-Agent Development/g' "$file"
  sed -i 's/MOB SAFe/SAFe multi-agent/g' "$file"
  sed -i 's/the MOB methodology/the SAFe methodology/g' "$file"

  # Replace specific GitHub URLs with placeholders
  sed -i 's|https://github\.com/tamasha-live/mobile-app|https://github.com/tamasha-live/mobile-app|g' "$file"
  sed -i 's|https://gitingest\.com/tamasha-live/mobile-app|https://gitingest.com/tamasha-live/{{GITHUB_REPO}}|g' "$file"
  sed -i 's|git clone https://github\.com/tamasha-live/mobile-app|git clone https://github.com/tamasha-live/mobile-app|g' "$file"
  sed -i 's|cd mobile-app|cd mobile-app|g' "$file"
  sed -i 's|https://tamasha-live\.github\.io/mobile-app/|https://tamasha-live.github.io/{{GITHUB_REPO}}/|g' "$file"

  # Replace MOB- ticket prefix with generic placeholder
  sed -i 's/MOB-\([0-9]\+\)/MOB-\1/g' "$file"
  sed -i 's/MOB-326/MOB-326/g' "$file"

  # Replace PROJ-1 examples with MOB-1
  sed -i 's/PROJ-1/MOB-1/g' "$file"

  # Keep generic GitHub URLs (like github.com/settings/tokens)
  # These are useful examples and should not be replaced

  # Clean up any double placeholder issues
  sed -i 's/MOB-MOB/MOB/g' "$file"

  echo -e "${GREEN}  ✓ Updated: $file${NC}"
}

# Update each file
update_file "docs/onboarding/DAY-1-CHECKLIST.md" "Day 1 Checklist"
update_file "docs/onboarding/SOCIAL-MEDIA-SETUP.md" "Social Media Setup"
update_file "docs/onboarding/AGENT-SETUP-GUIDE.md" "Agent Setup Guide"
update_file "docs/onboarding/META-PROMPTS-FOR-USERS.md" "Meta-Prompts"
update_file "docs/onboarding/USER-JOURNEY-VALIDATION-REPORT.md" "User Journey Validation"

echo ""
echo -e "${GREEN}✓ All files updated successfully!${NC}"
echo ""
echo "Changes made:"
echo "  1. Replaced 'MOB SAFe' with 'SAFe multi-agent' or 'SAFe'"
echo "  2. Replaced GitHub URLs with https://github.com/tamasha-live/mobile-app placeholder"
echo "  3. Replaced GitIngest URLs with tamasha-live/{{GITHUB_REPO}} placeholders"
echo "  4. Replaced 'MOB-' with 'MOB-' for ticket references"
echo "  5. Generalized clone/cd commands with mobile-app"
echo ""
echo "Backup files created with .bak extension"
echo "To restore: for f in docs/onboarding/*.bak; do mv \"\$f\" \"\${f%.bak}\"; done"
