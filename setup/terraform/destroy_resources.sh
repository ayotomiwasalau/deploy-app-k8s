#!/bin/bash

echo "=== AWS Resource Destruction Script ==="
echo "This script will help you destroy AWS resources that match your Terraform configuration"
echo ""

# Set AWS region and profile (change if needed)
AWS_REGION=${AWS_REGION:-us-east-1}
AWS_PROFILE=${AWS_PROFILE:-tomudacity}
export AWS_REGION
export AWS_PROFILE

echo "Using AWS Region: $AWS_REGION"
echo "Using AWS Profile: $AWS_PROFILE"
echo ""

# Function to check if AWS CLI is available
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "Error: AWS CLI is not installed or not in PATH"
        exit 1
    fi
}

# Function to check AWS credentials
check_aws_credentials() {
    if ! aws sts get-caller-identity --profile $AWS_PROFILE &> /dev/null; then
        echo "Error: AWS credentials not configured or invalid for profile '$AWS_PROFILE'"
        exit 1
    fi
}

# List and delete EKS clusters
delete_eks_clusters() {
    echo "=== EKS Clusters ==="
    CLUSTERS=$(aws eks list-clusters --region $AWS_REGION --profile $AWS_PROFILE --query 'clusters[]' --output text)
    
    if [ -z "$CLUSTERS" ]; then
        echo "No EKS clusters found"
        return
    fi
    
    for cluster in $CLUSTERS; do
        echo "Found EKS cluster: $cluster"
        read -p "Delete EKS cluster '$cluster'? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Deleting EKS cluster: $cluster"
            aws eks delete-cluster --name $cluster --region $AWS_REGION --profile $AWS_PROFILE
        fi
    done
}

# List and delete ECR repositories
delete_ecr_repositories() {
    echo ""
    echo "=== ECR Repositories ==="
    REPOS=$(aws ecr describe-repositories --region $AWS_REGION --profile $AWS_PROFILE --query 'repositories[].repositoryName' --output text)
    
    if [ -z "$REPOS" ]; then
        echo "No ECR repositories found"
        return
    fi
    
    for repo in $REPOS; do
        echo "Found ECR repository: $repo"
        read -p "Delete ECR repository '$repo'? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Deleting ECR repository: $repo"
            aws ecr delete-repository --repository-name $repo --force --region $AWS_REGION --profile $AWS_PROFILE
        fi
    done
}

# List and delete VPCs
delete_vpcs() {
    echo ""
    echo "=== VPCs ==="
    VPCS=$(aws ec2 describe-vpcs --region $AWS_REGION --profile $AWS_PROFILE --query 'Vpcs[?Tags[?Key==`Name` && Value==`udacity`]].VpcId' --output text)
    
    if [ -z "$VPCS" ]; then
        echo "No VPCs with name 'udacity' found"
        return
    fi
    
    for vpc in $VPCS; do
        echo "Found VPC: $vpc"
        read -p "Delete VPC '$vpc'? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Deleting VPC: $vpc"
            aws ec2 delete-vpc --vpc-id $vpc --region $AWS_REGION --profile $AWS_PROFILE
        fi
    done
}

# List and delete IAM roles
delete_iam_roles() {
    echo ""
    echo "=== IAM Roles ==="
    ROLES=$(aws iam list-roles --profile $AWS_PROFILE --query 'Roles[?contains(RoleName, `eks`) || contains(RoleName, `codebuild`) || contains(RoleName, `node`)].RoleName' --output text)
    
    if [ -z "$ROLES" ]; then
        echo "No relevant IAM roles found"
        return
    fi
    
    for role in $ROLES; do
        echo "Found IAM role: $role"
        read -p "Delete IAM role '$role'? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Deleting IAM role: $role"
            # Detach policies first
            POLICIES=$(aws iam list-attached-role-policies --role-name $role --profile $AWS_PROFILE --query 'AttachedPolicies[].PolicyArn' --output text)
            for policy in $POLICIES; do
                aws iam detach-role-policy --role-name $role --policy-arn $policy --profile $AWS_PROFILE
            done
            aws iam delete-role --role-name $role --profile $AWS_PROFILE
        fi
    done
}

# Main execution
main() {
    check_aws_cli
    check_aws_credentials
    
    echo "Starting resource cleanup..."
    echo ""
    
    delete_eks_clusters
    delete_ecr_repositories
    delete_vpcs
    delete_iam_roles
    
    echo ""
    echo "=== Cleanup Complete ==="
    echo "Note: Some resources may still exist if they were not found or you chose not to delete them"
    echo "You may need to manually check the AWS Console for any remaining resources"
}

# Run the script
main 