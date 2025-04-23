#!/bin/bash

XML_FILE="/home/abian/abianlog/abian.xml"

# Verifica si el archivo existe
if [[ ! -f "$XML_FILE" ]]; then
    echo "Error: No se encontró el archivo XML en $XML_FILE"
    exit 1
fi

# Detectar el namespace automáticamente
ns=$(xmlstarlet sel -t -v "namespace-uri(/*)" "$XML_FILE")

# Función para extraer valores con namespace
get_value() {
    path="$1"
    xmlstarlet sel -N s="$ns" -t -v "$path" -n "$XML_FILE"
}

# Limpiar variables
cpu_user=""; cpu_system=""; cpu_nice=""
cpu_iowait=""; cpu_steal=""; cpu_idle=""
timestamp_date=""; timestamp_time=""
sysdata_version=""; sysname=""; release=""
machine=""; num_cpus=""
real_file_date=""; real_file_time=""

# Obtener datos del sistema
sysdata_version=$(get_value "//s:sysdata-version")
sysname=$(get_value "//s:sysname")
release=$(get_value "//s:release")
machine=$(get_value "//s:machine")
num_cpus=$(get_value "//s:number-of-cpus")

# Obtener fecha y hora reales del archivo desde el sistema de archivos
real_file_date=$(date -r "$XML_FILE" "+%Y-%m-%d")
real_file_time=$(date -r "$XML_FILE" "+%H:%M:%S")

# Obtener fecha y hora del ÚLTIMO timestamp
timestamp_date=$(get_value "(//s:timestamp)[last()]/@date")
timestamp_time=$(get_value "(//s:timestamp)[last()]/@time")

# Obtener datos de CPU del último snapshot
cpu_user=$(get_value "(//s:timestamp)[last()]/s:cpu-load/s:cpu[@number='all']/@user")
cpu_system=$(get_value "(//s:timestamp)[last()]/s:cpu-load/s:cpu[@number='all']/@system")
cpu_nice=$(get_value "(//s:timestamp)[last()]/s:cpu-load/s:cpu[@number='all']/@nice")
cpu_iowait=$(get_value "(//s:timestamp)[last()]/s:cpu-load/s:cpu[@number='all']/@iowait")
cpu_steal=$(get_value "(//s:timestamp)[last()]/s:cpu-load/s:cpu[@number='all']/@steal")
cpu_idle=$(get_value "(//s:timestamp)[last()]/s:cpu-load/s:cpu[@number='all']/@idle")

# Mostrar resumen
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
echo "Fecha del último registro (timestamp):"
echo "  Fecha: $timestamp_date"
echo "  Hora UTC: $timestamp_time"
echo
echo "Uso de CPU del último snapshot:"
echo "  User:   $cpu_user%"
echo "  System: $cpu_system%"
echo "  Nice:   $cpu_nice%"
echo "  IOWait: $cpu_iowait%"
echo "  Steal:  $cpu_steal%"
echo "  Idle:   $cpu_idle%"
echo "------------------------------------"
