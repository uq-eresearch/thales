# Unicorn configuration
#
# See <http://unicorn.bogomips.org/Unicorn/Configurator.html>

worker_processes 4 # this should be >= nr_cpus

# Where project sources have been installed. Used in paths in this config file.
THALES_PROJ_DIR = '/home/thales/thales'

# Path to PID file
pid "#{THALES_PROJ_DIR}/tmp/pids/unicorn.pid"

# Path to log files
stderr_path "#{THALES_PROJ_DIR}/log/unicorn.stderr.log"
stdout_path "#{THALES_PROJ_DIR}/log/unicorn.stdout.log"

# Effective user and group for worker processes as log files.
# If this is commented out, then the current user will be used
# (which will be root if it is started by initd).
# Note: this is very important if relying on ident login authentication
# to PostgreSQL.
user 'thales', 'thales'

