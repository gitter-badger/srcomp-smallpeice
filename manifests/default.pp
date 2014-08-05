$extlookup_datadir = '/etc/boxconf'
$extlookup_precedence = ['git_repos', 'common']

node "srcomp" {
    package { "git":
        ensure => latest
    }

    VCSRepo {
        provider => git
    }

    user { 'competition':
        ensure => present,
        home => '/home/competition',
        managehome => true
    }


    vcsrepo { "/home/competition/state":
        ensure   => present,
        source   => extlookup('repo_state_uri'),
        user     => 'competition',
        revision => extlookup('repo_state_branch'),
        require  => User['competition']
    }

    class { 'api':
        user    => 'competition',
        root    => '/home/competition',
        socket_api    => '/var/run/comp-api.sock',
        socket_scorer => '/var/run/comp-scorer.sock',
        state_path => '/home/competition/state',
        subscribe  => VCSRepo['/home/competition/state']
    }

    augeas { 'set git details':
        lens => 'Puppet.lns',
        incl => '/home/competition/state/.git/config',
        changes => ['set user/name "Competition State"',
                    'set user/email "competition"'],
        require => VCSRepo['/home/competition/state']
    }

    vcsrepo { "/home/competition/srcomp-screens":
        ensure   => latest,
        source   => extlookup('repo_screens_uri'),
        user     => 'competition',
        revision => extlookup('repo_screens_branch'),
        require  => User['competition']
    }

    class { 'nginx':
        proxy_cache_path => '/tmp/www-cache'
    }

    $vhost = $fqdn

    nginx::resource::vhost { $vhost:
        www_root => '/home/competition/srcomp-screens',
        require => VCSRepo['/home/competition/srcomp-screens']
    }

    nginx::resource::upstream { 'api':
        members => ['unix:/var/run/comp-api.sock']
    }

    nginx::resource::location { 'api':
        vhost => $vhost,
        proxy => 'http://api/',
        location => '/comp-api/',
        proxy_set_header => ['X-Script-Name /comp-api']
    }

    nginx::resource::upstream { 'scorer':
        members => ['unix:/var/run/comp-scorer.sock']
    }

    nginx::resource::location { 'scorer':
        vhost => $vhost,
        proxy => 'http://scorer/',
        location => '/scorer/',
        proxy_set_header => ['X-Script-Name /scorer']
    }
}

