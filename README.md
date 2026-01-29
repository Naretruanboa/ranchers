# Rancher Kubernetes Management Server

This deployment provides a single-node Rancher management server running in Docker. Rancher is a comprehensive Kubernetes management platform that allows you to manage multiple Kubernetes clusters from a central control plane.

## Prerequisites

- **OS**: Ubuntu 20.04+ or similar Linux distribution (macOS requires Docker Desktop)
- **CPU**: Minimum 2 cores, recommended 4+ cores
- **RAM**: Minimum 2GB, recommended 4GB+
- **Disk**: 20GB free space for Rancher data
- **Network**: Ports 80, 443, 6443 open and accessible
- **Tools**: curl, bash 4+

## Quick Start

### 1. Initial Setup (Run Once)

```bash
# Configure kernel networking prerequisites for Kubernetes
bash ipv4-bridge.bash

# Install Docker, Docker Compose, and kubectl
bash install.bash
```

### 2. Start Rancher

```bash
bash start.bash
```

This will:
- Stop any existing Rancher containers
- Start fresh Rancher container
- Wait for Rancher to be ready (~1-2 minutes)
- Display container status

### 3. Access Rancher

```bash
# Get bootstrap password
bash get-pwd.bash
```

Then open your browser:
- **URL**: https://localhost (or your server's hostname/IP)
- **Username**: admin
- **Password**: (from get-pwd.bash output)

## Configuration

### Environment Variables

Create a `.env` file to customize deployment:

```bash
# Bootstrap password for initial admin account
CATTLE_BOOTSTRAP_PASSWORD=your-secure-password

# Server hostname for SSL certificate generation
SERVER_HOSTNAME=rancher.example.com
```

### Docker Compose Configuration

Key settings in `docker-compose.yml`:
- **Image**: Rancher v2.7.11 (pinned version for stability)
- **Ports**: 80 (HTTP), 443 (HTTPS), 6443 (Kubernetes API)
- **Memory**: 2-4GB reserved, up to 4GB limit
- **Volumes**: 
  - `rancher-data`: Cluster configs, projects, users, RBAC
  - `rancher-certs`: TLS certificates
- **Health Check**: Monitors container health every 30 seconds

## Common Tasks

### View Rancher Logs

```bash
docker logs rancher-center -f
```

### Check Container Status

```bash
docker ps --filter "name=rancher-center"
```

### Stop Rancher

```bash
docker compose down
```

### Clean Up Everything

```bash
# Deep cleanup (for worker/master nodes)
bash extended-cleanup-rancher2.sh

# Or just remove containers and volumes
docker compose down -v
```

### Backup Data

```bash
# Backup Rancher data volumes
tar -czf rancher-backup-$(date +%Y%m%d).tar.gz lib/rancher lib/certs
```

## Troubleshooting

### Rancher not starting

```bash
# Check logs for errors
docker logs rancher-center

# Verify Docker is running
docker ps

# Check system resources
free -h
df -h
```

### Port conflicts

```bash
# Check if ports are in use
sudo lsof -i :80
sudo lsof -i :443
sudo lsof -i :6443
```

### SSL/Certificate issues

- Self-signed certificates are generated automatically on first start
- Browser may show "Not Secure" - this is normal for self-signed certs
- To use trusted certificates, place them in `lib/certs/`

### Slow performance

- Monitor resource usage: `docker stats rancher-center`
- Increase memory limit in `docker-compose.yml` if needed
- Check disk space: `df -h`

## Security Considerations

1. **Change Default Password**: Set strong `CATTLE_BOOTSTRAP_PASSWORD` in `.env`
2. **Network Access**: Restrict access to ports 80, 443, 6443 by IP/firewall rules
3. **TLS Certificates**: Use trusted certificates for production (Let's Encrypt, corporate CA)
4. **Regular Backups**: Back up `lib/rancher/` and `lib/certs/` directories
5. **Keep Updated**: Periodically update to latest stable Rancher version

## File Structure

```
.
├── docker-compose.yml        # Rancher container configuration
├── install.bash              # Install Docker, Compose, kubectl
├── start.bash                # Start/restart Rancher
├── get-pwd.bash              # Retrieve bootstrap password
├── ipv4-bridge.bash          # Configure kernel networking
├── extended-cleanup-rancher2.sh  # Deep cluster node cleanup
├── README.md                 # This file
├── command.txt               # Quick reference commands
└── lib/                      # Data directories (created at runtime)
    ├── rancher/              # Rancher persistent data
    └── certs/                # TLS certificates
```

## Performance Tuning

For better performance with large clusters:

1. Increase resource limits in `docker-compose.yml`:
   ```yaml
   cpus: '4'
   memory: 8G
   ```

2. Enable persistent volume snapshots:
   ```bash
   docker exec rancher-center /opt/rancher/bin/rancher snapshot
   ```

## Support & Documentation

- **Rancher Docs**: https://rancher.com/docs/
- **GitHub**: https://github.com/rancher/rancher
- **Issues**: Check Docker logs and Rancher UI for errors

## License

Rancher is licensed under Apache 2.0. See https://github.com/rancher/rancher/blob/master/LICENSE for details.
