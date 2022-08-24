# Uptycs Image Scan Action

> [GitHub Action](https://github.com/features/actions) for [Uptycs](https://github.com/uptycslabs/uptycs-action)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Uptycs Image Scan Action](#uptycs-image-scan-action)
  - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
    - [Docker Image Scan CI Pipeline](#docker-image-scan-ci-pipeline)
  - [Configuration](#configuration)
    - [inputs](#inputs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Usage

### Docker Image Scan CI Pipeline

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
        run: |
          docker build -t <your image> .

      - name: Run Uptycs vulnerability scanner
        uses: uptycslabs/uptycs-action@main
        with:
          image_id: <your image>
```

## Configuration

### inputs

The following table defines the inputs that can be used as `step.with` keys:

| Name               | Type    | Default                            | Description                                                                           |
|--------------------|---------|------------------------------------|---------------------------------------------------------------------------------------|
| `uptycs-secret`    | String  |                                    | Tenant-specific secret for authenticating with uptycs                                 |
| `ca-certificate`   | String  |                                    | ca.crt for connecting to uptycs                                                       |
| `osquery-flags`    | String  |                                    | Tenant-specific osquery flags                                                         |
| `image-id`         | String  |                                    | The docker image reference for the image to scan                                      |
| `fatal-cvss-score` | String  | `8`                                | The maximum allowable CVSS score. Any vulnerabilities with a CVSS score above this value will cause a build to fail.|
| `tls-hostname`     | String  | `uptycs.io`                        |                                                                                       |
