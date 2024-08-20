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
    return 0
  else
    return 1
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

  get-generic-major-version

  aws s3 ls $SENZINGAPI_URI --recursive --no-sign-request --region us-east-1 | grep -o -E '[^ ]+.zip$' > /tmp/staging-versions
  latest_staging_version=$(< /tmp/staging-versions grep "_$MAJOR_VERSION" | sort -r | head -n 1 | grep -o '/.*')
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
  curl --output senzingapi.zip "$SENZINGAPI_ZIP_URL"

}


############################################
# install-senzing
############################################
install-senzing() {

  7z x -y -o"C:\Program Files" senzingapi.zip 
  mv "C:\Program Files\senzing" "C:\Program Files\Senzing"

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
  is-major-version-greater-than-3 && BUILD_VERSION_PATH="er/szBuildVersion" || BUILD_VERSION_PATH="g2/g2BuildVersion"
  if [ ! -f "/c/Program Files/senzing/$BUILD_VERSION_PATH.json" ]; then
    echo "[ERROR] /c/Program Files/senzing/$BUILD_VERSION_PATH.json not found."
    exit 1
  else
    echo "[INFO] cat /c/Program Files/senzing/$BUILD_VERSION_PATH.json"
    cat "/c/Program Files/senzing/$BUILD_VERSION_PATH.json"
  fi

}

############################################
# Main
############################################

echo "[INFO] senzing version to install is: $SENZING_INSTALL_VERSION"
configure-vars
determine-latest-zip-for-major-version
download-zip
install-senzing
verify-installation
