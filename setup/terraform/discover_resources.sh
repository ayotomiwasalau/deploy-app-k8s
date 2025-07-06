#!/bin/bash

echo "=== Discovering AWS Resources for Terraform Import ==="
echo

# Get VPC
echo "=== VPC ==="
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=udacity" --query 'Vpcs[0].VpcId' --output text 2>/dev/null)
if [ "$VPC_ID" != "None" ] && [ -n "$VPC_ID" ]; then
    echo "VPC ID: $VPC_ID"
    echo "terraform import aws_vpc.vpc $VPC_ID"
else
    echo "No VPC found with tag Name=udacity"
fi
echo

# Get Internet Gateway
if [ -n "$VPC_ID" ]; then
    echo "=== Internet Gateway ==="
    IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[0].InternetGatewayId' --output text 2>/dev/null)
    if [ "$IGW_ID" != "None" ] && [ -n "$IGW_ID" ]; then
        echo "Internet Gateway ID: $IGW_ID"
        echo "terraform import aws_internet_gateway.igw $IGW_ID"
    else
        echo "No Internet Gateway found attached to VPC $VPC_ID"
    fi
    echo
fi

# Get Subnets
echo "=== Subnets ==="
PUBLIC_SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=udacity-public" --query 'Subnets[0].SubnetId' --output text 2>/dev/null)
PRIVATE_SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=udacity-private" --query 'Subnets[0].SubnetId' --output text 2>/dev/null)

if [ "$PUBLIC_SUBNET_ID" != "None" ] && [ -n "$PUBLIC_SUBNET_ID" ]; then
    echo "Public Subnet ID: $PUBLIC_SUBNET_ID"
    echo "terraform import aws_subnet.public_subnet $PUBLIC_SUBNET_ID"
else
    echo "No public subnet found with tag Name=udacity-public"
fi

if [ "$PRIVATE_SUBNET_ID" != "None" ] && [ -n "$PRIVATE_SUBNET_ID" ]; then
    echo "Private Subnet ID: $PRIVATE_SUBNET_ID"
    echo "terraform import aws_subnet.private_subnet $PRIVATE_SUBNET_ID"
else
    echo "No private subnet found with tag Name=udacity-private"
fi
echo

# Get Route Tables
echo "=== Route Tables ==="
PUBLIC_RT_ID=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=public" --query 'RouteTables[0].RouteTableId' --output text 2>/dev/null)
PRIVATE_RT_ID=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=private" --query 'RouteTables[0].RouteTableId' --output text 2>/dev/null)

if [ "$PUBLIC_RT_ID" != "None" ] && [ -n "$PUBLIC_RT_ID" ]; then
    echo "Public Route Table ID: $PUBLIC_RT_ID"
    echo "terraform import aws_route_table.public $PUBLIC_RT_ID"
fi

if [ "$PRIVATE_RT_ID" != "None" ] && [ -n "$PRIVATE_RT_ID" ]; then
    echo "Private Route Table ID: $PRIVATE_RT_ID"
    echo "terraform import aws_route_table.private $PRIVATE_RT_ID"
fi
echo

# Get EKS Cluster
echo "=== EKS Cluster ==="
EKS_CLUSTER_ARN=$(aws eks describe-cluster --name cluster --query 'cluster.arn' --output text 2>/dev/null)
if [ "$EKS_CLUSTER_ARN" != "None" ] && [ -n "$EKS_CLUSTER_ARN" ]; then
    echo "EKS Cluster ARN: $EKS_CLUSTER_ARN"
    echo "terraform import aws_eks_cluster.main cluster"
else
    echo "No EKS cluster found with name 'cluster'"
fi
echo

# Get EKS Node Group
echo "=== EKS Node Group ==="
NODEGROUP_STATUS=$(aws eks describe-nodegroup --cluster-name cluster --nodegroup-name udacity --query 'nodegroup.status' --output text 2>/dev/null)
if [ "$NODEGROUP_STATUS" != "None" ] && [ -n "$NODEGROUP_STATUS" ]; then
    echo "EKS Node Group exists: udacity"
    echo "terraform import aws_eks_node_group.main cluster:udacity"
else
    echo "No EKS node group found with name 'udacity'"
fi
echo

