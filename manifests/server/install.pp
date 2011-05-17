# Class: git::server::install
#
#
class git::server::install {
	package { 'diffstat':
		ensure  => installed,
		require => Class['xinetd'],
	}
	
	# Redhat/CentOS need the git-daemon package
	if ($operatingsystem =~ /(?i)(Redhat|CentOS)/)
		package { 'git-daemon':
			ensure  => latest
			require => Class['xinetd'],
		}
	}
}
