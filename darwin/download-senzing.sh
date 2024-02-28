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
    SENZINGAPI_URI="s3://public-read-access/MacOS_API/"
    SENZINGAPI_URL="https://public-read-access.s3.amazonaws.com/MacOS_API"

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
# determine-latest-dmg-for-major-version
# GLOBALS:
#   SENZING_INSTALL_VERSION
#     one of: production-v<X>, staging-v<X>
#   SENZINGAPI_URI
############################################
determine-latest-dmg-for-major-version() {

  major_version=$(echo "$SENZING_INSTALL_VERSION" | grep -Eo '[0-9]+$')
  echo "[INFO] major version is: $major_version"

  aws s3 ls $SENZINGAPI_URI --recursive --no-sign-request | grep -o -E '[^ ]+.dmg$' > /tmp/staging-versions
  latest_staging_version=$(< /tmp/staging-versions grep "_$major_version" | sort -r | head -n 1 | grep -o '/.*')
  rm /tmp/staging-versions
  echo "[INFO] latest staging version is: $latest_staging_version"

  SENZINGAPI_DMG_URL="$SENZINGAPI_URL$latest_staging_version"

}

############################################
# download-dmg
# GLOBALS:
#   SENZINGAPI_DMG_URL
############################################
download-dmg() {

  echo "[INFO] curl --output /tmp/senzingapi.dmg $SENZINGAPI_DMG_URL"
  curl --output /tmp/senzingapi.dmg "$SENZINGAPI_DMG_URL"
  ls -tlc /tmp/

}

############################################
# Main
############################################

echo "[INFO] senzing version to install is: $SENZING_INSTALL_VERSION"
configure-vars
determine-latest-dmg-for-major-version
download-dmg
