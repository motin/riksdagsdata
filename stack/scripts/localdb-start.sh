#!/bin/bash
set -e

# Start server locally
echo '* Starting MySQL'
/entrypoint.sh mysqld --user=mysql --console --sql_mode=NO_ENGINE_SUBSTITUTION
