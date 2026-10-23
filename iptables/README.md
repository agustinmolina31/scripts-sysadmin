# Cortafuegos con iptables

Dos scripts con política restrictiva: se bloquea todo y solo se abre lo que
hace falta.

| Script | Para qué |
|---|---|
| [`firewall-equipo.sh`](firewall-equipo.sh) | Un equipo que solo puede navegar, hacer ping y conectarse por SSH. Bloquea facebook.com |
| [`firewall-router.sh`](firewall-router.sh) | Un Debian haciendo de router: deja salir a los clientes de la red interna a DNS, web y ping, con NAT |

## Lo que corregí de mi primera versión

Al repasar mis scripts originales para subirlos encontré varios fallos. Esto es
lo que he cambiado y por qué.

### En el equipo

| Fallo | Qué pasaba | Arreglo |
|---|---|---|
| No se permitía DNS | Con la salida bloqueada y solo los puertos 80 y 443 abiertos, no se resolvía ningún nombre: se podía navegar por IP, pero no por dirección | Abrir la salida al puerto 53 (UDP y TCP) |
| El bloqueo de Facebook iba después de abrir el 443 | iptables aplica la primera regla que coincide. El tráfico a Facebook ya se había aceptado por la regla del 443 y el `DROP` nunca llegaba a usarse | Poner el bloqueo antes de las reglas de web |
| La IP de Facebook salía de `nslookup` con un `grep` | Se ejecutaba con el DNS ya bloqueado, y además el `grep` podía coger la IP del servidor DNS en vez de la de Facebook | `dig +short facebook.com A`, que devuelve solo las IP, y todas ellas |
| El ping entrante no tenía respuesta | Entraba la petición, pero la respuesta no podía salir: la salida estaba bloqueada y no había regla para las conexiones establecidas | Añadir `ESTABLISHED,RELATED` también en `OUTPUT` |
| Las reglas de SSH eran al revés | Abrían el puerto 22 de entrada, o sea, dejaban que otros entraran por SSH al equipo. Lo que se pedía era poder conectarse a servidores SSH | Abrir la salida al puerto 22 de destino |

### En el router

| Fallo | Qué pasaba | Arreglo |
|---|---|---|
| Solo se reenviaban DNS y DHCP | No había reglas para web ni ping, ni para que volvieran las respuestas | Reglas de `FORWARD` para 80/443 e ICMP, y `ESTABLISHED,RELATED` |
| Se abría DHCP (puertos 67-68) en `FORWARD` | DHCP funciona por broadcast y no atraviesa un router. Esa regla no hacía nada | Quitarla |
| La interfaz estaba fija como `eth0` | En Debian moderno las tarjetas se llaman `enp0s3`, `ens18`... | Variables `WAN` y `LAN` al principio |

**La prueba me engañó.** El ping del cliente funcionaba, pero en la salida
aparecía `Redirect Host (New nexthop: 192.168.12.1)`: el cliente y el router
estaban en la misma red que la puerta de enlace real, así que el router le
decía al cliente "ve directamente por 192.168.12.1". El tráfico no pasaba por el
cortafuegos y por eso no se notaba que faltaban reglas. Para probarlo bien, el
cliente tiene que estar solo en la red interna (`LAN`), sin otra salida.

## Comprobar las reglas

```bash
sudo iptables -L -v -n            # reglas de filtrado con contadores
sudo iptables -t nat -L -v -n     # reglas de NAT
```

Los contadores de `-v` sirven para ver si una regla se está usando de verdad:
si se queda a 0 mientras pruebas, el tráfico no pasa por ahí.

## Pendiente

- Las reglas se pierden al reiniciar. Para que se mantengan, `iptables-persistent`
  (`netfilter-persistent save`).
- Bloquear por IP no es fiable para webs grandes: Facebook cambia de IP y usa
  muchas. Para eso es mejor un proxy o filtrar por DNS.
- `-m state` funciona, pero la forma actual es `-m conntrack --ctstate`.
