# vagrant-stack


Provides a standardised rinse and repeat Front End development environment.

## Prerequisites

- INSTALL [Virtual Box](https://www.virtualbox.org/)
- INSTALL [Vagrant](http://vagrantup.com/)

### Checkout or download project

#### Checkout

```
> cd some/dir
> git clone http://github.com/indieisaconcept/vagrant-stack.git
```
> Windows users use ```git bash``` or suitable alternative

## Installation

Initial installation should take at most 10-20 minutes as some resources may need to be downloaded form the internet.

### Install vagrant dependences

```
> vagrant plugin install vagrant-berkshelf
> vagrant plugin install vagrant-proxyconf 
```

### Customizing your environment (optional)

Depending upon the project you can customise the VM to suit your needs. If no configuration file is specified then the following defaults are applied.

- **Role**: Frontend

To override the default configuration, copy `chef/node/stack.json' to /stack.json at the root of vagrant-stack and add your customisations as required.

#### Roles

A role defines a collection of packages which are installed by default for the VM during the provisioning process.

##### Frontend (Default)

| Package   				| Overview
|:-------------------------|------------------------------------------------:|
| node.js & npm				| Provides support for node.js utilities
| n (node version manager)	| Provides support for switching node.js version
| bower						| Client side package manager
| grunt						| JavaScript task runner
| susy						| Responsive sass css framework
| sass						| CSS Preprocessor
| sassy buttons				| Quickly create CSS buttons
| compass					| Enhance SASS
| compass-normalize			| CSS Normalize reset

### Workspaces

If you have exisiting projects already checked out then these can be referenced using the workspaces configuration.

Locations added here will be available under ```workspaces/<project>```

```
workspaces: [

	{
		"host": "some/local/path"
		"guest" "some/remote/path"
	}

]

```

### Initialize environment

Execute the command below to provision the VM with the default setup.

```
> vagrant up
```

When ever you update your configuration, such as adding a new shared folder, exit out of the VM if you currently have an SSH session and run:

```
> vagrant reload
> vagrant ssh
```

### Using your development environment

Accessing the VM is done via SSH, the command below facilitates this.

```
> vagrant ssh
> cd /workspaces
```

If you reboot your machine you will need to run `vagrant up` again but since it has already been provisioned it should take < 60 seconds to resume.

For more information on available commands post installation review the vagrant commandline documentation located [here](http://docs.vagrantup.com/v2/cli/index.html)
