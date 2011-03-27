#
# Resource to clean out a working directory
# Useful for directories you want to pull from upstream, but might
# have added files. This resource is applied for all pull resources,
# by default.
#
define git::clean ($localtree="/srv/git/", $real_name=false) {
	exec { "git_clean_exec_$name":
		command => "/usr/bin/git clean -d -f",
		cwd     => $real_name ? {
			false   => "$localtree/$name",
			default => "$localtree/$real_name"
		}
	}
}
