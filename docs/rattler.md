# Rattler ZShell Tool

The Rattler Tool provides shortcuts to interacting with PipEnv and common environment executions of my Python Projects in ZShell. Unlike the Windws version, 3rd Party python repositories are not supported automatically.

## Install / Sync

The Install and Sync Commands are used to initialize a new project with the following:

* New PiFile (if not exists)
* Installs all dependencies
* Installs pipenv to local environment
* Activates the local environment

The Install and Sync Commands also take the following parameters:

* Python Version Number
* sca

When passing the Python Version number, the virtual environment will be created using that python version based on the --python parameter for PipEnv. The __install__ command also excepts the __sca__ value in which it will install the following test tools:

* pytest
* pytest-cov
* pyflakes
* pylint
* pycodestyle
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

# Print Help Text
rattler help

```
