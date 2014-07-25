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

    vcsrepo { "/home/competition/srcomp-http":
        ensure   => present,
        source   => "${git_root}/comp/srcomp-http.git",
        user     => 'competition',
        revision => 'master',
        require  => User['competition']
    }

    vcsrepo { "/home/competition/srcomp-screens":
        ensure   => present,
        source   => "${git_root}/comp/srcomp-screens.git",
        user     => 'competition',
        revision => 'master',
        require  => User['competition']
    }

    package { ['python-flask',
               'python-dateutil',
               'python-nose',
               'python-yaml',
               'python-simplejson']:
        ensure => latest,
        before => Notify['ready']
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

    notify { "ready":
        message => "Ready to run"
    }
}

