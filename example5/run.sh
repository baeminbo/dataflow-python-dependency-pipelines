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

# Run pipeline
echo "## Run pipeline with '--setup_file'."
PROJECT=$(gcloud config get-value project)
REGION=us-central1

python -m write2xml --runner=DataflowRunner \
  --project=$PROJECT \
  --region=$REGION \
  --job_name=example5 \
  --experiments=use_runner_v2 \
  --experiments=no_use_multiple_sdk_containers \
  --setup_file=./setup.py