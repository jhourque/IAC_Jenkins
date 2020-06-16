for i in `cat plugins.txt`
do
    wget https://updates.jenkins-ci.org/latest/$i
done
