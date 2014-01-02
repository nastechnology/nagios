class nagios::target {
  
  $my_os = downcase($operatingsystem)

  @@nagios_host { $fqdn:
    ensure  => present,
    alias   => $::hostname,
    address => $::ipaddress,
    use     => 'generic-host',
  }

  @@nagios_service { "check_ping_${::hostname}":
    check_command       => 'check_ping!100.0,20%!500.0,60%',
    use                 => 'generic-service',
    host_name           => $::fqdn,
    notification_period => '24x7',
    service_description => "${::hostname}_check_ping",
  }

  @@nagios_hostextinfo { $fqdn:
    ensure          => present,
    icon_image_alt  => $operatingsystem,
    icon_image      => "base/${my_os}.png",
    statusmap_image => "base/${my_os}.gd2",
  }

}
