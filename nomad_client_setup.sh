# Installs all required pre-requisites for running both containerized docker images
# as well as non-containerized Tomcat applications

sudo yum install -y java-1.8.0-openjdk.x86_64
wget http://apache.mirrors.lucidnetworks.net/tomcat/tomcat-7/v7.0.91/bin/apache-tomcat-7.0.91.tar.gz
sudo tar -C /usr/local/ -xvf apache-tomcat-7.0.91.tar.gz
sudo ln -s /usr/local/apache-tomcat-7.0.91 /usr/local/tomcat

sudo sed -i -e 's/dockerd/dockerd --storage-driver=overlay/' /usr/lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl start docker
