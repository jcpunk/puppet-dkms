# @api private
#
# @summary A class to track the installed state of the software
#
# @param package_manage should we manage the dkms package?
# @param package_names any package names for dkms
# @param package_ensure ensure for the dkms packages
# @param kernel_devel_package_manage should we manage the kernel-devel package?
# @param kernel_devel_package_names any package names for kernel-devel
# @param kernel_devel_package_ensure ensure for the kernel-devel packages
#
# @example
#   include dkms::install
class dkms::install (
  Boolean $package_manage = $dkms::package_manage,
  Array $package_names = $dkms::package_names,
  String $package_ensure = $dkms::package_ensure,

  Boolean $kernel_devel_package_manage = $dkms::kernel_devel_package_manage,
  Array $kernel_devel_package_names = $dkms::kernel_devel_package_names,
  String $kernel_devel_package_ensure = $dkms::kernel_devel_package_ensure,
) inherits dkms {
  assert_private()

  if $kernel_devel_package_manage {
    package { $kernel_devel_package_names:
      ensure => $kernel_devel_package_ensure,
    }
  }

  if $package_manage {
    package { $package_names:
      ensure => $package_ensure,
    }
  }
}
