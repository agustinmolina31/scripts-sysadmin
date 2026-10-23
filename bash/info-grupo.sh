#!/bin/bash
#
# info-grupo.sh
# Muestra el GID, los miembros y cuántos miembros tiene un grupo.
# Uso: ./info-grupo.sh nombre_grupo
#
##################################################################

if [ $# -ne 1 ]; then
    echo "Uso: $0 nombre_grupo"
    exit 1
fi

groupname=$1
found=false

# /etc/group: nombre:contraseña:GID:miembro1,miembro2,...
while IFS=: read -r group pass gid members && [ "$found" = false ]; do
    if [ "$group" = "$groupname" ]; then
        user_count=$(echo $members | tr ',' '\n' | wc -w)
        echo "GID: $gid"
        echo "Nombre del grupo: $group"
        echo "Miembros: $members"
        echo "Cantidad de miembros: $user_count"
        found=true
    fi
done < /etc/group

if [ "$found" = false ]; then
    echo "El grupo $groupname no existe."
fi

exit 0
