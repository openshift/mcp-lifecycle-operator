# MCP Lifecycle Operator Examples

This directory contains example MCPServer deployments.

## kubernetes-mcp-server

Deploys the [kubernetes-mcp-server](https://github.com/containers/kubernetes-mcp-server) which provides MCP tools for Kubernetes cluster interaction.

See [kubernetes-mcp-server/README.md](./kubernetes-mcp-server/README.md) for:
- Basic deployment
- ConfigMap-based configuration
- Testing and verification

## Quick Start

```bash
# Install CRDs
make install

# Run controller locally
make run

# Deploy example
kubectl apply -f examples/kubernetes-mcp-server/mcpserver.yaml

# Check status
kubectl get mcpserver
```

For complete documentation, see the [main README](../README.md).
