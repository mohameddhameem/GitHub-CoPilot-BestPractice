FROM mcr.microsoft.com/devcontainers/python:3.12

# Install Node.js (v20)
ARG NODE_VERSION="20"
RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION}"

# Install system dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    build-essential \
    curl \
    git \
    ansible \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up global pip tools
RUN pip install --no-cache-dir \
    ruff \
    black \
    mypy \
    pytest \
    pytest-asyncio \
    pytest-cov \
    pre-commit \
    ansible-lint \
    yamllint

# [Optional] Set the default shell to bash
ENV SHELL /bin/bash
