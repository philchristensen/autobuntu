define autobuntu::development::python::django::collectstatic($pythonpath, $projectpath, $managepath='manage.py', $env=[], $clear=false) {
  if ($clear) {
    $cmd = "${pythonpath} ${managepath} collectstatic --noinput --clear"
  } else {
    $cmd = "${pythonpath} ${managepath} collectstatic --noinput"
  }

  exec { "$projectpath/collectstatic":
    environment => $env,
    command => $cmd,
    cwd => $projectpath,
  }
}

define autobuntu::development::python::django::syncdb($pythonpath, $projectpath, $managepath='manage.py', $env=[]) {
  exec { "$projectpath/syncdb":
    environment => $env,
    command => "${pythonpath} ${managepath} syncdb --noinput",
    cwd => $projectpath,
  }
}

define autobuntu::development::python::django::migrate($pythonpath, $projectpath, $managepath='manage.py', $env=[]) {
  exec { "$projectpath/migrate":
    environment => $env,
    ## south 0.8.2 required
    command => "${pythonpath} ${managepath} migrate --noinput --ignore-ghost-migrations",
    cwd => $projectpath,
  }
}

define autobuntu::development::python::django::smartmigrate($pythonpath, $projectpath, $managepath='manage.py', $env=[]) {
  exec { "$projectpath/smartmigrate":
    environment => $env,
    command => "${pythonpath} ${managepath} smartmigrate --noinput --ignore-ghost-migrations",
    cwd => $projectpath,
  }
}

define autobuntu::development::python::django::clearcache($pythonpath, $projectpath, $managepath='manage.py', $env=[]) {
  exec { "$projectpath/clearcache":
    environment => $env,
    command => "${pythonpath} ${managepath} clear_cache",
    cwd => $projectpath,
  }
}

## django helps you ensure your non-volitile database cache table exists..
define autobuntu::development::python::django::createcachetable($pythonpath, $projectpath, $cachealias, $managepath='manage.py', $env=[]) {
  exec { "$projectpath/createcachetable":
    environment => $env,
    command => "${pythonpath} ${managepath} createcachetable ${cachealias}",
    cwd => $projectpath,
    logoutput => on_failure,
    ## the command, however, exits 1 if the table already exists..
    returns => [0, 1],
  }
}

define autobuntu::development::python::django::loaddata($pythonpath, $projectpath, $fixturefile, $managepath='manage.py', $database='default', $env=[]) {
  exec { "$projectpath/loaddata/$fixturefile":
    environment => $env,
    command => "${pythonpath} ${managepath} loaddata --database='${database}' ${fixturefile}",
    cwd => $projectpath,
  }
}

define autobuntu::development::python::django::superuser($pythonpath, $projectpath, $managepath='manage.py', $supername, $superemail, $superpass, $env=[]) {
  exec { "$projectpath/superuser":
    environment => $env,
    command => "${pythonpath} ${managepath} superuser '${supername}' '${superemail}' '${superpass}'",
    cwd => $projectpath,
  }
}

define autobuntu::development::python::django::set_cms_user_perms($pythonpath, $projectpath, $managepath='manage.py', $env=[]) {
  exec { "$projectpath/set_cms_user_perms":
    environment => $env,
    command => "${pythonpath} ${managepath} set_cms_user_perms",
    cwd => $projectpath,
  }
}

define autobuntu::development::python::django::cms_data_reset($pythonpath, $projectpath, $managepath='manage.py', $env=[]) {
  exec { "$projectpath/cms_data_reset/$fixturefile":
    environment => $env,
    command => "${pythonpath} ${managepath} cms_data_reset",
    cwd => $projectpath,
  }
}


define autobuntu::development::python::django::kronosinstall($pythonpath, $projectpath, $managepath='manage.py',  $env=[]) {
  exec { "$projectpath/installtasks":
    environment => $env,
    command => "${pythonpath} ${managepath} installtasks",
    cwd => $projectpath,
  }
}

define autobuntu::development::python::django::rewrite_proxy_rules($pythonpath, $projectpath, $sys_env, $managepath='manage.py', $output_dir='.', $env=[]) {
  ## cmd only on iws-proxy, for dumping proxy rules out to a set of files..
  exec { "$projectpath/rewrite_proxy_rules":
    environment => $env,
    command => "${pythonpath} ${managepath} rewrite_proxy_rules ${sys_env} --dir=${output_dir}",
    cwd => $projectpath,
  }
}
