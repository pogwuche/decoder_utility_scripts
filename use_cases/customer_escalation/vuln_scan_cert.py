import csv
import requests
import json
import pandas as pd

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


# Path to the input CSV file
input_file_path = '/workspaces/decoder_utility_scripts/Vuln Scan Cert Test Data 1 - Resubmitted Python.csv'
output_file_path = '/workspaces/decoder_utility_scripts/output - Sheet1.csv'

# Read input CSV file
data = pd.read_csv(input_file_path)

# Prepare the output data
output_data = []

for index, row in data.iterrows():
    cve_id = row['CVE']
    package_name = row['Package']
    package_version = row['Package Version']
    
    print(f"Processing CVE: {cve_id}, Package: {package_name}, Version: {package_version}")
    
    cve_details = get_cve_details(cve_id)
    
    if cve_details is None:
        continue

    severity = get_severity_rating(cve_details)
    rhsa_list = get_rhsa_list(cve_details)
    advisories_products = get_advisories_and_products(cve_details)
    affected_status = check_affected_status(cve_details, package_name, package_version)
    
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
            print(output_data)  # Print each row of data to the terminal

# Write output data to CSV
output_df = pd.DataFrame(output_data)
output_df.to_csv(output_file_path, index=False)

print(f"Enriched data has been written to {output_file_path}")



