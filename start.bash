#!/bin/bash

# Exit on error
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

trap 'echo -e "${RED}Error on line $LINENO${NC}"' ERR

echo -e "${YELLOW}>>> Stopping existing Rancher containers...${NC}"
docker compose down || true

echo -e "${YELLOW}>>> Starting Rancher management server...${NC}"
docker compose up -d

echo -e "${YELLOW}>>> Waiting for Rancher to be ready (timeout: 5 minutes)...${NC}"

# Wait for Rancher container to be healthy
for i in {1..60}; do
  if docker ps | grep -q rancher-center && \
     docker exec rancher-center curl -sf https://localhost/ping &>/dev/null; then
    echo -e "${GREEN}✓ Rancher is ready!${NC}"
    echo -e "${GREEN}>>> Container Status:${NC}"
    docker ps --filter "name=rancher-center" --format "table {{.Names}}\t{{.Status}}"
    echo ""
    echo -e "${GREEN}>>> To get bootstrap password, run:${NC}"
    echo "  bash get-pwd.bash"
    echo ""
    exit 0
  fi
  echo -n "."
  sleep 5
done

echo -e "${RED}✗ Rancher failed to become ready within 5 minutes${NC}"
docker logs rancher-center | tail -20
exit 1
