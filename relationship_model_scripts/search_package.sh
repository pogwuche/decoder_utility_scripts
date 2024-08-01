#!/bin/bash

# Function to get repository URL from podman inspect
get_repo_url() {
  local image=$1
  podman inspect $image | jq -r '.[].Labels.url'
}

# Function to get image ID from Pyxis
get_image_id() {
  local namespace=$1
  local repository=$2
  local tag=$3
  curl -s "$PYXIS_URL/repositories/registry/registry.access.redhat.com/repository/$namespace/$repository/tag/$tag" | jq -r '.data._id'
}

# Function to list RPMs in an image
list_rpms_in_image() {
  local image_id=$1
  curl -s "$PYXIS_URL/images/id/$image_id/rpm-manifest" | jq -r '.rpms[]? | .nvra' | sort
}

# Function to list DEB packages in an image
list_deb_packages_in_image() {
  local image=$1
  podman run --rm -it --entrypoint /bin/bash $image -c "dpkg -l"
}

# Function to check available updates for RPMs in an image
check_available_updates() {
  local image_id=$1
  curl -s "$PYXIS_URL/images/id/$image_id/vulnerabilities" | jq -r '.data[] | "\(.cve_id) | \(.advisory_type)-\(.advisory_id)"'
}

# Main script execution
IMAGE=$1
PACKAGE=$2
FIXED_VERSION=$3

if [ -z "$IMAGE" ]; then
  echo "Usage: $0 <container-image> [package-name] [fixed-version]"
  exit 1
fi

# Pyxis API URL
PYXIS_URL="https://catalog.redhat.com/api/containers/v1"

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

# Step 2: Get image ID
IMAGE_ID=$(get_image_id $NAMESPACE $REPOSITORY $TAG)
if [ -z "$IMAGE_ID" ]; then
  echo "Error: Unable to get image ID for $IMAGE"
  exit 1
fi

echo "Image ID: $IMAGE_ID"

if [ -z "$PACKAGE" ]; then
  echo "No package specified. Listing all packages in image '$IMAGE'..."
  
  echo "RPM packages:"
  list_rpms_in_image $IMAGE_ID
  
  echo "DEB packages:"
  list_deb_packages_in_image $IMAGE
else
  echo "Searching for package '$PACKAGE' in image '$IMAGE'..."
  
  RPM_RESULT=$(list_rpms_in_image $IMAGE_ID | grep $PACKAGE)
  DEB_RESULT=$(list_deb_packages_in_image $IMAGE | grep $PACKAGE)
  
  if [ -z "$RPM_RESULT" ] && [ -z "$DEB_RESULT" ]; then
    echo "Package '$PACKAGE' not found in image '$IMAGE'."
  else
    if [ -n "$RPM_RESULT" ]; then
      echo "Package '$PACKAGE' found in RPM packages:"
      echo "$RPM_RESULT"
      if [ -n "$FIXED_VERSION" ]; then
        if [[ "$RPM_RESULT" == *"$FIXED_VERSION"* ]]; then
          echo "The installed version in RPM is the fixed version."
        else
          echo "The installed version in RPM is not the fixed version."
        fi
      fi
    else
      echo "Package '$PACKAGE' not found in RPM packages."
    fi
    
    if [ -n "$DEB_RESULT" ]; then
      echo "Package '$PACKAGE' found in DEB packages:"
      echo "$DEB_RESULT"
      if [ -n "$FIXED_VERSION" ]; then
        if [[ "$DEB_RESULT" == *"$FIXED_VERSION"* ]]; then
          echo "The installed version in DEB is the fixed version."
        else
          echo "The installed version in DEB is not the fixed version."
        fi
      fi
    else
      echo "Package '$PACKAGE' not found in DEB packages."
    fi
  fi
fi
