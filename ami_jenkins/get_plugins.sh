for i in `cat /tmp/plugins.txt`
do
    wget https://updates.jenkins-ci.org/latest/$i
done
