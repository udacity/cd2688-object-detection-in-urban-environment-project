#!/usr/bin/env bash
#
# Build the TF2 Object Detection training image and push it to ECR.
#
# Usage: sh ./docker/build_and_push.sh <image_name>
#
# Notes:
# - Fails fast on any error so the notebook cell does not silently hang on a
#   broken earlier step (e.g. a failed ECR login).
# - Resolves its own directory, so it works regardless of the current working
#   directory the notebook launches it from.

set -euo pipefail

image=${1:?"Usage: build_and_push.sh <image_name>"}

# Directory this script lives in (the docker/ folder).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The Dockerfile COPYs models/research/object_detection, so it must exist first.
if [ ! -d "${SCRIPT_DIR}/models/research/object_detection" ]; then
    echo "ERROR: ${SCRIPT_DIR}/models/research/object_detection is missing."
    echo "Run the earlier notebook cell that clones https://github.com/tensorflow/models.git into docker/models first."
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)
if [ -z "${AWS_REGION}" ]; then
    AWS_REGION=${AWS_DEFAULT_REGION:-us-east-1}
fi
TAG=$(date +%Y%m%d%H%M%S)

fullname="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${image}:${TAG}"

# If the repository doesn't exist in ECR, create it.
if ! aws ecr describe-repositories --repository-names "${image}" > /dev/null 2>&1; then
    echo "Creating ECR repository ${image}"
    aws ecr create-repository --repository-name "${image}" > /dev/null
fi

# Get the login password from ECR and log docker in.
echo "Logging docker in to ECR"
aws ecr get-login-password --region "${AWS_REGION}" \
    | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Build the docker image locally and then push it to ECR with the full name.
cd "${SCRIPT_DIR}"

echo "Building image with name ${image}"
docker build --no-cache -t "${image}" -f Dockerfile .
docker tag "${image}" "${fullname}"

echo "Pushing image to ECR ${fullname}"
docker push "${fullname}"

# Writing the image name to let the calling process extract it without manual intervention:
echo "Saving ECR image URI into ecr_image_fullname.txt"
echo "${fullname}" > "${SCRIPT_DIR}/ecr_image_fullname.txt"

echo "Done."
