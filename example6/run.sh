#!/bin/bash

PROJECT=$(gcloud config get-value project)
PYTHON_VERSION=$(python -c "import sys; print('{}.{}'.format(*sys.version_info[0:2]))")

# Move to workdir
WORK_DIR="$(cd "$(dirname $0)"; pwd)"
cd "$WORK_DIR"

# Build SDK container image
echo "## Build SDK container."
pushd container
IMAGE_URI="gcr.io/$PROJECT/custom_beam_python${PYTHON_VERSION}:2.35.0"
gcloud builds submit --project=$PROJECT --config cloudbuild.yaml \
  --substitutions=_PYTHON_VERSION=$PYTHON_VERSION,_BEAM_VERSION=2.35.0,_LXML_VERSION=4.7.1,_IMAGE_URI=$IMAGE_URI
popd

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
  --job_name=example6 \
  --experiments=use_runner_v2 \
  --experiments=no_use_multiple_sdk_containers \
  --sdk_container_image=$IMAGE_URI \
  --sdk_location=container