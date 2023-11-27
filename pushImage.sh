#!/bin/bash

# Script for automating the process of building and pushing docker image to AWS ECR
# Usage: ./pushImage.sh <AWS_ACCOUNT_ID> <AWS_DEFAULT_REGION> <IMAGE_NAME>

# Set variables
AWS_ACCOUNT_ID=$1
AWS_DEFAULT_REGION=$2
IMAGE_NAME=$3

# Check if AWS_ACCOUNT_ID is provided
if [ -z "$AWS_ACCOUNT_ID" ]
then
    echo "AWS_ACCOUNT_ID is not provided. Using default AWS_ACCOUNT_ID"
    AWS_ACCOUNT_ID=137435002474
fi

# Check if AWS_DEFAULT_REGION is provided
if [ -z "$AWS_DEFAULT_REGION" ]
then
    echo "AWS_DEFAULT_REGION is not provided. Using default AWS_DEFAULT_REGION"
    AWS_DEFAULT_REGION=us-east-1
fi

# Check if IMAGE_NAME is provided
if [ -z "$IMAGE_NAME" ]
then
    echo "IMAGE_NAME is not provided. Using default IMAGE_NAME"
    IMAGE_NAME=drupal-dockerized
fi

# Check if docker is installed
if ! [ -x "$(command -v docker)" ]; then
    echo "Docker is not installed. Please install docker and try again"
    exit 1
fi

# Check if aws is installed
if ! [ -x "$(command -v aws)" ]; then
    echo "AWS CLI is not installed. Please install AWS CLI and try again"
    exit 1
fi

# Check if AWS credentials are configured
if ! [ -x "$(command -v aws configure)" ]; then
    echo "AWS credentials are not configured. Please configure AWS credentials and try again"
    exit 1
fi

# Check if AWS ECR repository exists
aws ecr describe-repositories --repository-names $IMAGE_NAME > /dev/null 2>&1
if [ $? -ne 0 ]
then
    echo "AWS ECR repository does not exist. Please create first the AWS ECR repository"
    exit 1
fi


# Login to AWS ECR
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com

# Build and push docker image to AWS ECR
docker build -t $IMAGE_NAME:latest .
docker tag $IMAGE_NAME:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_NAME:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_NAME:latest