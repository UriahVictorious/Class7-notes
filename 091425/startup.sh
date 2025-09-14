#!/bin/bash
# Install and start web server
dnf update -y
dnf install -y httpd
systemctl start httpd
systemctl enable httpd

# Variable for the URL
BASE_URL="http://169.254.169.254/latest"
# Get token for metadata requests
TOKEN=$(curl -X PUT "$BASE_URL/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 3600" -s)

# Collect instance info and save to variables
LOCAL_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "$BASE_URL/meta-data/local-ipv4")
AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "$BASE_URL/meta-data/placement/availability-zone")
HOST_NAME=$(hostname -f)

# GitHub repository URLs - UPDATE THESE WITH YOUR ACTUAL REPO DETAILS
GITHUB_USER="aaron-dm-mcdonald"
GITHUB_REPO="Class7-notes"
GITHUB_BRANCH="main"  # or "master" depending on your default branch

# IMAGE ENVIRONMENT VARIABLES 
IMAGE_1="1.jpg"
IMAGE_2="2.jpg"
IMAGE_3="3.jpg"

# Download index.html from GitHub
curl -o /var/www/html/index.html "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/index.html"

# Download CSS file from GitHub (assuming it's named style.css - adjust as needed)
curl -o /var/www/html/style.css "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/style.css"

# Download images from GitHub using the environment variables
curl -o /var/www/html/${IMAGE_1} "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/${IMAGE_1}"
curl -o /var/www/html/${IMAGE_2} "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/${IMAGE_2}"
curl -o /var/www/html/${IMAGE_3} "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/${IMAGE_3}"


# Inject the instance metadata into the downloaded HTML file
sed -i "s/{{HOSTNAME}}/${HOST_NAME}/g" /var/www/html/index.html
sed -i "s/{{LOCAL_IP}}/${LOCAL_IP}/g" /var/www/html/index.html
sed -i "s/{{AZ}}/${AZ}/g" /var/www/html/index.html

# Inject the image filenames into the HTML file
sed -i "s/{{IMAGE_1}}/${IMAGE_1}/g" /var/www/html/index.html
sed -i "s/{{IMAGE_2}}/${IMAGE_2}/g" /var/www/html/index.html
sed -i "s/{{IMAGE_3}}/${IMAGE_3}/g" /var/www/html/index.html

# Restart httpd to ensure all changes take effect
systemctl restart httpd