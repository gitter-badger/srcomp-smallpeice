$extlookup_datadir = '/etc/boxconf'
$extlookup_precedence = ['common']

node "srcomp" {
    package { "git":
        ensure => latest
    }

    VCSRepo {
        require => Package['git'],
        provider => git
    }

    vcsrepo { "/root/test.git":
        ensure => bare
    }

    notify { 'eyes':
        message => extlookup('notification')
    }
}

