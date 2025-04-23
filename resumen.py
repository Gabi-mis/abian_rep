#!/bin/bash

# Ruta al archivo XML generado por sadf -x
XML_FILE="/home/abian/abianlog/abian.xml"

# Verificar si el archivo existe
if [[ ! -f "$XML_FILE" ]]; then
    echo "Error: No se encontró el archivo XML en $XML_FILE"
    exit 1
fi

# Extraer información de CPU
cpu_user=$(xmllint --xpath "string(//cpu[@number='all']/@user)" "$XML_FILE")
cpu_system=$(xmllint --xpath "string(//cpu[@number='all']/@system)" "$XML_FILE")
cpu_iowait=$(xmllint --xpath "string(//cpu[@number='all']/@iowait)" "$XML_FILE")
cpu_idle=$(xmllint --xpath "string(//cpu[@number='all']/@idle)" "$XML_FILE")
cpu_nice=$(xmllint --xpath "string(//cpu[@number='all']/@nice)" "$XML_FILE")
cpu_steal=$(xmllint --xpath "string(//cpu[@number='all']/@steal)" "$XML_FILE")

# Fecha y hora del registro
timestamp_date=$(xmllint --xpath "string(//timestamp/@date)" "$XML_FILE")
timestamp_time=$(xmllint --xpath "string(//timestamp/@time)" "$XML_FILE")

# Mostrar los datos
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
