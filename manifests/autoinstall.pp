# @summary Just a place to run autoinstall
#
# @param timeout this is the exec timeout
#
# @example
#   include dkms::autoinstall
class dkms::autoinstall (
  Integer $timeout,
) {
  exec { 'dkms autoinstall':
    path        => $facts['path'],
    refreshonly => true,
    timeout     => $timeout,
  }
}
