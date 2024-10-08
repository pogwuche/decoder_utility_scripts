# component_pedigree.sh Script

The `component_pedigree.sh` script is designed to trace the origin and inclusion rationale of fixed components within container images. This script takes a component version from a container and outputs its pedigree, detailing its origin, inclusion rationale, and patch information. Below is a detailed explanation of what the pedigree summary tells us, including an example pedigree summary generated by the script.

**Short Video explaining how it works:** [Watch Video](https://www.loom.com/share/8d8d552f51a9450f80c86d8161479efe?sid=57df1d67-3e7f-4ff1-bc37-7f1905f3e0fd)

## Example Command

```sh
./component_pedigree.sh registry.access.redhat.com/quay/quay-container-security-operator-rhel8:v3.11.1-4 libssh 0.9.8
```

## Example Pedigree Summary

```
=== Pedigree Summary ===
Image ID: 663d48de4fc225b41c54e647
Package 'libssh' found in RPM packages:
libssh-0.9.6-13.el8_9.x86_64
libssh-config-0.9.6-13.el8_9.noarch
Installed version: 0.9.6-13.el8_9.x86_64
config-0.9.6-13.el8_9.noarch
The installed version in RPM is not the fixed version.
Fixed version: 0.9.8
CVE ID: CVE-2023-6918
Advisory: RHSA-2024:3233
Advisory URL: https://access.redhat.com/errata/RHSA-2024:3233
Upstream fix version: libssh 0.9.8, libssh 0.10.6
The installed version is not the upstream fixed version.
CVE ID: CVE-2023-6004
Advisory: RHSA-2024:3233
Advisory URL: https://access.redhat.com/errata/RHSA-2024:3233
```

## What the Pedigree Summary Tells Us

1. **Image ID:**
    - **Image ID:** 663d48de4fc225b41c54e647
    - This unique identifier is crucial for tracking and referencing the specific container image being analyzed. It helps in pinpointing the exact build and version of the image in question.

2. **Package Information:**
    - **Package ‘libssh’ found in RPM packages:**
    - This confirms that the specified package (`libssh`) is present in the container image.
    - **Installed version:** `libssh-0.9.6-13.el8_9.x86_64` or `libssh-config-0.9.6-13.el8_9.noarch`
    - This indicates the version of the package that is currently installed in the container image.
    - **The installed version in RPM is not the fixed version.**
    - This statement tells us that the installed version of the package does not match the provided fixed version, indicating a potential security risk.
    - **Fixed version:** `libssh 0.9.8, libssh 0.10.6`
    - This shows the version of the package that is known to be fixed for the vulnerabilities identified. This comparison is crucial for understanding if the current container image is protected against known vulnerabilities.

3. **Vulnerabilities and Updates:**
    - **CVE IDs and Advisories:**
    - The script lists all known CVEs (Common Vulnerabilities and Exposures) that affect the package and the corresponding advisories that address these vulnerabilities. Each advisory provides detailed information on the fixes available for the identified CVEs.
    - **Example:**
        - **CVE ID:** CVE-2024-2961
        - **Advisory:** RHSA-2024:3269
        - **CVE ID:** CVE-2024-33602
        - **Advisory:** RHSA-2024:3344
    - This information is critical for security teams to assess the risk and ensure that the container image is updated with the latest security patches.

## Detailed Guideline for `component_pedigree.sh` Script

### 1. Script Creation

To create the `component_pedigree.sh` script, follow these steps:

- **Open a Terminal:** On your Linux machine, open a terminal.
- **Create the Script File:** Use a text editor such as `nano` or `vim` to create the script file. For example:

    ```sh
    nano component_pedigree.sh
    ```

- **Copy the Script Content:** Copy the entire content of the `component_pedigree.sh` script.
- **Save and Close the File:** Save the file and exit the text editor. In `nano`, you can do this by pressing `Ctrl+O`, then `Enter` to save, and `Ctrl+X` to exit.
- **Make the Script Executable:** Change the permissions of the script file to make it executable:

    ```sh
    chmod +x component_pedigree.sh
    ```

### 2. Running the Script

To run the `component_pedigree.sh` script, follow these steps:

- **Open a Terminal:** On your Linux machine, open a terminal.
- **Navigate to the Directory:** Navigate to the directory where the script file is located:

    ```sh
    cd /path/to/directory
    ```

- **Run the Script:** Use the following command format to run the script:

    ```sh
    ./component_pedigree.sh <container-image> <package-name> [fixed-version]
    ```

    **Example:**

    ```sh
    ./component_pedigree.sh registry.access.redhat.com/quay/quay-container-security-operator-rhel8:v3.11.1-4 libssh 0.9.8
    ```
```
