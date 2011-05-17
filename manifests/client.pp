# Class: git::client
#
# This class causes the client to gain git capabilities. Boo!
#
class git::client {
	package { 'git':
		name   => $operatingsystem ? {
			/(?i)(Debian|Ubuntu)/ => 'git-core',
			/(?i)(Redhat|CentOS)/ => 'git',
		},
		ensure => latest,
	}
}
