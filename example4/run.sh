#!/bin/bash

# Move to workdir
WORK_DIR="$(cd "$(dirname $0)"; pwd)"
cd "$WORK_DIR"

# Create venv
echo "## Create venv."
python -m venv env
source env/bin/activate

# Install apache-beam
echo "## Install apache-beam[gcp] and dependency packages."
pip install --upgrade pip
pip install apache-beam[gcp]==2.35.0 lxml==4.7.1

# Download google-cloud-translate source package
echo "## Download lxml binary package."
pip download --no-deps --dest downloads --platform manylinux1_x86_64 lxml==4.7.1
BINARY_PACKAGE=$(ls downloads/*)

# Run pipeline
echo "## Run pipeline with '--extra_packages'."
PROJECT=$(gcloud config get-value project)
REGION=us-central1

python -m write2xml --runner=DataflowRunner \
  --project=$PROJECT \
  --region=$REGION \
  --job_name=example4 \
  --experiments=use_runner_v2 \
  --experiments=no_use_multiple_sdk_containers \
  --extra_packages=$BINARY_PACKAGE