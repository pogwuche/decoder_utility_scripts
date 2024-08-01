# Relationship Model Workflow Details

## Identify the Fixed Component in a Container

**Command:** `./gather_security_data.sh <container-image> output.txt`  
**Description:** Run `gather_security_data.sh` to list all RPM packages in the container image. Identify the package version of interest.  
**Example Results:**
- RPM Packages:
  - `bash-4.4.20-1.el8.x86_64`
  - `coreutils-8.30-6.el8.x86_64`
  - `openssl-1.1.1k-1.el8.x86_64`

## Determine If the Component Is Vulnerable

**Command:** Review the output from `gather_security_data.sh`  
**Description:** Use the output from `gather_security_data.sh` to identify if there are any CVEs related to the package. If vulnerabilities are found, note the CVE IDs.  
**Example Results:**
- CVE IDs:
  - `CVE-2021-23358`

## Fetch Detailed CVE Information

**Command:** `./get_cve_info.sh CVE-2021-23358 output_cve.txt`  
**Description:** Run `get_cve_info.sh` with the identified CVE IDs to get detailed information about the CVEs. Examine the affected release and package state sections to see if the specific package version in your container is listed as vulnerable or fixed.  
**Example Results:**
- Detailed CVE Information:
  - Severity: Moderate
  - Affected Products: Red Hat Advanced Cluster Management for Kubernetes 2.0 for RHEL 8
  - Advisory: RHSA-2021:1448
  - Fix State: Fixed

## Verify the Package Version

**Command:** `./search_package.sh registry.access.redhat.com/quay/quay-container-security-operator-rhel8:v3.11.1-4 openssl 1.1.1k-1.el8.x86_64`  
**Description:** Run `search_package.sh` to verify the presence and version of the specific package within the container image.  
**Example Results:**
- Search Result:
  - Package `openssl` found in RPM packages: `openssl-1.1.1k-1.el8.x86_64`
  - The installed version in RPM is the fixed version.

## Trace Fixed Component Origins

**Command:** Review the output from `get_cve_info.sh`  
**Description:** Use the advisory details from `get_cve_info.sh` to trace back which product or team was responsible for the fix and how it was included in the container image.  
**Example Results:**
- Product/Team Responsible for Fix:
  - Product/Team: Red Hat Product Security
  - Contact: `security@redhat.com`

## Short Videos Explaining How Each Script Works

