#
# This resource enables one to update a working directory
# from an upstream GIT source repository. Note that by default,
# the working directory is reset (undo any changes to tracked
# files), and clean (remove untracked files)
#
# Note that to prevent a reset to be executed, you can set $reset to
# false when calling this resource.
#
# Note that to prevent a clean to be executed as part of the reset, you
# can set $clean to false
#
define git::pull ($localtree = '/srv/git/',
									$real_name = false,
									$reset     = true,
									$clean     = true,
									$branch    = false) {

	if $reset {
		git::reset { $name:
			localtree => $localtree,
			real_name => $real_name,
			clean     => $clean,
		}
	}

	@exec { "git_pull_exec_${name}":
		command => '/usr/bin/git pull',
		cwd     => "${localtree}/${real_name}",
		onlyif  => "test -d ${localtree}/${real_name}/.git/info",
	}

	case $branch {
		false: {}
		default: {
			exec { "git_pull_checkout_${branch}_${localtree}/${name}":
				cwd => "${localtree}/${name}",
				command => "/usr/bin/git checkout --track -b ${branch} origin/${branch}",
				creates => "${localtree}/${name}/refs/heads/${branch}",
			}
		}
	}

	if defined(Git::Reset[$name]) {
		Exec["git_pull_exec_${name}"] {
			require +> Git::Reset[$name],
		}
	}

	if defined(Git::Clean[$name]) {
		Exec["git_pull_exec_${name}"] {
			require +> Git::Clean[$name],
		}
	}

	realize(Exec["git_pull_exec_${name}"])
}
