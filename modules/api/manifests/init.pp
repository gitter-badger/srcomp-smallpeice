class api($root,
          $user,
          $port,
          $port_scorer,
          $state_path) {
    $git_root = extlookup('git_root')

    vcsrepo { "$root/srcomp-http":
        ensure   => present,
        source   => "${git_root}/comp/srcomp-http.git",
        user     => $user,
        revision => 'master',
        before   => Service['comp-api']
    }

    vcsrepo { "$root/srcomp-scorer":
        ensure   => present,
        source   => 'https://github.com/tomleese/srcomp-scorer.git',
        user     => $user,
        revision => 'master'
    }

    package { ['python-flask',
               'python-dateutil',
               'python-nose',
               'python-yaml',
               'python-simplejson',
               'gunicorn']:
        ensure => latest,
        before => Service['comp-api']
    }

    file { '/etc/init.d/comp-api':
        ensure  => file,
        content => template('api/init.erb'),
        mode    => '0755',
        before  => Service['comp-api']
    }

    file { '/etc/init.d/comp-scorer':
        ensure  => file,
        content => template('api/init_scorer.erb'),
        mode    => '0755',
        before  => Service['comp-scorer']
    }

    file { '/etc/comp-api-wsgi':
        ensure  => file,
        content => template('api/wsgi_config.erb'),
        before  => Service['comp-api']
    }

    service { 'comp-api':
        ensure  => running
    }

    service { 'comp-scorer':
        ensure  => running,
        require => Service['comp-api']
    }
}

