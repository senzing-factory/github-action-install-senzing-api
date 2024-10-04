# github-action-install-senzing-api

## Synopsis

A GitHub Action for installing the Senzing API.

## Overview

The GitHub Action performs a
[system install]
of the Senzing API.
The GitHub Action works where the
[RUNNER_OS]
GitHub variable is `Linux`, `macOS`, or `Windows`.

## Usage

1. An example `.github/workflows/install-senzing-example.yaml` file
   which installs the latest released Senzing API:

    ```yaml
    name: install senzing example

    on: [push]

    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
          - name: Install Senzing API
            uses: senzing-factory/github-action-install-senzing-api@v4
            with:
              senzingapi-version: production-v3
    ```

1. An example `.github/workflows/install-senzing-example.yaml` file
   which installs a specific Senzing API version:

    ```yaml
    name: install senzing example

    on: [push]

    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
          - name: Install Senzing API
            uses: senzing-factory/github-action-install-senzing-api@v4
            with:
              senzingapi-version: 3.6.0-23160
    ```

1. An example `.github/workflows/install-senzing-example.yaml` file
   which installs senzingapi-runtime and senzingapi-setup with a 
   specific Senzing API semantic version:

    ```yaml
    name: install senzing example

    on: [push]

    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
          - name: Install Senzing API
            uses: senzing-factory/github-action-install-senzing-api@v4
            with:
              package(s)-to-install: "senzingapi-runtime senzingapi-setup"
              senzingapi-version: 3.12.0
    ```

### package(s)-to-install

`package(s)-to-install` values can include the following:

- Version <= 3.X:
  - `senzingapi`
  - `senzingapi-runtime`
  - `senzingapi-setup`
  - `senzingapi-tools`
  - `senzingdata-v<X>`
- Version >= 4.0:
  - `senzingapi-poc`
  - `senzingapi-runtime`
  - `senzingapi-setup`
  - `senzingapi-tools`

### senzingapi-version

`senzingapi-version` values can include the following:

- `production-v<MAJOR_VERSION>`
  - Ex. `production-v3`
  - This will install the latest version of the respective major version from *production*.
- `staging-v<MAJOR_VERSION>`
  - Ex. `staging-v3`
  - This will install the latest version of the respective major version from *staging*.
- `X.Y.Z`
  - Ex. `3.8.2`
  - This will install the latest build of the respective semantic version from *production*.
- `X.Y.Z-ABCDE`
  - Ex. `3.8.3-24043`
  - This will install the exact version supplied from *production*.

[RUNNER_OS]: https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables
[system install]: https://github.com/senzing-garage/knowledge-base/blob/main/WHATIS/senzing-system-installation.md
