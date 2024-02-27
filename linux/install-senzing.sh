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
  PROD_REPO=https://senzing-production-apt.s3.amazonaws.com/senzingrepo_1.0.1-1_all.deb
  STAGING_REPO=https://senzing-staging-apt.s3.amazonaws.com/senzingstagingrepo_1.0.1-1_all.deb

  # semantic versions
  REGEX_SEM_VER="^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$"
  # semantic version with build number
  REGEX_SEM_VER_BUILD_NUM="^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)-([0-9]){5}$"

  if [[ $SENZING_INSTALL_VERSION =~ "production" ]]; then

    echo "[INFO] install senzingapi from production"
    INSTALL_REPO="$PROD_REPO"
    SENZING_PACKAGE="senzingapi"
    restrict-major-version

  elif [[ $SENZING_INSTALL_VERSION =~ "staging" ]]; then

    echo "[INFO] install senzingapi from staging"
    INSTALL_REPO="$STAGING_REPO"
    SENZING_PACKAGE="senzingapi"
    restrict-major-version

  elif [[ $SENZING_INSTALL_VERSION =~ $REGEX_SEM_VER ]]; then
  
    echo "[INFO] install senzingapi semantic version"
    INSTALL_REPO="$PROD_REPO"
    SENZING_PACKAGE="senzingapi=$SENZING_INSTALL_VERSION*"

  elif [[ $SENZING_INSTALL_VERSION =~ $REGEX_SEM_VER_BUILD_NUM ]]; then

    echo "[INFO] install senzingapi semantic version with build number"
    INSTALL_REPO="$PROD_REPO"
    SENZING_PACKAGE="senzingapi=$SENZING_INSTALL_VERSION"

  else
    echo "[ERROR] senzingapi install version $SENZING_INSTALL_VERSION is unsupported"
    exit 1
  fi

}

############################################
# install-senzing-repository
# GLOBALS:
#   SENZING_INSTALL_VERSION
#     one of: production-v<X>, staging-v<X>
#     semver does not apply here
############################################
restrict-major-version() {

  MAJOR_VERSION=$(echo "$SENZING_INSTALL_VERSION" | grep -Eo '[0-9]+$')
  senzingapi_preferences_file="/etc/apt/preferences.d/senzingapi"
  echo "[INFO] restrict senzingapi major version to: $MAJOR_VERSION"

  echo "Package: senzingapi" | sudo tee -a $senzingapi_preferences_file
  echo "Pin: version $MAJOR_VERSION.*" | sudo tee -a $senzingapi_preferences_file
  echo "Pin-Priority: 999" | sudo tee -a $senzingapi_preferences_file

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
install-senzingapi() {

  echo "[INFO] sudo --preserve-env apt-get -y install $SENZING_PACKAGE"
  sudo --preserve-env apt-get -y install "$SENZING_PACKAGE"

}

############################################
# Main
############################################

echo "[INFO] senzing version to install is: $SENZING_INSTALL_VERSION"
configure-vars
install-senzing-repository
install-senzingapi