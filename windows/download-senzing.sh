#!/usr/bin/env bash
set -e

############################################
# configure-vars
# GLOBALS:
#   SENZING_INSTALL_VERSION
#     one of: production-v<X>, staging-v<X>
############################################
configure-vars() {

  if [[ $SENZING_INSTALL_VERSION =~ "production" ]]; then

    echo "[INFO] install senzingapi from production"
    SENZINGAPI_URI="s3://public-read-access/Windows_API/"
    SENZINGAPI_URL="https://public-read-access.s3.amazonaws.com/Windows_API"

  elif [[ $SENZING_INSTALL_VERSION =~ "staging" ]]; then

    echo "[INFO] install senzingapi from staging"
    SENZINGAPI_URI="s3://public-read-access/staging/"
    SENZINGAPI_URL="https://public-read-access.s3.amazonaws.com/staging"

  else
    echo "[ERROR] senzingapi install version $SENZING_INSTALL_VERSION is unsupported"
    exit 1
  fi 

}

############################################
# determine-latest-zip-for-major-version
# GLOBALS:
#   SENZING_INSTALL_VERSION
#     one of: production-v<X>, staging-v<X>
#   SENZINGAPI_URI
############################################
determine-latest-zip-for-major-version() {

  major_version=$(echo "$SENZING_INSTALL_VERSION" | grep -Eo '[0-9]+$')
  echo "[INFO] major version is: $major_version"

  aws s3 ls $SENZINGAPI_URI --recursive --no-sign-request --region us-east-1 | grep -o -E '[^ ]+.zip$' > /tmp/staging-versions
  latest_staging_version=$(< /tmp/staging-versions grep "_$major_version" | sort -r | head -n 1 | grep -o '/.*')
  rm /tmp/staging-versions
  echo "[INFO] latest staging version is: $latest_staging_version"

  SENZINGAPI_ZIP_URL="$SENZINGAPI_URL$latest_staging_version"

}

############################################
# download-zip
# GLOBALS:
#   SENZINGAPI_ZIP_URL
############################################
download-zip() {

  echo "[INFO] curl --output senzingapi.zip $SENZINGAPI_ZIP_URL"
  curl --output /tmp/senzingapi.zip "$SENZINGAPI_ZIP_URL"
  pwd
  ls -tlc

}

############################################
# Main
############################################

echo "[INFO] senzing version to install is: $SENZING_INSTALL_VERSION"
configure-vars
determine-latest-zip-for-major-version
download-zip
