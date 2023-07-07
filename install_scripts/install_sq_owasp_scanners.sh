#!/bin/bash

# Install SonarScanner CLI
#SONAR_SCANNER_VERSION=4.8.0.2856
#wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip
#unzip sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip
#sudo mv sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux /opt
#sudo ln -s /opt/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux /opt/sonar-scanner
#rm -rf sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip
#echo Add /opt/sonar-scanner/bin to $PATH.

# Install OWASP Dependency Check
OWASP_DC_VERSION=8.3.1
mkdir $HOME/owasp
pushd $HOME/owasp
    wget "https://github.com/jeremylong/DependencyCheck/releases/download/v${OWASP_DC_VERSION}/dependency-check-${OWASP_DC_VERSION}-release.zip"
    unzip dependency-check*.zip
    chmod +x dependency-check/bin/dependency-check.sh
    sudo ln -s $HOME/owasp/dependency-check/bin/dependency-check.sh /usr/local/bin/dependency-check.sh
    mkdir $HOME/owasp/dependency-check/data
    chmod a+w $HOME/owasp/dependency-check/data
popd
