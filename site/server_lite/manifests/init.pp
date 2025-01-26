# basic server setup
class server_lite {
  user { 'ansible':
    ensure     => present,
    home       => '/home/ansible',
    shell      => '/bin/bash',
    managehome => true,
    gid        => 'ansible',
  }

  group { 'ansible':
    ensure  => present,
  }
  file { '/etc/sudoers.d/00_ansible':
    owner  => root,
    group  => root,
    mode   => '0440',
    source => 'puppet:///modules/server_lite/sudo/nopasswd_users/00_ansible',
  }
  group { 'hf-admin':
    ensure  => present,
  }

  file { '/etc/sudoers.d/hf-admin':
    owner  => root,
    group  => root,
    mode   => '0440',
    source => 'puppet:///modules/server_lite/sudo/groups/hf-admin',
  }

  if $kernel == 'Linux' {
    file { '/root/.ssh':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0700';
    }
    file { '/root/.ssh/authorized_keys':
      ensure  => file,
      backup  => false,
      content => template('server_lite/sshkeys/authorized_keys.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0600';
    }
  }

  if $kernel == 'Linux' {
    file { '/home/ansible/.ssh':
      ensure => directory,
      owner  => 'ansible',
      group  => 'ansible',
      mode   => '0700';
    }
    file { '/home/ansible/.ssh/authorized_keys':
      ensure  => file,
      backup  => false,
      content => template('server_lite/sshkeys/authorized_keys.erb'),
      owner   => 'ansible',
      group   => 'ansible',
      mode    => '0600';
    }
  }

  package {
    'file':        ensure => installed;
    'sudo':        ensure => installed;
    'wget':        ensure => installed;
    'less':        ensure => installed;
    'curl':        ensure => installed;
    'rsync':       ensure => installed;
    'git':         ensure => installed;
    'strace':      ensure => installed;
    'tmux':        ensure => installed;
    'ethtool':     ensure => installed;
    'bpftrace':    ensure => installed;
    'tcpdump':     ensure => installed;
    'bc':          ensure => installed;
    'python3':     ensure => installed;
    'python3-pip': ensure => installed;
  }
  if $facts['os']['family'] == 'Debian' {
    package {
      'openssh-server':       ensure => installed;
    }

    service {
      'ssh':
        ensure     => running,
        require    => Package['openssh-server'],
        enable     => true,
        hasstatus  => true,
        hasrestart => true;
    }

    file { '/etc/ssh/sshd_config':
      owner  => root,
      group  => root,
      mode   => '0644',
      source => 'puppet:///modules/server_lite/sshd/debian/sshd_config'
    }

    exec {
      'ssh_restart':
        command     => '/usr/bin/systemctl restart sshd',
        refreshonly => true;
    }

    package {
      'chase':          ensure => installed;
      'iotop':          ensure => installed;
      'pwgen':          ensure => installed;
      'xz-utils':       ensure => installed;
      'cron-apt':       ensure => installed;
      'dnsutils':       ensure => installed;
      'sysstat':        ensure => installed;
      'virt-what':      ensure => installed;
      'net-tools':      ensure => installed;
      'tldr':           ensure => installed;
      'netcat-openbsd': ensure => installed;
      'locales-all':    ensure => installed;
      'psmisc':         ensure => installed;
    }
    if ! defined(Package['vim']) {
      package {
        'vim':       ensure => installed;
      }
    }
  }

  if $facts['os']['family'] =='RedHat' {
    package {
      'openssh-server':       ensure => installed;
    }

    service {
      'sshd':
        ensure     => running,
        require    => Package['openssh-server'],
        enable     => true,
        hasstatus  => true,
        hasrestart => true;
    }

    file { '/etc/ssh/sshd_config':
      owner  => root,
      group  => root,
      mode   => '0644',
      source => 'puppet:///modules/server_lite/sshd/rhel/sshd_config',
    }

    exec {
      'ssh_restart':
        command     => '/usr/bin/systemctl restart sshd',
        refreshonly => true;
    }

    package {
      'xz':                ensure => installed;
      'vim-enhanced':      ensure => installed;
      'coreutils':         ensure => installed;
      'bind-utils':        ensure => installed;
      'sysstat':           ensure => installed;
      'virt-what':         ensure => installed;
      'net-tools': ensure => installed;
      'tldr': ensure => installed;
      # used in module patching_as_code
      # 'yum-utils': ensure => installed;
    }

    if $facts['os']['release'] =~ /^7.*/ {
      package {
        'nmap-ncat':       ensure => installed;
      }
    } else {
      package {
        'nc':              ensure => installed;
      }
    }
  }
  service {
    'puppet-agetn':
      ensure     => stopped,
      enable     => false,
      hasstatus  => true,
      hasrestart => true;
  }
}
