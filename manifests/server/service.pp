# Class: git::server::service
#
#
class git::server::service {
	service { "elasticsearch":
		ensure     => running,
		enable     => true,
		hasrestart => true,
		hasstatus  => true,
		notify     => Class["xinetd::service"],
		require    => Class["git::service::config"]
	}
}
