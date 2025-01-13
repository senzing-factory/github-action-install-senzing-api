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
    SENZINGAPI_URI="s3://senzing-staging-osx/"
    SENZINGAPI_URL="https://senzing-staging-osx"

  else
    echo "[ERROR] senzingapi install version $SENZING_INSTALL_VERSION is unsupported"
    exit 1
  fi 

}

############################################
# get-generic-major-version
# GLOBALS:
#   SENZING_INSTALL_VERSION
#     one of: production-v<X>, staging-v<X>
#     semver does not apply here
############################################
get-generic-major-version(){

  MAJOR_VERSION=$(echo "$SENZING_INSTALL_VERSION" | grep -Eo '[0-9]+$')
  echo "[INFO] major version is: $MAJOR_VERSION"
  export MAJOR_VERSION

}

############################################
# is-major-version-greater-than-3
# GLOBALS:
#   MAJOR_VERSION
#     set prior to this call via
#     get-generic-major-version
############################################
is-major-version-greater-than-3() {

  if [[ $MAJOR_VERSION -gt 3 ]]; then
    echo "[ERROR] this action only supports senzing major versions 3 and lower"
    echo "[ERROR] please refer to https://github.com/senzing-factory/github-action-install-senzing-sdk"
    echo "[ERROR] for installing senzing versions 4 and above"
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

  get-generic-major-version
  is-major-version-greater-than-3

  aws s3 ls $SENZINGAPI_URI --recursive --no-sign-request | grep -o -E '[^ ]+.dmg$' > /tmp/staging-versions
  latest_staging_version=$(< /tmp/staging-versions grep "_$MAJOR_VERSION" | sort -r | head -n 1 | grep -o '/.*')
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

}

############################################
# install-senzing
# GLOBALS:
#   MAJOR_VERSION
#     set prior to this call via either
#     get-generic-major-version or
#     get-semantic-major-version
############################################
install-senzing() {

  ls -tlc /tmp/
  hdiutil attach /tmp/senzingapi.dmg
  sudo mkdir -p /opt/senzing/
  sudo cp -R /Volumes/SenzingAPI/senzing/g2 /opt/senzing

}

############################################
# verify-installation
# GLOBALS:
#   MAJOR_VERSION
#     set prior to this call via either
#     get-generic-major-version or
#     get-semantic-major-version
############################################
verify-installation() {

  echo "[INFO] verify senzing installation"
  if [ ! -f /opt/senzing/g2/g2BuildVersion.json ]; then
    echo "[ERROR] /opt/senzing/g2/g2BuildVersion.json not found."
    exit 1
  else
    echo "[INFO] cat /opt/senzing/g2/g2BuildVersion.json"
    cat /opt/senzing/g2/g2BuildVersion.json
  fi

}

############################################
# Main
############################################

echo "[INFO] senzing version to install is: $SENZING_INSTALL_VERSION"
configure-vars
determine-latest-dmg-for-major-version
download-dmg
install-senzing
verify-installation
