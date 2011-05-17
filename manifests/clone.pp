define git::clone ($source,
									 $localtree  = '/srv/git/',
									 $real_name  = false,
									 $branch     = false,
									 $submodules = false,
									 $user       = '') {

	include git::client
	
	if $real_name {
		$_name = $real_name
	}
	else {
		$_name = $name
	}

	# if defined(File["git-${localtree}"]) {
	# 		realize(
	# 			File["git-${localtree}"]
	# 		)
	# 	} else {
	# 		@file { "git-${localtree}":
	# 			path   => $localtree,
	# 			ensure => directory
	# 		}
	# 		realize(
	# 			File["git-${localtree}"]
	# 		)
	# 	}

	exec { "git_clone_exec_$localtree/$_name":
		command => "/usr/bin/git clone `echo ${source} | sed -r -e 's,(git://|ssh://)(.*)//(.*),\\1\\2/\\3,g'` ${_name}",
		cwd     => $localtree,
		creates => "${localtree}/${_name}/.git/",
		user    => $user ? {
			''      => undef,
			default => $user
		},
		require => Class['git::client'],
	}

	case $branch {
		false: {}
		default: {
			exec { "git_clone_checkout_${branch}_${localtree}/${_name}":
				command => "git checkout --track -b ${branch} origin/${branch}",
				cwd     => "${localtree}/${_name}",
				creates => "${localtree}/${_name}/.git/refs/heads/${branch}",
				user    => $user ? {
					''      => undef,
					default => $user,
				},
				require => Exec["git_clone_exec_${localtree}/${_name}"],
			}
		}
	}

	case $submodules {
		false: {}
		default: {
			exec { "git_update_subomodules_${localtree}/${_name}":
				command => 'git submodule update --init --recursive',
				cwd     => "${localtree}/${_name}",
				onlyif  => 'git submodule status | grep ^-',
				user    => $user ? {
					''      => undef,
					default => $user,
				},
				require => $branch ? {
					false   => Exec["git_clone_exec_${localtree}/${_name}"],
					default => Exec["git_clone_checkout_${branch}_${localtree}/${_name}"],
				},
			}
		}
	}
}
