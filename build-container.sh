#!/bin/bash

USER_OVERRIDE=${1-}
UID_OVERRIDE=${2-}

docker build \
    --build-arg VCS_REF=$(git rev-parse --short HEAD) \
    --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
    --build-arg user=${USER_OVERRIDE:=$USER} \
    --build-arg uid=${UID_OVERRIDE:=$UID} \
    -t youmych/pandoxy-base:latest .
