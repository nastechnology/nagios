class nagios::target::windows {
	  
  package { "NSClientPlusPlus.${architecture}":
      ensure => installed,
      before => Service['NSClientpp'],
  }

  service { 'NSClientpp':
    ensure  => 'running',
    enable  => true,
  }

  file { "C:/Program Files/NSClient++/NSC.ini":
    ensure  => file,
    owner   => 'Administrator',
    group   => 'Administrators',
    mode    => 0777,
    source  => 'puppet:///modules/nagios/NSC.ini',
    require => Package["NSClientPlusPlus.${architecture}"],
    notify  => Service['NSClientpp'],
  }

  if ($fqdn == ''){
    $fqdn = "${hostname}.nas.local"
  }

  @@nagios_host { $fqdn:
    ensure  => present,
    alias   => $::hostname,
    address => $::ipaddress,
    use     => 'windows-server',
  }

  @@nagios_hostextinfo { $fqdn:
     ensure          => present,
     icon_image_alt  => 'windows',
     icon_image      => "base/win40.png",
     statusmap_image => "base/win40.gd2",
  }

  @@nagios_service { "check_ping_${hostname}":
    check_command       => 'check_ping!100.0,20%!500.0,60%',
    use                 => 'generic-service',
    host_name           => $fqdn,
    notification_period => '24x7',
    service_description => "${::hostname}_check_ping",
  }

  @@nagios_service { "check_cpu_load_${hostname}":
    use                 => "generic-service",
    host_name           => $fqdn,
    check_command       => 'check_nt!CPULOAD!-l 5,80,90',
    service_description => "check_cpu_load_${hostname}",
  }
 
  @@nagios_service { "check_nscpp_version_${hostname}":
    use                 => "generic-service",
    host_name           => $fqdn,
    check_comman        => 'check_nt!CLIENTVERSION',
    service_description => "check_nscpp_version_${hostname}",
  }

  @@nagios_service { "check_mem_usage_${hostname}":
    use                 => "generic-service",
    host_name           => $fqdn,
    check_command       => 'check_nt!MEMUSE!-w 80 -c 90',
    service_description => "check_mem_usage_${hostname}",
  }
}