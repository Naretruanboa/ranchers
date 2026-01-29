#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail
set -o errtrace

# Color output for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

trap 'echo -e "${RED}Error on line $LINENO${NC}"' ERR

echo -e "${YELLOW}>>> Installing Docker...${NC}"
if command -v docker &> /dev/null; then
  echo -e "${GREEN}✓ Docker already installed${NC}"
else
  curl -fsSL https://releases.rancher.com/install-docker/25.0.0.sh | sh
  echo -e "${GREEN}✓ Docker installed${NC}"
fi

echo -e "${YELLOW}>>> Installing Docker Compose plugin...${NC}"
if docker compose version &> /dev/null; then
  echo -e "${GREEN}✓ Docker Compose plugin already installed${NC}"
else
  # Using modern docker-compose-plugin instead of deprecated docker-compose
  apt-get update && apt-get install -y docker-compose-plugin
  echo -e "${GREEN}✓ Docker Compose plugin installed${NC}"
fi

echo -e "${YELLOW}>>> Configuring Kubernetes networking prerequisites...${NC}"
if grep -q "br_netfilter" /etc/modules-load.d/k8s.conf 2>/dev/null; then
  echo -e "${GREEN}✓ Kubernetes networking already configured${NC}"
else
  bash ipv4-bridge.bash
  echo -e "${GREEN}✓ Kubernetes networking configured${NC}"
fi

echo -e "${YELLOW}>>> Installing kubectl...${NC}"
if command -v kubectl &> /dev/null; then
  echo -e "${GREEN}✓ kubectl already installed${NC}"
else
  snap install kubectl --classic
  echo -e "${GREEN}✓ kubectl installed${NC}"
fi

echo -e "${GREEN}=== Installation completed successfully ===${NC}"
