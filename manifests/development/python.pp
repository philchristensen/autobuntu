class autobuntu::development::python {
  ## need to ensure that we have an up to date distribute
  ## at time of this mod, ubuntu happens to ship with:
  ## 0.6.24dev-r0 which pip hates due to the non-numeric suffix
  ## Since the issue is the distro shipped python lib, we only
  ## force this out onto the global python path 
  autobuntu::development::python::pip::package { "distribute":
    ensure => latest,
    package => "distribute",
    pip_path => '/usr/bin/env pip'
  }
}