- **search_package.sh:** [Watch Video](https://www.loom.com/share/bce2faee19a849cdbf0555838d6b19e9?sid=4850b7c2-1539-4b93-ab5e-3b3ec61ad5ec)
- **get_cve_info.sh:** [Watch Video](https://www.loom.com/share/c8b36ad619a64278984e8decfa226414?sid=7b31f194-2a5f-4116-bd51-66c05715e2c0)
- **gather_security_data.sh:** [Watch Video](https://www.loom.com/share/24e0dfab938944c8ad9e769b2626ff42?sid=cf657ce7-e5e8-4c84-8cf6-9a7e849539a9)

# Relationship Model Template

Use this template to conduct a Relationship Model Analysis on Container Images. All filled details below are examples.

| Step | Substep | Command | Result |
| --- | --- | --- | --- |
| 1. Identify the Fixed Component in a Container | | | |
| | Run gather_security_data.sh to list all RPM packages in the container image. | `./gather_security_data.sh <container-image> output.txt` | List of RPM packages: <br> - `bash-4.4.20-1.el8.x86_64` <br> - `coreutils-8.30-6.el8.x86_64` <br> - `openssl-1.1.1k-1.el8.x86_64` |
| | Identify the package version of interest. | Review the output from gather_security_data.sh | Identified Package and Version: `openssl-1.1.1k-1.el8.x86_64` |
| 2. Determine If the Component Is Vulnerable | | | |
| | Use the output from gather_security_data.sh to identify if there are any CVEs related to the package. | Review the output from gather_security_data.sh | CVE IDs related to the package: <br> - `CVE-2021-23358` |
| | If vulnerabilities are found, note the CVE IDs. | Note the CVE IDs | CVE IDs: `CVE-2021-23358` |
| 3. Fetch Detailed CVE Information | | | |
| | Run get_cve_info.sh with the identified CVE IDs to get detailed information about the CVEs. | `./get_cve_info.sh CVE-2021-23358 output_cve.txt` | Detailed CVE Information: <br> - Severity: Moderate <br> - Affected Products: Red Hat Advanced Cluster Management for Kubernetes 2.0 for RHEL 8 <br> - Advisory: RHSA-2021:1448 <br> - Fix State: Fixed |
| | Examine the affected release and package state sections to see if the specific package version in your container is listed as vulnerable or fixed. | Review the output from get_cve_info.sh | Affected Release and Package State: <br> - `openssl-1.1.1k-1.el8.x86_64` is Fixed |
| 4. Verify the Package Version | | | |
| | Run search_package.sh to verify the presence and version of the specific package within the container image. | `./search_package.sh registry.access.redhat.com/quay/quay-container-security-operator-rhel8:v3.11.1-4 openssl 1.1.1k-1.el8.x86_64` | Search Result: <br> - Package `openssl` found in RPM packages: `openssl-1.1.1k-1.el8.x86_64` <br> - The installed version in RPM is the fixed version. |
| 5. Trace Fixed Component Origins | | | |
| | Use the advisory details from get_cve_info.sh to trace back which product or team was responsible for the fix and how it was included in the container image. | Review the output from get_cve_info.sh | Product/Team Responsible for Fix: <br> - Product/Team: Red Hat Product Security <br> - Contact: `security@redhat.com` |

# Break Down of How Each Question is Addressed by the Model and the Scripts

## 1. Where did the fixed component in a container come from?
- **Scripts Involved:** `gather_security_data.sh`, `get_cve_info.sh`, `search_package.sh`
- **Process:**
  - **gather_security_data.sh:** Collects detailed metadata about the container image, including all RPM packages installed. This helps identify which packages and versions are present in the image.
  - **search_package.sh:** Verifies the presence and version of specific packages within the container image, helping to identify if a package is included and if it matches the fixed version.
  - **get_cve_info.sh:** Fetches detailed information about specific CVEs, including affected products and advisories, which helps trace back to when and where a particular fix was applied.

## 2. Which image rebuild process was involved?
- **Scripts Involved:** `gather_security_data.sh`, `get_cve_info.sh`
- **Process:**
  - **gather_security_data.sh:** Identifies all packages in the container and any known vulnerabilities, which is the first step in understanding the build process.
  - **get_cve_info.sh:** Provides details on advisories related to CVEs, including information about the build and patch process. By analyzing the advisories, you can understand the steps involved in rebuilding the image to include the fixed components.

## 3. Which product or team was responsible for the patch?
- **Scripts Involved:** `get_cve_info.sh`
- **Process:**
  - **get_cve_info.sh:** Fetches detailed information about advisories related to CVEs. Each advisory typically includes information about the product team responsible for the patch and the product affected. By analyzing these advisories, you can trace back to the responsible team.

# Guide to Using `search_package.sh` Script

This guide provides detailed instructions on how to create, make executable, and run the `search_package.sh` script to search for specific packages within a container image and compare them to fixed versions.

## 1. Creating the Script

1. **Open a Terminal:**
   Open a terminal on your Linux system.

2. **Create the Script File:**
   Use a text editor like `nano`, `vi`, or `gedit` to create the script file. Here, we'll use `nano`:

   ```sh
   nano search_package.sh
   ```

3. **Copy and Paste the Script:**
   Copy and paste the `search_package.sh` script into the text editor.

4. **Save and Exit:**
   - In `nano`, press `Ctrl + X`, then `Y`, and `Enter`.
   - In `vi`, press `Esc`, then `:wq`, and `Enter`.
   - In `gedit`, click the save button or press `Ctrl + S`, then close the window.

## 2. Making the Script Executable

1. **Make the Script Executable:**
   Run the following command to make the script executable:

   ```sh
   chmod +x search_package.sh
   ```

## 3. Running the Script

The script can be run with different arguments based on the information you need.

1. **Listing All Packages:**
   To list all packages within a container image, run the script without specifying a package:

   ```sh
   ./search_package.sh <IMAGE>
   ```

   **Example:**

   ```sh
   ./search_package.sh registry.redhat.io/quay/quay-container-security-operator-rhel8:v3.11.1-4
   ```

2. **Searching for a Specific Package:**
   To search for a specific package within a container image, provide the image and package name:

   ```sh
   ./search_package.sh <IMAGE> <PACKAGE>
   ```

   **Example:**

   ```sh
   ./search_package.sh registry.redhat.io/quay/quay-container-security-operator-rhel8:v3.11.1-4 openssl
   ```

3. **Searching for a Specific Package and Comparing to a Fixed Version:**
   To search for a specific package and compare the installed version to a fixed version, provide the image, package name, and the fixed version:

   ```sh
   ./search_package.sh <IMAGE> <PACKAGE> <FIXED_VERSION>
   ```

   **Example:**

   ```sh
   ./search_package.sh registry.redhat.io/quay/quay-container-security-operator-rhel8:v3.11.1-4 libssh 0.9.8
   ```

## Summary of Script Usage

- **No Package Specified:** Lists all packages in the container image.
- **Package Specified:** Searches for the specified package in both RPM and DEB packages, indicating where it was found.
- **Package and Fixed Version Specified:** Searches for the specified package and compares its version to the provided fixed version.

## Example Outputs

1. **Listing All Packages:**

   ```sh
   ./search_package.sh registry.redhat.io/quay/quay-container-security-operator-rhel8:v3.11.1-4
   ```

   **Output:**

   ```
   No package specified. Listing all packages in image 'registry.redhat.io/quay/quay-container-security-operator-rhel8:v3.11.1-4'...
   (lists all RPM and DEB packages)
   ```

2. **Searching for a Specific Package:**

   ```sh
   ./search_package.sh registry.redhat.io/quay/quay-container-security-operator-rhel8:v3.11.1-4 libssh
   ```

   **Output:**

   ```
   Searching for package 'libssh' in image 'registry.redhat.io/quay/quay-container-security-operator-rhel8:v3.11.1-4'...
   Package 'libssh' found in RPM packages:
   libssh-config-0.9.6-13.el8_9.noarch
   libssh-0.9.6-13.el8_9.x86_64
   Package 'libssh' found in DEB packages:
   ```

3. **Searching for a Specific Package and Comparing to a Fixed Version:**

   ```sh
   ./search_package.sh registry.redhat.io/quay/quay-container-security-operator-rhel8:v3.11.1-4 libssh 0.9.8
   ```

   **Output:**

   ```
   Searching for package 'libssh' in image 'registry.redhat.io/quay/quay-container-security-operator-rhel8:v3.11.1-4'...
   Package 'libssh' found in RPM packages:
   libssh-config-0.9.6-13.el8_9.noarch
   libssh-0.9.6-13.el8_9.x86_64
   The installed version in RPM is not the fixed version.
   Package 'libssh' found in DEB packages:
   /bin/bash: dpkg: command not found
   The installed version in DEB is not the fixed version.
   ```

By following this guide, your team members will be able to create, make executable, and run the `search_package.sh` script to obtain detailed package information from container images.

# Detailed Guideline for Creating, Running, and Using the gather_security_data.sh Script

This guideline provides step-by-step instructions for creating, running, and using the `gather_security_data.sh` script. It also explains how to interpret the information it presents.

## 1. Creating the Script

1. **Open a Terminal:**
   Open a terminal window on your computer.

2. **Create a New Script File:**
   Create a new file named `gather_security_data.sh` using your preferred text editor. For example, you can use `nano`:

   ```sh
   nano gather_security_data.sh
   ```

3. **Copy and Paste the Script:**
   Copy the following `gather_security_data.sh` script:

   ```sh
   #!/bin/bash
   # Your script content here
   ```

4. **Save and Exit:**
   Save the file and exit the text editor. In `nano`, you can do this by pressing `Ctrl+X`, then `Y` to confirm saving, and `Enter` to exit.

5. **Make the Script Executable:**

   ```sh
   chmod +x gather_security_data.sh
   ```

## 2. Running the Script

1. **Run the Script with a Container Image and Output File:**

   ```sh
   ./gather_security_data.sh <container-image> <output-file>
   ```

   **Example:**

   ```sh
   ./gather_security_data.sh registry.redhat.io/quay/quay-container-security-operator-rhel8:v3.11.1-4 output.txt
   ```

2. **View the Output File:**
   Use a text editor or a pager like `less` to view the output file:

   ```sh
   less output.txt
   ```

3. **Navigate and Exit `less`:**
   - **Scroll Down:** Press the Space bar to scroll down one page at a time.
   - **Scroll Up:** Press the `b` key to scroll up one page at a time.
   - **Line by Line:** Use the arrow keys to scroll up and down line by line.
   - **Quit:** Press `q` to quit and exit the `less` viewer.

## 3. Interpreting the Information

1. **Repository URL:**
   - The URL of the repository where the container image is stored.
   - **Repository URL:** `https://catalog.redhat.com/api/containers/v1/repositories/registry/registry.access.redhat.com/repository/quay/quay-container-security-operator-rhel8/images`

2. **Image Metadata:**
   - Detailed metadata about the container image, including its versions, architecture, and other relevant information.

   ```json
   {
     "data": [
       {
         "architecture": "amd64",
         "brew": {
           "nvra": "quay-container-security-operator-rhel8-3.11.1-4.amd64"
         },
         "_id": "5f4f69e5f1b6791b7e0a3f9c",
         "_links": {
           "rpm_manifest": {
             "href": "/api/containers/v1/images/id/5f4f69e5f1b6791b7e0a3f9c/rpm-manifest"
           }
         }
       }
     ]
   }
   ```

3. **RPM Manifest Links:**
   - Information about the RPM packages included in the image.
   - **Version:** quay-container-security-operator-rhel8-3.11.1-4.amd64
   - **ID:** 5f4f69e5f1b6791b7e0a3f9c
   - **Link:** `/api/containers/v1/images/id/5f4f69e5f1b6791b7e0a3f9c/rpm-manifest`

4. **Listing RPMs in the Image:**
   - A detailed list of all RPM packages included in the image.

   ```
   Listing RPMs in image ID 5f4f69e5f1b6791b7e0a3f9c...
     - bash-4.4.20-1.el8.x86_64
     - coreutils-8.30-6.el8.x86_64
     - glibc-2.28-101.el8.x86_64
     ...
   ```

5. **Checking Available Updates for RPMs in the Image:**
   - A list of CVEs and advisories for available updates.

   ```
   Checking available updates for RPMs in image ID 5f4f69e5f1b6791b7e0a3f9c...
     - CVE: CVE-2021-33910
       Advisory: RHSA-2021:2717
   -------------------------
     - CVE: CVE-2021-27218
       Advisory: RHSA-2021:3058
   -------------------------
   ```

6. **Latest Image ID:**
   - The ID of the latest image available in the repository.
   - **Latest image ID:** 6140d134702c563e892d3576

7. **Listing RPMs in the Latest Image:**
   - A detailed list of all RPM packages included in the latest image.

   ```
   Listing RPMs in the latest image ID 6140d134702c563e892d3576...
     - bash-4.4.20-2.el8.x86_64
     - coreutils-8.30-7.el8.x86_64
     - glibc-2.28-102.el8.x86_64
     ...
   ```

8. **Checking Vulnerabilities in the Latest Image:**
   - A list of CVEs and advisories for vulnerabilities in the latest image.

   ```
   Checking vulnerabilities in the latest image ID 6140d134702c563e892d3576...
     - CVE: CVE-2021-33910
       Advisory: RHSA-2021:2717
   -------------------------
     - CVE: CVE-2021-27218
       Advisory: RHSA-2021:3058
   -------------------------
   ```

# Detailed Guideline for Creating, Running, and Using the get_cve_info.sh Script

This guideline provides step-by-step instructions for creating, running, and using the `get_cve_info.sh` script. It also explains how to interpret the information it presents.

## 1. Creating the Script

1. **Open a Terminal:**
   Open a terminal window on your computer.

2. **Create a New Script File:**
   Create a new file named `get_cve_info.sh` using your preferred text editor. For example, you can use `nano`:

   ```sh
   nano get_cve_info.sh
   ```

3. **Copy and Paste the Script:**
   Copy the following `get_cve_info.sh` file content into the text editor:

   ```sh
   #!/bin/bash
   # Your script content here
   ```

4. **Save and Exit:**
   Save the file and exit the text editor. In `nano`, you can do this by pressing `Ctrl+X`, then `Y` to confirm saving, and `Enter` to exit.

5. **Make the Script Executable:**

   ```sh
   chmod +x get_cve_info.sh
   ```

## 2. Running the Script

1. **Run the Script with a CVE ID and Output File:**

   ```sh
   ./get_cve_info.sh <CVE-ID> <output-file>
   ```

   **Example:**

   ```sh
   ./get_cve_info.sh CVE-2021-23358 output.txt
   ```

2. **View the Output File:**
   Use a text editor or a pager like `less` to view the output file:

   ```sh
   less output.txt
   ```

3. **Navigate and Exit `less`:**
   - **Scroll Down:** Press the Space bar to scroll down one page at a time.
   - **Scroll Up:** Press the `b` key to scroll up one page at a time.
   - **Line by Line:** Use the arrow keys to scroll up and down line by line.
   - **Quit:** Press `q` to quit and exit the `less` viewer.

## 3. Interpreting the Information

1. **Fetching Details for CVE:**
   The script starts by displaying the CVE ID for which the details are being fetched.

   ```
   Fetching details for CVE: CVE-2021-23358
   ```

2. **CVE Details:**
   Detailed information about the CVE, including affected products, fix state, and advisories.

   ```json
   {
     "CVE": "CVE-2021-23358",
     "threat_severity": "Moderate",
     "public_date": "2021-02-18T00:00:00Z",
     "bugzilla": {
       "description": "nodejs-lodash: Prototype pollution in zipObjectDeep function",
       "id": "1920669",
       "url": "https://bugzilla.redhat.com/show_bug.cgi?id=1920669"
     },
     "cvss3": {
       "cvss3_base_score": "6.1",
       "cvss3_scoring_vector": "CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:N/I:L/A:L",
       "status": "draft"
     },
     "affected_release": [
       {
         "product_name": "Red Hat Advanced Cluster Management for Kubernetes 2.0 for RHEL 8",
         "advisory": "RHSA-2021:1448"
       },
       {
         "product_name": "Red Hat Advanced Cluster Management for Kubernetes 2.2 for RHEL 8",
         "advisory": "RHSA-2021:1499"
       }
     ],
     "package_state": [
       {
         "product_name": "Red Hat Ceph Storage 3",
         "fix_state": "Will not fix"
       }
     ]
   }
   ```

3. **Advisory Details:**
   Detailed information about each advisory related to the CVE.

   **Advisory Details for RHSA-2021:1448:**

   ```json
   {
     "document_title": "RHSA-2021:1448: Moderate: nodejs:12 security update (ABRT plugin)",
     "document_type": "Security Advisory",
     "release_date": "2021-03-17T00:00:00Z",
     "severity": "Moderate",
     "vulnerability_list": [
       {
         "CVE": "CVE-2021-23358",
         "impact": "Moderate"
       }
     ]
   }
   ```

## 4. Example Workflow

1. **Run the Script:**

   ```sh
   ./get_cve_info.sh CVE-2021-23358 output.txt
   ```

2. **View the Output:**

   ```sh
   less output.txt
   ```

3. **Exit `less`:**
   Press `q` to quit.
```

