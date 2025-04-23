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
    new_id=1
else
    last_number=$(echo "$last_file" | grep -oP "\d+" | tail -n 1)
    new_number=$((last_number + 1))
    new_file="${BASE_FILE}${new_number}${EXT}"
    new_id=$new_number
fi

# Eliminar archivos anteriores excepto el último
if [[ -n "$last_file" ]]; then
    echo "Eliminando archivos antiguos..."
    for file in $(ls -1 "$LOG_DIR" | grep -oP "${BASE_FILE}\d+${EXT}" | sort -V | head -n -1); do
        rm "$LOG_DIR/$file"
        echo "Archivo eliminado: $file"
    done
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

# Mostrar encabezado general
echo "Resumen del registro sysstat:"
echo "------------------------------------"
echo "Fecha del archivo (según sistema de archivos):"
echo "  Fecha: $(date -r "$LOG_DIR/$new_file" "+%Y-%m-%d")"
echo "  Hora:  $(date -r "$LOG_DIR/$new_file" "+%H:%M:%S")"
echo

# Obtener el último timestamp del archivo recién creado (basado en el ID)
timestamp_id=$(xmlstarlet sel -N s="$ns" -t -m "//s:timestamp" -v "s@id" -n "$LOG_DIR/$new_file" | tail -n 1)

# Extraer los valores de CPU de ese timestamp específico
user=$(xmlstarlet sel -N s="$ns" -t -v "//s:timestamp[s@id='$timestamp_id']/s:cpu-load/s:cpu[@number='all']/@user" "$LOG_DIR/$new_file")
system=$(xmlstarlet sel -N s="$ns" -t -v "//s:timestamp[s@id='$timestamp_id']/s:cpu-load/s:cpu[@number='all']/@system" "$LOG_DIR/$new_file")
nice=$(xmlstarlet sel -N s="$ns" -t -v "//s:timestamp[s@id='$timestamp_id']/s:cpu-load/s:cpu[@number='all']/@nice" "$LOG_DIR/$new_file")
iowait=$(xmlstarlet sel -N s="$ns" -t -v "//s:timestamp[s@id='$timestamp_id']/s:cpu-load/s:cpu[@number='all']/@iowait" "$LOG_DIR/$new_file")
steal=$(xmlstarlet sel -N s="$ns" -t -v "//s:timestamp[s@id='$timestamp_id']/s:cpu-load/s:cpu[@number='all']/@steal" "$LOG_DIR/$new_file")
idle=$(xmlstarlet sel -N s="$ns" -t -v "//s:timestamp[s@id='$timestamp_id']/s:cpu-load/s:cpu[@number='all']/@idle" "$LOG_DIR/$new_file")

# Mostrar el resumen de este snapshot
echo "Último snapshot registrado:"
echo "------------------------------------"
echo "  ID del timestamp: $timestamp_id"
echo "  User:   $user%"
echo "  System: $system%"
echo "  Nice:   $nice%"
echo "  IOWait: $iowait%"
echo "  Steal:  $steal%"
echo "  Idle:   $idle%"
echo "------------------------------------"
