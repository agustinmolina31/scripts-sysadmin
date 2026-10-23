#!/bin/bash
#
# gestion-usuarios.sh
# Menú para crear y borrar usuarios y grupos, cambiar contraseñas
# y añadir usuarios a grupos. Necesita permisos de sudo.
#
# Cada función devuelve un código de salida propio para que el menú
# pueda decir exactamente qué ha fallado:
#   1 = el usuario no existe      2 = el grupo no existe
#   3 = el usuario ya existe      4 = el grupo ya existe
#   100 = contraseña vacía
#
##################################################################

# Funciones
crearUsuario() {
    if id "$1" &>/dev/null; then
        return 3
    fi
    sudo useradd -m "$1"
    return $?
}

crearGrupo() {
    if grep -q "^$1:" /etc/group; then
        return 4
    fi
    sudo groupadd "$1"
    return $?
}

eliminarUsuario() {
    if ! id "$1" &>/dev/null; then
        return 1
    fi
    sudo userdel -r "$1"
    return $?
}

eliminarGrupo() {
    if ! grep -q "^$1:" /etc/group; then
        return 2
    fi
    sudo groupdel "$1"
    return $?
}

cambiarContrasena() {
    if ! id "$1" &>/dev/null; then
        return 1
    fi
    if [ -z "$2" ]; then
        return 100
    fi
    echo "$1:$2" | sudo chpasswd
    return $?
}

anadirUsuarioAGrupo() {
    if ! id "$1" &>/dev/null; then
        return 1
    fi
    if ! grep -q "^$2:" /etc/group; then
        return 2
    fi
    sudo usermod -aG "$2" "$1"
    return $?
}

mostrarMenu() {
    clear
    echo "MENÚ"
    echo "a) Crear usuario"
    echo "b) Crear grupo"
    echo "c) Eliminar usuario"
    echo "d) Eliminar grupo"
    echo "e) Cambiar contraseña de un usuario"
    echo "f) Añadir usuario a un grupo"
    echo "x) Salir"
    echo -n "Elige una opción: "
}

# Programa
while true; do
    mostrarMenu
    read opcion

    case $opcion in
        a|A)
            read -p "Nombre del usuario: " usuario
            crearUsuario "$usuario"
            case $? in
                0) echo "Usuario $usuario creado correctamente";;
                3) echo "Error: el usuario $usuario ya existe";;
                *) echo "Error desconocido";;
            esac
            ;;
        b|B)
            read -p "Nombre del grupo: " grupo
            crearGrupo "$grupo"
            case $? in
                0) echo "Grupo $grupo creado correctamente";;
                4) echo "Error: el grupo $grupo ya existe";;
                *) echo "Error desconocido";;
            esac
            ;;
        c|C)
            read -p "Nombre del usuario a eliminar: " usuario
            eliminarUsuario "$usuario"
            case $? in
                0) echo "Usuario $usuario eliminado correctamente";;
                1) echo "Error: el usuario $usuario no existe";;
                *) echo "Error desconocido";;
            esac
            ;;
        d|D)
            read -p "Nombre del grupo a eliminar: " grupo
            eliminarGrupo "$grupo"
            case $? in
                0) echo "Grupo $grupo eliminado correctamente";;
                2) echo "Error: el grupo $grupo no existe";;
                *) echo "Error desconocido";;
            esac
            ;;
        e|E)
            read -p "Nombre del usuario: " usuario
            read -sp "Nueva contraseña: " contrasena
            echo
            cambiarContrasena "$usuario" "$contrasena"
            case $? in
                0) echo "Contraseña cambiada correctamente";;
                1) echo "Error: el usuario $usuario no existe";;
                100) echo "Error: no has escrito ninguna contraseña";;
                *) echo "Error desconocido";;
            esac
            ;;
        f|F)
            read -p "Nombre del usuario: " usuario
            read -p "Nombre del grupo: " grupo
            anadirUsuarioAGrupo "$usuario" "$grupo"
            case $? in
                0) echo "Usuario $usuario añadido al grupo $grupo correctamente";;
                1) echo "Error: el usuario $usuario no existe";;
                2) echo "Error: el grupo $grupo no existe";;
                *) echo "Error desconocido";;
            esac
            ;;
        x|X)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción no válida"
            ;;
    esac

    read -p "Pulsa [Intro] para continuar"
done
