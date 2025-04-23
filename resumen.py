#!/bin/bash

# Ruta al archivo XML
XML_FILE="/home/abian/abianlog/abian.xml"

# Verificación
if [[ ! -f "$XML_FILE" ]]; then
    echo "Error: No se encontró el archivo XML en $XML_FILE"
    exit 1
fi

# Prefijo del namespace que declararemos como "s"
ns="https://sysstat.github.io"

# Función para obtener valores XML con namespace
get_value() {
    xpath="$1"
    xmllint --xpath "string($xpath)" --xpath "declare namespace s='$ns'; $xpath" "$XML_FILE" 2>/dev/null
}

# Extraer datos de CPU con prefijo de espacio de nombres
cpu_user=$(get_value "//s:cpu[@number='all']/@user")
cpu_system=$(get_value "//s:cpu[@number='all']/@system")
cpu_iowait=$(get_value "//s:cpu[@number='all']/@iowait")
cpu_idle=$(get_value "//s:cpu[@number='all']/@idle")
cpu_nice=$(get_value "//s:cpu[@number='all']/@nice")
cpu_steal=$(get_value "//s:cpu[@number='all']/@steal")

# Fecha y hora
timestamp_date=$(get_value "//s:timestamp/@date")
timestamp_time=$(get_value "//s:timestamp/@time")

# Mostrar resultados
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
