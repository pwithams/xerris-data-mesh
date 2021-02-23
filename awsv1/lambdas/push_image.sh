#!/usr/bin/env bash

# The argument to this script is the image name. This will be used as the image on the local
# machine and combined with the account and region to form the repository name for ECR.
echo "Running..."

image=$1
tag=$2

if [[ "$image" == "" || "$tag" == "" ]]
then
    echo "This script pushes a prebuilt container to ECR"
    echo "Usage: $0 <image-name> <tag-name>"
    exit 1
fi

echo "Getting account number..."
# Get the account number associated with the current IAM credentials
account=$(aws sts get-caller-identity --query Account --output text)

if [ $? -ne 0 ]
then
    echo "Getting account details failed, exiting..."
    exit 255
else
    echo "Account number: ${account}"
fi

# Get the region defined in the current configuration (default to us-west-2 if none defined) region=$(aws configure get region) region=${region:-us-east-1}
region="us-east-1"

fullname="${account}.dkr.ecr.${region}.amazonaws.com/${image}:${tag}"

# If the repository doesn't exist in ECR, create it.
echo "Describing repositories..."
aws ecr describe-repositories --repository-names "${image}" > /dev/null 2>&1

if [ $? -ne 0 ]
then
    echo "Creating repository ${image}..."
    aws ecr create-repository --repository-name "${image}" > /dev/null
else
    echo "Repository already created"
fi

# Get the login command from ECR and execute it directly
echo "Logging into ECR..."
aws ecr get-login-password --region "${region}" | docker login --username AWS --password-stdin "${account}".dkr.ecr."${region}".amazonaws.com

echo "Tagging image with full ECR name..."
docker tag ${image}:${tag} ${fullname}

echo "Pushing image.."
docker push ${fullname}
if [ $? -ne 0 ]
then
    echo "Image push failed, exiting..."
    exit 1
fi

echo "Successfully pushed" ${fullname}
