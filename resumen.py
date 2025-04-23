#!/bin/bash

XML_FILE="/home/abian/abianlog/abian.xml"

# Verifica si el archivo existe
if [[ ! -f "$XML_FILE" ]]; then
    echo "Error: No se encontró el archivo XML en $XML_FILE"
    exit 1
fi

# Extraer automáticamente el namespace del documento (xmlns en el nodo raíz)
ns=$(xmlstarlet sel -t -v "namespace-uri(/*)" "$XML_FILE")

# Función auxiliar para extraer valores usando namespace detectado
get_value() {
    path="$1"
    xmlstarlet sel -N s="$ns" -t -v "$path" -n "$XML_FILE"
}

# ----- Datos del sistema -----
sysdata_version=$(get_value "//s:sysdata-version")
sysname=$(get_value "//s:sysname")
release=$(get_value "//s:release")
machine=$(get_value "//s:machine")
num_cpus=$(get_value "//s:number-of-cpus")

# ----- Fecha y hora del archivo -----
file_date=$(get_value "//s:file-date")
file_time=$(get_value "//s:file-utc-time")
timestamp_date=$(get_value "//s:timestamp/@date")
timestamp_time=$(get_value "//s:timestamp/@time")

# ----- Uso de CPU -----
cpu_user=$(get_value "//s:cpu[@number='all']/@user")
cpu_system=$(get_value "//s:cpu[@number='all']/@system")
cpu_nice=$(get_value "//s:cpu[@number='all']/@nice")
cpu_iowait=$(get_value "//s:cpu[@number='all']/@iowait")
cpu_steal=$(get_value "//s:cpu[@number='all']/@steal")
cpu_idle=$(get_value "//s:cpu[@number='all']/@idle")

# ----- Mostrar resumen -----
echo "Resumen del registro sysstat:"
echo "------------------------------------"
echo "Versión y sistema:"
echo "  sysstat version:  $sysdata_version"
echo "  Sistema operativo: $sysname"
echo "  Kernel:           $release"
echo "  Arquitectura:     $machine"
echo "  Núcleos de CPU:   $num_cpus"
echo
echo "Fecha del archivo:"
echo "  Fecha de registro:     $file_date"
echo "  Hora UTC del registro: $file_time"
echo "  Timestamp del snapshot: $timestamp_date $timestamp_time"
echo
echo "Uso de CPU:"
echo "  User:   $cpu_user%"
echo "  System: $cpu_system%"
echo "  Nice:   $cpu_nice%"
echo "  IOWait: $cpu_iowait%"
echo "  Steal:  $cpu_steal%"
echo "  Idle:   $cpu_idle%"
echo "------------------------------------"
