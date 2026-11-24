#!/bin/bash
# Upload all secrets from .env to GitHub repository using gh CLI
# How to use this script:
# 1. Make sure you have the GitHub CLI (gh) installed AND authenticated "gh login".
# 2. Place this script in the same directory as your .env file.
# 3. Update the REPO variable with your GitHub repository in the format "owner/repo" (eg.: "cesarniyo/DealStands").
# 4. Run the script: 
#    Save the script as upload_secrets.sh.
#    chmod +x upload_secrets.sh
#     ./upload_secrets.sh (bash upload_secrets.sh)

REPO="cesarniyo/AIOps"  # change this to your repo

if [ ! -f .env ]; then
  echo ".env file not found!"
  exit 1
fi

while IFS='=' read -r name value; do
  # Skip empty lines or lines starting with #
  [[ -z "$name" || "$name" =~ ^# ]] && continue
  
  echo "Setting secret $name..."
  gh secret set "$name" --repo "$REPO" --body "$value"
done < .env

echo "All secrets uploaded!"
