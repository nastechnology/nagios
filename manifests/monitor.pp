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
}
