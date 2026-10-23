#!/bin/bash
#
# firewall-equipo.sh
# Cortafuegos para un equipo con política restrictiva: todo bloqueado
# salvo navegar por web, hacer ping (en los dos sentidos) y conectarse
# a servidores SSH. Además bloquea facebook.com.
#
# Ejecutar como root. Las reglas no sobreviven a un reinicio.
#
##################################################################

# Limpiar reglas y cadenas previas
iptables -F
iptables -X

# Política por defecto: denegar todo
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Tráfico local del propio equipo
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Respuestas a conexiones ya establecidas, en los dos sentidos
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# DNS: sin esto no se resuelve ningún nombre y no se puede navegar
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Bloquear facebook.com. Tiene que ir ANTES de permitir HTTP/HTTPS:
# iptables aplica la primera regla que coincide.
for ip in $(dig +short facebook.com A); do
    iptables -A OUTPUT -d "$ip" -j DROP
done

# Navegación web
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Ping saliente (la respuesta entra por la regla de ESTABLISHED)
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT

# Ping entrante (la respuesta sale por la regla de ESTABLISHED de OUTPUT)
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# Conectarse a servidores SSH
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
