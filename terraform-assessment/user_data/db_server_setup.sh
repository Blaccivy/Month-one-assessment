#!/bin/bash
# Script to install Apache and PostgreSQL 15 on Amazon Linux 2023

set -e

# -------------------------------
# Update system
# -------------------------------
dnf update -y

# -------------------------------
# Install Apache
# -------------------------------
dnf install -y httpd
systemctl enable --now httpd

# -------------------------------
# Install PostgreSQL15 from Amazon Linux repos
# -------------------------------
sudo dnf install postgresql15-server postgresql15-contrib -y


# Initialize database
/usr/bin/postgresql-setup --initdb

# Enable and start PostgreSQL
systemctl enable --now postgresql
systemctl start postgresql

# -------------------------------
# Finished
# -------------------------------
echo "Apache and PostgreSQL 15 installation complete!"
