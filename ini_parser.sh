#!/usr/bin/env bash

# ========================================================================================
# Bash-INI-Parser
#
# A robust and modular library for parsing INI files in Bash.
# Designed to be sourced by other Bash scripts.
#
# @author      : Marcel Gräfen
# @version     : 1.0.0
# @date        : 2025-08-07
#
# @requires    : Bash 4.0+
#
# @see         : https://github.com/Marcel-Graefen/Bash-INI-Parser
#
# @copyright   : Copyright (c) 2025 Marcel Gräfen
# @license     : MIT License
# ========================================================================================


# FUNCTION: check_bash_version
# Checks if the current Bash version is at least 4.0.
# Exits with an error message if the version is too old.
# Notes:
#   - This function should be called at the very beginning of the script.
#   - It's crucial because the INI parser uses features like associative arrays,
#     which require Bash 4.0 or higher.

check_bash_version() {

  local required_version="4.0"
  local current_version

  # Get the current Bash version number (e.g., 5.1.4)
  # The BASH_VERSION variable holds the full version string
  current_version=$(echo "$BASH_VERSION" | cut -d'.' -f1,2)

  # Compare the current version to the required version
  # The 'printf' trick ensures a correct numeric comparison
  if [[ "$(printf '%s\n' "$required_version" "$current_version" | sort -V | head -n1)" != "$required_version" ]]; then
    echo "❌ ERROR: This script requires Bash version $required_version or higher." >&2
    echo "       Your current version is: $BASH_VERSION" >&2
    echo "        Please update your Bash installation to run this script." >&2
    exit 1
  fi

}

# ---------------------------------------------------------------------------------------

check_bash_version

# ---------------------------------------------------------------------------------------

# FUNCTION: parse_ini_file
# Parses a basic INI file and populates an associative array.
# Arguments:
#   $1 - Path to the INI file
#   $2 - Name of the associative array to populate (e.g., "config")
# Output:
#   - Populates the specified associative array with keys in the form "section.key"
#   - Returns 0 if parsing succeeds, 1 on error (e.g., file not found)
# Supported INI Format:
#   - Section headers: [section]
#   - Key-value pairs: key=value
#   - Comments: lines starting with # or ;
# Notes:
#   - Keys and values are trimmed of leading/trailing whitespace
#   - Empty lines and comment lines are ignored
#   - Duplicate keys overwrite previous values
#   - Key-value pairs before the first section are assigned to a "default" section.
#   - Bash 4+ is required for associative arrays

