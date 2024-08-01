#!/bin/bash

# Function to get CVE details from Red Hat Security Data API
get_cve_details() {
  local cve_id=$1
  curl -s "https://access.redhat.com/hydra/rest/securitydata/cve/$cve_id.json"
}

# Function to get the severity rating for a CVE
get_severity_rating() {
  local cve_details=$1
  echo "$cve_details" | jq -r '.threat_severity'
}

# Function to get the list of all RHSAs attached to a CVE
get_rhsa_list() {
  local cve_details=$1
  echo "$cve_details" | jq -rc '.affected_release[] | .advisory' | sort -u
}

# Function to get advisory URL
get_advisory_url() {
  local advisory_id=$1
  echo "https://access.redhat.com/errata/$advisory_id"
}

# Function to get advisories and products affected by a CVE
get_advisories_and_products() {
  local cve_details=$1
  echo "$cve_details" | jq -rc '.affected_release[] | {advisory: .advisory, product_name: .product_name, package: .package, version: .product_version}'
}

# Function to check affected status for a given CVE, package, and version
check_affected_status() {
  local cve_details=$1
  local package_name=$2
  local package_version=$3
  echo "$cve_details" | jq -r --arg pkg "$package_name" --arg ver "$package_version" '.package_state[] | select(.package_name == $pkg and (.fix_state == "Affected" or .fix_state == "Will not fix") and (.product_version == $ver or $ver == "")) | .fix_state'
}

# Function to get CVEs affecting a container image
get_container_cves() {
  local image=$1
  local pyxis_url="https://catalog.redhat.com/api/containers/v1"
  local namespace=$(echo $image | cut -d'/' -f2)
  local repository=$(echo $image | cut -d'/' -f3 | cut -d':' -f1)
  local tag=$(echo $image | cut -d':' -f2)

  image_metadata=$(curl -s "$pyxis_url/repositories/registry/registry.access.redhat.com/repository/$namespace/$repository/tag/$tag" | jq -r '.data[0]')
  image_id=$(echo "$image_metadata" | jq -r '._id')

  vulnerabilities=$(curl -s "$pyxis_url/images/id/$image_id/vulnerabilities" | jq -rc '.data[] | {cve_id: .cve_id, advisory_id: .advisory_id}')

  echo "CVEs affecting container image '$image':"
  while IFS= read -r line; do
    cve_id=$(echo $line | jq -r '.cve_id')
    advisory_id=$(echo $line | jq -r '.advisory_id')
    advisory_url=$(get_advisory_url $advisory_id)
    echo "  - CVE: $cve_id"
    echo "    Advisory: $advisory_id"
    echo "    URL: $advisory_url"
  done <<< "$vulnerabilities"
}

# Main script execution
CVE_ID=$1
PACKAGE_NAME=$2
PACKAGE_VERSION=$3

if [ -z "$CVE_ID" ]; then
  echo "Usage: $0 <CVE-ID> [package-name] [package-version]"
  exit 1
fi

echo "Fetching details for CVE: $CVE_ID"

CVE_DETAILS=$(get_cve_details $CVE_ID)

if [[ $CVE_ID =~ ^CVE- ]]; then
  SEVERITY=$(get_severity_rating "$CVE_DETAILS")
  RHSA_LIST=$(get_rhsa_list "$CVE_DETAILS")
  
  echo -e "\nCVE Details:"
  echo "  - CVE ID: $CVE_ID"
  echo "  - Severity: $SEVERITY"
  
  if [ -n "$PACKAGE_NAME" ]; then
    echo -e "\nChecking details for package '$PACKAGE_NAME':"
    AFFECTED_STATUS=$(check_affected_status "$CVE_DETAILS" "$PACKAGE_NAME" "$PACKAGE_VERSION")
    if [ -n "$AFFECTED_STATUS" ]; then
      echo "  - Affected status for package '$PACKAGE_NAME': $AFFECTED_STATUS"
    fi
    
    echo -e "\nAdvisories and products affected for package '$PACKAGE_NAME':"
    ADVISORIES_PRODUCTS=$(get_advisories_and_products "$CVE_DETAILS")
    while IFS= read -r line; do
      advisory=$(echo "$line" | jq -r '.advisory')
      product_name=$(echo "$line" | jq -r '.product_name')
      package=$(echo "$line" | jq -r '.package')
      version=$(echo "$line" | jq -r '.version')
      if [[ $package == "$PACKAGE_NAME" ]]; then
        advisory_url=$(get_advisory_url $advisory)
        echo "  - Advisory: $advisory"
        echo "    Product: $product_name"
        echo "    Package Version: $version"
        echo "    URL: $advisory_url"
      fi
    done <<< "$ADVISORIES_PRODUCTS"
  fi

  if [ -n "$PACKAGE_VERSION" ]; then
    echo -e "\nChecking affected status for package '$PACKAGE_NAME' version '$PACKAGE_VERSION':"
    AFFECTED_STATUS=$(check_affected_status "$CVE_DETAILS" "$PACKAGE_NAME" "$PACKAGE_VERSION")
    echo "  - Affected status for package '$PACKAGE_NAME' version '$PACKAGE_VERSION': $AFFECTED_STATUS"
  fi

  if [ -z "$PACKAGE_NAME" ]; then
    echo -e "\nAffected Packages and Versions:"
    echo "$CVE_DETAILS" | jq -rc '.affected_release[] | {package: .package, version: .product_version}' | while IFS= read -r line; do
      package=$(echo "$line" | jq -r '.package')
      version=$(echo "$line" | jq -r '.version')
      echo "  - Package: $package"
      echo "    Version: $version"
    done
  fi

  echo -e "\nList of all RHSAs attached to CVE $CVE_ID:"
  echo "$RHSA_LIST"
fi

if [[ $CVE_ID =~ ^registry ]]; then
  get_container_cves "$CVE_ID"
fi
