# Class: git::server::config
#
#
class git::server::config {
	File {
		require => Class["git::server::install"],
		notify  => Class["git::server::service"],
		owner   => root,
		group   => root
	}
	
	file { "/git/":
		ensure => directory,
		mode   => 755
	}

	file { "/usr/local/bin/git_init_script":
		mode => 750,
		source => [ "puppet:///modules/files/git/git_init_script", "puppet:///modules/git/git_init_script" ]
	}
}
