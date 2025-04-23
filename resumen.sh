#!/bin/bash

XML_FILE="/home/abian/abianlog/abian.xml"

# Verifica si el archivo existe
if [[ ! -f "$XML_FILE" ]]; then
    echo "Error: No se encontró el archivo XML en $XML_FILE"
    exit 1
fi

# Detectar el namespace automáticamente
ns=$(xmlstarlet sel -t -v "namespace-uri(/*)" "$XML_FILE")

# Eliminar todos los snapshots (timestamp) del XML
xmlstarlet ed -N s="$ns" -d "//s:timestamp" "$XML_FILE" > "${XML_FILE}.tmp" && mv "${XML_FILE}.tmp" "$XML_FILE"

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
echo "No se detectaron snapshots (han sido eliminados previamente)."
echo "------------------------------------"
