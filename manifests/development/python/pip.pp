class autobuntu::development::python::pip {
  tag('provisioning')
  file { ["/var/cache/pip",
          "/var/cache/pip/requirements"]:
    ensure => directory
  }
}

define autobuntu::development::python::pip::package(
  $package = $name,
  $ensure = "present",
  $index_url = nil,
  $pip_cache_dir = nil,
  $pip_path
){
  if($index_url != nil){
    $index_url_switch = "--use-mirrors --index-url=${index_url}"
  }
  else {
    $index_url_switch = '--use-mirrors'
  }
  
  if ($pip_cache_dir != nil){
    ## ensure it exists if it's provided..
    ## you're on your own to create it.
    validate_absolute_path($pip_cache_dir)
    $pip_cache_switch = "--download-cache ${pip_cache_dir}"
  } else {
    $pip_cache_switch = ''
  }
  
  case $ensure {
    'absent': {
      exec { "pip-uninstall-${name}":
        onlyif => "${pip_path} freeze | grep -i ${package}",
        command => "${pip_path} uninstall ${package}",
        timeout => 0
      }
    }
    'latest': {
      exec { "pip-install-latest-${name}":
        command => "${pip_path} install ${pip_cache_switch} ${index_url_switch} -U ${package}",
        timeout => 0
      }
    }
    'present': {
      exec { "pip-install-${name}":
        unless => "${pip_path} freeze | grep -i ${package}",
        command => "${pip_path} install ${pip_cache_switch} ${index_url_switch} ${package}",
        timeout => 0
      }
    }
    default: {
      exec { "pip-install-version-${name}":
        unless => "${pip_path} freeze | grep -i ^${package}==${ensure}$",
        command => "${pip_path} install ${pip_cache_switch} ${index_url_switch} ${package}",
        timeout => 0
      }
    }
  }
}

define autobuntu::development::python::pip::requirements(
  $pip_path,
  $requirements = $name,
  $ensure = "present",
  $pip_cache_dir = nil,
  $index_url = nil
){
  if($index_url != nil){
    $index_url_switch = " --index-url=${index_url}"
  }
  else {
    $index_url_switch = ''
  }

  if ($pip_cache_dir != nil){
    validate_absolute_path($pip_cache_dir)
    $pip_cache_switch = "--download-cache ${pip_cache_dir}"
  } else {
    $pip_cache_switch = ''
  }

  include autobuntu::development::python::pip

  case $ensure {
    'present': {
      $reqhash = md5($requirements)
      $hashpath = "/var/cache/pip/requirements/${reqhash}.txt.md5"
      exec { "pip-install-requirements-${name}":
        command => "${pip_path} install ${pip_cache_switch} ${index_url_switch} -r ${requirements}",
        unless => "test -f ${hashpath} && test \"$(md5sum ${requirements})\" != \"$(cat ${hashpath})\"",
        path => "/usr/bin",
        timeout => 0,
        notify => Exec["pip-install-requirements-${name}-md5"]
      }
      
      exec { "pip-install-requirements-${name}-md5":
        command => "/usr/bin/md5sum ${requirements} > /var/cache/pip/requirements/${reqhash}.txt.md5",
        refreshonly => true,
        require => File["/var/cache/pip/requirements"]
      }
    }
    'latest': {
      exec { "pip-install-requirements-latest-${name}":
        command => "${pip_path} install ${pip_cache_switch} ${index_url_switch} -U -r ${requirements}",
        timeout => 0
      }
    }
    'bleeding': {
      exec { "pip-install-requirements-bleeding-edge-${name}":
        command => "${pip_path} install ${pip_cache_switch} ${index_url_switch} --no-deps -U -r ${requirements}",
        timeout => 0
      }
    }
  }
}
