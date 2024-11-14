#!/usr/bin/env sh
# shellcheck shell=sh

CWD="$(pwd)"

# Constants
ROOT="${CWD}"

#######################################
# Log a line with the date and file.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   A time-stamped log line with the
#   executed file.
#######################################
log() {
  echo "[$(date '+%d-%m-%Y_%T')] $(basename "${0}"): ${*}"
}

#######################################
# Ensure we're in the project root.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 if we are, 1 otherwise.
#######################################
ensure_project_root() {
  # check if current dir
  if [ ! -e "${ROOT}/package.json" ]; then
    log "ERROR: script is not being executed from project root!"
    return 1
  fi

  return 0
}

#######################################
# Install LHCI dependencies.
# Globals:
#   APP_ENV
# Arguments:
#   None
# Returns:
#   0 if we were able to install them,
#   1 if not.
#######################################
install_dependencies() {
  ensure_project_root

  # build args
  args=""
  if [ "${APP_ENV}" = "prod" ]; then args="${args} --omit=dev"; fi

  # check if npm is installed
  if [ "$(command -v npm)" ]; then
    if ! npm install "${args}"; then
      log "ERROR: Could not install LHCI dependencies"
      return 1
    fi
  else
    log "ERROR: Cannot install LHCI dependencies. 'npm' is not installed!"
  fi
}

#######################################
# Initialize the database or wait for
#   a connection.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0 if the database is ready and
#   initialized, 1 if it isn't ready
#   or coudln't be initialized.
#######################################
init_database() {
  ensure_project_root

  sql_dialect=$(yq '.ci.server.storage.sqlDialect' lighthouserc.yaml)
  # SQLite
  sql_path=$(yq '.ci.server.storage.sqlDatabasePath' lighthouserc.yaml)
  # MySQl/PostgreSQL
  sql_connection=$(yq '.ci.server.storage.sqlConnectionUrl' lighthouserc.yaml)

  case ${sql_dialect} in
  "sqlite")
    log "Creating SQLite database"
    sqlite3 "${sql_path}" <<EOF
.exit
EOF
    ;;
  "postgres")
    log "Watching for PostgreSQL database connection"
    database_connection_check "${sql_connection}"
    ;;
  "mysql")
    log "Watching for MySQL database connection"
    database_connection_check "${sql_connection}"
    ;;
  esac
}

#######################################
# Check that the database connection available
# Globals:
#   DATABASE_URL
#   DATABASE_HOST
#   DATABASE_TIMEOUT
# Arguments:
#   None
# Outputs:
#   Logs remaining seconds on each iteration.
#######################################
database_connection_check() {
  database_url=${1}

  echo "|--------------------------------------------------------------|"
  echo "|      Checking for an active MySQL/PostgreSQL connection      |"
  echo "|--------------------------------------------------------------|"

  # shellcheck disable=SC2086
  database_host=${DATABASE_HOST:-"$(trurl "${database_url}" --get '{host}')"}
  database_port=${DATABASE_PORT:-"$(trurl "${database_url}" --get '{port}')"}
  tries=0

  until nc -z -w$((DATABASE_TIMEOUT + 20)) -v "$database_host" "${database_port:-3306}"; do
    log "Waiting $((DATABASE_TIMEOUT - tries)) more seconds for database connection to become available"
    sleep 1
    tries=$((tries + 1))

    if [ "$tries" -eq "${DATABASE_TIMEOUT}" ]; then
      log "FATAL: Could not connect to database within timeout of ${tries} seconds. Exiting."
      exit 1
    fi
  done
}
