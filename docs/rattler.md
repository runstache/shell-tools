# Rattler ZShell Tool

The Rattler Tool provides shortcuts to interacting with common environment executions of my Python Projects in ZShell. The windows version of this tool leverages PipEnv to allow for easier use of 3rd party repositories. This version leverages UV for package management and installation.

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

When passing the Python Version number, the project will be pinned to the version by UV. The __install__ command also excepts the __sca__ value in which it will install the following test tools:

* pytest
* pytest-cov
* pyflakes
* pylint
* pycodestyle
* flake8
* bandit
* assertpy

Additional parameters are available for the __rattler__ command:

```command
# Install New Environment
rattler install

# Install New Environment for Python 3.11.7
rattler install 3.11.7

# Sync New Environment
rattler sync

# Sync new Environment for Python 3.11.7
rattler sync 3.11.7

# Install Static Code Analysis and Testing Packages
rattler install sca

# Install AWS CDK Libraries
rattler install cdk

# Activate Virtual Environment
rattler activate

# Run Pytest with Code Coverage Report
rattler coverage

# Run Static Code Analysis
rattler sca

# Remove Virtual Environment
rattler rm

```
