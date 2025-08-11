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
  
  # Try alternative path
  SOURCE_FILE="${SRCROOT}/Resources/notification.wav"
  if [ ! -f "$SOURCE_FILE" ]; then
    echo "ERROR: El archivo de sonido tampoco existe en $SOURCE_FILE"
    exit 1
  fi
fi

# Crear directorio de destino si no existe
mkdir -p "$DEST_DIR"

# Copiar el archivo
cp "$SOURCE_FILE" "$DEST_DIR/"

# Set proper permissions
chmod 644 "$DEST_DIR/notification.wav"

echo "Archivo de sonido copiado con éxito a $DEST_DIR/notification.wav"

# Verify file was copied
if [ -f "$DEST_DIR/notification.wav" ]; then
  echo "✅ Verification successful: notification.wav is in the bundle"
  ls -la "$DEST_DIR/notification.wav"
else
  echo "❌ Verification failed: notification.wav not found in bundle"
  exit 1
fi