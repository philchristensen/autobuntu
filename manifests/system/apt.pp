class autobuntu::system::apt {
  include apt
  include apt::update

  file { "/etc/apt/sources.list.d":
    ensure => directory
  }

  apt::source { "ubuntu_archiv_precise":
    location        => "http://us-east-1.ec2.archive.ubuntu.com/ubuntu",
    release         => "precise",
    repos           => "main restricted universe multiverse",
    include_src     => false,
  }

  apt::source { "ubuntu_archiv_precise-updates":
    location        => "http://us-east-1.ec2.archive.ubuntu.com/ubuntu",
    release         => "precise-updates",
    repos           => "main restricted universe multiverse",
    include_src     => false,
  }

  apt::source { "ubuntu_archiv_precise-security":
    location        => "http://security.ubuntu.com/ubuntu",
    release         => "precise-security",
    repos           => "main restricted universe multiverse",
    include_src     => false,
  }
}