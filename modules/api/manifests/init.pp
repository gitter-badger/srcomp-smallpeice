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

    class { 'python':
        pip        => true,
        dev        => true,
        virtualenv => true,
        gunicorn   => true
    }

    $venv = "$root/comp-venv"

    python::virtualenv { $venv:
        owner      => $user,
        systempkgs => true # to get at gunicorn
    }

    python::pip { ['flask',
                   'python-dateutil',
                   'nose',
                   'pyyaml',
                   'simplejson']:
        ensure     => latest,
        virtualenv => $venv,
        owner      => $user
    }

    file { '/etc/comp-wsgi':
        ensure  => file,
        mode    => '0644',
        content => template('api/wsgi_config.erb')
    }

    Python::Gunicorn {
        owner      => $user,
        virtualenv => $venv,
        template   => 'api/gunicorn.erb',
        subscribe  => File['/etc/comp-wsgi']
    }

    python::gunicorn { 'comp-api':
        dir         => "$root/srcomp-http",
        bind        => "unix:$socket_api",
        subscribe   => VCSRepo["$root/srcomp-http"],
        environment => {'COMPSTATE' => $state_path}
    }

    python::gunicorn { 'comp-scorer':
        dir         => "$root/srcomp-scorer",
        bind        => "unix:$socket_scorer",
        subscribe   => VCSRepo["$root/srcomp-scorer"],
        environment => {'COMPSTATE' => $state_path}
    }
}

