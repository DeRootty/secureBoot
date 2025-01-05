#!/bin/bash
# Verifica si el script se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Este script debe ejecutarse como root. Saliendo."
  exit 1
fi
# verifica que el script contenga dos argumentos
if [ "$#" -ne 2 ]; then
  echo "Error: Se requieren exactamente 2 argumentos."
  echo "Uso: $0 <nombre archivo> <ID arranque>"
  exit 1
fi

# Verificacion de dependencias
if ! command -v openssl &> /dev/null; then
  echo "Error: OpenSSL no está instalado. Instálalo e inténtalo nuevamente."
  exit 1
fi

# Variables
output_priv="$1.priv"
output_pem="$1.pem"
additional_der="$2.der"
additional_priv="$2.priv"
cn="/CN=$2"

# Se crean los archivos de clave publica clave privada.
echo "1.- Se inicia la creacion de clave publica - privada"
if ! openssl req -new -x509 -newkey rsa:2048 -keyout "$output_priv" -out "$output_pem" -nodes -days 3650 -subj "$cn"; then
  echo "Error: Falló la creación de las claves. Saliendo."
  exit 1
fi

# openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -out MOK.der -nodes -days 3650 -subj "/CN=$2"
# Se chequea la clave privada
echo "2.- Verificacion de clave privada"
if ! openssl rsa -in "$output_priv" -check -noout; then
  echo "Error: La clave privada no pasó la verificación. Saliendo."
  exit 1
fi

echo "3.- Verificacion de clave publica formato PEM"
if ! openssl x509 -in "$output_pem" -inform DER -modulus -noout | openssl md5; then
   echo "Error: La clave publica no paso la verificacion. Saliendo."
   exit 1
fi

# Crear un archivo adicional
echo "4.- Generando archivo adicional DER"
openssl x509 -in "$output_pem" -outform DER -out "$additional_der"
openssl x509 -in "$additional_der" -inform DER -modulus -noout | openssl md5

echo "5.- Verificacion de clave publica formato DER"
if ! openssl x509 -in "$additional_der" -inform DER -modulus -noout | openssl md5; then
   echo "Error: La clave publica no paso la verificacion. Saliendo."
   exit 1
fi
cp "$output_priv" "$additional_priv" 

#openssl req -new -x509 -newkey rsa:2048 -keyout MOK1.priv -out MOK1.der -nodes -days 3650 -subj "/CN=Install Arch Linux Secure Boot"

