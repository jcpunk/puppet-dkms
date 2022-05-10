# @summary Install DKMS and optional service
#
# @param package_manage should we manage the dkms package?
# @param package_names any package names for dkms
# @param package_ensure ensure for the dkms packages
# @param kernel_devel_package_manage should we manage the kernel-devel package?
# @param kernel_devel_package_names any package names for kernel-devel
# @param kernel_devel_package_ensure ensure for the kernel-devel packages
# @param service_manage should we manage a dkms service?
# @param service_names names of any dkms services
# @param service_ensure ensure for the dkms services
# @param service_enable enable for the dkms services
# @param kernel_modules create these `dkms::kernel_module` resources
#
# @example
#   include dkms
class dkms (
  Boolean $package_manage,
  Array $package_names,
  String $package_ensure,

  Boolean $kernel_devel_package_manage,
  Array $kernel_devel_package_names,
  String $kernel_devel_package_ensure,

  Boolean $service_manage,
  Array $service_names,
  String $service_ensure,
  Boolean $service_enable,

  Hash $kernel_modules,
) {
  include dkms::install

  if $service_manage {
    service { $service_names:
      ensure  => $service_ensure,
      enable  => $service_enable,
      require => Class['Dkms::Install'],
    }
  }

  $kernel_modules.each |$module_name, $module_params| {
    dkms::kernel_module { $module_name:
      * => $module_params,
    }
  }
}
