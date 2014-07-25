node "srcomp" {
    notify { "bees":
        message => "This is working!"
    }
}

