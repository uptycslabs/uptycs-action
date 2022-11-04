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
```

## Configuration

### inputs

The following table defines the inputs that can be used as `step.with` keys:

| Name               | Type    | Default                            | Description                                                                           |
|--------------------|---------|------------------------------------|---------------------------------------------------------------------------------------|
| `uptycs-secret`    | String  |                                    | Tenant-specific secret for authenticating with uptycs                                 |
| `hostname`  | String  |                                    | Hostname for the uptycs stack to send scan results to
| `image-id`         | String  |                                    | The full sha256 docker image reference for the image to scan                          |
| `fatal-cvss-score` | String  | `8`                                | The maximum allowable CVSS score. Any discovered vulnerabilities with a CVSS score above this value will cause a build to fail |
| `custom_ca_cert` | String  | ``                                | A Custom root CA certificate for connecting to uptycs |

### Secrets

Because they contain sensitive information, it is recommended to store both the `uptycs-secret` and `osquery-flags` input parameters as [Github Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets).
