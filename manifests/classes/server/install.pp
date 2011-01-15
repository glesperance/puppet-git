# Class: git::server::install
#
#
class git::server::install {
	Package {
		require => Class["xinetd"]
	}
	
	package { "diffstat":
		ensure => installed
	}
	
	# Redhat/CentOS need the git-daemon package
	if ($operatingsystem =~ /(?i)(Redhat|CentOS)/)
		package { "git-daemon":
			ensure => latest
		}
	}
}
