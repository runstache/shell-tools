# Powershell Tools

The following tools are available for creating simplifying interactions with AWS CLI connections and Python/PyEnv/PipEnv environments. These are incredibly opinionated for my usage :).

## AWS Connect

The AWS Connect Powershell Utility contains shortend commands for the following operations:

* Performing an AWS SSO Login
* Connecting to Bastion Instances through AWS SSM

### AWS Connect Environment Variables

The utility requires the following Environment Variables to be set:

* AWS_CONNECT_PROFILE - Default AWS Profile to use for SSO Login commands

### AWS Connect Login

The Login command will perform an AWS SSO Login for the profile defined in the AWS_CONNECT_PROFILE environment variable.

```command
aws_connect login
```

### AWS Connect Bastion

The Bastion command is used to connect to the sepcified Bastion Configuration. Configurations are stored in the __%USERPROFILE%\.aws\bastions.json__ file.

The following commands are available:

```command
# List Available Bastions

aws_connect bastion list

# Connection Bastion

aws_connect bastion <Name of Bastion>
```

The __bastions.json__ file contains entries in the following format:

```json
{
  "name-of-bastion": {
    "profile": "AWS Profile Name",
    "stackName": "Tagged Value for Stack name on the AWS EC2",
    "sourcePort": "Local Port to map",
    "destinationPort": "Desitination Port to map",
    "host": "Host Name to connect",
    "environment": "Environment Tag on the EC2"
  },
    "name-of-bastion": {
    "profile": "AWS Profile Name",
    "stackName": "Tagged Value for Stack name on the AWS EC2",
    "sourcePort": "Local Port to map",
    "destinationPort": "Desitination Port to map",
    "host": "Host Name to connect",
    "environment": "Environment Tag on the EC2"
  }
}
```

Multiple Bastions can be configured in the file as new Key/Value pairs at the root level. Each Key at the root level is used for the Listing of Bastions and the connection.

## Rattler

The Rattler Tool provides shortcuts to interacting with PipEnv and common environment executions of my Python Projects.

### Rattler Environment Variables

The utility leverages the following environment variables:

* MAVEN_REPO_USER - 3rd Party Repository User
* MAVEN_REPO_PASS - 3rd Party Repository Password
* ARTIFACTORY_URL - Base URL to 3rd Party repositories. If not set, the source will not be created in any newly created Pipfiles. Also a .env file will not be added to the root.

## Install / Sync

The Install and Sync Commands are used to initialize a new project with the following:

* New PiFile (if not exists) with 2 Indexes
  * PyPi Index
  * Remote Artifactory Index defined by the Environment Variable __ARTIFACTORY_URL__
* .env file with the Environment Variables MAVEN_REPO_USER and MAVEN_REPO_PASS with the values defined at the system enviroment variables with the same name.
* Installs all dependencies
* Installs pipenv to local environment
* Activates the environment

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
rattler install

# Install New Environment for Python 3.11.7
rattler install 3.11.7

# Sync New Environment
rattler sync

# Sync new Environment for Python 3.11.7
rattler sync 3.11.7

# Install Static Code Analysis and Testing Packages
rattler install sca

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
