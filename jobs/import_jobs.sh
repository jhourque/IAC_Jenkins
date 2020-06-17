#!/bin/bash

jenkins_ip=127.0.0.1
ADMIN_PASSWORD=$(sudo cat /var/lib/jenkins/adminpassword.txt)

TEMPO=300
while [ "$TEMPO" -gt 0 ]; do
    wget http://${jenkins_ip}:8080/jnlpJars/jenkins-cli.jar -O ./jenkins-cli.jar && break || true
    TEMPO=$(($TEMPO-1))
    echo "Jenkins not ready, waiting ..." > /tmp/wait.log
    sleep 1
done

[ -f ./jenkins-cli.jar ] || exit 1

for d in `find . -type d |grep './' |sed 's#\./##'`
do
    echo import directory $d
    java -jar ./jenkins-cli.jar -auth admin:$ADMIN_PASSWORD -s http://${jenkins_ip}:8080 create-job $d < folder.tpl
done


for j in `find . -name '*xml' |sed 's#./##; s#.xml##'`
do
    echo import jobs $j
    java -jar ./jenkins-cli.jar -auth admin:$ADMIN_PASSWORD -s http://${jenkins_ip}:8080 create-job $j < ./${j}.xml
done

