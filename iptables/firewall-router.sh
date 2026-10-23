#!/bin/bash
#
# firewall-router.sh
# Debian haciendo de router entre una red interna y la salida a internet,
# filtrando lo que los clientes pueden hacer: DNS, web y ping.
#
# Ejecutar como root. Antes, cambiar los nombres de las tarjetas.
#
##################################################################

WAN=enp0s3   # tarjeta hacia internet
LAN=enp0s8   # tarjeta hacia los clientes

# Activar el reenvío de paquetes (para que sea permanente:
# net.ipv4.ip_forward = 1 en /etc/sysctl.conf)
echo 1 > /proc/sys/net/ipv4/ip_forward

# Limpiar reglas previas, también las de NAT
iptables -F
iptables -t nat -F
iptables -X

# Política por defecto
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

# El propio router
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Que las respuestas vuelvan a los clientes
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Lo que los clientes pueden pedir hacia fuera
iptables -A FORWARD -i $LAN -o $WAN -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -i $LAN -o $WAN -p tcp --dport 53 -j ACCEPT
iptables -A FORWARD -i $LAN -o $WAN -p tcp -m multiport --dports 80,443 -j ACCEPT
iptables -A FORWARD -i $LAN -o $WAN -p icmp --icmp-type echo-request -j ACCEPT

# NAT: los clientes salen a internet con la IP del router
iptables -t nat -A POSTROUTING -o $WAN -j MASQUERADE