parse_ini_file() {

  local ini_file="$1"
  local -n ini_array="$2" # Use nameref to reference the array by name
  local section="default"
  local line key value

  #----------------------

  if [[ -z "$2" ]]; then
    echo "❌ ERROR: No array name provided for parsing" >&2
    return 1
  fi

  #----------------------

  # This prevents errors when the variable is missing or incorrectly declared in the main script.
  if ! declare -p "$2" &>/dev/null || ! [[ "$(declare -p "$2")" =~ "declare -A" ]]; then
    echo "❌ ERROR: The variable '$2' must be declared as an associative array ('declare -A $2') before calling parse_ini_file." >&2
    return 1
  fi

  #----------------------

  if [[ ! -f "$ini_file" ]]; then
    echo "❌ ERROR: INI file not found: $ini_file" >&2
    return 1
  fi

  #----------------------

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Trim leading/trailing whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    # Skip comments and empty lines
    [[ -z "$line" || "$line" =~ ^[\;\#] ]] && continue

  #----------------------

    # Match section headers
    if [[ "$line" =~ ^\[(.+)\]$ ]]; then
      section="${BASH_REMATCH[1]}"
      continue
    fi

  #----------------------

    # Match key=value lines
    if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
    key="${BASH_REMATCH[1]}"
    value="${BASH_REMATCH[2]}"

    # Trim whitespace from key and value
      key="${key#"${key%%[![:space:]]*}"}"
      key="${key%"${key##*[![:space:]]}"}"
      value="${value#"${value%%[![:space:]]*}"}"
      value="${value%"${value##*[![:space:]]}"}"

  #----------------------

      if [[ -n "$key" ]]; then
        ini_array["$section.$key"]="$value"
      fi
    fi
  done < "$ini_file"

  return 0

}

# ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------

# # EXAMPLE

# # Vorbereitung: Erstelle eine Datei namens 'config.ini' mit folgendem Inhalt:
# # [database]
# # user=admin
# # password=secret
# # host=localhost
# #
# # [cache]
# # enabled=true
# # ttl=3600

# declare -A MY_CONFIG

# echo "Parse 'config.ini' into the array 'MY_CONFIG'..."
# parse_ini_file "config.ini" "MY_CONFIG"

# echo "All keys and values in the array:"
# for key in "${!MY_CONFIG[@]}"; do
#   echo "  $key = ${MY_CONFIG[$key]}"
# done


# ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------


# FUNCTION: get_ini_value
# Retrieves a value from a parsed INI configuration.
# Arguments:
#   $1 - Name of the associative array (e.g., "config")
#   $2 - Section name (e.g., "settings")
#   $3 - Key name within the section (e.g., "LOG_LEVEL")
# Output:
#   - Echoes the value if found.
#   - Returns 0 if successful, 1 on error.
# Notes:
#   - Uses an associative array populated by the parse_ini_file function.

get_ini_value() {

  local -n ini_array="$1" # Use nameref to reference the array by name
  local section="$2"
  local key="$3"
  local composite_key="${section}.${key}"

  #----------------------

  if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    echo "⚠️ WARNING: get_ini_value() called with insufficient arguments." >&2
    return 1
  fi

  #----------------------

  # This prevents errors when the variable is missing or incorrectly declared in the main script.
  if ! declare -p "$1" &>/dev/null || ! [[ "$(declare -p "$1")" =~ "declare -A" ]]; then
    echo "❌ ERROR: The variable '$1' must be declared as an associative array ('declare -A $1') before calling get_ini_value." >&2
    return 1
  fi

  #----------------------

  # Check if section exists more efficiently
  if [[ ! -v ini_array["$section."] && ! -v ini_array["$composite_key"] ]]; then
    echo "⚠️ WARNING: INI section [$section] not found" >&2
    return 1
  fi

  #----------------------

  # Check if key exists in section
  if [[ ! -v ini_array["$composite_key"] ]]; then
    echo "⚠️ WARNING: Key '$key' not found in section [$section]" >&2
    return 1
  fi

  echo "${ini_array[$composite_key]}"
  return 0

}

# ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------

# # EXAMPLE

# declare -A MY_CONFIG
# # Simulate filling the array
# MY_CONFIG["database.user"]="admin"
# MY_CONFIG["database.host"]="localhost"

# echo "Retrieve the database user..."
# db_user=$(get_ini_value "MY_CONFIG" "database" "user")

# if [[ $? -eq 0 ]]; then
#   echo "✅ Found value: $db_user"
# else
#   echo "❌ ERROR: Retrieving the value."
# fi

# ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------



# FUNCTION: find_and_parse_ini
# Finds and parses an INI file based on a provided path or automatically.
# Arguments:
#   $1 - Optional path to the INI file. If empty, searches for a *.ini file.
#   $2 - Name of the associative array to populate (e.g., "config").
# Output:
#   - Populates the specified associative array.
#   - Returns 0 on success, 1 on error.

find_and_parse_ini() {

  local ini_array_name=$1
  local ini_file=$2
  local default_file

  #----------------------

  # Check if the array name exists
  if [[ -z "$ini_array_name" ]]; then
    echo "❌ ERROR: find_and_parse_ini() requires an array name." >&2
    return 1
  fi

  #----------------------

  # This prevents errors when the variable is missing or incorrectly declared in the main script.
  if ! declare -p "$ini_array_name" &>/dev/null || ! [[ "$(declare -p "$ini_array_name")" =~ "declare -A" ]]; then
    echo "❌ ERROR: The variable '$ini_array_name' must be declared as an associative array ('declare -A $ini_array_name') before calling find_and_parse_ini." >&2
    return 1
  fi

  #----------------------

  # A specific file path has been passed.
  if [[ -n "$ini_file" ]]; then
    if [[ ! -f "$ini_file" ]]; then
      echo "⚠️ WARNING: The specified INI file was not found: '$ini_file'. Try to find a standard file..." >&2
    else
      echo "✅ Process the specified INI file: '$ini_file'..."
      parse_ini_file "$ini_file" "$ini_array_name"
      return $?
    fi
  fi

  #----------------------

  # No file path was provided or the file was not found
  echo "🔎 Search for a standard INI file in the current directory (*.ini)..."
  default_file=$(find . -maxdepth 1 -type f -name "*.ini" | head -n 1)

  #----------------------

  if [[ -n "$default_file" ]]; then
    echo "✅ Standard file found and is being processed: '${default_file}'."
    parse_ini_file "$default_file" "$ini_array_name"
    return $?
  else
    echo "❌ FEHLER: No INI file found." >&2
    return 1
  fi

}

# ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------

# # EXAMPLE

# declare -A APP_CONFIG

# echo "Search and parse an INI file..."
# find_and_parse_ini "" "APP_CONFIG"

# echo "All keys and values in the array:"
# for key in "${!APP_CONFIG[@]}"; do
#   echo "  $key = ${APP_CONFIG[$key]}"
# done

# ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------

# FUNCTION: load_ini_config
# A wrapper to find and parse an INI file into a specified array.
# This function is the central point for initializing the configuration.
# Arguments:
#   $1 - Name of the associative array to populate (e.g., "config").
#   $2 - Optional path to the INI file. If empty, searches for *.ini.
# Output:
#   - Populates the specified associative array.
#   - Returns 0 on success, 1 on error.

load_ini_config() {

  local ini_array_name="$1"
  local ini_file="$2"

  #----------------------

  if [[ -z "$ini_array_name" ]]; then
    echo "❌ ERROR: load_ini_config() requires an array name as the first argument." >&2
    return 1
  fi

  #----------------------

  # This prevents errors when the variable is missing or incorrectly declared in the main script.
  if ! declare -p "$ini_array_name" &>/dev/null || ! [[ "$(declare -p "$ini_array_name")" =~ "declare -A" ]]; then
    echo "❌ ERROR: The variable '$ini_array_name' must be declared as an associative array ('declare -A $ini_array_name') before calling load_ini_config." >&2
  return 1
  fi

  #----------------------

  # Check that the file path is not the same as the array name
  if [[ "$ini_file" == "$ini_array_name" ]]; then
    echo "❌ ERROR: The file path ('$ini_file') cannot be the same as the array name." >&2
    return 1
  fi

  #----------------------

  # Check if the array name is a valid variable name
  if ! [[ "$ini_array_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
    echo "❌ ERROR: The provided array name ('$ini_array_name') is not a valid variable name." >&2
    return 1
  fi

  #----------------------

  # Use the existing find_and_parse_ini function
  # Note: find_and_parse_ini expects file path first, then array name
  find_and_parse_ini "$ini_file" "$ini_array_name"
  return $?
}

# ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------

# # EXAMPLE

# # Vorbereitung: Erstelle eine Datei namens 'config.ini':
# # [database]
# # user=admin
# # password=secret
# # host=localhost
# #
# # [cache]
# # enabled=true
# # ttl=3600

# declare -A MY_CONFIG

# if load_ini_config "MY_CONFIG" "../test.ini"; then
#   echo "Configuration loaded successfully."
#   # Get a value from the 'database' section
#   db_user=$(get_ini_value "MY_CONFIG" "database" "user")
#   if [[ $? -eq 0 ]]; then
#     echo "Database User: $db_user"
#   fi

#   # Get a value from the 'cache' section
#   cache_enabled=$(get_ini_value "MY_CONFIG" "cache" "enabled")
#   if [[ $? -eq 0 ]]; then
#     echo "Cache Enabled: $cache_enabled"
#   fi
# else
#   echo "Failed to load configuration."
#   exit 1
# fi





#----------------------------------------------------------------------------------------
# Only execute the following code if the script is run directly.
# $0 is the name of the script.
# The first argument of the script is used here to check if the script was included via `source`.
# The script recognizes that it was included via `source` because `$BASH_SOURCE` does not match `$0`.
# The environment variable `$BASH_SOURCE` contains the path to the current script, even when called with `source`.
# `$0` always contains the name of the script that is executing the current shell.
# In a standard shell, `$0` and `$BASH_SOURCE` are the same when you execute the script directly.
# When you include the script via `source`, `$BASH_SOURCE` is the script you are including, and `$0` is the main script.
#----------------------------------------------------------------------------------------

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "⚠️ WARNING: This script is a library designed to be sourced." >&2
  echo "       It is not intended for direct execution." >&2
  echo "       Please refer to the documentation for proper usage." >&2
  echo "       --> [README.md]" >&2
  exit 1
fi
