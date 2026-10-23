#!/bin/bash
#
# backup.sh
# Copia de seguridad de directorios importantes en un .zip con la fecha,
# dejando constancia de cada ejecución en un log.
#
##################################################################

# Variables
BACKUP_DIR="$HOME/Backup"
LOG_FILE="$BACKUP_DIR/backups.log"
FECHA=$(date +%Y%m%d)
HOSTNAME=$(hostname)
USUARIO=$(whoami)
DIRS_TO_BACKUP=("/opt" "/etc/apache2" "/var/www")
ZIP_FILE="$BACKUP_DIR/$FECHA-backup.zip"

# Se crea el directorio Backup si no existe
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Escribe una línea en el log
log_message() {
    echo "$HOSTNAME -- $USUARIO -- [$(date)] $1" >> "$LOG_FILE"
}

log_message "Iniciando backup"

# Si falta algún directorio, no se hace la copia
for dir in "${DIRS_TO_BACKUP[@]}"; do
    if [ ! -d "$dir" ]; then
        log_message "ERROR: El directorio $dir no existe"
        exit 1
    fi
done

# Crear el zip con todos los directorios
if zip -r "$ZIP_FILE" "${DIRS_TO_BACKUP[@]}" > /dev/null 2>&1; then
    log_message "Backup realizado correctamente en $ZIP_FILE"
    exit 0
else
    log_message "ERROR: Fallo al crear el backup"
    exit 1
fi
