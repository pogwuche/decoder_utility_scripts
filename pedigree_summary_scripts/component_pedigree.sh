#!/bin/bash

# Check if at least one argument is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <container-image> [package-name] [fixed-version]"
    exit 1
fi

IMAGE=$1
PACKAGE=$2
FIXED_VERSION=$3

# Pyxis API URL
PYXIS_URL="https://catalog.redhat.com/api/containers/v1"

# Function to get image metadata from Pyxis
get_image_metadata() {
    local namespace=$1
    local repository=$2
    local tag=$3
    curl -s "$PYXIS_URL/repositories/registry/registry.access.redhat.com/repository/$namespace/$repository/tag/$tag" | jq -r '.data[0]'
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

# Function to get detailed CVE information
get_cve_info() {
    local cve_id=$1
    curl -s "https://access.redhat.com/hydra/rest/securitydata/cve/$cve_id.json"
}

# Function to generate advisory URL
get_advisory_url() {
    local advisory_id=$1
    echo "https://access.redhat.com/errata/$advisory_id"
}

# Function to extract the first three numeric components of a version
extract_version() {
    echo "$1" | grep -oP '\d+\.\d+\.\d+' | head -n 1
}

# Function to compare versions
compare_versions() {
    local installed=$1
    local fixed=$2
    installed=$(extract_version "$installed")
    fixed=$(extract_version "$fixed")
    dpkg --compare-versions "$installed" lt "$fixed"
}

# Main script execution

# Extract namespace and repository from the image
NAMESPACE=$(echo $IMAGE | cut -d'/' -f2)
REPOSITORY=$(echo $IMAGE | cut -d'/' -f3 | cut -d':' -f1)
TAG=$(echo $IMAGE | cut -d':' -f2)

# Initialize pedigree summary
PEDIGREE_SUMMARY=""

# Step 1: Get image metadata
echo "Fetching image metadata..."
IMAGE_METADATA=$(get_image_metadata $NAMESPACE $REPOSITORY $TAG)
IMAGE_ID=$(echo "$IMAGE_METADATA" | jq -r '._id')

if [ -z "$IMAGE_ID" ];then
    echo "Error: Unable to get image ID for $IMAGE"
    exit 1
fi

echo "Image ID: $IMAGE_ID"
PEDIGREE_SUMMARY+="Image ID: $IMAGE_ID\n"

# Step 2: List RPMs in the image
echo "Listing RPM packages in image ID $IMAGE_ID..."
RPMS=$(list_rpms_in_image $IMAGE_ID)
echo "$RPMS"

# Step 3: Search for the package in RPM packages
if [ -n "$PACKAGE" ]; then
    echo "Searching for package '$PACKAGE' in image '$IMAGE'..."
    RPM_RESULT=$(echo "$RPMS" | grep $PACKAGE)
    if [ -z "$RPM_RESULT" ]; then
        echo "Package '$PACKAGE' not found in image '$IMAGE'."
        PEDIGREE_SUMMARY+="Package '$PACKAGE' not found in image '$IMAGE'.\n"
    else
        echo "Package '$PACKAGE' found in RPM packages:"
        echo "$RPM_RESULT"
        INSTALLED_VERSION=$(echo "$RPM_RESULT" | sed 's/^[^-]*-//')
        PEDIGREE_SUMMARY+="Package '$PACKAGE' found in RPM packages:\n$RPM_RESULT\n"
        PEDIGREE_SUMMARY+="Installed version: $INSTALLED_VERSION\n"
        if [ -n "$FIXED_VERSION" ]; then
            if [[ "$RPM_RESULT" == *"$FIXED_VERSION"* ]]; then
                echo "The installed version in RPM is the fixed version."
                PEDIGREE_SUMMARY+="The installed version in RPM is the fixed version.\n"
            else
                echo "The installed version in RPM is not the fixed version."
                PEDIGREE_SUMMARY+="The installed version in RPM is not the fixed version.\n"
                PEDIGREE_SUMMARY+="Fixed version: $FIXED_VERSION\n"
            fi
        fi
    fi
fi

# Step 4: Check available updates for RPMs in the image
echo "Checking available updates for RPMs in image ID $IMAGE_ID..."
UPDATES=$(check_available_updates $IMAGE_ID)
echo "$UPDATES"

# Step 5: Get detailed CVE information for each CVE
echo "Fetching detailed CVE information..."
while read -r line; do
    CVE_ID=$(echo $line | cut -d'|' -f1 | tr -d ' ')
    ADVISORY=$(echo $line | cut -d'|' -f2 | tr -d ' ')
    CVE_INFO=$(get_cve_info $CVE_ID)
    UPSTREAM_FIX=$(echo "$CVE_INFO" | jq -r '.upstream_fix // empty')

    if [ -z "$PACKAGE" ] || [ "$PACKAGE" == "all" ] || grep -q "$PACKAGE" <<< "$CVE_INFO"; then
        echo "Details for $CVE_ID:"
        echo "$CVE_INFO" | jq .
        ADVISORY_URL=$(get_advisory_url $ADVISORY)
        echo "Advisory URL for $ADVISORY: $ADVISORY_URL"
        PEDIGREE_SUMMARY+="CVE ID: $CVE_ID\nAdvisory: $ADVISORY\nAdvisory URL: $ADVISORY_URL\n"
        if [ -n "$UPSTREAM_FIX" ]; then
            PEDIGREE_SUMMARY+="Upstream fix version: $UPSTREAM_FIX\n"
            # Check if the installed version matches the upstream fix version
            IFS=', ' read -r -a FIX_VERSIONS <<< "$UPSTREAM_FIX"
            for FIX in "${FIX_VERSIONS[@]}"; do
                FIX=$(echo "$FIX" | sed 's/^[^0-9]*//')
                if compare_versions "$INSTALLED_VERSION" "$FIX"; then
                    PEDIGREE_SUMMARY+="The installed version is not the upstream fixed version.\n"
                    break
                else
                    PEDIGREE_SUMMARY+="The installed version is the upstream fixed version.\n"
                fi
            done
        fi
    fi
done <<< "$UPDATES"

# Output pedigree summary
echo -e "\n=== Pedigree Summary ==="
echo -e "$PEDIGREE_SUMMARY"
#!/bin/bash

# Check if at least one argument is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <container-image> [package-name] [fixed-version]"
    exit 1
fi

IMAGE=$1
PACKAGE=$2
FIXED_VERSION=$3

# Pyxis API URL
PYXIS_URL="https://catalog.redhat.com/api/containers/v1"

# Function to get image metadata from Pyxis
get_image_metadata() {
    local namespace=$1
    local repository=$2
    local tag=$3
    curl -s "$PYXIS_URL/repositories/registry/registry.access.redhat.com/repository/$namespace/$repository/tag/$tag" | jq -r '.data[0]'
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

# Function to get detailed CVE information
get_cve_info() {
    local cve_id=$1
    curl -s "https://access.redhat.com/hydra/rest/securitydata/cve/$cve_id.json"
}

# Function to generate advisory URL
get_advisory_url() {
    local advisory_id=$1
    echo "https://access.redhat.com/errata/$advisory_id"
}

# Function to extract the first three numeric components of a version
extract_version() {
    echo "$1" | grep -oP '\d+\.\d+\.\d+' | head -n 1
}

# Function to compare versions
compare_versions() {
    local installed=$1
    local fixed=$2
    installed=$(extract_version "$installed")
    fixed=$(extract_version "$fixed")
    dpkg --compare-versions "$installed" lt "$fixed"
}

# Main script execution

# Extract namespace and repository from the image
NAMESPACE=$(echo $IMAGE | cut -d'/' -f2)
REPOSITORY=$(echo $IMAGE | cut -d'/' -f3 | cut -d':' -f1)
TAG=$(echo $IMAGE | cut -d':' -f2)

# Initialize pedigree summary
PEDIGREE_SUMMARY=""

# Step 1: Get image metadata
echo "Fetching image metadata..."
IMAGE_METADATA=$(get_image_metadata $NAMESPACE $REPOSITORY $TAG)
IMAGE_ID=$(echo "$IMAGE_METADATA" | jq -r '._id')

if [ -z "$IMAGE_ID" ];then
    echo "Error: Unable to get image ID for $IMAGE"
    exit 1
fi

echo "Image ID: $IMAGE_ID"
PEDIGREE_SUMMARY+="Image ID: $IMAGE_ID\n"

# Step 2: List RPMs in the image
echo "Listing RPM packages in image ID $IMAGE_ID..."
RPMS=$(list_rpms_in_image $IMAGE_ID)
echo "$RPMS"

# Step 3: Search for the package in RPM packages
if [ -n "$PACKAGE" ]; then
    echo "Searching for package '$PACKAGE' in image '$IMAGE'..."
    RPM_RESULT=$(echo "$RPMS" | grep $PACKAGE)
    if [ -z "$RPM_RESULT" ]; then
        echo "Package '$PACKAGE' not found in image '$IMAGE'."
        PEDIGREE_SUMMARY+="Package '$PACKAGE' not found in image '$IMAGE'.\n"
    else
        echo "Package '$PACKAGE' found in RPM packages:"
        echo "$RPM_RESULT"
        INSTALLED_VERSION=$(echo "$RPM_RESULT" | sed 's/^[^-]*-//')
        PEDIGREE_SUMMARY+="Package '$PACKAGE' found in RPM packages:\n$RPM_RESULT\n"
        PEDIGREE_SUMMARY+="Installed version: $INSTALLED_VERSION\n"
        if [ -n "$FIXED_VERSION" ]; then
            if [[ "$RPM_RESULT" == *"$FIXED_VERSION"* ]]; then
                echo "The installed version in RPM is the fixed version."
                PEDIGREE_SUMMARY+="The installed version in RPM is the fixed version.\n"
            else
                echo "The installed version in RPM is not the fixed version."
                PEDIGREE_SUMMARY+="The installed version in RPM is not the fixed version.\n"
                PEDIGREE_SUMMARY+="Fixed version: $FIXED_VERSION\n"
            fi
        fi
    fi
fi

# Step 4: Check available updates for RPMs in the image
echo "Checking available updates for RPMs in image ID $IMAGE_ID..."
UPDATES=$(check_available_updates $IMAGE_ID)
echo "$UPDATES"

# Step 5: Get detailed CVE information for each CVE
echo "Fetching detailed CVE information..."
while read -r line; do
    CVE_ID=$(echo $line | cut -d'|' -f1 | tr -d ' ')
    ADVISORY=$(echo $line | cut -d'|' -f2 | tr -d ' ')
    CVE_INFO=$(get_cve_info $CVE_ID)
    UPSTREAM_FIX=$(echo "$CVE_INFO" | jq -r '.upstream_fix // empty')

    if [ -z "$PACKAGE" ] || [ "$PACKAGE" == "all" ] || grep -q "$PACKAGE" <<< "$CVE_INFO"; then
        echo "Details for $CVE_ID:"
        echo "$CVE_INFO" | jq .
        ADVISORY_URL=$(get_advisory_url $ADVISORY)
        echo "Advisory URL for $ADVISORY: $ADVISORY_URL"
        PEDIGREE_SUMMARY+="CVE ID: $CVE_ID\nAdvisory: $ADVISORY\nAdvisory URL: $ADVISORY_URL\n"
        if [ -n "$UPSTREAM_FIX" ]; then
            PEDIGREE_SUMMARY+="Upstream fix version: $UPSTREAM_FIX\n"
            # Check if the installed version matches the upstream fix version
            IFS=', ' read -r -a FIX_VERSIONS <<< "$UPSTREAM_FIX"
            for FIX in "${FIX_VERSIONS[@]}"; do
                FIX=$(echo "$FIX" | sed 's/^[^0-9]*//')
                if compare_versions "$INSTALLED_VERSION" "$FIX"; then
                    PEDIGREE_SUMMARY+="The installed version is not the upstream fixed version.\n"
                    break
                else
                    PEDIGREE_SUMMARY+="The installed version is the upstream fixed version.\n"
                fi
            done
        fi
    fi
done <<< "$UPDATES"

# Output pedigree summary
echo -e "\n=== Pedigree Summary ==="
echo -e "$PEDIGREE_SUMMARY"
