#!/bin/bash

# Move to workdir
WORK_DIR="$(cd "$(dirname $0)"; pwd)"
cd "$WORK_DIR"

# Create venv
echo "## Create venv."
python -m venv env
source env/bin/activate

# Install apache-beam
echo "## Install apache-beam[gcp]."
pip install --upgrade pip
pip install apache-beam[gcp]==2.35.0

# Run pipeline
echo "## Run pipeline."
PROJECT=$(gcloud config get-value project)
REGION=us-central1

python -m print_sum --runner=DataflowRunner \
  --project=$PROJECT \
  --region=$REGION \
  --job_name= \
  --experiments=use_runner_v2 \
  --experiments=no_use_multiple_sdk_containers # To run single SDK container