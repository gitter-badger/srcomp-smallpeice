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

    vcsrepo { "/home/competition/test":
        ensure   => present,
        source   => "${git_root}/test.git",
        user     => 'competition',
        revision => 'master',
        require  => User['competition']
    }
}

