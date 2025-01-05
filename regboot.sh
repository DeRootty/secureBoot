#!/bin/bash

# Verifica si el script se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "Este script debe ejecutarse como root. Saliendo."
  exit 1
fi

# Verifica que el script contenga un argumento
if [ "$#" -ne 1 ]; then
  echo "Error: Se requiere exactamente 1 argumento."
  echo "Uso: $0 <archivo DER (.der)>"
  exit 1
fi

# Verificación de dependencias
if ! command -v mokutil &> /dev/null; then
  echo "Error: mokutil no está instalado. Instálalo e inténtalo nuevamente."
  exit 1
fi

# Variables
cert_file="$1"

# Verifica que el archivo de entrada exista
if [ ! -f "$cert_file" ]; then
  echo "Error: El archivo certificado '$cert_file' no existe. Saliendo."
  exit 1
fi

# Registrar la clave
echo "Registrando la clave en Secure Boot..."
if ! mokutil --import "$cert_file"; then
  echo "Error: Falló el registro de la clave MOK."
  exit 1
fi

echo "Clave registrada correctamente. Debes reiniciar el sistema para completar el registro."
echo "Durante el arranque, selecciona la opción 'Enroll MOK' en el menú de Secure Boot."
