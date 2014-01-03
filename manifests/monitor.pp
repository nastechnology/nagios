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
  Nagios_timeperiod <<||>> { notify => Service['nagios'] }
  Nagios_hostextinfo <<||>> { notify => Service['nagios'] }

  exec { 'SetNagiosPerms':
    command => '/usr/bin/sudo /bin/chmod -Rf 644 /etc/nagios/*',
  }

  @@nagios_host { 'windows-server':
    ensure                => present,
    use                   => 'generic-host',
    target                => '/etc/nagios/template.cfg',
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

  @@nagios_timeperiod { 'weekdays':
    ensure           => present,
    timeperiod_name  => 'weekdays',
    alias            => 'weekdays',
    monday           => '00:00-24:00',
    tuesday          => '00:00-24:00',
    wednesday        => '00:00-24:00',
    thursday         => '00:00-24:00',
    friday           => '00:00-24:00',
  }

  @@nagios_timeperiod { 'weekends':
    ensure           => present,
    alias            => 'weekends',
    timeperiod_name  => 'weekends',
    saturday         => '00:00-24:00',
    sunday           => '00:00-24:00',
  }

  @@nagios_timeperiod { 'holidays':
    ensure           => present,
    alias            => 'holidays',
    timeperiod_name  => 'holidays',
    'january1'         => '00:00-24:00 ; New Years Day',
    #2008-03-23    00:00-24:00 ; Easter (2008)
    #2009-04-12    00:00-24:00 ; Easter (2009)
    #monday -1 may   00:00-24:00 ; Memorial Day (Last Monday in May)
    #july 4      00:00-24:00 ; Independence Day
    #monday 1 september  00:00-24:00 ; Labor Day (1st Monday in September)
    #thursday 4 november 00:00-24:00 ; Thanksgiving (4th Thursday in November)
    #december 25   00:00-24:00 ; Christmas
    #december 31   17:00-24:00 ; New Year's Eve (5pm onwards)
  }

}
