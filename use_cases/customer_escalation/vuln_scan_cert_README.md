# Customer Escalation Use Case

This directory contains scripts designed for vulnerability scanning and certification, specifically tailored for customer escalation scenarios. The main scripts included are `vuln_scan_cert.py` and `vuln_scan_cert.sh`.

## Table of Contents
- [Overview](#overview)
- [vuln_scan_cert.py](#vuln_scan_certpy)
  - [Description](#description)
  - [Usage](#usage)
  - [Dependencies](#dependencies)
  - [Example](#example)
- [vuln_scan_cert.sh](#vuln_scan_certsh)
  - [Description](#description)
  - [Usage](#usage)
  - [Example](#example)
- [Sample Data](#sample-data)

## Overview

The `vuln_scan_cert.py` script is a Python-based tool that processes a CSV file containing CVE details and generates an enriched CSV output with additional information such as severity ratings, advisory URLs, and affected products. The `vuln_scan_cert.sh` script is a shell script that facilitates vulnerability scanning and certification.

## vuln_scan_cert.py

### Description

The `vuln_scan_cert.py` script processes a given CSV file containing CVE details, fetches additional information from the Red Hat Security Data API, and generates an enriched CSV output. This script is useful for understanding the impact and status of various vulnerabilities on specified packages.

### Usage

To use the `vuln_scan_cert.py` script, follow these steps:

1. **Setup the virtual environment:**

    ```sh
    python -m venv venv
    source venv/bin/activate  # On Windows use `venv\Scripts\activate`
    pip install -r requirements.txt
    ```

2. **Run the script with the input and output file paths as arguments:**

    ```sh
    python vuln_scan_cert.py path/to/your/input.csv path/to/your/output.csv
    ```

### Dependencies

The script requires the following Python packages, which are listed in the `requirements.txt` file:

- `requests`
- `pandas`

Install the dependencies using:

```sh
pip install -r requirements.txt
```

### Example

1. **Input CSV File:**

    ```
    CVE,Package,Package Version,Severity,CVSS,Description,Vulnerability Link,Fix Status
    CVE-2018-15209,libtiff,4.0.9-28.el8_8,moderate,5.3,"Description of CVE-2018-15209","https://access.redhat.com/security/cve/CVE-2018-15209",affected
    ```

2. **Command to Run:**

    ```sh
    python vuln_scan_cert.py /path/to/input.csv /path/to/output.csv
    ```

3. **Output CSV File:**

    ```
    CVE,Package,Package Version,Severity,RHSA,Advisory URL,Product Name,Fixed Status
    CVE-2018-15209,libtiff,4.0.9-28.el8_8,moderate,RHSA-2018:0001,https://access.redhat.com/errata/RHSA-2018:0001,Red Hat Enterprise Linux 8,Affected
    ```

## vuln_scan_cert.sh

### Description

The `vuln_scan_cert.sh` script is a shell script designed for vulnerability scanning and certification. It can be used to automate the process of fetching CVE details, checking for vulnerabilities, and generating reports.

### Usage

To use the `vuln_scan_cert.sh` script, follow these steps:

1. **Make the script executable:**

    ```sh
    chmod +x vuln_scan_cert.sh
    ```

2. **Run the script:**

    ```sh
    ./vuln_scan_cert.sh
    ```

### Example

1. **Command to Run:**

    ```sh
    ./vuln_scan_cert.sh
    ```

2. **Output:**

    The script will fetch CVE details, check for vulnerabilities, and display the results in the terminal or generate a report based on the implementation.

## Sample Data

### Input CSV Sample

The input CSV file should have the following format:

```csv
CVE,Package,Package Version,Severity,CVSS,Description,Vulnerability Link,Fix Status
CVE-2018-15209,libtiff,4.0.9-28.el8_8,moderate,5.3,"Description of CVE-2018-15209","https://access.redhat.com/security/cve/CVE-2018-15209",affected
CVE-2019-20916,pip,9.0.3,medium,8,"Description of CVE-2019-20916","https://nvd.nist.gov/vuln/detail/CVE-2019-20916",fixed in 19.2
```

### Output CSV Sample

The output CSV file generated by the `vuln_scan_cert.py` script will have the following format:

```csv
CVE,Package,Package Version,Severity,RHSA,Advisory URL,Product Name,Fixed Status
CVE-2018-15209,libtiff,4.0.9-28.el8_8,moderate,RHSA-2018:0001,https://access.redhat.com/errata/RHSA-2018:0001,Red Hat Enterprise Linux 8,Affected
CVE-2019-20916,pip,9.0.3,medium,RHSA-2019:0002,https://access.redhat.com/errata/RHSA-2019:0002,Red Hat Enterprise Linux 8,Fixed
```

---

This README provides detailed instructions and information for using the `vuln_scan_cert.py` and `vuln_scan_cert.sh` scripts for the Customer Escalation use case. For any issues or further assistance, please refer to the individual script comments and documentation.
