class api($root,
          $user,
          $socket_api,
          $socket_scorer,
          $state_path) {

    vcsrepo { "$root/srcomp-http":
        ensure   => latest,
        source   => extlookup('repo_http_uri'),
        user     => $user,
        revision => extlookup('repo_http_branch')
    }

    vcsrepo { "$root/srcomp-scorer":
        ensure   => latest,
        source   => extlookup('repo_scorer_uri'),
        user     => $user,
        revision => extlookup('repo_scorer_branch')
    }

    package { ['python-flask',
               'python-dateutil',
               'python-nose',
               'python-yaml',
               'python-simplejson',
               'gunicorn']:
        ensure => latest,
        notify => [Service['comp-api'], Service['comp-scorer']]
    }

    file { '/etc/init.d/comp-api':
        ensure  => file,
        content => template('api/init.erb'),
        mode    => '0755'
    }

    file { '/etc/init.d/comp-scorer':
        ensure  => file,
        content => template('api/init_scorer.erb'),
        mode    => '0755'
    }

    file { '/etc/comp-api-wsgi':
        ensure  => file,
        content => template('api/wsgi_config.erb')
    }

    service { 'comp-api':
        ensure  => running,
        subscribe => [File['/etc/comp-api-wsgi'],
                      File['/etc/init.d/comp-api'],
                      VCSRepo["$root/srcomp-http"]]
    }

    service { 'comp-scorer':
        ensure    => running,
        subscribe => [File['/etc/comp-api-wsgi'],
                      File['/etc/init.d/comp-scorer'],
                      VCSRepo["$root/srcomp-scorer"]]
    }
}

