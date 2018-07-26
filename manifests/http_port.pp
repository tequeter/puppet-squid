define squid::http_port (
  Optional[Integer] $port    = undef,
  Optional[String]  $host    = undef,
  Boolean           $ssl     = false,
  String            $options = '',
  String            $order   = '05',
) {
  $_title = String($title)

  if $port == undef {
    if $_title =~ /^(?:.+:)?(\d+)$/ {
      $_port = Integer($1)
    } else {
      fail("port couldn't be determined from title nor args")
    }
  } else {
    $_port = $port
  }

  # Only grab the host from the title if no port arg given and the title is
  # very likely to mean host:port. This should be backward-compatible with
  # client code from before this feature was introduced.
  if $port == undef and $host == undef and $_title =~ /^(.+):\d+$/ {
    $_host = $1
  } else {
    $_host = $host # May be undef
  }

  $protocol = $ssl ? {
    true    => 'https',
    default => 'http',
  }

  concat::fragment{"squid_${protocol}_port_${_title}":
    target  => $squid::config,
    content => template('squid/squid.conf.port.erb'),
    order   => "30-${order}",
  }

  if $facts['selinux'] == true {
    selinux::port{"selinux port squid_port_t ${_port}":
      ensure   => 'present',
      seltype  => 'squid_port_t',
      protocol => 'tcp',
      port     => $_port,
    }
  }

}

