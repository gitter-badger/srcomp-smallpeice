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
}

