# github-action-make-go-github-file

## Synopsis

Install Senzing API.

## Overview

The github action performs a
[system install](https://github.com/Senzing/knowledge-base/blob/main/WHATIS/senzing-system-installation.md)
of Senzing.

## Usage

1. A `.github/workflows/make-go-github-file.yaml` file
   that creates a `cmd/github.go` file for "package cmd".
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
            uses: Senzing/github-action-install-senzing@main
    ```
