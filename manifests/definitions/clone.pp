define git::clone ($source, $localtree="/srv/git/", $real_name=false, $branch=false) {
	if $real_name {
		$_name = $real_name
	}
	else {
		$_name = $name
	}

	exec { "git_clone_exec_$localtree/$_name":
		command => "/usr/bin/git clone `echo $source | sed -r -e 's,(git://|ssh://)(.*)//(.*),\\1\\2/\\3,g'` $_name",
		cwd     => $localtree,
		creates => "$localtree/$_name/.git/",
		require => File["$localtree"]
	}

	if defined(File["$localtree"]) {
		realize(
			File["$localtree"]
		)
	} else {
		@file { "$localtree":
			ensure => directory
		}
		realize(
			File["$localtree"]
		)
	}

	case $branch {
		false: {}
		default: {
			exec { "git_clone_checkout_$branch_$localtree/$_name":
				command => "git checkout --track -b $branch origin/$branch",
				cwd     => "$localtree/$_name",
				creates => "$localtree/$_name/.git/refs/heads/$branch",
				require => Exec["git_clone_exec_$localtree/$_name"]
            }
        }
    }
}
