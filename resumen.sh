#!/bin/bash

# Directorio donde se guardan los archivos
LOG_DIR="/home/abian/abianlog"
BASE_FILE="abian"
EXT=".xml"

# Verifica si el directorio existe
if [[ ! -d "$LOG_DIR" ]]; then
    echo "Error: El directorio $LOG_DIR no existe."
    exit 1
fi

# Buscar el siguiente número disponible para el archivo
last_file=$(ls -1 "$LOG_DIR" | grep -oP "${BASE_FILE}\d+${EXT}" | sort -V | tail -n 1)
if [[ -z "$last_file" ]]; then
    new_file="${BASE_FILE}1${EXT}"
else
    last_number=$(echo "$last_file" | grep -oP "\d+" | tail -n 1)
    new_number=$((last_number + 1))
    new_file="${BASE_FILE}${new_number}${EXT}"
fi

# Crear el nuevo archivo XML con el comando sadf
sadf -x > "$LOG_DIR/$new_file"
echo "Nuevo archivo XML creado: $new_file"

# Verifica si el archivo fue creado correctamente
if [[ ! -f "$LOG_DIR/$new_file" ]]; then
    echo "Error: No se pudo crear el archivo XML en $LOG_DIR/$new_file"
    exit 1
fi

# Detectar el namespace automáticamente del nuevo archivo
ns=$(xmlstarlet sel -t -v "namespace-uri(/*)" "$LOG_DIR/$new_file")

# Función para extraer valores con namespace
get_value() {
    path="$1"
    xmlstarlet sel -N s="$ns" -t -v "$path" -n "$LOG_DIR/$new_file"
}

# Obtener datos del sistema
sysdata_version=$(get_value "//s:sysdata-version")
sysname=$(get_value "//s:sysname")
release=$(get_value "//s:release")
machine=$(get_value "//s:machine")
num_cpus=$(get_value "//s:number-of-cpus")

# Obtener fecha y hora reales del archivo desde el sistema de archivos
real_file_date=$(date -r "$LOG_DIR/$new_file" "+%Y-%m-%d")
real_file_time=$(date -r "$LOG_DIR/$new_file" "+%H:%M:%S")

# Mostrar encabezado general
echo "Resumen del registro sysstat:"
echo "------------------------------------"
echo "Versión y sistema:"
echo "  sysstat version:   $sysdata_version"
echo "  Sistema operativo: $sysname"
echo "  Kernel:            $release"
echo "  Arquitectura:      $machine"
echo "  Núcleos de CPU:    $num_cpus"
echo
echo "Fecha del archivo (según sistema de archivos):"
echo "  Fecha: $real_file_date"
echo "  Hora:  $real_file_time"
echo
echo "Último snapshot registrado:"
echo "------------------------------------"

# Obtener los valores del último snapshot (último timestamp)
date=$(get_value "(//s:timestamp)[last()]/@date")
time=$(get_value "(//s:timestamp)[last()]/@time")

user=$(get_value "(//s:timestamp)[last()]/s:cpu-load/s:cpu[@number='all']/@user")
system=$(get_value "(//s:timestamp)[last()]/s:cpu-load/s:cpu[@number='all']/@system")
nice=$(get_value "(//s:timestamp)[last()]/s:cpu-load/s:cpu[@number='all']/@nice")
iowait=$(get_value "(//s:timestamp)[last()]/s:cpu-load/s:cpu[@number='all']/@iowait")
steal=$(get_value "(//s:timestamp)[last()]/s:cpu-load/s:cpu[@number='all']/@steal")
idle=$(get_value "(//s:timestamp)[last()]/s:cpu-load/s:cpu[@number='all']/@idle")

echo "  Fecha y hora del snapshot: $date $time"
echo "  User:   $user%"
echo "  System: $system%"
echo "  Nice:   $nice%"
echo "  IOWait: $iowait%"
echo "  Steal:  $steal%"
echo "  Idle:   $idle%"
echo "------------------------------------"
