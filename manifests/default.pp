$extlookup_datadir = '/etc/boxconf'
$extlookup_precedence = ['git_repos', 'common']

node "srcomp" {
    package { "git":
        ensure => latest
    }

    VCSRepo {
        require => Package['git'],
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
    } ~>
    class { 'api':
        user    => 'competition',
        root    => '/home/competition',
        socket_api    => '/var/run/comp-api.sock',
        socket_scorer => '/var/run/comp-scorer.sock',
        state_path => '/home/competition/state'
    }

    vcsrepo { "/home/competition/srcomp-screens":
        ensure   => present,
        source   => extlookup('repo_screens_uri'),
        user     => 'competition',
        revision => extlookup('repo_screens_branch'),
        require  => User['competition']
    }

    class { 'nginx':
    }

    nginx::resource::vhost { $fqdn:
        www_root => '/home/competition/srcomp-screens',
        require => VCSRepo['/home/competition/srcomp-screens']
    }

    nginx::resource::upstream { 'api':
        members => ['unix:/var/run/comp-api.sock']
    }

    nginx::resource::location { 'api':
        vhost => $fqdn,
        proxy => 'http://api/',
        location => '/comp-api/'
    }

    nginx::resource::upstream { 'scorer':
        members => ['unix:/var/run/comp-scorer.sock']
    }

    nginx::resource::location { 'scorer':
        vhost => $fqdn,
        proxy => 'http://scorer/',
        location => '/scorer/',
        proxy_set_header => ['X-Script-Name /scorer']
    }
}

