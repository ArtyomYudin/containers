#!/usr/bin/env bash

set -e
[ "${DEBUG:-false}" == 'true' ] && set -x

# Load libraries
. /opt/keeper/scripts/liblog.sh

if [ ! -f $HTML_ROOT"/manager/index.php" ]; then
    warn "** MODX was not found **";
    bash /opt/keeper/scripts/modx-prepare.sh;
fi

exec "$@"