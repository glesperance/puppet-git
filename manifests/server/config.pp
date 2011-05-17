# Class: git::server::config
#
#
class git::server::config {
	file { '/git/':
		ensure  => directory,
		owner   => 'root',
		group   => 'root',
		mode    => '0755'
		notify  => Class['git::server::service'],
		require => Class['git::server::install'],
	}

	file { '/usr/local/bin/git_init_script':
		source  => [ 'puppet:///modules/files/git/git_init_script', 'puppet:///modules/git/git_init_script' ]
		owner   => 'root',
		group   => 'root'
		mode    => '0750',
		notify  => Class['git::server::service'],
		require => Class['git::server::install'],
	}
}
