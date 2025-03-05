#!/bin/bash
docker build --build-arg NUM_THREADS=8 --rm -t ollama-configured .