# Chuleta de PowerShell para Active Directory

Lo que más se usa para gestionar usuarios y grupos de un dominio desde
PowerShell. Necesita el módulo `ActiveDirectory` (viene con las herramientas
RSAT o en el propio controlador de dominio).

En los ejemplos, el dominio es `empresa.local` y el usuario `jperez`.

## Usuarios

```powershell
# Crear un usuario activado
New-ADUser -Name "Juan Pérez" -SamAccountName "jperez" `
  -UserPrincipalName "jperez@empresa.local" `
  -Path "CN=Users,DC=empresa,DC=local" `
  -AccountPassword (Read-Host -AsSecureString "Contraseña") `
  -Enabled $true

# Ver un usuario (con propiedades extra)
Get-ADUser -Identity "jperez" -Properties SID, PrimaryGroup

# Deshabilitar y volver a habilitar
Disable-ADAccount -Identity "jperez"
Enable-ADAccount -Identity "jperez"

# Cambiar la contraseña
Set-ADAccountPassword -Identity "jperez" -Reset `
  -NewPassword (Read-Host -AsSecureString "Nueva contraseña")

# Borrar (pide confirmación)
Remove-ADUser -Identity "jperez"
```

`Read-Host -AsSecureString` pide la contraseña sin que se vea ni quede escrita
en el historial. La alternativa, `ConvertTo-SecureString "texto" -AsPlainText -Force`,
deja la contraseña en claro en el script.

## Unidades organizativas

```powershell
# Crear una OU y mover un usuario dentro
New-ADOrganizationalUnit -Name "Usuarios" -Path "DC=empresa,DC=local"
Move-ADObject -Identity "CN=Juan Pérez,CN=Users,DC=empresa,DC=local" `
  -TargetPath "OU=Usuarios,DC=empresa,DC=local"
```

## Búsquedas

```powershell
# Cuentas deshabilitadas
Get-ADUser -Filter {Enabled -eq $false}

# Usuarios con contraseña que no caduca nunca
Get-ADUser -Filter {PasswordNeverExpires -eq $true} -Properties PasswordNeverExpires

# Usuarios con la contraseña caducada
Search-ADAccount -PasswordExpired -UsersOnly

# Cuentas inactivas
Search-ADAccount -AccountInactive -UsersOnly

# Usuarios cuyo nombre empieza por A
Get-ADUser -Filter {Name -like "A*"}
```

Ojo: `-PasswordExpired` y `-AccountExpired` no son lo mismo. El primero busca
contraseñas caducadas; el segundo, cuentas con fecha de caducidad vencida (la
que se pone en "La cuenta expira" a cuentas temporales, por ejemplo de
becarios). La primera vez usé `-AccountExpired` para buscar contraseñas
caducadas y no salía nada.

## Grupos y dominio

```powershell
# Información de un grupo
Get-ADGroup -Identity "Usuarios"

# Grupos cuyo nombre contiene "Admins"
Get-ADGroup -Filter {Name -like "*Admins*"}

# Dominios del bosque
Get-ADForest | Select-Object Domains

# Cualquier objeto del directorio (usuarios, equipos, OU...)
Get-ADObject -Filter * -SearchBase "OU=Usuarios,DC=empresa,DC=local"
```

## net user

`net user` no es de PowerShell: es un comando de Windows de toda la vida, y
funciona también desde `cmd`.

```powershell
net user                    # cuentas locales del equipo
net user jperez /domain     # datos de un usuario del dominio
```

## Si falta un parámetro obligatorio

Si se escribe un cmdlet sin un parámetro obligatorio, por ejemplo
`Set-ADAccountPassword` sin `-Identity`, PowerShell no da error: pregunta el
valor que falta, y en este caso después también la contraseña actual.
