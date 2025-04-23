#!/bin/bash

XML_FILE="/home/abian/abianlog/abian.xml"

# Verifica si el archivo existe
if [[ ! -f "$XML_FILE" ]]; then
    echo "Error: No se encontró el archivo XML en $XML_FILE"
    exit 1
fi

# Namespace que usa el XML
ns="https://sysstat.github.io"

# Función auxiliar para extraer valores con namespace
get_value() {
    path="$1"
    xmlstarlet sel -N s="$ns" -t -v "$path" -n "$XML_FILE"
}

# Extraer valores de CPU
cpu_user=$(get_value "//s:cpu[@number='all']/@user")
cpu_system=$(get_value "//s:cpu[@number='all']/@system")
cpu_nice=$(get_value "//s:cpu[@number='all']/@nice")
cpu_iowait=$(get_value "//s:cpu[@number='all']/@iowait")
cpu_steal=$(get_value "//s:cpu[@number='all']/@steal")
cpu_idle=$(get_value "//s:cpu[@number='all']/@idle")

# Extraer fecha y hora
timestamp_date=$(get_value "//s:timestamp/@date")
timestamp_time=$(get_value "//s:timestamp/@time")

# Mostrar resumen
echo "Resumen del registro sysstat:"
echo "------------------------------------"
echo "Fecha del registro: $timestamp_date $timestamp_time"
echo
echo "Uso de CPU:"
echo "  User:   $cpu_user%"
echo "  System: $cpu_system%"
echo "  Nice:   $cpu_nice%"
echo "  IOWait: $cpu_iowait%"
echo "  Steal:  $cpu_steal%"
echo "  Idle:   $cpu_idle%"
echo "------------------------------------"
