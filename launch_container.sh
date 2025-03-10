#!/bin/bash

docker run --name ollama --detach --gpus all --rm \
    -e HTTP_PROXY="${HTTP_PROXY}" \
    -e HTTPS_PROXY="${HTTPS_PROXY}" \
    -e NO_PROXY="127.0.0.0/8,localhost" \
    --dns 8.8.8.8 --dns 8.8.4.4 \
    -e OLLAMA_HOST=0.0.0.0:11434 \
    -p 11434:11434 \
    ollama-configured:latest