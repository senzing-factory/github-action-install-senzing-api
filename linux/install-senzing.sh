#!/usr/bin/env bash
set -e

############################################
# configure-vars
# GLOBALS:
#   SENZING_INSTALL_VERSION
#     one of: production-v<X>, staging-v<X>
#             X.Y.Z, X.Y.Z-ABCDE
############################################
configure-vars() {

  # senzing apt repository packages
  # v3 and lower
  PROD_REPO_V3_AND_LOWER=https://senzing-production-apt.s3.amazonaws.com/senzingrepo_1.0.1-1_all.deb
  STAGING_REPO_V3_AND_LOWER=https://senzing-staging-apt.s3.amazonaws.com/senzingstagingrepo_1.0.1-1_all.deb
  # v4 and above
  PROD_REPO_V4_AND_ABOVE=https://senzing-production-apt.s3.amazonaws.com/senzingrepo_2.0.0-1_all.deb
  STAGING_REPO_V4_AND_ABOVE=https://senzing-staging-apt.s3.amazonaws.com/senzingstagingrepo_2.0.0-1_all.deb

  # semantic versions
  REGEX_SEM_VER="^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$"
  # semantic version with build number
  REGEX_SEM_VER_BUILD_NUM="^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)-([0-9]){5}$"

  if [[ $SENZING_INSTALL_VERSION =~ "production" ]]; then

    echo "[INFO] install senzingapi-runtime from production"
    get-generic-major-version
    is-major-version-greater-than-3 && INSTALL_REPO="$PROD_REPO_V4_AND_ABOVE" || INSTALL_REPO="$PROD_REPO_V3_AND_LOWER"
    SENZING_PACKAGE="senzingapi-runtime"
    restrict-major-version

  elif [[ $SENZING_INSTALL_VERSION =~ "staging" ]]; then

    echo "[INFO] install senzingapi-runtime from staging"
    get-generic-major-version
    is-major-version-greater-than-3 && INSTALL_REPO="$STAGING_REPO_V4_AND_ABOVE" || INSTALL_REPO="$STAGING_REPO_V3_AND_LOWER"
    SENZING_PACKAGE="senzingapi-runtime"
    restrict-major-version

  elif [[ $SENZING_INSTALL_VERSION =~ $REGEX_SEM_VER ]]; then
  
    echo "[INFO] install senzingapi-runtime semantic version"
    get-semantic-major-version
    is-major-version-greater-than-3 && INSTALL_REPO="$PROD_REPO_V4_AND_ABOVE" || INSTALL_REPO="$PROD_REPO_V3_AND_LOWER"
    INSTALL_REPO="$PROD_REPO"
    SENZING_PACKAGE="senzingapi-runtime=$SENZING_INSTALL_VERSION*"

  elif [[ $SENZING_INSTALL_VERSION =~ $REGEX_SEM_VER_BUILD_NUM ]]; then

    echo "[INFO] install senzingapi-runtime semantic version with build number"
    get-semantic-major-version
    is-major-version-greater-than-3 && INSTALL_REPO="$PROD_REPO_V4_AND_ABOVE" || INSTALL_REPO="$PROD_REPO_V3_AND_LOWER"
    INSTALL_REPO="$PROD_REPO"
    SENZING_PACKAGE="senzingapi-runtime=$SENZING_INSTALL_VERSION"

  else
    echo "[ERROR] senzingapi-runtime install version $SENZING_INSTALL_VERSION is unsupported"
    exit 1
  fi

}

############################################
# is-major-version-greater-than-3
# GLOBALS:
#   MAJOR_VERSION
#     set prior to this call via either
#     get-generic-major-version or
#     get-semantic-major-version
############################################
is-major-version-greater-than-3() {

  if [[ $MAJOR_VERSION -gt 3 ]]; then
    return true
  else
    return false
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
# get-semantic-major-version
# GLOBALS:
#   SENZING_INSTALL_VERSION
#     one of: X.Y.Z, X.Y.Z-ABCDE
#     production-v<X> and staging-v<X> 
#     does not apply here
############################################
get-semantic-major-version(){

  MAJOR_VERSION=$(echo ${SENZING_INSTALL_VERSION%%.*})
  echo "[INFO] major version is: $MAJOR_VERSION"
  export MAJOR_VERSION

}

############################################
# restrict-major-version
# GLOBALS:
#   SENZING_INSTALL_VERSION
#     one of: production-v<X>, staging-v<X>
#     semver does not apply here
############################################
restrict-major-version() {

  get-generic-major-version
  senzingapi_runtime_preferences_file="/etc/apt/preferences.d/senzingapi-runtime"
  echo "[INFO] restrict senzingapi-runtime major version to: $MAJOR_VERSION"

  echo "Package: senzingapi-runtime" | sudo tee -a $senzingapi_runtime_preferences_file
  echo "Pin: version $MAJOR_VERSION.*" | sudo tee -a $senzingapi_runtime_preferences_file
  echo "Pin-Priority: 999" | sudo tee -a $senzingapi_runtime_preferences_file

}

############################################
# install-senzing-repository
# GLOBALS:
#   INSTALL_REPO
#     APT Repository Package URL
############################################
install-senzing-repository() {

  echo "[INFO] wget -qO /tmp/senzingrepo.deb $INSTALL_REPO"
  wget -qO /tmp/senzingrepo.deb $INSTALL_REPO
  echo "[INFO] sudo apt-get -y install /tmp/senzingrepo.deb"
  sudo apt-get -y install /tmp/senzingrepo.deb
  echo "[INFO] sudo apt-get update"
  sudo apt-get update

}

############################################
# install-senzingapi
# GLOBALS:
#   SENZING_PACKAGE
#     full package name used for install
############################################
install-senzingapi-runtime() {

  echo "[INFO] sudo --preserve-env apt-get -y install $SENZING_PACKAGE"
  sudo --preserve-env apt-get -y install "$SENZING_PACKAGE"

}

############################################
# Main
############################################

echo "[INFO] senzing version to install is: $SENZING_INSTALL_VERSION"
configure-vars
install-senzing-repository
install-senzingapi-runtime