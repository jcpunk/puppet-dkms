# @summary Setup a kernel module for DKMS
#
# @param kmod_version
#   The version of this kernel module
# @param kmod_name
#   The name of this kernel module
# @param ensure
#   Should this be, added (present), built, installed, or absent?
#   The `built` or `installed` option will actually run the compile
#   as part of the puppet run and may require an increased `build_timeout`.
# @param on_kernel
#   Which kernel should we track.
#   If you set this to `ALL`, it will select all kernels
# @param build_timeout
#   How long should we wait for the module to compile
# @param use_autoinstall
#   Should we run `dkms autoinstall` afterwards?
#
# @example
#   dkms::kernel_module { 'openafs':
#     kmod_version => '1.8.2',
#   }
#
#   dkms::kernel_module { 'my clean title':
#     kmod_name    => 'openafs',
#     kmod_version => '1.8.2',
#     ensure       => 'installed',
#   }
define dkms::kernel_module (
  Variant[String, Integer] $kmod_version,
  String $kmod_name = $title,
  Enum['present', 'built', 'installed', 'absent'] $ensure = 'present',
  String $on_kernel = $facts['kernelrelease'],
  Integer $build_timeout = 600,
  Boolean $use_autoinstall = false,
) {
  if ! defined(Class['dkms']) {
    fail('You must include the dkms base class before using any defined resources')
  }

  include dkms::autoinstall

  if empty($on_kernel) or ($on_kernel.downcase == 'all') {
    $kernel = '--all'
  } else {
    $kernel = "-k ${on_kernel}"
  }

  if $ensure in ['present', 'built', 'installed'] {
    exec { "dkms add -m ${kmod_name} -v ${kmod_version}":
      path    => $facts['path'],
      unless  => "dkms status -m ${kmod_name} -v ${kmod_version} | grep ':'",
      require => Class['Dkms::Install'],
    }

    if $use_autoinstall {
      Exec["dkms add -m ${kmod_name} -v ${kmod_version}"] {
        notify => Class['Dkms::Autoinstall'],
      }
    }

    if $ensure in ['built', 'installed'] {
      exec { "dkms build -m ${kmod_name} -v ${kmod_version} ${kernel}":
        path    => $facts['path'],
        unless  => "dkms status -m ${kmod_name} -v ${kmod_version} ${kernel} | grep -E ': (built|installed)'",
        timeout => $build_timeout,
        require => [Exec["dkms add -m ${kmod_name} -v ${kmod_version}"], Class['Dkms::Install'],],
      }

      if $use_autoinstall {
        Exec["dkms build -m ${kmod_name} -v ${kmod_version} ${kernel}"] {
          notify => Class['Dkms::Autoinstall'],
        }
      }
      if $ensure == 'installed' {
        exec { "dkms install -m ${kmod_name} -v ${kmod_version} ${kernel}":
          path    => $facts['path'],
          unless  => "dkms status -m ${kmod_name} -v ${kmod_version} ${kernel} | grep ': installed'",
          require => [Exec["dkms build -m ${kmod_name} -v ${kmod_version} ${kernel}"], Class['Dkms::Install'],],
        }
        if $use_autoinstall {
          Exec["dkms install -m ${kmod_name} -v ${kmod_version} ${kernel}"] {
            notify => Class['Dkms::Autoinstall'],
          }
        }
      }
    }
  } elsif $ensure == 'absent' {
    exec { "dkms remove -m ${kmod_name} -v ${kmod_version} ${kernel}":
      path    => $facts['path'],
      onlyif  => "dkms status -m ${kmod_name} -v ${kmod_version} ${kernel} | grep ':'",
      require => Class['Dkms::Install'],
    }

    if $use_autoinstall {
      Exec["dkms remove -m ${kmod_name} -v ${kmod_version} ${kernel}"] {
        notify => Class['Dkms::Autoinstall'],
      }
    }
  } else {
    fail('this is just here to make extending this easier')
  }
}
