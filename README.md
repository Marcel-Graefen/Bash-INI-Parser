# 📋 Bash INI Parser

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
[![German](https://img.shields.io/badge/Language-German-blue)](./README.de.md)
![GitHub last commit](https://img.shields.io/github/last-commit/Marcel-Graefen/Bash-INI-Parser)
[![Author](https://img.shields.io/badge/author-Marcel%20Gr%C3%A4fen-green.svg)](#-author--contact)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
![](https://komarev.com/ghpvc/?username=Marcel-Graefen)

A robust and modular Bash library for parsing INI files. It provides functions to safely load and retrieve configuration values.

---

## 🚀 Table of Contents

* [📋 Features](#-features)
* [⚙️ Requirements](#%EF%B8%8F-requirements)
* [📦 Installation](#-installation)
* [📝 Example INI File](#-example-ini-file)
* [🚀 Usage](#-usage)
    * [Loading Configuration](#loading-configuration)
    * [Retrieving Values](#retrieving-values)
* [📌 API Reference](#-api-reference)
    * [`check_bash_version`](#check_bash_version)
    * [`parse_ini_file`](#parse_ini_file)
    * [`get_ini_value`](#get_ini_value)
    * [`find_and_parse_ini`](#find_and_parse_ini)
    * [`load_ini_config`](#load_ini_config)
* [👤 Author & Contact](#-author--contact)
* [🤖 Generation Notice](#-generation-notice)
* [📜 License](#-license)

---

## 📋 Features

* **Bash 4.0+ Support:** Ensures that necessary features like associative arrays are available.
* **Flexible Parsing:** Reads key-value pairs and sections from INI files.
* **Intelligent File Search:** Can load a specific file or automatically find the first `.ini` file in the directory.
* **Robust Error Handling:** Checks for missing files, incorrectly declared variables, and invalid arguments.
* **Simple API Access:** Provides a clear and safe interface for loading and retrieving configuration values.

---

## ⚙️ Requirements

* **Bash** version 4.0 or higher.

---

## 📦 Installation

Simply source the `ini_loader.sh` file at the beginning of your Bash script:

```bash
#!/usr/bin/env bash

# Source the ini_loader.sh file
source "/path/to/ini_loader.sh"

# Your main script code starts here ...
````

-----

## 📝 Example INI File

Create a file named `config.ini` and use the following format:

```ini
# Example configuration file (config.ini)

# Key-value pairs without a section are assigned to the "default" section
name = Marcel
project = bash-ini-parser

[database]
user = admin
password = secret123
host = localhost
port = 5432

[server]
host = 192.168.1.100
enabled = true

[application]
name = AwesomeApp
version = 1.0.0
```

-----

## 🚀 Usage

The recommended method is the `load_ini_config` function, as it consolidates all necessary checks and parsing into a single call.

> ⚠️ **Note:** Key-value pairs that appear before the first section (`[section]`) are automatically assigned to the "default" section.

### Loading Configuration

First, you must declare an associative array and then load the configuration.

```bash
# Declare the associative array
declare -A MY_CONFIG

# Load a specific INI file
if load_ini_config "MY_CONFIG" "config.ini"; then
  echo "Configuration from 'config.ini' loaded successfully."
else
  echo "Error: Configuration could not be loaded."
  exit 1
fi
```

**Note:** If you do not specify a file path, the function automatically searches for the first `.ini` file in the current directory.

### Retrieving Values

After the configuration has been loaded, you can access values with `get_ini_value`.

```bash
# Retrieve a value from the 'database' section
db_user=$(get_ini_value "MY_CONFIG" "database" "user")

# Retrieve a value from the 'server' section
server_enabled=$(get_ini_value "MY_CONFIG" "server" "enabled")

if [[ $? -eq 0 ]]; then
  echo "Database User: $db_user"
  echo "Server Enabled: $server_enabled"
fi
```

-----

## 📌 API Reference

### `check_bash_version`

Checks if the current Bash version is at least 4.0. The script will exit if the version is too old.

**Example:**

```bash
check_bash_version
```

### `parse_ini_file`

Parses a specific INI file and populates an associative array.

  * `$1`: Path to the INI file.
  * `$2`: Name of the associative array (as a string).

**Example:**

```bash
declare -A MY_CONFIG
# Simulate filling the array
MY_CONFIG["database.user"]="admin"
MY_CONFIG["database.host"]="localhost"

echo "Retrieve the database user..."
db_user=$(get_ini_value "MY_CONFIG" "database" "user")

if [[ $? -eq 0 ]]; then
  echo "✅ Found value: $db_user"
else
  echo "❌ ERROR: Retrieving the value."
fi
```

### `get_ini_value`

Retrieves a value from a parsed associative array.

  * `$1`: Name of the associative array (as a string).
  * `$2`: Section name.
  * `$3`: Key name.

**Example:**

```bash
declare -A MY_CONFIG
# Simulate filling the array
MY_CONFIG["database.user"]="admin"
MY_CONFIG["database.host"]="localhost"

echo "Retrieve the database user..."
db_user=$(get_ini_value "MY_CONFIG" "database" "user")

if [[ $? -eq 0 ]]; then
  echo "✅ Found value: $db_user"
else
  echo "❌ ERROR: Retrieving the value."
fi
```

### `find_and_parse_ini`

Searches for an INI file and parses it into an associative array.

  * `$1` (optional): Path to the INI file. If empty, it searches for the first `.ini` file in the current directory.
  * `$2`: Name of the associative array (as a string).

**Example:**

```bash
declare -A APP_CONFIG

echo "Search and parse an INI file..."
find_and_parse_ini "" "APP_CONFIG"

echo "All keys and values in the array:"
for key in "${!APP_CONFIG[@]}"; do
  echo "  $key = ${APP_CONFIG[$key]}"
done
```

### `load_ini_config`

The central wrapper function that encapsulates the logic of `find_and_parse_ini` and performs additional validations.

  * `$1`: Name of the associative array (as a string).
  * `$2` (optional): Path to the INI file.

**Example:**

```bash
declare -A MY_CONFIG

if load_ini_config "MY_CONFIG" "../test.ini"; then
  echo "Configuration loaded successfully."
  # Get a value from the 'database' section
  db_user=$(get_ini_value "MY_CONFIG" "database" "user")
  if [[ $? -eq 0 ]]; then
    echo "Database User: $db_user"
  fi

  # Get a value from the 'cache' section
  cache_enabled=$(get_ini_value "MY_CONFIG" "cache" "enabled")
  if [[ $? -eq 0 ]]; then
    echo "Cache Enabled: $cache_enabled"
  fi
else
  echo "Failed to load configuration."
  exit 1
fi
```

-----

## 👤 Author & Contact

  * **Marcel Gräfen**
  * 📧 [info@mgraefen.com](mailto:info@mgraefen.com)

-----

## 🤖 Generation Notice

This project was developed with the help of an Artificial Intelligence (AI). The AI assisted in creating the script, comments, and documentation (README.md). The final result was reviewed and adjusted by me.

-----

## 📜 License

[MIT License](https://www.google.com/search?q=LICENSE)
