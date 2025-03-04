#!/bin/bash

docker run --name ollama --entrypoint bash -it --gpus all --rm \
    -e HTTP_PROXY="http://address:port" \
    -e HTTPS_PROXY="http://address:port" \
    -e NO_PROXY="127.0.0.0/8,localhost" \
    -p 11434:11434 \
    ollama-deepseek:latest
