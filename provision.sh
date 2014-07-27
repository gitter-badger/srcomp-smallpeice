#!/bin/bash
set -e
ln -s `pwd`/files /etc/boxconf
exec puppet apply --modulepath modules manifests/default.pp

