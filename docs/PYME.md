# PyMe ZShell Tool

The PyMe Tool provides shortcuts to interacting with PipEnv and common environment executions of my Python Projects in ZShell.

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
* checkov

Additional parameters are available for the __py_me__ command:

```command
# Install New Environment
py_me install

# Install New Environment for Python 3.11.7
py_me install 3.11.7

# Sync New Environment
py_me sync

# Sync new Environment for Python 3.11.7
py_me sync 3.11.7

# Install Static Code Analysis and Testing Packages
py_me install sca

# Activate Virtual Environment
py_me activate

# Run Pytest with Code Coverage Report
py_me coverage

# Run Static Code Analysis
py_me sca

# Remove Virtual Environment
py_me rm

# Print Help Text
py_me help

```
