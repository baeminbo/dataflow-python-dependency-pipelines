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
pip install apache-beam[gcp]==2.35.0 google-cloud-translate==3.6.1

# Download google-cloud-translate source package
echo "## Download google-cloud-translate source package."
pip download --no-binary :all: --no-deps --dest downloads google-cloud-translate==3.6.1
SOURCE_PACKAGE=$(ls downloads/*)

# Run pipeline
echo "## Run pipeline with '--extra_packages'."
PROJECT=$(gcloud config get-value project)
REGION=us-central1

python -m translate --runner=DataflowRunner \
  --project=$PROJECT \
  --region=$REGION \
  --job_name=example2 \
  --experiments=use_runner_v2 \
  --experiments=no_use_multiple_sdk_containers \
  --extra_packages=$SOURCE_PACKAGE