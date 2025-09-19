# Bezos CLI

The Bezos CLI provides some convenience methods for interacting with AWS Services primarily the following:

* Refreshing SSO Credentials
* Connecting to Remote Machines through AWS Session Manager
* Generating temporary credentials from SSO Login sessions

## Requirements

For the CLI to work, the following must be available prior to using:

* AWS CLI
* AWS Session Manager Plugin
* jq
* sed

## Configuration

If you intend to use the Session Manager connections, you will need to configure the remote hosts through a json file named __bastion.json__ stored in your Home directory. A sample of this configuration can be found in the __templates__ directory of this project.

```javascript
{
    "<connection_name>": {
      "profile": "AWS Profile Name",
      "tags": ["Collection of Tag Objects (Name, Values) to search for the EC2"],
      "sourcePort": "Local Port to map",
      "destinationPort": "Desitination Port to map",
      "host": "Host Name to connect",
      "environment": "Environment Tag on the EC2"
      "document": "Bastion Session Document
    }
}
```

Tags should look like this:

```javascript
tags: [{
        "Name": "tag:Environment",
        "Values": ["prd"]
      }]
```

Each Top level key is the name of the connection you want to establish. Within that key contains the information required by the SSM command to find and connect to the EC2 Instance.  This is a very opinionated utility and may not be suitable for your individual implementation.

### Environment Variables

The CLI does expect an environment variable to be configured as __ACTIVE_PROFILE__. This should be the SSO profile you would like to use as the default for operations. It will be the account used to refresh your login credentials.

## Using the CLI

The CLI contains three base commands:

* login
* bastion
* creds

### Login

The login command uses the profile defined in the __ACTIVE_PROFILE__ to perform an AWS SSO Login operation. This should refresh any additional profiles that utilize the same SSO Url.

### Bastion

The Bastion command is used to connect to remote machines based on the __bastion.json__ configuration file. It contains the __list__ subcommand which will list the configured items in your __bastion.json__ file.

To connect to a remote instance, use the following command:

```command
bezos bastion <name of configuration>
```

This should utilize the configuration from the __bastion.json__ file to connect to your EC2 instance through the AWS Session Manager.

### Creds

The __creds__ command is used to generate temporary keys from the provided profile. This creates a temporary HTML page displaying these credentials that allows for you to copy/paste the items easily to wherever they are needed.

```command
bezos creds my-profile
```
