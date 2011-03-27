# FIXME
# Why does this include server? One can run repositories without a
# git daemon..!!
#
# - The defined File["git_init_script"] resource will need to move to
# this class
#
# Documentation on this resource
#
# Set $public to true when calling this resource to make the repository
# readable to others
#
# Set $shared to true to allow the group owner (set with $group) to
# write to the repository
#
# Set $localtree to the base directory of where you would like to have
# the git repository located.
#
# The actual git repository would end up in $localtree/$name, where
# $name is the title you gave to the resource.
#
# Set $owner to the user that is the owner of the entire git repository
#
# Set $group to the group that is the owner of the entire git repository
#
# Set $init to false to prevent the initial commit to be made
#
define git::repository ($public=false, $shared=false, $localtree="/srv/git/", $owner="root", $group="root", $symlink_prefix=false, $symbolic_link=true,
						$prefix=false, $recipients=false, $real_name=false, $description=false) {
    if !defined(File["/usr/local/bin/git_init_script"]) {
		file { "/usr/local/bin/git_init_script":
			owner => "root",
			group => "root",
			mode => 750,
			source => "puppet:///modules/git/git_init_script"
		}
	}
	
	if defined(User["$owner"]) {
		realize(User["$owner"])
	} else {
		@user { "$owner":
			ensure  => present,
			comment => "User for git repository $name",
			groups  => "$group",
			shell   => "/usr/bin/git-shell"
		}
		realize(User["$owner"])
	}

	if defined(Group["$group"]) {
		realize(Group["$group"])
	} else  {
		@group { "$group":
			ensure => present
		}
		realize(Group["$group"])
	}

	if ($real_name) {
		$_name = $real_name
	} else {
		$_name = $name
	}

	file { "git_repository_$name":
		path    => $prefix ? {
			false   => "$localtree/$_name",
			default => "$localtree/$prefix-$_name"
		},
		ensure  => directory,
		owner   => "$owner",
		group   => "$group",
		mode    => $public ? {
			true    => $shared ? {
				true    => 2775,
				default => 0755
			},
			default => $shared ? {
				true    => 2770,
				default => 0750
			}
		}
	}

	# Set the hook for this repository
	file { "git_repository_hook_post-commit_$name":
		path    => $prefix ? {
			false   => "$localtree/$_name/hooks/post-commit",
			default => "$localtree/$prefix-$_name/hooks/post-commit"
		},
		source  => "puppet:///modules/git/post-commit",
        mode    => 755,
        require => [ File["git_repository_$name"], Exec["git_init_script_$name"] ]
	}

	file { "git_repository_hook_update_$name":
		path    => $prefix ? {
			false   => "$localtree/$_name/hooks/update",
			default => "$localtree/$prefix-$_name/hooks/update"
		},
		ensure  => $prefix ? {
			false   => "$localtree/$_name/hooks/post-commit",
			default => "$localtree/$prefix-$_name/hooks/post-commit"
		},
		links   => manage,
		require => [ File["git_repository_$name"], Exec["git_init_script_$name"] ]
	}

    file { "git_repository_hook_post-update_$name":
		path    => $prefix ? {
			false   => "$localtree/$_name/hooks/post-update",
			default => "$localtree/$prefix-$_name/hooks/post-update"
		},
		mode    => 755,
		owner   => "$owner",
		group   => "$group",
		require => [ File["git_repository_$name"], Exec["git_init_script_$name"] ]
	}

	# In case there are recipients defined, get in the commit-list
	case $recipients {
		false: {
			file { "git_repository_commit_list_$name":
				path    => $prefix ? {
					false   => "$localtree/$_name/commit-list",
					default => "$localtree/$prefix-$_name/commit-list"
				},
				content => "",
				require => [ File["git_repository_$name"], Exec["git_init_script_$name"] ]
			}
		}
		default: {
			file { "git_repository_commit_list_$name":
				path    => $prefix ? {
					false   => "$localtree/$_name/commit-list",
					default => "$localtree/$prefix-$_name/commit-list"
				},
				content => template('git/commit-list.erb'),
				require => [ File["git_repository_$name"], Exec["git_init_script_$name"] ]
			}
		}
	}

	case $description {
		false: {
			file { "git_repository_description_$name":
				path    => $prefix ? {
					false   => "$localtree/$_name/description",
					default => "$localtree/$prefix-$_name/description"
				},
				content => "Unnamed repository",
				require => [ File["git_repository_$name"], Exec["git_init_script_$name"] ]
			}
		}
		default: {
			file { "git_repository_description_$name":
				path    => $prefix ? {
					false   => "$localtree/$_name/description",
					default => "$localtree/$prefix-$_name/description"
				},
				content => "$description",
				require => [ File["git_repository_$name"], Exec["git_init_script_$name"] ]
			}
		}
	}

	if $symbolic_link {
		file { "git_repository_symlink_$name":
			path    => $symlink_prefix ? {
				false   => $prefix ? {
					false   => "/git/$_name",
					default => "/git/$prefix-$_name"
				},
				default => $prefix ? {
					false   => "/git/$symlink_prefix-$_name",
					default => "/git/$symlink_prefix-$prefix-$_name"
				}
			},
			links   => manage,
			backup  => false,
			ensure  => $prefix ? {
				false   => "$localtree/$_name",
				default => "$localtree/$prefix-$_name"
			},
			require => [ User["$owner"], Group["$group"] ]
		}
	}

	exec { "git_init_script_$name":
		command => $prefix ? {
			false   => "git_init_script --localtree $localtree --name $_name --shared $shared --public $public --owner $owner --group $group",
			default => "git_init_script --localtree $localtree --name $prefix-$_name --shared $shared --public $public --owner $owner --group $group"
		},
		creates => $prefix ? {
			false   => "$localtree/$_name/info",
			default => "$localtree/$prefix-$_name/info"
		},
		require => [ File["git_repository_$name"], File["/usr/local/bin/git_init_script"] ]
	}
}
