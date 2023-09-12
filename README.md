# Uptycs Image Scan Action

[GitHub Action](https://github.com/features/actions) for [Uptycs](https://github.com/uptycslabs/uptycs-action), providing Docker image vulnerability scanning.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Usage](#usage)
  - [Example Docker Image Scan CI Pipeline](#example-docker-image-scan-ci-pipeline)
- [Configuration](#configuration)
  - [inputs](#inputs)
  - [Secrets](#secrets)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Usage

### Example Docker Image Scan CI Pipeline

```yaml
name: build
on:
  push:
    branches:
      - main

jobs:
  build:
    name: Build
    runs-on: ubuntu-20.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Build an image from Dockerfile
        id: image_build
        run: |
          docker build -t <your image> --iidfile=image_id.out .
          echo ::set-output name=image_id::$(cat image_id.out)

      - name: Run Uptycs vulnerability scanner
        uses: uptycslabs/uptycs-action@main
        with:
          image-id: ${{ steps.image_build.outputs.image_id }}
          # It's recommended to store both the uptycs-secret and the
          # uptycs-hostname values as secrets. See the section below on secrets
          # management for additional information.
          uptycs-secret: ${{ secrets.UPTYCS_SECRET }}
          uptycs-hostname: ${{ secrets.UPTYCS_HOSTNAME }}
          api-key: ${{ secrets.UPTYCS_API_KEY }}
          api-secret: ${{ secrets.UPTYCS_API_SECRET }}
          customer-id: ${{ secrets.UPTYCS_CUSTOMER_ID }}
```

## Configuration

### inputs

The following table defines the inputs that can be used as `step.with` keys:

| Name                           | Type    | Default            | Description                                                                           |
|--------------------------------|---------|--------------------|---------------------------------------------------------------------------------------|
| `uptycs-secret`                | String  |                    | Tenant-specific secret for authenticating with uptycs                                 |
| `hostname`                     | String  |                    | Hostname for the uptycs stack to send scan results to                                 |
| `image-id`                     | String  |                    | The full sha256 docker image reference for the image to scan                          |
| `fatal-cvss-score`             | String  | `7`                | The maximum allowable CVSS score. Any discovered vulnerabilities with a CVSS score above this value will cause a build to fail |
| `vulnerabilities-enabled`      | String  | true               | Enable or disable vulnerability scanning                                              |
| `secret-scanning-enabled`      | String  | true               | Enable or disable secret scanning                                                     |
| `secret-path`                  | String  | `'/%%'`            | Path to scan for secrets                                                              |
| `malware-path`                 | String  | `'/%%'`            | Path to scan for malware                                                              |
| `api-key`                      | String  |                    | Tenant-specific key for authenticating to the uptycs API. Required if enabling grace-period. |
| `api-secret`                   | String  |                    | Tenant-specific secret for authenticating to the uptycs API. Required if enabling grace-period. |
| `customer-id`                  | String  |                    | Uptycs Customer ID. Required if enabling grace-period.                                |
| `grace-period`                 | String  |                    | Duration of time to allow vulnerabilities to remain in an image without failing a build. Example: `grace-period: "7d"` |
| `ignore-no-fix`                | String  | false              | Only report vulnerabilities for which fixes are available.                            |
| `custom-ca-cert`               | String  | ``                 | A Custom root CA certificate for connecting to uptycs                                 |
| `output-log-format`            | String  | `'tab'`            | The format type to use when logging results to stdout. Valid values are 'json' and 'tab'. |
| `output-format`                | String  | `'json'`           | The format type to use when writing reports to disk. Valid values are 'json' and 'csv'. |
| `ignore-cve-file`              | String  |                    | Ignore any CVEs contained within the specified CSV file.                              |
| `ignore-packages-file`         | String  |                    | Ignore vulnerabilities in packages specified within the specified CSV file.           |
| `ignore-no-exploit`            | String  | false              | Ignore any vulnerabilities for which no known exploits are available.                 |
| `audit`                        | String  | false              | Run an audit of the specified image but do not fail the build.                        |
| `fatal-secret-severity`        | String  | `'high'`           | Severity level at which detected secrets will fail the build.                         |
| `fatal-vulnerability-severity` | String  |                    | Maximum allowable severity for a detected vulnerability.                              |
| `vulnerability-log-minimum`    | String  |                    | Filter any vulnerabilities with a severity lower than the specified severity when logging results. |
| `secret-log-minimum`           | String  | `'high'`           | Filter any secrets with a severity lower than the specified severity when logging results. |
| `config-file`                  | String  | `'.uptycs-ci.yml'` | The path to the uptycs-ci configuration file to load.                                 |


### Secrets

Because they contain sensitive information, it is recommended to store both the `uptycs-secret` and `osquery-flags` input parameters as [Github Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets).
