#!/bin/bash

# Install and start web server
dnf update -y
dnf install -y httpd
systemctl start httpd
systemctl enable httpd

# Configuration variables for webpage
IMAGE="https://www.w3schools.com/images/w3schools_green.jpg"
TEXT="My EC2 Instance"

# Get IMDS token and set variables for metadata requests
BASE_URL="http://169.254.169.254/latest"
HEADERS="X-aws-ec2-metadata-token"

TOKEN=$(curl -X PUT "$BASE_URL/api/token" -H "$HEADERS-ttl-seconds: 3600" -s)

# Collect instance info
LOCAL_IP=$(curl -H "$HEADERS: $TOKEN" -s "$BASE_URL/meta-data/local-ipv4")
AZ=$(curl -H "$HEADERS: $TOKEN" -s "$BASE_URL/meta-data/placement/availability-zone")
MAC_ID=$(curl -H "$HEADERS: $TOKEN" -s "$BASE_URL/meta-data/network/interfaces/macs/")
INSTANCE_NAME=$(curl -H "$HEADERS: $TOKEN" -s "$BASE_URL/meta-data/tags/instance/Name")

VPC_ID=$(curl -H "$HEADERS: $TOKEN" -s "$BASE_URL/meta-data/network/interfaces/macs/${MAC_ID}/vpc-id")

# Create simple webpage
cat << EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>EC2 Instance Info</title>

    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #232f3e; }
        p { margin: 10px 0; }
        img { max-width: 300px; margin: 20px 0; }
    </style>
</head>

<body>
    <h1>${TEXT}</h1>
    
    <!-- Instance image -->
    <img src="${IMAGE}" alt="Instance Image">
    
    <h2>Instance Details</h2>
    <p><strong>Name:</strong> ${INSTANCE_NAME}</p>
    <p><strong>Private IP:</strong> ${LOCAL_IP}</p>
    <p><strong>Availability Zone:</strong> ${AZ}</p>
    <p><strong>VPC ID:</strong> ${VPC_ID}</p>
</body>
</html>
EOF