#!/bin/bash

# Function to install Jenkins on Ubuntu/Debian
install_jenkins_ubuntu() {
	local new_port=8081
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt update
    sudo apt install openjdk-17-jre
    sudo apt install -y jenkins"$1"
    sudo sed -i "s/Environment=\"JENKINS_PORT=8080\"/Environment=\"JENKINS_PORT=$new_port\"/" /usr/lib/systemd/system/jenkins.service
    sudo systemctl daemon-reload
    sudo systemctl restart jenkins
}

# Function to install Jenkins on CentOS/RHEL
install_jenkins_centos() {
	local new_port=8081
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
	sudo yum upgrade
	sudo yum install java -y
	sudo yum install jenkins"$1" -y
	sudo sed -i "s/Environment=\"JENKINS_PORT=8080\"/Environment=\"JENKINS_PORT=$new_port\"/" /usr/lib/systemd/system/jenkins.service
	sudo systemctl daemon-reload
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
}

# Check the operating system
if [[ -e /etc/os-release ]]; then
    source /etc/os-release
    case $ID in
        ubuntu|debian)
            install_jenkins_ubuntu "$1"
            ;;
        centos|rhel|amzn)
            install_jenkins_centos "$1"
            ;;
        *)
            echo "Unsupported operating system: $ID"
            exit 1
            ;;
    esac
else
    echo "Unable to determine the operating system."
    exit 1
fi
echo "Your intial admin password is"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
