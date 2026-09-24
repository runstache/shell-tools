# Hat CLI

Wrapper CLI to handle logging into OpenShift Environments and Docker Image Registries.

## Requirements

The CLI utilizes a configuration file named `clusters.json` stored in the home directory with the following structure:

```json
{
  "cluster_alias": {
    "api": "openshift-api-url",
    "docker": "docker-image-registry-endpoint"
  }
}
```

## Available Commands

The following commands are available in the Hat CLI:

* login - Completes the Login command for the provider cluster alias. Cluster alias required
* token - Retrieves a login token for the current cluster.
* list - Lists the Configured clusters from clusters.json

### Usage

```bash
# login

hat login dev

# token

hat token

# List

hat list

```

### Autocomplete

The available environments for the cli are available through autocomplete.
