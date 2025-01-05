#!/bin/bash

# Verifica si el script se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "Este script debe ejecutarse como root. Saliendo."
  exit 1
fi

# Verificación de dependencia: mokutil
if ! command -v mokutil &> /dev/null; then
  echo "Error: mokutil no está instalado. Instálalo e inténtalo nuevamente."
  exit 1
fi

# Verificar si Secure Boot está habilitado
secure_boot_status=$(mokutil --sb-state)

echo "Verificando estado de Secure Boot..."
echo "$secure_boot_status"

if echo "$secure_boot_status" | grep -q "SecureBoot enabled"; then
  echo "Secure Boot está habilitado en este sistema."
else
  echo "Secure Boot no está habilitado o no está disponible en este sistema."
  exit 0
fi

# Verificar si se admite el registro de claves
echo "Verificando soporte para el registro de claves MOK..."
if mokutil --list-new &> /dev/null; then
  echo "Tu sistema admite el registro de claves MOK."
else
  echo "Tu sistema no admite el registro de claves MOK. Verifica la configuración de Secure Boot en el firmware UEFI."
fi

echo "Verificación completada."
