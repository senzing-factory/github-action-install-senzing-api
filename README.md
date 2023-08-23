# github-action-install-senzing-api

## Synopsis

Install Senzing API in a GitHub Action.

## Overview

The GitHub Action performs a
[system install](https://github.com/Senzing/knowledge-base/blob/main/WHATIS/senzing-system-installation.md)
of Senzing.
The GitHub Action works where the
[RUNNER_OS](https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables)
GitHub variable is `Linux`, `macOS`, or `Windows`.

## Usage

1. A example `.github/workflows/install-senzing-example.yaml` file.
   Example:

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
