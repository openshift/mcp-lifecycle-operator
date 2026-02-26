# Kubernetes MCP Server Example

This example demonstrates deploying the [kubernetes-mcp-server](https://github.com/containers/kubernetes-mcp-server) using the MCP Lifecycle Operator.

## Prerequisites

- Kubernetes cluster
- MCP Lifecycle Operator installed (`make install`)
- Controller running (`make run`)

## Basic Deployment

Deploy the kubernetes-mcp-server with default configuration:

```bash
kubectl apply -f mcpserver.yaml
```

This creates:
- Deployment running the MCP server
- Service exposing port 8080

Check status:

```bash
kubectl get mcpserver kubernetes-mcp-server
```

## Deployment with ConfigMap

Deploy with custom TOML configuration:

```bash
kubectl apply -f mcpserver-with-config.yaml
```

This example shows how to:
1. Create a ConfigMap with `config.toml`
2. Reference the ConfigMap in the MCPServer spec
3. Optionally specify a custom mount path via `configMapMountPath` (defaults to `/etc/mcp-config`)
4. Optionally specify a custom volume name via `configMapVolumeName` (defaults to `mcp-config`)
5. Pass the config path via args

The ConfigMap is mounted as a read-only volume at the specified path.

## Deployment with RBAC (Recommended)

The kubernetes-mcp-server needs RBAC permissions to access Kubernetes resources like pods, namespaces, and events.

Deploy with a ServiceAccount and proper RBAC:

```bash
kubectl apply -f mcpserver-with-rbac.yaml
```

This creates:
1. **ServiceAccount** (`mcp-viewer`) - Identity for the MCP server pods
2. **ClusterRoleBinding** - Binds the ServiceAccount to the built-in `view` ClusterRole
3. **ConfigMap** - Optional configuration
4. **MCPServer** - References the ServiceAccount via `serviceAccountName`

### Why is RBAC Needed?

The kubernetes-mcp-server provides tools that interact with the Kubernetes API:
- `namespaces_list` - List all namespaces
- `events_list` - List cluster events
- `pods_list` - List pods across namespaces
- `resources_get` - Get specific resources
- And many more read-only operations

Without proper RBAC, these tools will fail with permission errors.

### Built-in ClusterRole: `view`

The `view` ClusterRole provides read-only access to most resources:
- Pods, Services, ConfigMaps, Secrets (metadata only)
- Deployments, ReplicaSets, StatefulSets
- Events, Namespaces
- And more

This is perfect for read-only MCP server operations.

### Custom RBAC Permissions

For tighter control, create a custom ClusterRole with specific permissions:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: mcp-custom-viewer
rules:
  - apiGroups: [""]
    resources: ["pods", "namespaces", "events"]
    verbs: ["get", "list"]
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list"]
```

Then create a ClusterRoleBinding and update the MCPServer to use your ServiceAccount:

```yaml
spec:
  serviceAccountName: my-custom-sa
```

## Testing

Port-forward to the service:

```bash
kubectl port-forward svc/kubernetes-mcp-server 8080:8080
```

Test the health endpoint:

```bash
curl http://localhost:8080/healthz
```

Verify the ServiceAccount is being used:

```bash
kubectl get pod -l mcp-server=kubernetes-mcp-server -o jsonpath='{.items[0].spec.serviceAccountName}'
# Should output: mcp-viewer
```

## Cleanup

```bash
# Basic deployment
kubectl delete -f mcpserver.yaml

# With ConfigMap
kubectl delete -f mcpserver-with-config.yaml

# With RBAC (also deletes ServiceAccount and ClusterRoleBinding)
kubectl delete -f mcpserver-with-rbac.yaml
```
