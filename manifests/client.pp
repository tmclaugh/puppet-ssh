
class ssh::client {
	include ssh::params
	
	package { "openssh-clients":
		ensure => present
	}

	file { $ssh::params::ssh_config :
		owner => "root",
		group => "root",
		mode => 644,
		require => Package["openssh-clients"],
	}
}

define ssh::client::config_value ($value, $file="$ssh::params::ssh_config") {
	# XXX: Only set these values for 'Host *' so it can be disabled
	# in previous host pattern matches.
	#
	# GSSAPIAuthentication
	exec { "${name}_client" :
		command => "sed -i '/^Host \\*/,\$ {s/${name}.*$/${name} $value/'} $file",
		unless => "sed -n '/^Host \\*/,\$p' $file | grep \'${name} yes\'",
		require => File[$file]
	}
	
}
