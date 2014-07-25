node "srcomp" {
    package { "git":
        ensure => latest
    }

    VCSRepo {
        require => Package['git']
    }

    vcsrepo { "/root/test.git":
        ensure => bare,
        provider => git
    }
}

