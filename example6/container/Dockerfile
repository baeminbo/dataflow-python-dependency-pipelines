ARG PYTHON_VERSION='3.7'
ARG BEAM_VERSION='2.35.0'
ARG LXML_VERSION='4.7.1'

FROM apache/beam_python${PYTHON_VERSION}_sdk:${BEAM_VERSION} AS beam_python

FROM python:${PYTHON_VERSION}-slim
ARG BEAM_VERSION
ARG LXML_VERSION

RUN pip install --no-cache-dir --upgrade pip

# If apache-beam pre-installed, you can use '--sdk-location=container' to skip
# Apache Beam package install at Dataflow worker. This reduces sdk application
# initilization time.
RUN pip install --no-cache-dir apache-beam[gcp]==${BEAM_VERSION} \
    lxml==${LXML_VERSION}

COPY --from=beam_python /opt/apache/beam /opt/apache/beam

ENTRYPOINT [ "/opt/apache/beam/boot" ]