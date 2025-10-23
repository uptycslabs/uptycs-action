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
          echo ::set-output name=image::<your image>

      - name: Run Uptycs vulnerability scanner
        uses: uptycslabs/uptycs-action@main
        with:
          image-id: ${{ steps.image_build.outputs.image }}
          # It's recommended to store the UPTYCS_CREDENTIALS as a secrets.
          #
          # See the section below on secrets management for additional
          # information.
          credentials: ${{ secrets.UPTYCS_CREDENTIALS }}
```

## Configuration

### inputs

The following table defines the inputs that can be used as `step.with` keys:

| Name                           | Type    | Default | Description                                                                           |
|--------------------------------|---------|---------|---------------------------------------------------------------------------------------|
| `credentials`                  | String  |         | JSON formatted credentials used to authenticate to Uptycs.                            |
| `image`                        | String  |         | The docker image to scan.                                                             |
| `fata-cvss-score`              | Float   | -1      | Maximum allowable CVSS score for a detected vulnerability.                            |
| `fatal-vulnerability-severity` | String  |         | Maximum allowable severity for a detected vulnerability.                              |
| `ignore-no-exploit`            | Boolean |         | Ignore any vulnerabilities for which no known exploits are available.                 |
| `ignore-no-fix`                | Boolean |         | Ignore any vulnerabilities for which no fixes are available.                          |
| `output-format`                | String  |         | The format type to use when writing reports to disk. Either 'json' or 'csv'.          |
| `output-name`                  | String  |         | A unique ID that can be used to organize output files from multiple scans. Defaults to the id of the scanned image. |
| `policy-name`                  | String  |         | The name of an image security policy to evaluate the image against.                   |
| `scanner-image`                | String  |         | A specific uptycs-ci image to use. By default the latest stable image will be used.   |
| `uptycs-ca-cert`               | String  |         | Path to a custom root CA Certificate for connecting to uptycs.                        |
| `verbose`                      | String  |         | Include verbose output.                                                               |
| `exit-on-error`                | String  |         | Return a non-zero exit code for scan results with vulnerabilities/secrets/malware     |


### Secrets

Because they contain sensitive information, it is recommended to store all api credentials as [Github Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets).
