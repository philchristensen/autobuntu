class autobuntu::apps::bash(
  $prompt_label = ''
) {
  tag('provisioning')

  file { "/etc/bash.bashrc":
    ensure => file,
    content => template("autobuntu/apps/bash/bash.bashrc.erb"),
    owner => "root",
    group => "root",
    mode => "0644"
  }
  
  file { "/etc/skel/.bashrc":
    ensure => file,
    content => template("autobuntu/apps/bash/skel-dot-bashrc.erb"),
    owner => "root",
    group => "root",
    mode => "0644"
  }
}
