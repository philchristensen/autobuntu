class autobuntu::development::git {
  tag('provisioning')

  package { "git":
    ensure => latest
  }
}

define autobuntu::development::git::checkout($dirname, $url, $path, $branch='master', $revision='', $manage_working_dir=true, $owner='root', $group='root', $mode='0755', $hard=false, $force=true, $shallow=false, $envvars=[]) {
  ###
  # required args
  # @dirname: directory to check out into
  # @url: full url to git repo
  # @path: full path leading up to @dirname
  # 
  # optional args
  # (dir mgmt)
  # @manage_working_dir: create checkout path or require it exists? defaults to true
  # @owner: user chowned to, defaults to root 
  # @group: user chowned to, defaults to root 
  # @mode: mode chmodded to, defaults to 0775
  # (git)
  # @branch: branch name, defaults to master
  # @revision: short or long sha to checkout from branch, defaults to ''
  # @hard: do a hard checkout, can be: true, false, or 'ignore'. 
  #        If 'ignore' even ignored files are trashed.
  # @force: do a clone/checkout even if nothing about the repo has changed
  require autobuntu::development::git
  
  $checkout_path = "${path}/${dirname}"
  $unless_git = "/bin/bash -c '[[ -e ${checkout_path}/.git ]] && [[ $([[ -n \"${revision}\" ]] && echo \"${revision}\" || git --git-dir=${checkout_path}/.git ls-remote --heads origin ${branch} | cut -f1) == \"$(git --git-dir=${checkout_path}/.git rev-parse HEAD)\" ]]'"
  #notify { "GIT UNLESS: $unless_git": }

  if($manage_working_dir){
    file { "working-dir/${url}:${checkout_path}":
      ensure => directory,
      path => $checkout_path,
      backup => false,
      owner => $owner,
      group => $group,
      mode => $mode,
      require => Package["git"],
      before => Exec["clone/${url}:${checkout_path}"],
    }
  }

  ## figure out if we need to do anything..
  ## local head sha: git rev-parse HEAD
  ## remote head sha is:  $revision if passed else  git rev-parse origin/$branch
  exec { "clone/${url}:${checkout_path}":
    command => "git clone --branch ${branch} ${url} ${dirname}",
    timeout => 0,
    environment => $envvars,
    cwd => $path,
    creates => "${checkout_path}/.git",
    user => $owner,
    group => $group,
    path => ["/bin", "/usr/bin"],
    unless => $unless_git,
  }

  if ($hard) { 
    ## decides some things about remotes and swaps origin if needed..
    ## This only runs in hard mode.  Swapping remotes without hard
    ## cleaning after can have unexpected results..

    ## skip this whole chain if our shas match
    exec { "check-remote/${url}:${checkout_path}":
      command => "git remote set-url origin ${url}",
      timeout => 0,
      environment => $envvars,
      cwd => "${checkout_path}",
      user => $owner,
      group => $group,
      path => ["/bin", "/usr/bin"],
      onlyif => "test \"$(git config remote.origin.url)\" != \"${url}\"",
      require => [Exec["clone/${url}:${checkout_path}"], Package["git"]],
      unless => $unless_git,
    }

    ## this does a "pull" but it also insures any local changes
    ## are blown out. 
    exec { "fetch/${url}:${checkout_path}":
      command => "git fetch --all",
      timeout => 0,
      environment => $envvars,
      cwd => "${checkout_path}",
      user => $owner,
      group => $group,
      path => ["/bin", "/usr/bin"],
      require => Exec["check-remote/${url}:${checkout_path}"],
      unless => $unless_git,
    }

    exec { "pull/${url}:${checkout_path}":
      command => "git reset --hard origin/${branch}",
      timeout => 0,
      environment => $envvars,
      cwd => "${checkout_path}",
      user => $owner,
      group => $group,
      path => ["/bin", "/usr/bin"],
      require => Exec["fetch/${url}:${checkout_path}"],
      unless => $unless_git,
    }

    ## so hard we even trash things listed in .gitignore..
    if ($hard == 'ignore') {
      $clean_flags = '-dfx'
    } else {
      $clean_flags = '-df'
    }
    exec { "clean/${url}:${checkout_path}":
      command => "git clean ${clean_flags}",
      timeout => 0,
      environment => $envvars,
      cwd => "${checkout_path}",
      user => $owner,
      group => $group,
      path => ["/bin", "/usr/bin"],
      require => Exec["pull/${url}:${checkout_path}"],
      ## clean if dirty even if the repo is unchanged..
      onlyif => "/bin/bash -c 'git status --porcelain 2>/dev/null| grep -E \"^(\?\?| M)\"'",
    }
    # end hard checkout
  } else {
    # soft checkout
    exec { "pull/${url}:${checkout_path}":
      command => "git pull origin ${branch}",
      timeout => 0,
      environment => $envvars,
      cwd => "${checkout_path}",
      user => $owner,
      group => $group,
      path => ["/bin", "/usr/bin"],
      require => [Exec["clone/${url}:${checkout_path}"], Package["git"]],
      unless => $unless_git,
    }
    # end soft checkout
  }

  if($revision){
    exec { "checkout/${url}/${revision}/${checkout_path}":
      command => "git checkout ${revision}",
      timeout => 0,
      environment => $envvars,
      cwd => "${checkout_path}",
      user => $owner,
      group => $group,
      path => ["/bin", "/usr/bin"],
      require => [Exec["pull/${url}:${checkout_path}"], Package["git"]],
      unless => $unless_git,
    }
  }
  
  anchor { "checkout/${url}/${revision}/${checkout_path}": }
} ## end checkout
