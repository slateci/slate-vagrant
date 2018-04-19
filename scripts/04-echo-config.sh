#!/bin/bash

set -e
set -o pipefail

cat /etc/kubernetes/admin.conf

if [ -d /vagrant ]; then
  cp /etc/kubernetes/admin.conf "/vagrant/$HOSTNAME.kconfig"
fi
