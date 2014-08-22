class autobuntu::development::gitlab(
    $dbhost,
    $dbpasswd,
    $gitlab_hostname
){
  tag('provisioning')

    include apache
    include apache::mod::proxy
    include apache::mod::proxy_http
    
    apache::mod { "rewrite": }

    include apt
    apt::key { "E1DF1F24":}->
    apt::ppa { "ppa:git-core/ppa": }

    package { 'ruby1.9.3':
      ensure => present,
    }

    package { ['libaugeas-ruby1.9.1', 'build-essential', 'zlib1g-dev', 'libyaml-dev', 'libssl-dev', 'libgdbm-dev', 'libreadline-dev', 'libncurses5-dev',
                'libffi-dev', 'git-core', 'openssh-server', 'redis-server', 'checkinstall', 'libxml2-dev', 'libpq-dev', 
                'libxslt-dev', 'libcurl4-openssl-dev', 'libicu-dev', 'python-docutils']:
      ensure => present,
      require => Package['ruby1.9.3']
    }
    
    user { "git":
      ensure => present,
      home => "/var/git",
      shell => "/bin/bash",
      managehome => true,
    }

    file { "git-home":
      path => "/var/git",
      owner => "git",
      group => "git",
      mode => "0755"
    }

    file { "var-git-repositories":
      ensure => directory,
      path => "/var/git/repositories",
      owner => "git",
      group => "git",
      mode => "2770",
      require => User["git"]
    }

    file { "var-git-bin":
      ensure => directory,
      path => "/var/git/bin",
      owner => "git",
      group => "git",
      mode => "0775",
      require => User["git"]
    }

    file { "var-git-profile":
      ensure => file,
      path => "/var/git/.profile",
      owner => "git",
      group => "git",
      mode => "0775",
      content => 'export PATH=$PATH:/var/git/bin'
    }

    file { "gitlab-gitconfig":
      ensure => file,
      path => "/var/git/.gitconfig",
      owner => "git",
      group => "git",
      mode => "0775",
      content => template("autobuntu/development/gitlab/gitconfig.ini.erb"),
    }

    autobuntu::development::git::checkout { "checkout-gitlab-shell":
      dirname => "gitlab-shell",
      path => "/var/git",
      owner => "git",
      group => "git",
      url => "https://github.com/gitlabhq/gitlab-shell.git",
      branch => "master",
      revision => 'ca425566d0266a1786019153757e283d7d246450', #v1.9.6',
      manage_working_dir => false,
      notify => Service[httpd],
      require => User["git"]
    }->
    
    file { "gitlab-shell-config":
      ensure => file,
      path => "/var/git/gitlab-shell/config.yml",
      content => template("autobuntu/development/gitlab/shell-config.yml.erb"),
      owner => "git",
      group => "git"
    }
    
    autobuntu::development::git::checkout { "checkout-gitlab":
      dirname => "gitlab",
      path => "/var/git",
      url => "https://github.com/gitlabhq/gitlabhq.git",
      # note that you want both the branch and the revision
      branch => '7-1-stable',
      revision => "facfec4b242ce151af224e20715d58e628aa5e74",
      manage_working_dir => false,
      owner => "git",
      group => "git",
      notify => Service[httpd],
      require => User["git"]
    }
    
    file { "gitlab-app-config":
      path => "/var/git/gitlab/config/gitlab.yml",
      content => template("autobuntu/development/gitlab/config.yml.erb"),
      require => Wt::Git::Checkout['checkout-gitlab'],
    }
    
    file { "gitlab-database-config":
      path => "/var/git/gitlab/config/database.yml",
      content => template("autobuntu/development/gitlab/database.yml.erb"),
      require => Wt::Git::Checkout['checkout-gitlab'],
    }
    
    file { "gitlab-unicorn-config":
      path => "/var/git/gitlab/config/unicorn.rb",
      source => "puppet:///modules/autobuntu/development/gitlab/unicorn.rb",
      require => Wt::Git::Checkout['checkout-gitlab'],
    }

    file { "gitlab-init":
      path => "/etc/init.d/gitlab",
      source => "puppet:///modules/autobuntu/development/gitlab/init.sh",
      owner => "git",
      group => "git",
      mode => "0755",
      require => Wt::Git::Checkout['checkout-gitlab'],
    }

    file { "gitlab-log":
      ensure => directory,
      path => "/var/git/gitlab/log",
      owner => "git",
      mode => "0775",
      require => Wt::Git::Checkout['checkout-gitlab'],
    }

    file { "gitlab-tmp":
      ensure => directory,
      path => "/var/git/gitlab/tmp",
      owner => "git",
      mode => "0775",
      require => Wt::Git::Checkout['checkout-gitlab'],
    }
    
    file { "gitlab-tmp-pids":
      ensure => directory,
      path => "/var/git/gitlab/tmp/pids",
      owner => "git",
      mode => "0775",
      require => Wt::Git::Checkout['checkout-gitlab'],
    }
    
    file { "gitlab-satellites":
      ensure => directory,
      path => "/var/git/gitlab-satellites",
      require => User['git']
    }

    file { "gitlab-uploads":
      ensure => directory,
      path => "/var/git/gitlab/public/uploads",
      require => User['git']
    }

    exec { "gitlab-bundle-install":
      command => "bundle install --deployment --without development test --deployment",
      cwd => "/var/git/gitlab",
      user => "git",
      group => "git",
      creates => "/var/git/gitlab/vendor/bundle",
      path => [
        "/usr/local/bin",
        "/usr/bin",
        "/bin",
      ],
      require => Wt::Git::Checkout['checkout-gitlab'],
    }

    apache::vhost { "${gitlab_hostname}-secure":
      priority => "10",
      docroot_owner => "git",
      docroot_group => "git",
      servername => $gitlab_hostname,
      vhost_name => $ipaddress,
      port => "443",
      ssl => true,
      template => "autobuntu/development/gitlab/vhost.conf.erb",
      docroot => "/var/git/gitlab/public"
      }->
    
    apache::vhost { $gitlab_hostname:
      priority => "10",
      docroot_owner => "git",
      docroot_group => "git",
      servername => $gitlab_hostname,
      vhost_name => $ipaddress,
      port => "80",
      ssl => false,
      template => 'autobuntu/development/gitlab/vhost.conf.erb',
      docroot => "/var/git/gitlab/public"
    }
}
