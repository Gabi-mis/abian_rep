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

# Extraer los valores de CPU de todo el archivo
cpu_user=$(get_value "//s:cpu-load/s:cpu[@number='all']/@user")
cpu_system=$(get_value "//s:cpu-load/s:cpu[@number='all']/@system")
cpu_nice=$(get_value "//s:cpu-load/s:cpu[@number='all']/@nice")
cpu_iowait=$(get_value "//s:cpu-load/s:cpu[@number='all']/@iowait")
cpu_steal=$(get_value "//s:cpu-load/s:cpu[@number='all']/@steal")
cpu_idle=$(get_value "//s:cpu-load/s:cpu[@number='all']/@idle")

# Mostrar el resumen de la CPU
echo "Uso de CPU:"
echo "  User:   $cpu_user%"
echo "  System: $cpu_system%"
echo "  Nice:   $cpu_nice%"
echo "  IOWait: $cpu_iowait%"
echo "  Steal:  $cpu_steal%"
echo "  Idle:   $cpu_idle%"
echo "------------------------------------"
