class nagios::target::ubuntu {
	  
  package { 'nagios-nrpe-server':
    ensure => installed,
  }

  service { 'nagios-nrpe-server':
    ensure  => running,
    enable  => true,
    require => Package['nagios-nrpe-server'],
  }

  augeas { 'nrpe config':
    context   => '/files/etc/nagios/nrpe.cfg',
    changes   => present ? {
      present => "set allowed_hosts[.= '10.20.2.18'] 10.20.2.18",
      default => "rm allowed_host 127.0.0.1",
    },
    require   => Package['nagios-nrpe-server'],
    notify    => Service['nagios-nrpe-server'],
  }

  @@nagios_host { $fqdn:
    ensure  => present,
    alias   => $::hostname,
    address => $::ipaddress,
    use     => 'generic-host',
  }

  @@nagios_hostgroup { 'ubuntu-servers':
    ensure => absent,
  }

  @@nagios_hostextinfo { $fqdn:
     ensure          => present,
     icon_image_alt  => 'ubuntu',
     icon_image      => "base/ubuntu.png",
     statusmap_image => "base/ubuntu.gd2",
  }

  @@nagios_service { "check_ping_${::hostname}":
    check_command       => 'check_ping!100.0,20%!500.0,60%',
    use                 => 'generic-service',
    host_name           => $::fqdn,
    notification_period => '24x7',
    service_description => "${::hostname}_check_ping",
  }

  @@nagios_service { "check_load_${hostname}":
    use                 => "generic-service",
    host_name           => "$fqdn",
    check_command       => 'check_nrpe_1arg!check_load',
    service_description => "check_load_${hostname}",
  }

  @@nagios_service { "check_total_procs_${hostname}":
    use                 => "generic-service",
    host_name           => $fqdn,
    check_command       => 'check_nrpe_1arg!check_total_procs',
    service_description => "check_total_procs_${hostname}",
  }
}