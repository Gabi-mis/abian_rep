#!/bin/bash

# Nuevo directorio donde se guardan los archivos
LOG_DIR="/home/abian/archivos"
BASE_FILE="abian"
EXT=".xml"

# Verifica si el directorio existe
if [[ ! -d "$LOG_DIR" ]]; then
    echo "Error: El directorio $LOG_DIR no existe."
    exit 1
fi

# Crear el nuevo archivo XML con el comando sadf
sadf -x > "$LOG_DIR/$BASE_FILE.xml"

# Verifica si el archivo fue creado correctamente
new_file="$LOG_DIR/$BASE_FILE.xml"
if [[ ! -f "$new_file" ]]; then
    echo "Error: No se pudo crear el archivo XML en $new_file"
    exit 1
fi

# Detectar el namespace automáticamente del nuevo archivo
ns=$(xmlstarlet sel -t -v "namespace-uri(/*)" "$new_file")

# Función para extraer valores con namespace
get_value() {
    path="$1"
    xmlstarlet sel -N s="$ns" -t -v "$path" -n "$new_file"
}

# Mostrar encabezado general
echo "Resumen del registro sysstat:"
echo "------------------------------------"
echo "Fecha del archivo (según sistema de archivos):"
echo "  Fecha: $(date -r "$new_file" "+%Y-%m-%d")"
echo "  Hora:  $(date -r "$new_file" "+%H:%M:%S")"
echo

# Extraer y ordenar los registros de timestamp
timestamps=$(xmlstarlet sel -N s="$ns" -t -m "//s:timestamp" -v "@date" -o " " -v "@time" -n "$new_file" | sort)

# Obtener el primer timestamp (el más antiguo)
first_timestamp=$(echo "$timestamps" | head -n 1)

# Mostrar el primer timestamp
echo "Primer registro (timestamp):"
echo "$first_timestamp"
echo

# Extraer la fecha y hora del primer timestamp
timestamp_date=$(echo "$first_timestamp" | awk '{print $1}')
timestamp_time=$(echo "$first_timestamp" | awk '{print $2}')

# Mostrar la información de CPU del primer timestamp
echo "Uso de CPU para el timestamp $timestamp_date $timestamp_time:"
cpu_user=$(get_value "//s:timestamp[@date='$timestamp_date' and @time='$timestamp_time']/s:cpu-load/s:cpu[@number='all']/@user")
cpu_system=$(get_value "//s:timestamp[@date='$timestamp_date' and @time='$timestamp_time']/s:cpu-load/s:cpu[@number='all']/@system")
cpu_nice=$(get_value "//s:timestamp[@date='$timestamp_date' and @time='$timestamp_time']/s:cpu-load/s:cpu[@number='all']/@nice")
cpu_iowait=$(get_value "//s:timestamp[@date='$timestamp_date' and @time='$timestamp_time']/s:cpu-load/s:cpu[@number='all']/@iowait")
cpu_steal=$(get_value "//s:timestamp[@date='$timestamp_date' and @time='$timestamp_time']/s:cpu-load/s:cpu[@number='all']/@steal")
cpu_idle=$(get_value "//s:timestamp[@date='$timestamp_date' and @time='$timestamp_time']/s:cpu-load/s:cpu[@number='all']/@idle")

echo "  User:   $cpu_user%"
echo "  System: $cpu_system%"
echo "  Nice:   $cpu_nice%"
echo "  IOWait: $cpu_iowait%"
echo "  Steal:  $cpu_steal%"
echo "  Idle:   $cpu_idle%"
echo "------------------------------------"
