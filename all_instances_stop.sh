#!/bin/bash

# Script to list EC2 instances, choose by number, and delete with confirmation

# Ensure AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
  echo "AWS CLI is not configured. Please run 'aws configure' first."
  exit 1
fi

# Fetch EC2 instances and store details in an array
echo "Fetching EC2 instances..."
INSTANCE_DETAILS=$(aws ec2 describe-instances \
  --query "Reservations[*].Instances[*].[InstanceId, Tags[?Key=='Name'].Value | [0], State.Name]" \
  --output text)

if [ -z "$INSTANCE_DETAILS" ]; then
  echo "No EC2 instances found."
  exit 0
fi

# Display instances with numbering
echo "Available EC2 Instances:"
IFS=$'\n' read -rd '' -a INSTANCE_ARRAY <<<"$INSTANCE_DETAILS"

for i in "${!INSTANCE_ARRAY[@]}"; do
  INSTANCE_ID=$(echo "${INSTANCE_ARRAY[$i]}" | awk '{print $1}')
  INSTANCE_NAME=$(echo "${INSTANCE_ARRAY[$i]}" | awk '{print $2}')
  INSTANCE_STATE=$(echo "${INSTANCE_ARRAY[$i]}" | awk '{print $3}')
  printf "%d) Instance ID: %s | Name: %s | State: %s\n" "$((i+1))" "$INSTANCE_ID" "$INSTANCE_NAME" "$INSTANCE_STATE"
done

# Ask user to choose an instance by number
read -p "Enter the number of the instance you want to delete: " INSTANCE_NUMBER

# Validate the selection
if ! [[ "$INSTANCE_NUMBER" =~ ^[0-9]+$ ]] || [ "$INSTANCE_NUMBER" -lt 1 ] || [ "$INSTANCE_NUMBER" -gt "${#INSTANCE_ARRAY[@]}" ]; then
  echo "Invalid selection. Please run the script again."
  exit 1
fi

# Get selected instance details
SELECTED_INSTANCE="${INSTANCE_ARRAY[$((INSTANCE_NUMBER-1))]}"
INSTANCE_ID=$(echo "$SELECTED_INSTANCE" | awk '{print $1}')
INSTANCE_NAME=$(echo "$SELECTED_INSTANCE" | awk '{print $2}')

# Confirm deletion
read -p "Are you sure you want to terminate the instance '$INSTANCE_NAME' (ID: $INSTANCE_ID)? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Termination cancelled."
  exit 0
fi

# Terminate the instance
echo "Terminating instance $INSTANCE_ID..."
aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" > /dev/null

# Wait for the instance to terminate
echo "Waiting for instance $INSTANCE_ID to terminate..."
aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID"

# Final confirmation
echo "Instance $INSTANCE_ID has been successfully terminated."
































































# #!/bin/bash

# # Script to list EC2 instances, choose by name, and delete

# # Ensure AWS CLI is configured
# if ! aws sts get-caller-identity > /dev/null 2>&1; then
#   echo "AWS CLI is not configured. Please run 'aws configure' first."
#   exit 1
# fi

# # List all EC2 instances with their names and IDs
# echo "Fetching EC2 instances..."
# aws ec2 describe-instances \
#   --query "Reservations[*].Instances[*].[InstanceId, Tags[?Key=='Name'].Value | [0], State.Name]" \
#   --output table

# # Prompt user to enter the EC2 instance name
# read -p "Enter the EC2 Instance Name you want to delete: " INSTANCE_NAME

# # Get the instance ID based on the instance name
# INSTANCE_ID=$(aws ec2 describe-instances \
#   --filters "Name=tag:Name,Values=$INSTANCE_NAME" \
#   --query "Reservations[*].Instances[*].InstanceId" \
#   --output text)

# # Check if INSTANCE_ID is found
# if [ -z "$INSTANCE_ID" ]; then
#   echo "No instance found with the name '$INSTANCE_NAME'. Exiting."
#   exit 1
# fi

# # Confirm deletion
# read -p "Are you sure you want to terminate the instance '$INSTANCE_NAME' (ID: $INSTANCE_ID)? (yes/no): " CONFIRM

# if [ "$CONFIRM" != "yes" ]; then
#   echo "Termination cancelled."
#   exit 0
# fi

# # Terminate the instance
# echo "Terminating instance $INSTANCE_ID..."
# aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"

# echo "Termination command sent. It may take a few minutes for the instance to be fully terminated."
