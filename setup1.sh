#!/bin/bash

function installPackage(){
    local packageName=${1}
    if ! apt-get install -y ${packageName}
    then
        echo "${packageName} installation is failed."
        exit 1
    fi

}

function mavenTarget(){
    local mavenCmd=${1}
    if ! mvn ${mavenCmd}
    then
        echo "${mavenCmd} Failed."
        exit 1
    fi
}

if [[ ${UID} != 0 ]]
then
    echo "This is not a root user."
    exit 1
fi

read -p "Please enter the access path: " APP_CONTEXT
APP_CONTEXT=${APP_CONTEXT:-app}
IP=$(ifconfig ens33 | grep inet | head -1 | awk '{print $2}')

if ! apt-get update
then
    echo "apt-get update is failed."
    exit 1
fi

installPackage maven
installPackage tomcat9
mavenTarget test
mavenTarget package

if cp -rvf target/hello-world-0.0.1-SNAPSHOT.war /var/lib/tomcat9/webapps/${APP_CONTEXT}.war
then
    echo "App deployment is successful. You can access it on http://${IP}:8080/${APP_CONTEXT}"
else
    echo "App deployment is failed now."
    exit 1
fi
exit 0
