#!/usr/bin/env bash
# Usage example:
# ./run-csl.sh init
# "init" is optional arg, it will generate generic db.

set -ex

# export COMPOSE_DOCKER_CLI_BUILD=1
# export DOCKER_BUILDKIT=1
# VCS_REF=$(git rev-parse --short=10 HEAD)
# For docker-compose use VCS_REF
# export VCS_REF

# REPO_ROOT=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )
# declare -xr REPO_ROOT
# cd "${REPO_ROOT}"

# ========================================================================
# Prepare docker volumes
# ========================================================================
mkdir -p es_data

# ========================================================================
# Build docker image
# ========================================================================
docker-compose -f docker-compose.yml build

# ========================================================================
# Run CSL
# ========================================================================
docker-compose -f docker-compose.yml up -d
