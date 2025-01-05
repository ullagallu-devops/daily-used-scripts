#!/bin/bash

# Script to list EC2 instances, choose by name, and delete

# Ensure AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
  echo "AWS CLI is not configured. Please run 'aws configure' first."
  exit 1
fi

# List all EC2 instances with their names and IDs
echo "Fetching EC2 instances..."
aws ec2 describe-instances \
  --query "Reservations[*].Instances[*].[InstanceId, Tags[?Key=='Name'].Value | [0], State.Name]" \
  --output table

# Prompt user to enter the EC2 instance name
read -p "Enter the EC2 Instance Name you want to delete: " INSTANCE_NAME

# Get the instance ID based on the instance name
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$INSTANCE_NAME" \
  --query "Reservations[*].Instances[*].InstanceId" \
  --output text)

# Check if INSTANCE_ID is found
if [ -z "$INSTANCE_ID" ]; then
  echo "No instance found with the name '$INSTANCE_NAME'. Exiting."
  exit 1
fi

# Confirm deletion
read -p "Are you sure you want to terminate the instance '$INSTANCE_NAME' (ID: $INSTANCE_ID)? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Termination cancelled."
  exit 0
fi

# Terminate the instance
echo "Terminating instance $INSTANCE_ID..."
aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"

echo "Termination command sent. It may take a few minutes for the instance to be fully terminated."
