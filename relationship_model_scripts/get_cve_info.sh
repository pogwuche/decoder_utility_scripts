#!/bin/bash

# Function to get CVE details from Red Hat Security Data API
get_cve_details() {
  local cve_id=$1
  curl -s "https://access.redhat.com/hydra/rest/securitydata/cve/$cve_id.json"
}

# Function to generate advisory URL
get_advisory_url() {
  local advisory_id=$1
  echo "https://access.redhat.com/errata/$advisory_id"
}

# Main script execution
CVE_ID=$1
OUTPUT_FILE=$2

if [ -z "$CVE_ID" ]; then
  echo "Usage: $0 <CVE-ID> [output-file]"
  exit 1
fi

# Redirect output to file if specified
exec > >(tee -i "${OUTPUT_FILE:-/dev/stdout}") 2>&1

echo "Fetching details for CVE: $CVE_ID"

# Step 1: Get CVE details
CVE_DETAILS=$(get_cve_details $CVE_ID)
echo -e "\nCVE Details:"
echo "$CVE_DETAILS" | jq .

# Extract advisory IDs and product names
ADVISORY_PRODUCTS=$(echo "$CVE_DETAILS" | jq -rc '.affected_release[] | {advisory: .advisory, product_name: .product_name}')

# Step 2: Get advisory URLs
echo -e "\nAdvisory URLs for CVE: $CVE_ID"
echo "$ADVISORY_PRODUCTS" | while IFS= read -r line; do
  ADVISORY=$(echo "$line" | jq -r '.advisory')
  PRODUCT_NAME=$(echo "$line" | jq -r '.product_name')
  ADVISORY_URL=$(get_advisory_url $ADVISORY)
  echo "This is the URL for the advisory for the affected product ($PRODUCT_NAME):"
  echo "Advisory ID: $ADVISORY"
  echo "URL: $ADVISORY_URL"
  echo ""
done
