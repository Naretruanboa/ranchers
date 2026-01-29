#!/bin/bash

# Exit on error
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if ! docker ps | grep -q rancher-center; then
  echo -e "${RED}✗ Rancher container is not running${NC}"
  exit 1
fi

echo -e "${YELLOW}>>> Retrieving Rancher bootstrap credentials...${NC}"
echo ""

# Get bootstrap password from logs
if PASSWORD=$(docker logs rancher-center 2>&1 | grep "Bootstrap Password:"); then
  echo -e "${GREEN}${PASSWORD}${NC}"
  echo ""
  echo -e "${GREEN}>>> Access Rancher at: https://localhost${NC}"
  echo -e "${GREEN}>>> Default username: admin${NC}"
else
  echo -e "${YELLOW}⚠ Bootstrap password not found in logs${NC}"
  echo -e "${YELLOW}Rancher may still be initializing. Check logs with:${NC}"
  echo "  docker logs rancher-center"
  exit 1
fi