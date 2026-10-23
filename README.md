# Scripts de administración de sistemas

Scripts y chuletas para tareas del día a día con usuarios, copias y cortafuegos,
en Linux y en Windows.

| Carpeta | Qué hay |
|---|---|
| [`bash/`](bash/) | Gestión de usuarios y grupos, copia de seguridad con log y consulta de usuarios y grupos |
| [`iptables/`](iptables/) | Cortafuegos para un equipo y para un Debian que hace de router |
| [`powershell/`](powershell/) | Chuleta de PowerShell para Active Directory |

## Bash

| Script | Qué hace |
|---|---|
| [`gestion-usuarios.sh`](bash/gestion-usuarios.sh) | Menú para crear y borrar usuarios y grupos, cambiar contraseñas y añadir usuarios a grupos. Cada función devuelve un código de salida propio, y el menú dice exactamente qué ha fallado ("el usuario ya existe", "el grupo no existe"...) |
| [`backup.sh`](bash/backup.sh) | Mete varios directorios en un `.zip` con la fecha y apunta cada ejecución en un log, con equipo, usuario y hora. Si falta algún directorio, no hace la copia y lo registra |
| [`info-usuario.sh`](bash/info-usuario.sh) | Busca un usuario en `/etc/passwd` y muestra su UID, grupo, carpeta personal y shell |
| [`info-grupo.sh`](bash/info-grupo.sh) | Muestra el GID de un grupo, sus miembros y cuántos son |

```bash
chmod +x bash/*.sh
./bash/gestion-usuarios.sh
./bash/info-grupo.sh sudo
```

Para que `backup.sh` se ejecute solo cada noche a las 2:00, con `crontab -e`:

```
0 2 * * * /ruta/a/backup.sh
```

Los directorios que copia están en la variable `DIRS_TO_BACKUP`, al principio
del script.

## iptables

Los fallos que encontré en mi primera versión, y cómo los arreglé, están en
[`iptables/README.md`](iptables/README.md).

## PowerShell

[`active-directory.md`](powershell/active-directory.md): crear, deshabilitar,
mover y borrar usuarios; cambiar contraseñas; buscar cuentas deshabilitadas,
inactivas o con la contraseña caducada; y consultar grupos.

## Lo que mejoraría

- `gestion-usuarios.sh` comprueba los grupos con `grep` sobre `/etc/group`;
  `getent group` sería más fiable (también ve grupos de LDAP).
- `backup.sh` no borra copias antiguas: con el tiempo llenaría el disco. Le
  faltaría algo como `find "$BACKUP_DIR" -name "*.zip" -mtime +7 -delete`.
- `backup.sh` necesita permisos para leer todo lo que copia (por ejemplo, partes
  de `/etc`): para un servidor real, mejor ejecutarlo desde el cron de root.