# Get ECR Repositories
echo "=== ECR Repositories ==="
FRONTEND_REPO=$(aws ecr describe-repositories --repository-names frontend --query 'repositories[0].repositoryName' --output text 2>/dev/null)
BACKEND_REPO=$(aws ecr describe-repositories --repository-names backend --query 'repositories[0].repositoryName' --output text 2>/dev/null)

if [ "$FRONTEND_REPO" != "None" ] && [ -n "$FRONTEND_REPO" ]; then
    echo "Frontend ECR Repository: $FRONTEND_REPO"
    echo "terraform import aws_ecr_repository.frontend $FRONTEND_REPO"
else
    echo "No frontend ECR repository found"
fi

if [ "$BACKEND_REPO" != "None" ] && [ -n "$BACKEND_REPO" ]; then
    echo "Backend ECR Repository: $BACKEND_REPO"
    echo "terraform import aws_ecr_repository.backend $BACKEND_REPO"
else
    echo "No backend ECR repository found"
fi
echo

# Get IAM Roles
echo "=== IAM Roles ==="
EKS_CLUSTER_ROLE=$(aws iam get-role --role-name eks_cluster_role --query 'Role.RoleName' --output text 2>/dev/null)
NODEGROUP_ROLE=$(aws iam get-role --role-name udacity-node-group --query 'Role.RoleName' --output text 2>/dev/null)
CODEBUILD_ROLE=$(aws iam get-role --role-name codebuild-role --query 'Role.RoleName' --output text 2>/dev/null)

if [ "$EKS_CLUSTER_ROLE" != "None" ] && [ -n "$EKS_CLUSTER_ROLE" ]; then
    echo "EKS Cluster Role: $EKS_CLUSTER_ROLE"
    echo "terraform import aws_iam_role.eks_cluster $EKS_CLUSTER_ROLE"
fi

if [ "$NODEGROUP_ROLE" != "None" ] && [ -n "$NODEGROUP_ROLE" ]; then
    echo "Node Group Role: $NODEGROUP_ROLE"
    echo "terraform import aws_iam_role.node_group $NODEGROUP_ROLE"
fi

if [ "$CODEBUILD_ROLE" != "None" ] && [ -n "$CODEBUILD_ROLE" ]; then
    echo "CodeBuild Role: $CODEBUILD_ROLE"
    echo "terraform import aws_iam_role.codebuild $CODEBUILD_ROLE"
fi
echo

# Get IAM User
echo "=== IAM User ==="
GITHUB_USER=$(aws iam get-user --user-name github-action-user --query 'User.UserName' --output text 2>/dev/null)
if [ "$GITHUB_USER" != "None" ] && [ -n "$GITHUB_USER" ]; then
    echo "GitHub Action User: $GITHUB_USER"
    echo "terraform import aws_iam_user.github_action_user $GITHUB_USER"
else
    echo "No GitHub Action user found"
fi
echo

# Get CodeBuild Project
echo "=== CodeBuild Project ==="
CODEBUILD_PROJECT=$(aws codebuild batch-get-projects --names udacity --query 'projects[0].name' --output text 2>/dev/null)
if [ "$CODEBUILD_PROJECT" != "None" ] && [ -n "$CODEBUILD_PROJECT" ]; then
    echo "CodeBuild Project: $CODEBUILD_PROJECT"
    echo "terraform import aws_codebuild_project.codebuild $CODEBUILD_PROJECT"
else
    echo "No CodeBuild project found with name 'udacity'"
fi
echo

# Get VPC Endpoints (if they exist)
if [ -n "$VPC_ID" ]; then
    echo "=== VPC Endpoints ==="
    VPC_ENDPOINTS=$(aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$VPC_ID" --query 'VpcEndpoints[*].VpcEndpointId' --output text 2>/dev/null)
    if [ "$VPC_ENDPOINTS" != "None" ] && [ -n "$VPC_ENDPOINTS" ]; then
        echo "VPC Endpoints found: $VPC_ENDPOINTS"
        echo "You may need to import these individually based on their service names:"
        aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$VPC_ID" --query 'VpcEndpoints[*].[VpcEndpointId,ServiceName]' --output table
    else
        echo "No VPC endpoints found"
    fi
fi

echo
echo "=== Summary ==="
echo "Run these commands in order to import your existing resources:"
echo "1. First import IAM roles and policies"
echo "2. Then import VPC and networking resources"
echo "3. Then import ECR repositories"
echo "4. Then import EKS cluster and node group"
echo "5. Finally import CodeBuild and other resources" 