# Packer templates for Debian
[![Build Status](https://box-cutter.ci.cloudbees.com/buildStatus/icon?job=debian-vm)](https://box-cutter.ci.cloudbees.com/job/debian-vm/) 

### Overview

The repository contains templates for Debian that can create Vagrant boxes
using Packer.

## Current Boxes

64-bit boxes:

* [box-cutter/debian75](https://vagrantcloud.com/box-cutter/debian75) - Debian Wheezy 7.5 (64-bit), VMware 264MB/VirtualBox 204MB
* [box-cutter/debian74](https://vagrantcloud.com/box-cutter/debian74) - Debian Wheezy 7.4 (64-bit), VMware 260MB/VirtualBox 215MB
* [box-cutter/debian73](https://vagrantcloud.com/box-cutter/debian73) - Debian Wheezy 7.3 (64-bit), VMware 260MB/VirtualBox 204MB
* [box-cutter/debian609](https://vagrantcloud.com/box-cutter/debian609) - Debian Squeeze 6.0.9 (64-bit), VMware 215MB/VirtualBox 160MB

## Building the Vagrant boxes

To build all the boxes, you will need both VirtualBox and VMware Fusion installed.

A GNU Make `Makefile` drives the process via the following targets:

    make        # Build all the box types (VirtualBox & VMware)
    make test   # Run tests against all the boxes
    make list   # Print out individual targets
    make clean  # Clean up build detritus
    
### Tests

The tests are written in [Serverspec](http://serverspec.org) and require the
`vagrant-serverspec` plugin to be installed with:

    vagrant plugin install vagrant-serverspec
    
The `Makefile` has individual targets for each box type with the prefix
`test-*` should you wish to run tests individually for each box.

Similarly there are targets with the prefix `ssh-*` for registering a
newly-built box with vagrant and for logging in using just one command to
do exploratory testing.  For example, to do exploratory testing
on the VirtualBox training environmnet, run the following command:

    make ssh-box/virtualbox/debian75-nocm.box
    
Upon logout `make ssh-*` will automatically de-register the box as well.

### Makefile.local override

You can create a `Makefile.local` file alongside the `Makefile` to override
some of the default settings.  It is most commonly used to override the
default configuration management tool, for example with Chef:

    # Makefile.local
    CM := chef

Changing the value of the `CM` variable changes the target suffixes for
the output of `make list` accordingly.

Possible values for the CM variable are:

* `nocm` - No configuration management tool
* `chef` - Install Chef
* `puppet` - Install Puppet
* `salt`  - Install Salt

You can also specify a variable `CM_VERSION`, if supported by the
configuration management tool, to override the default of `latest`.
The value of `CM_VERSION` should have the form `x.y` or `x.y.z`,
such as `CM_VERSION := 11.12.4`

Another use for `Makefile.local` is to override the default locations
for the Debian install ISO files.

For Debian, the ISO path variables are:

* DEBIAN75_AMD64
* DEBIAN74_AMD64
* DEBIAN73_AMD64
* DEBIAN609_AMD64
* DEBIAN75_I386
* DEBIAN74_I386
* DEBIAN73_I386
* DEBIAN609_I386

This override is commonly used to speed up Packer builds by
pointing at pre-downloaded ISOs instead of using the default
download Internet URLs:
`DEBIAN75_AMD64 := file:///Volumes/Debian/debian-7.5.0-amd64-DVD-1.iso`

### Acknowledgments

[CloudBees](http://www.cloudbees.com) is providing a hosted [Jenkins master](http://box-cutter.ci.cloudbees.com/) through their CloudBees FOSS program. Their [On-Premise Executor](https://developer.cloudbees.com/bin/view/DEV/On-Premise+Executors) feature is used to connect physical machines as build slaves running VirtualBox, VMware Fusion, VMware Workstation, VMware ESXi/vSphere and Hyper-V.

![Powered By CloudBees](http://www.cloudbees.com/sites/default/files/Button-Powered-by-CB.png "Powered By CloudBees")![Built On DEV@Cloud](http://www.cloudbees.com/sites/default/files/Button-Built-on-CB-1.png "Built On DEV@Cloud")
