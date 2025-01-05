#!/bin/bash
# Script para firma de binarios
# Verifica si el script se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "Este script debe ejecutarse como root. Saliendo."
  exit 1
fi

# Verifica que el script contenga dos argumentos
if [ "$#" -ne 2 ]; then
  echo "Error: Se requieren exactamente 2 argumentos."
  echo "Uso: $0 <archivo DER (.der)> <binario a firmar>"
  exit 1
fi

# Verificación de dependencias
for cmd in sbsign mokutil; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: La herramienta '$cmd' no está instalada. Instálala e inténtalo nuevamente."
    exit 1
  fi
done

# Variables
cert_file="$1"
binary_file="$2"
key_file="${cert_file%.*}.priv" # Supone que la clave privada tiene el mismo prefijo que el .der
signed_binary="${binary_file%.*}-signed.${binary_file##*.}"

# Verifica que los archivos de entrada existan
if [ ! -f "$cert_file" ]; then
  echo "Error: El archivo certificado '$cert_file' no existe. Saliendo."
  exit 1
fi

if [ ! -f "$key_file" ]; then
  echo "Error: No se encontró la clave privada correspondiente ('$key_file'). Saliendo."
  exit 1
fi

if [ ! -f "$binary_file" ]; then
  echo "Error: El binario '$binary_file' no existe. Saliendo."
  exit 1
fi

# Firmar el binario
echo "Firmando el binario '$binary_file'..."
if ! sbsign --key "$key_file" --cert "$cert_file" --output "$signed_binary" "$binary_file"; then
  echo "Error: Falló el proceso de firma del binario. Saliendo."
  exit 1
fi

echo "El binario fue firmado correctamente y se guardó como '$signed_binary'."

# Opción para verificar la firma
echo "¿Deseas verificar la firma del binario firmado? (s/n)"
read -r confirm
if [[ "$confirm" =~ ^[Ss]$ ]]; then
  if ! sbverify --cert "$cert_file" "$signed_binary"; then
    echo "Error: La verificación de la firma falló."
    exit 1
  fi
  echo "La firma del binario '$signed_binary' es válida."
fi

# Opción para registrar la clave en el sistema con Secure Boot
echo "¿Deseas registrar la clave con MOK? (s/n)"
read -r enroll
if [[ "$enroll" =~ ^[Ss]$ ]]; then
  if ! mokutil --import "$cert_file"; then
    echo "Error: Falló el registro de la clave MOK."
    exit 1
  fi
  echo "Clave registrada. Reinicia el sistema para completar el proceso de registro."
fi

echo "Proceso completado."
