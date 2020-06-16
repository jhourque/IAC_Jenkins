#!/bin/bash

jenkins_ip=$(cd ../terraform; ../.bin/terraform output jenkins_ip)

TEMPO=300
while [ "$TEMPO" -gt 0 ]; do
    wget http://${jenkins_ip}:8080/jnlpJars/jenkins-cli.jar -O ./jenkins-cli.jar && break || true
    TEMPO=$(($TEMPO-1))
    echo "Jenkins not ready, waiting ..." > /tmp/wait.log
    sleep 1
done

[ -f ./jenkins-cli.jar ] || exit 1

STET_ADMIN_PASSWORD=$(cd ../terraform; make get_password)


for d in `find . -type d |grep './' |sed 's#\./##'`
do
    echo import directory $d
    java -jar ./jenkins-cli.jar -auth stetadmin:$STET_ADMIN_PASSWORD -s http://${jenkins_ip}:8080 create-job $d < folder.tpl
done


for j in `find . -name '*xml' |sed 's#./##; s#.xml##'`
do
    echo import jobs $j
    java -jar ./jenkins-cli.jar -auth stetadmin:$STET_ADMIN_PASSWORD -s http://${jenkins_ip}:8080 create-job $j < ./${j}.xml
done

