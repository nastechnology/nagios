class nagios::monitor {

  # Manage the packages
  package { ['nagios3', 'nagios-plugins', 'nagios-nrpe-plugin' ]: ensure => installed }

  # Manage the Nagios monitoring service
  service { 'nagios3':
    ensure    => running,
    hasstatus => true,
    enable    => true,
    alias     => 'nagios',
    subscribe => [ Package['nagios3'], Package['nagios-plugins'], Package['nagios-nrpe-plugin'] ],
  }

  # Collect resources and populate /etc/nagios/nagios_*.cfg
  Nagios_host    <<||>> { notify => Service['nagios'] }
  Nagios_service <<||>> { notify => Service['nagios'] }
  Nagios_hostextinfo <<||>> { notify => Service['nagios'] }

  @@nagios_host { 'windows-server':
    ensure                => present,
    use                   => 'generic-host',
    target                => '/etc/nagios3/objects/template.cfg',
    check_period          => '24x7',
    check_interval        => '5',
    retry_interval        => '1',
    max_check_attempts    => '10',
    check_command         => 'check-host-alive',
    notification_period   => '24x7',
    notification_interval => '30',
    notification_options  => 'd,r',
    contact_groups        => 'admins',
    register              => '0',
    notify                => Service['nagios'],
  }

  exec { 'SetNagiosObjectsPerms':
    command => '/usr/bin/sudo /bin/chmod -Rf 744 /etc/nagios3/objects',
  }

  exec { 'SetNagiosPerms':
    command => '/usr/bin/sudo /bin/chmod -Rf 744 /etc/nagios',
  }
}
