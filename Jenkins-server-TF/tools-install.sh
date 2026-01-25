#!/bin/bash

# --- START LOGGING CONFIGURATION ---
# Log file for debugging
LOG_FILE="/var/log/user-data-install.log"
# Redirect stdout (>) and stderr (2) to the log file, while also printing to console (tee)
exec > >(tee -a ${LOG_FILE}) 2>&1

echo "=== Starting User Data Script at $(date) ==="
# -----------------------------------

# 1. Update and Install Prerequisites (Java & Git)
echo "Step 1: Installing Prerequisites (Java & Git)..."
sudo apt-get update -y
sudo apt-get install fontconfig openjdk-17-jre git -y

# 2. Install Jenkins (Using the required 2026 key)
echo "Step 2: Installing Jenkins..."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
sudo apt-get install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins

# 3. Install Docker
echo "Step 3: Installing Docker..."
sudo apt-get install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins  # Allows Jenkins to run Docker containers

# 4. Install Terraform
echo "Step 4: Installing Terraform..."
sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update -y && sudo apt-get install terraform -y

# 5. Install the Requested Jenkins Plugins
echo "Step 5: Installing Jenkins Plugins..."
sudo systemctl stop jenkins

# wget -O /tmp/jenkins-plugin-manager.jar https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.0/jenkins-plugin-manager-2.13.0.jar

# # List of all plugins you requested
# PLUGINS="eclipse-temurin-installer sonar nodejs docker-plugin docker-commons docker-workflow docker-build-step dependency-check-jenkins terraform aws-credentials pipeline-aws-steps prometheus"

# sudo -u jenkins java -jar /tmp/jenkins-plugin-manager.jar --war /usr/share/java/jenkins.war --plugin-download-directory /var/lib/jenkins/plugins --plugins $PLUGINS
#it may throw error, need to fix this later

# 6. Final Start
echo "Step 6: restarting Jenkins..."
sudo systemctl start jenkins

echo "=== Setup Complete ==="
echo "Jenkins is initializing. Wait about 30 seconds for the password file to be generated..."
sleep 30
echo "----------------------------------------"
echo "Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "----------------------------------------"

# WARNING: This command usually fails in User Data unless you have 
# git cloned a repo containing 'variables.tfvars' into the current directory.
# terraform apply -var-file=variables.tfvars --auto-approve

echo "=== Script Finished at $(date) ==="