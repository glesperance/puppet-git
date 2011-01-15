define git::repository::domain ($public=false, $shared=false, $localtree="/srv/git/", $owner="root", $group="root", $prefix=false,
								$symlink_prefix=false, $recipients=false, $satelliteuser=false, $description=false) {
	repository { "$name":
		public         => $public,
		shared         => $shared,
		localtree      => "$localtree/",
		owner          => "$owner",
		group          => "git-$name",
		prefix         => $prefix,
		symlink_prefix => $symlink_prefix,
		recipients     => $recipients,
		description    => "$description",
		require        => Group["git-$name"]
    }

	if defined(Group["git-$name"]) {
		realize(Group["git-$name"])
	} else {
		@group { "git-$name":
			ensure => present
		}
		realize(Group["git-$name"])
	}

	if ($satelliteuser) {
		if defined(User["satellite-$name"]) {
			realize(User["satellite-$name"])
		} else {
			@user { "satellite-$name":
				ensure  => present,
				comment => "Satellite user for domain $name",
				groups  => "git-$name",
				shell   => "/usr/bin/git-shell"
			}
			realize(User["satellite-$name"])
        }
    }
}
