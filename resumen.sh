#!/bin/bash

XML_FILE="/home/abian/abianlog/abian.xml"

# Verifica si el archivo existe
if [[ ! -f "$XML_FILE" ]]; then
    echo "Error: No se encontró el archivo XML en $XML_FILE"
    exit 1
fi

# Detectar el namespace automáticamente
ns=$(xmlstarlet sel -t -v "namespace-uri(/*)" "$XML_FILE")

# Contar la cantidad total de snapshots
total_snapshots=$(xmlstarlet sel -N s="$ns" -t -v "count(//s:timestamp)" "$XML_FILE")

# Si hay más de un snapshot, elimina todos excepto el último
if [[ "$total_snapshots" -gt 1 ]]; then
    # Crea un archivo temporal eliminando todos los timestamp menos el último
    xmlstarlet ed -N s="$ns" $(for (( i=1; i<total_snapshots; i++ )); do echo -n "-d (//s:timestamp)[$i] "; done) "$XML_FILE" > "${XML_FILE}.tmp" && mv "${XML_FILE}.tmp" "$XML_FILE"
fi

# Función para extraer valores con namespace
get_value() {
    path="$1"
    xmlstarlet sel -N s="$ns" -t -v "$path" -n "$XML_FILE"
}

# Obtener datos del sistema
sysdata_version=$(get_value "//s:sysdata-version")
sysname=$(get_value "//s:sysname")
release=$(get_value "//s:release")
machine=$(get_value "//s:machine")
num_cpus=$(get_value "//s:number-of-cpus")

# Obtener fecha y hora reales del archivo desde el sistema de archivos
real_file_date=$(date -r "$XML_FILE" "+%Y-%m-%d")
real_file_time=$(date -r "$XML_FILE" "+%H:%M:%S")

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
