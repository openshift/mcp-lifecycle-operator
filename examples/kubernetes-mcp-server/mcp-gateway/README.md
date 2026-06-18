## MCP Gateway Integration

If you have [mcp-gateway](https://github.com/Kuadrant/mcp-gateway) deployed in your cluster, you can expose the in-cluster kubernetes-mcp-server through the gateway.

**What You Need:**

Since the MCP server is running **in-cluster** (not external), you only need:
1. **HTTPRoute** - Routes traffic from the gateway to your Service
2. **MCPServerRegistration** - Registers the MCP server with the gateway

**What You DON'T Need:**

Unlike external MCP servers, you do NOT need:
- ❌ ExternalName Service (you already have a ClusterIP Service from the MCPServer CR)
- ❌ ServiceEntry (not needed for in-cluster services)

**Deploy the integration:**

```bash
kubectl apply -f mcp-gateway-integration.yaml
```

This creates:
- HTTPRoute pointing to `kubernetes-mcp-server` Service on port 8080
- MCPServerRegistration with `kube_` prefix for all tools

**Verify:**

```bash
# Check the HTTPRoute (should show hostname: kubernetes-mcp.mcp.local)
kubectl get httproute kubernetes-mcp -n default

# Check the MCPServerRegistration (should show READY: True and TOOLS: 13)
kubectl get mcpserverregistration kubernetes-mcp-server -n default

# Example output:
# NAME                    PREFIX   TARGET           PATH   READY   TOOLS   AGE
# kubernetes-mcp-server   kube_    kubernetes-mcp   /mcp   True    13      10s

# The gateway will now expose kubernetes-mcp-server tools with the kube_ prefix
# Example tools: kube_namespaces_list, kube_events_list, kube_pods_list
```

**Important Notes:**

- The HTTPRoute **requires a hostname** (e.g., `kubernetes-mcp.mcp.local`) for the gateway to route traffic correctly
- The MCPServerRegistration should show `READY: True` and list the number of tools discovered
- If `READY: False`, check that the HTTPRoute has a hostname and the Service is accessible

