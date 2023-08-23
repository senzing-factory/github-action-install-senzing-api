# github-action-install-senzing

## Synopsis

Install Senzing API.

## Overview

The GitHub action performs a
[system install](https://github.com/Senzing/knowledge-base/blob/main/WHATIS/senzing-system-installation.md)
of Senzing.

The GitHub action works where the
[RUNNER_OS](https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables)
GitHub variable is `Linux`, `macOS`, or `Windows`

## Usage

1. A example `.github/workflows/install-senzing.yaml` file.
   Example:

    ```yaml
    name: install-senzing.yaml

    on:
      push:
        tags:
          - "[0-9]+.[0-9]+.[0-9]+"

    jobs:
      build:
        name: Update cmd/github.go
        runs-on: ubuntu-latest
        steps:
          - name: Install Senzing API
            uses: Senzing/github-action-install-senzing@latest
    ```
