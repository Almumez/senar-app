#!/bin/bash

# Script para copiar el archivo de sonido de notificación al bundle principal
# Este script debe ejecutarse durante la fase de compilación

echo "Copiando archivo de sonido de notificación al bundle principal..."

# Rutas de origen y destino
SOURCE_FILE="${SRCROOT}/Runner/Resources/notification.wav"
DEST_DIR="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"

# Verificar que el archivo de origen existe
if [ ! -f "$SOURCE_FILE" ]; then
  echo "ERROR: El archivo de sonido no existe en $SOURCE_FILE"
  exit 1
fi

# Crear directorio de destino si no existe
mkdir -p "$DEST_DIR"

# Copiar el archivo
cp "$SOURCE_FILE" "$DEST_DIR/"

echo "Archivo de sonido copiado con éxito a $DEST_DIR/notification.wav"
