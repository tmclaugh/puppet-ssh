
class ssh::server{
	include ssh::params
	
	package { "openssh-server" :
		ensure => installed,
	}

	file { "$ssh::params::sshd_config" :
		owner => "root",
		group => "root",
		mode => 600,
		require => Package["openssh-server"],
	}

	service { "sshd" :
		enable => true,
		ensure => true,
		subscribe => Package["openssh-server"]
	}
}


# XXX: The following line(), replace(), line() functions work in
# together. First we uncomment the option if no uncommeneted line
# exists. Next we replace that uncommented line with a wanted
# value. Finally, we ensure that the wanted value exists. If the
# config option did not exist in the first place then the previous
# two functions would have passed but we would still not have the
# wanted config value. This idiom is cumbersome but does not
# require tons of error handling in the functions and lets us
# keep them simple.

define ssh::server::config_value ($value, $file="$ssh::params::sshd_config") {
	line { "${name}_uncomment" :
		file => "$file",
		line => "${name}",
		ensure => "uncomment",
		require => File["$file"],
	}

	replace { "${name}_replace" :
		file => "$file",
		pattern => "^${name}.*",
		replacement => "${name} $value",
		require => Line["${name}_uncomment"],
	}

	line { "${name}_present" :
		file => "$file",
		line => "${name} $value",
		ensure => "present",
		require => Replace["${name}_replace"],
		notify => Service['sshd']
	}
}