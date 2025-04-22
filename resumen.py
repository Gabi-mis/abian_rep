import xml.etree.ElementTree as ET

def resumir_sadf(xml_path="/home/abian/abianlog/abian.xml"):
    tree = ET.parse(xml_path)
    root = tree.getroot()

    host = root.find(".//host")
    hostname = host.attrib.get("nodename", "Desconocido")
    sysname = host.findtext("sysname", "Linux")
    release = host.findtext("release", "Desconocido")
    cpu_count = host.findtext("number-of-cpus", "N/A")
    file_date = host.findtext("file-date", "N/A")
    boot = host.find("restarts/boot")
    boot_time = f"{boot.attrib.get('date')} {boot.attrib.get('time')} UTC"

    # Extraer estadísticas de CPU
    timestamp = host.find(".//statistics/timestamp")
    cpu_data = timestamp.find(".//cpu")
    time = timestamp.attrib.get("time", "Desconocido")

    usage = {
        "user": float(cpu_data.attrib.get("user", 0.0)),
        "system": float(cpu_data.attrib.get("system", 0.0)),
        "iowait": float(cpu_data.attrib.get("iowait", 0.0)),
        "idle": float(cpu_data.attrib.get("idle", 0.0)),
    }

    resumen = f"""
🖥️ Resumen del sistema: {hostname}
-------------------------------------
📅 Fecha del informe: {file_date} a las {time} UTC
🔁 Último reinicio: {boot_time}
💻 Sistema operativo: {sysname} {release}
🧠 Núcleos de CPU: {cpu_count}

🔍 Uso de CPU:
- Uso por el usuario: {usage['user']}%
- Uso por el sistema: {usage['system']}%
- Espera de disco (iowait): {usage['iowait']}%
- Inactividad (idle): {usage['idle']}%

⚙️ Carga total estimada de CPU: {100 - usage['idle']:.2f}%
"""
    return resumen

# Ejemplo de uso
if __name__ == "__main__":
    print(resumir_sadf())
