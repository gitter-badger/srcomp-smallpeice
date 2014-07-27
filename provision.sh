#!/bin/bash
set -e
apt-get install ruby-augeas
ln -s `pwd`/files /etc/boxconf
exec puppet apply --modulepath modules manifests/default.pp

