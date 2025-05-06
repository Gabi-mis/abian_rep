#!/bin/bash

# Directorio donde se encuentran los archivos XML
LOG_DIR="/home/abian/abian_log"
BASE_FILE="abian"
EXT=".xml"

# Verifica si el directorio existe
if [[ ! -d "$LOG_DIR" ]]; then
    echo "Error: El directorio $LOG_DIR no existe."
    exit 1
fi

# Buscar el archivo XML más reciente en el directorio
new_file=$(ls -t "$LOG_DIR/$BASE_FILE"*"$EXT" 2>/dev/null | head -n 1)

# Verifica si se encontró un archivo XML
if [[ ! -f "$new_file" ]]; then
    echo "Error: No se encontró ningún archivo XML en $LOG_DIR."
    exit 1
fi

# Detectar el namespace automáticamente del archivo
ns=$(xmlstarlet sel -t -v "namespace-uri(/*)" "$new_file")

# Función para extraer valores con namespace
get_value() {
    path="$1"
    xmlstarlet sel -N s="$ns" -t -v "$path" -n "$new_file"
}

# Mostrar información básica del archivo
echo "Resumen del registro sysstat:"
echo "------------------------------------"
echo "Archivo analizado:"
echo "  Ruta:   $new_file"
echo "  Fecha:  $(date -r "$new_file" "+%Y-%m-%d")"
echo "  Hora:   $(date -r "$new_file" "+%H:%M:%S")"
echo "  Tamaño: $(du -h "$new_file" | cut -f1)"
echo "  Namespace detectado: $ns"
echo

# Contar número de registros
timestamp_count=$(xmlstarlet sel -N s="$ns" -t -v "count(//s:timestamp)" "$new_file")
echo "Cantidad de registros <timestamp>: $timestamp_count"
echo

# Extraer y ordenar timestamps combinando fecha y hora
timestamps=$(xmlstarlet sel -N s="$ns" -t -m "//s:timestamp" -v "@date" -o " " -v "@time" -n "$new_file" | sort)

# Mostrar todos los timestamps con su información
echo "Timestamps y sus datos de uso de CPU:"
echo "------------------------------------"

while IFS= read -r timestamp; do
    timestamp_date=$(echo "$timestamp" | awk '{print $1}')
    timestamp_time=$(echo "$timestamp" | awk '{print $2}')

    echo "Fecha: $timestamp_date"
    echo "Hora:  $timestamp_time"

    # Extraer valores de CPU
    cpu_user=$(get_value "//s:timestamp[@date='$timestamp_date' and @time='$timestamp_time']/s:cpu-load/s:cpu[@number='all']/@user")
    cpu_system=$(get_value "//s:timestamp[@date='$timestamp_date' and @time='$timestamp_time']/s:cpu-load/s:cpu[@number='all']/@system")
    cpu_nice=$(get_value "//s:timestamp[@date='$timestamp_date' and @time='$timestamp_time']/s:cpu-load/s:cpu[@number='all']/@nice")
    cpu_iowait=$(get_value "//s:timestamp[@date='$timestamp_date' and @time='$timestamp_time']/s:cpu-load/s:cpu[@number='all']/@iowait")
    cpu_steal=$(get_value "//s:timestamp[@date='$timestamp_date' and @time='$timestamp_time']/s:cpu-load/s:cpu[@number='all']/@steal")
    cpu_idle=$(get_value "//s:timestamp[@date='$timestamp_date' and @time='$timestamp_time']/s:cpu-load/s:cpu[@number='all']/@idle")

    echo "  User:   ${cpu_user:-N/A}%"
    echo "  System: ${cpu_system:-N/A}%"
    echo "  Nice:   ${cpu_nice:-N/A}%"
    echo "  IOWait: ${cpu_iowait:-N/A}%"
    echo "  Steal:  ${cpu_steal:-N/A}%"
    echo "  Idle:   ${cpu_idle:-N/A}%"
    echo "------------------------------------"
done <<< "$timestamps"
