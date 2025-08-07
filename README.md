# 📋 bash-ini-parser

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
[![Author](https://img.shields.io/badge/author-Marcel%20Gr%C3%A4fen-green.svg)](https://mgraefen.com)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

Eine robuste und modulare Bash-Bibliothek zum Parsen von INI-Dateien. Sie bietet Funktionen, um Konfigurationen sicher zu laden und abzurufen.

-----

## 🚀 Inhaltsverzeichnis

  * [📋 Features](#-features)
  * [⚙️ Voraussetzungen](#%EF%B8%8F-voraussetzungen)
  * [📦 Installation](#-installation)
  * [📝 Beispiel-INI-Datei](#-beispiel-ini-datei)
  * [🚀 Nutzung](#-nutzung)
      * [Konfiguration laden](#konfiguration-laden)
      * [Werte abrufen](#werte-abrufen)
  * [📌 API-Referenz](#-api-referenz)
      * [`check_bash_version`](#check_bash_version)
      * [`parse_ini_file`](#parse_ini_file)
      * [`get_ini_value`](#get_ini_value)
      * [`find_and_parse_ini`](#find_and_parse_ini)
      * [`load_ini_config`](#load_ini_config)
  * [👤 Autor & Kontakt](#-autor--kontakt)
  * [📜 Lizenz](#-lizenz)

-----

## 📋 Features

  * **Bash 4.0+ Unterstützung:** Stellt sicher, dass die notwendigen Features wie assoziative Arrays verfügbar sind.
  * **Flexibles Parsen:** Liest Schlüssel-Wert-Paare und Sektionen aus INI-Dateien.
  * **Intelligente Dateisuche:** Kann eine spezifische Datei laden oder automatisch die erste `.ini`-Datei im Verzeichnis finden.
  * **Robuste Fehlerbehandlung:** Prüft auf fehlende Dateien, falsch deklarierte Variablen und ungültige Argumente.
  * **Einfacher API-Zugriff:** Bietet eine klare und sichere Schnittstelle zum Laden und Abrufen von Konfigurationswerten.

-----

## ⚙️ Voraussetzungen

  * **Bash** Version 4.0 oder höher.

-----

## 📦 Installation

Binde die Datei `ini_loader.sh` einfach am Anfang deines Bash-Skripts ein:

```bash
#!/usr/bin/env bash

# Binde die ini_loader.sh als Quelle ein
source "/pfad/zu/ini_loader.sh"

# Dein Skript-Code ...
```

-----

## 📝 Beispiel-INI-Datei

Erstelle eine Datei mit dem Namen `config.ini` und verwende das folgende Format:

```ini
# Beispiel für eine Konfigurationsdatei (config.ini)

# Schlüssel-Wert-Paare ohne Sektion werden der Sektion "default" zugewiesen
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

## 🚀 Nutzung

Die empfohlene Methode ist die Funktion `load_ini_config`, da sie alle notwendigen Prüfungen und das Parsen in einem einzigen Aufruf zusammenfasst.


> ⚠️ **Hinweis:** Schlüssel-Wert-Paare, die vor der ersten Sektion ([Sektion]) stehen, werden automatisch der Sektion "default" zugewiesen.


### Konfiguration laden

Zuerst musst du ein assoziatives Array deklarieren und dann die Konfiguration laden.

```bash
# Deklariere das assoziative Array
declare -A MY_CONFIG

# Lade eine spezifische INI-Datei
if load_ini_config "MY_CONFIG" "config.ini"; then
  echo "Konfiguration aus 'config.ini' erfolgreich geladen."
else
  echo "Fehler: Konfiguration konnte nicht geladen werden."
  exit 1
fi
```

**Hinweis:** Wenn du keinen Dateipfad angibst, sucht die Funktion automatisch nach der ersten `.ini`-Datei im aktuellen Verzeichnis.

### Werte abrufen

Nachdem die Konfiguration geladen wurde, kannst du mit `get_ini_value` auf die Werte zugreifen.

```bash
# Rufe einen Wert aus der 'database'-Sektion ab
db_user=$(get_ini_value "MY_CONFIG" "database" "user")

# Rufe einen Wert aus der 'server'-Sektion ab
server_enabled=$(get_ini_value "MY_CONFIG" "server" "enabled")

if [[ $? -eq 0 ]]; then
  echo "Datenbank-Benutzer: $db_user"
  echo "Server aktiviert: $server_enabled"
fi
```

-----

## 📌 API-Referenz

### `check_bash_version`

Überprüft, ob die aktuelle Bash-Version mindestens 4.0 ist. Das Skript wird beendet, wenn die Version zu alt ist.

**Beispiel:**

```bash
check_bash_version
```

### `parse_ini_file`

Parsiert eine spezifische INI-Datei und füllt ein assoziatives Array.

  * `$1`: Pfad zur INI-Datei.
  * `$2`: Name des assoziativen Arrays (als String).

**Beispiel:**

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

Ruft einen Wert aus einem geparsten assoziativen Array ab.

  * `$1`: Name des assoziativen Arrays (als String).
  * `$2`: Name der Sektion.
  * `$3`: Name des Schlüssels.

**Beispiel:**

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

Sucht nach einer INI-Datei und parst sie in ein assoziatives Array.

  * `$1` (optional): Pfad zur INI-Datei. Wenn leer, wird nach der ersten `.ini`-Datei im aktuellen Verzeichnis gesucht.
  * `$2`: Name des assoziativen Arrays (als String).

**Beispiel:**

```bash
declare -A APP_CONFIG

echo "Search and parse an INI file..."
find_and_parse_ini "" "APP_CONFIG"

echo "All keys and values in the array:"
for key in "${!APP_CONFIG[@]}"; do
  echo "  $key = ${APP_CONFIG[$key]}"
done
```

### `load_ini_config`

Die zentrale Wrapper-Funktion, die die Logik von `find_and_parse_ini` kapselt und zusätzliche Validierungen durchführt.

  * `$1`: Name des assoziativen Arrays (als String).
  * `$2` (optional): Pfad zur INI-Datei.

**Beispiel:**

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

## 👤 Autor & Kontakt

  * **Marcel Gräfen**
  * 📧 [info@mgraefen.com](mailto:info@mgraefen.com)
  * 🌐 [https://mgraefen.com](https://mgraefen.com)

-----

## 📜 Lizenz

[MIT Lizenz](https://opensource.org/licenses/MIT)
