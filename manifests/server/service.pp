# Class: git::server::service
#
#
class git::server::service {
	service { 'git':
		ensure     => running,
		enable     => true,
		hasrestart => true,
		hasstatus  => true,
		notify     => Class['xinetd::service'],
		require    => Class['git::server::config'],
	}
}
