#!/bin/bash
#
# info-usuario.sh
# Busca un usuario en /etc/passwd y muestra sus datos.
#
##################################################################

echo -n "Nombre de usuario: "
read username

found=false

# /etc/passwd tiene un usuario por línea, con los campos separados por ":"
while IFS=: read -r user pass uid gid desc home shell && [ "$found" = false ]; do
    if [ "$user" = "$username" ]; then
        echo "Usuario: $user"
        echo "UID: $uid"
        echo "GID del grupo principal: $gid"
        echo "Directorio personal: $home"
        echo "Shell: $shell"
        found=true
    fi
done < /etc/passwd

if [ "$found" = false ]; then
    echo "El usuario $username no existe."
fi

exit 0
