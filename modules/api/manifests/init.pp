class api($root,
          $user,
          $port,
          $state_path) {
    $git_root = extlookup('git_root')

    vcsrepo { "$root/srcomp-http":
        ensure   => present,
        source   => "${git_root}/comp/srcomp-http.git",
        user     => $user,
        revision => 'master',
        before   => Service['comp-api']
    }

    package { ['python-flask',
               'python-dateutil',
               'python-nose',
               'python-yaml',
               'python-simplejson']:
        ensure => latest,
        before => Service['comp-api']
    }

    file { '/etc/init.d/comp-api':
        ensure  => file,
        content => template('api/init.erb'),
        mode    => '0755'
    }

    service { 'comp-api':
        ensure  => running,
        require => File['/etc/init.d/comp-api']
    }
}

