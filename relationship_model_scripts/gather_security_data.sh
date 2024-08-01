#!/bin/bash

# Pyxis API URL
PYXIS_URL="https://catalog.redhat.com/api/containers/v1"

# Function to get repository URL from podman inspect
get_repo_url() {
  local image=$1
  podman inspect $image | jq -r '.[].Labels.url'
}

# Function to get image metadata from Pyxis
get_image_metadata() {
  local namespace=$1
  local repository=$2
  local tag=$3
  if [[ $tag == sha256:* ]]; then
    curl -s "$PYXIS_URL/repositories/registry/registry.access.redhat.com/repository/$namespace/$repository/images?filter=digest=$tag" | jq 'del(.data[].raw_config) | .data[0]'
  else
    curl -s "$PYXIS_URL/repositories/registry/registry.access.redhat.com/repository/$namespace/$repository/tag/$tag" | jq 'del(.data[].raw_config) | .data[0]'
  fi
}

# Function to get RPM manifest link for an image version
get_rpm_manifest_link() {
  local namespace=$1
  local repository=$2
  curl -s "$PYXIS_URL/repositories/registry/registry.access.redhat.com/repository/$namespace/$repository/images" | jq -r '.data[] | select(.architecture =="amd64") | {version: .brew.nvra, id: ._id, link: ._links.rpm_manifest.href}'
}

# Function to list RPMs in an image
list_rpms_in_image() {
  local image_id=$1
  curl -s "$PYXIS_URL/images/id/$image_id/rpm-manifest" | jq -r '.rpms[]? | .nvra' | sort
}

# Function to check available updates for RPMs in an image
check_available_updates() {
  local image_id=$1
  curl -s "$PYXIS_URL/images/id/$image_id/vulnerabilities" | jq -r '.data[] | "\(.cve_id) | \(.advisory_type)-\(.advisory_id)"'
}

# Function to get the latest image ID
get_latest_image_id() {
  local namespace=$1
  local repository=$2
  curl -s "$PYXIS_URL/repositories/registry/registry.access.redhat.com/repository/$namespace/$repository/images?sort_by=creation_date&page_size=500" | jq -r '.data[] | select(.architecture == "amd64") | ._id' | head -n 1
}

# Main script execution
IMAGE=$1
OUTPUT_FILE=$2

if [ -z "$IMAGE" ]; then
  echo "Usage: $0 <container-image> [output-file]"
  exit 1
fi

# Redirect output to file if specified
exec > >(tee -i "${OUTPUT_FILE:-/dev/stdout}") 2>&1

# Extract namespace and repository from the image
NAMESPACE=$(echo $IMAGE | cut -d'/' -f2)
REPOSITORY=$(echo $IMAGE | cut -d'/' -f3 | cut -d':' -f1)
TAG=$(echo $IMAGE | cut -d':' -f2)

# Step 1: Get repository URL
REPO_URL=$(get_repo_url $IMAGE)
if [ -z "$REPO_URL" ]; then
  echo "Error: Unable to get repository URL for image $IMAGE"
  exit 1
fi

echo "Repository URL: $REPO_URL"

# Step 2: Get image metadata
echo -e "\nFetching image metadata..."
IMAGE_METADATA=$(get_image_metadata $NAMESPACE $REPOSITORY $TAG)
if [ -z "$IMAGE_METADATA" ]; then
  echo "Error: No image metadata found for $IMAGE"
  exit 1
fi
echo "$IMAGE_METADATA" | jq .

# Step 3: Get RPM manifest link
echo -e "\nFetching RPM manifest links..."
RPM_MANIFEST_LINKS=$(get_rpm_manifest_link $NAMESPACE $REPOSITORY)
if [ -z "$RPM_MANIFEST_LINKS" ]; then
  echo "Error: No RPM manifest links found for $IMAGE"
  exit 1
fi
echo "$RPM_MANIFEST_LINKS" | jq -r '. | "Version: \(.version)\nID: \(.id)\nLink: \(.link)\n-------------------------"'

# Step 4: List RPMs in the image
IMAGE_ID=$(echo "$RPM_MANIFEST_LINKS" | jq -r '.id')
if [ -z "$IMAGE_ID" ]; then
  echo "Error: Unable to get image ID from RPM manifest links"
  exit 1
fi
echo -e "\nListing RPMs in image ID $IMAGE_ID..."
RPMS=$(list_rpms_in_image $IMAGE_ID)
echo "$RPMS" | awk '{print "  - " $0}'

# Step 5: Check available updates for RPMs in the image
echo -e "\nChecking available updates for RPMs in image ID $IMAGE_ID..."
UPDATES=$(check_available_updates $IMAGE_ID)
if [ -z "$UPDATES" ]; then
  echo "No updates available."
else
  echo "$UPDATES" | awk -F '|' '{print "  - CVE: " $1 "\n    Advisory: " $2 "\n-------------------------"}'
fi

# Step 6: Get the latest image ID
LATEST_IMAGE_ID=$(get_latest_image_id $NAMESPACE $REPOSITORY)
if [ -z "$LATEST_IMAGE_ID" ]; then
  echo "Error: Unable to get the latest image ID for $IMAGE"
  exit 1
fi
echo -e "\nLatest image ID: $LATEST_IMAGE_ID"

# Step 7: List RPMs in the latest image
echo -e "\nListing RPMs in the latest image ID $LATEST_IMAGE_ID..."
LATEST_RPMS=$(list_rpms_in_image $LATEST_IMAGE_ID)
echo "$LATEST_RPMS" | awk '{print "  - " $0}'

# Step 8: Check vulnerabilities in the latest image
echo -e "\nChecking vulnerabilities in the latest image ID $LATEST_IMAGE_ID..."
LATEST_UPDATES=$(check_available_updates $LATEST_IMAGE_ID)
if [ -z "$LATEST_UPDATES" ]; then
  echo "No vulnerabilities found."
else
  echo "$LATEST_UPDATES" | awk -F '|' '{print "  - CVE: " $1 "\n    Advisory: " $2 "\n-------------------------"}'
fi
