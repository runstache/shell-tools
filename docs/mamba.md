# Mamba ZShell Tool

The Mamba Tool provides shortcuts to interacting with common environment executions of my Python Projects in ZShell. This version leverages UV for package management and installation unlike the Rattler tool which leverages PipEnv.

## Requirements

The utility assumes the following are installed:

* uv
* rust

## Install / Sync

The Install and Sync Commands are used to initialize a new project with the following:

* New PyProject.toml if not exists
* Creates a Virtual Environment if one does not exist
* Installs all dependencies
* Activates the local environment

The Install and Sync Commands also take the following parameters:

* Python Version Number - The Python Version to use for the project. (Will use last cached version for UV by default)
* sca - Installs the Static Code analysis Tools
* cdk - Install AWS CDK Libraries and Checkov scanning

When passing the Python Version number, the project will be pinned to the version by UV. The __install__ command also excepts the __sca__ and __cdk__ value in which it will install the following test tools:

* pytest
* pytest-cov
* mypy
* assertpy
* aws-cdk-lib (cdk)
* constructs (cdk)
* checkov (cdk, dev only)

Additional parameters are available for the __mamba__ command:

```command
# Install New Environment with Package Upgrades
mamba install

# Install New Environment for Python 3.11.7 with Package Upgrades
mamba install 3.11.7

# Sync New Environment
mamba sync

# Sync new Environment for Python 3.11.7
mamba sync 3.11.7

# Install Static Code Analysis and Testing Packages
mamba install sca

# Install AWS CDK Libraries
mamba install cdk

# Activate Virtual Environment
mamba activate

# Run Pytest with Code Coverage Report
mamba coverage

# Run Static Code Analysis
mamba sca

# Remove Virtual Environment
mamba rm

# Upgrade Project Dependencies
mamba upgrade

```
