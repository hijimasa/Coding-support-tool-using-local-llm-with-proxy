#!/bin/bash
docker build \
  --build-arg HTTP_PROXY="${HTTP_PROXY}" \
  --build-arg HTTPS_PROXY="${HTTPS_PROXY}" \
  --build-arg NUM_THREADS=8 \
  --rm \
  -t ollama-configured .