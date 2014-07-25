node "srcomp" {
    notify { "bees":
        message => "This is working!"
    }

    package { "git":
        ensure => latest
    } ->
    vcsrepo { "/root/test.git":
        ensure => bare,
        provider => git
    }
}

