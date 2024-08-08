import csv
import requests
import json
import pandas as pd
import sys
import os


# Function to get CVE details from Red Hat Security Data API
def get_cve_details(cve_id):
    try:
        response = requests.get(f"https://access.redhat.com/hydra/rest/securitydata/cve/{cve_id}.json")
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching details for CVE {cve_id}: {e}")
        return None


# Function to get the severity rating for a CVE
def get_severity_rating(cve_details):
    return cve_details.get('threat_severity', 'N/A')


# Function to get the list of all RHSAs attached to a CVE
def get_rhsa_list(cve_details):
    return list(set(release['advisory'] for release in cve_details.get('affected_release', [])))


# Function to get advisory URL
def get_advisory_url(advisory_id):
    return f"https://access.redhat.com/errata/{advisory_id}"


# Function to get advisories and products affected by a CVE
def get_advisories_and_products(cve_details):
    return [
        {
            'advisory': release['advisory'],
            'product_name': release['product_name'],
            'package': release.get('package', 'N/A'),
            'version': release.get('product_version', 'N/A')
        }
        for release in cve_details.get('affected_release', [])
    ]


# Function to check affected status for a given CVE, package, and version
def check_affected_status(cve_details, package_name, package_version):
    return [
        state['fix_state']
        for state in cve_details.get('package_state', [])
        if state['package_name'] == package_name and (state.get('product_version', '') == package_version or package_version == "")
    ]


def main(input_file_path, output_file_path):

    # Read input CSV file
    data = pd.read_csv(input_file_path)

    # Prepare the output data
    output_data = []

    for index, row in data.iterrows():
        cve_id = row['CVE']
        package_name = row['Package']
        package_version = row['Package Version']

        print(f"\nProcessing CVE: {cve_id}, Package: {package_name}, Version: {package_version}")

        cve_details = get_cve_details(cve_id)
        if cve_details is None:
            continue

        # Fetch and print the severity rating
        severity = get_severity_rating(cve_details)
        print(f"Severity: {severity}")

        # Fetch and print the list of RHSAs attached to the CVE
        rhsa_list = get_rhsa_list(cve_details)
        print(f"RHSAs: {', '.join(rhsa_list) if rhsa_list else 'N/A'}")

        # Fetch and print advisories and products affected by the CVE
        advisories_products = get_advisories_and_products(cve_details)
        for advisory_product in advisories_products:
            print(f"Advisory: {advisory_product['advisory']}")
            print(f"Product Name: {advisory_product['product_name']}")
            print(f"Package: {advisory_product['package']}")
            print(f"Version: {advisory_product['version']}")
            print(f"Advisory URL: {get_advisory_url(advisory_product['advisory'])}")

        # Fetch and print affected status for the given CVE, package, and version
        affected_status = check_affected_status(cve_details, package_name, package_version)
        print(f"Fixed Status: {affected_status[0] if affected_status else 'N/A'}")

        # Prepare data for output CSV
        for advisory_product in advisories_products:
            if advisory_product['package'] == package_name and (package_version == "" or advisory_product['version'] == package_version):
                row_data = {
                    'CVE': cve_id,
                    'Package': package_name,
                    'Package Version': package_version,
                    'Severity': severity,
                    'RHSA': advisory_product['advisory'],
                    'Advisory URL': get_advisory_url(advisory_product['advisory']),
                    'Product Name': advisory_product['product_name'],
                    'Fixed Status': affected_status[0] if affected_status else 'N/A'
                }
                output_data.append(row_data)

    # Write output data to CSV
    output_df = pd.DataFrame(output_data)
    output_df.to_csv(output_file_path, index=False)
    print(f"\nEnriched data has been written to {output_file_path}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python vuln_scan_cert.py <input_file_path> <output_file_path>")
        sys.exit(1)

    input_file_path = sys.argv[1]
    output_file_path = sys.argv[2]

    # Check if the input file exists
    if not os.path.isfile(input_file_path):
        print(f"Error: The file '{input_file_path}' does not exist.")
        sys.exit(1)

    main(input_file_path, output_file_path)

# command on terminal: python vuln_scan_cert.py "Vuln Scan Cert Test Data 1 - Resubmitted Python.csv" "output - Sheet1.csv"
