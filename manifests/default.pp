$extlookup_datadir = '/etc/boxconf'
$extlookup_precedence = ['common']

node "srcomp" {
    package { "git":
        ensure => latest
    }

    $git_root = extlookup('git_root')

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
        source   => "${git_root}/comp/dummy-comp.git",
        user     => 'competition',
        revision => 'master',
        require  => User['competition']
    } ->
    class { 'api':
        user    => 'competition',
        root    => '/home/competition',
        port    => 1100,
        port_scorer => 1101,
        state_path => '/home/competition/state'
    }

    vcsrepo { "/home/competition/srcomp-screens":
        ensure   => present,
        source   => "${git_root}/comp/srcomp-screens.git",
        user     => 'competition',
        revision => 'master',
        require  => User['competition']
    }

    class { 'nginx':
    }

    nginx::resource::vhost { $fqdn:
        www_root => '/home/competition/srcomp-screens',
        require => VCSRepo['/home/competition/srcomp-screens']
    }

    nginx::resource::upstream { 'api':
        members => ['localhost:1100']
    }

    nginx::resource::location { 'api':
        vhost => $fqdn,
        proxy => 'http://api/',
        location => '/comp-api/'
    }

    nginx::resource::upstream { 'scorer':
        members => ['localhost:1101']
    }

    nginx::resource::location { 'scorer':
        vhost => $fqdn,
        proxy => 'http://scorer/',
        location => '/scorer/'
    }
}

