# github-action-install-senzing-api

## Synopsis

A GitHub Action for installing the Senzing API.

## Overview

The GitHub Action performs a
[system install](https://github.com/Senzing/knowledge-base/blob/main/WHATIS/senzing-system-installation.md)
of the Senzing API.
The GitHub Action works where the
[RUNNER_OS](https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables)
GitHub variable is `Linux`, `macOS`, or `Windows`.

## Usage

1. An example `.github/workflows/install-senzing-example.yaml` file
   which installs the latest Senzing API:

    ```yaml
    name: install-senzing-example.yaml

    on: [push]

    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
          - name: Install Senzing API
            uses: Senzing/github-action-install-senzing-api@latest
    ```

1. An example `.github/workflows/install-senzing-example.yaml` file
   which installs a specific Senzing API verson:

    ```yaml
    name: install-senzing-example.yaml

    on: [push]

    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
          - name: Install Senzing API
            uses: Senzing/github-action-install-senzing-api@latest
            with:
              senzingapi-version: 3.6.0-23160
    ```

   If `senzingapi-version` is not specified, the default is "latest".
