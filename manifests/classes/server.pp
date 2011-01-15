# Class: git::server inherits git::client
#
# Including this class will install git, the git-daemon, ensure the
# service is running
#
class git::server inherits git::client {
	include xinetd
	include git::server::install, git::server::config, git::server::service
}
