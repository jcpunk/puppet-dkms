# dkms

Manage DKMS Kernel modules.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with dkms](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with dkms](#beginning-with-dkms)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Install and manage DKMS, along with any kernel modules.

## Setup

### Setup Requirements

If you wish to use the `dkms::kernel_module` defined type, you must
first put your source in `/usr/src/<kmod-name>-<kmod-version>/`.

### Beginning with dkms

Modern linux distros have hooks for DKMS to automatically build a module
when a new kernel is installed.  Odds are for most users all you need is:

```puppet
include dkms
```

## Usage

There is a parameter provided to easily create any kmod entries you need:

```puppet
class { 'dkms':
  kernel_modules => {
    'kmod_name' => {
      'kmod_version' => 'ver string',
      'ensure' => 'installed',
      'on_kernel' => 'ALL',
    }
  }
}
```

Review the documentation on the `dkms::kernel_module` defined type for
more information.

## Limitations

If you wish to use the `dkms::kernel_module` defined type, you must
first put your source in `/usr/src/<kmod-name>-<kmod-version>/`.

The `dkms::kernel_module` defined type does not support tar or alternate
source modes for adding modules.

## Development

See the repo defined in `metadata.json`.


[1]: https://puppet.com/docs/pdk/latest/pdk_generating_modules.html
[2]: https://puppet.com/docs/puppet/latest/puppet_strings.html
[3]: https://puppet.com/docs/puppet/latest/puppet_strings_style.html
