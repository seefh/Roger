
printf "[DEFAULT]\nignoreip = 127.0.0.1/8\nignorecommand =\nbantime  = 600\nfindtime  = 600\nmaxretry = 3\n[sshd]\nenabled=true"

printf"
# Ignoreip is used to set the list of IPs which will not be banned. The list of IP addresses should be given with a space separator.
# This parameter is used to set your personal IP address (if you access the server from a fixed IP).
# Bantime parameter is used to set the duration of seconds for which a host needs to be banned.
# Findtime is the parameter which is used to check if a host must be banned or not. When the host generates maxrety in its last findtime,
# it is banned. Maxretry is the parameter used to set the limit for the number of retry's by a host, upon exceeding this limit,
# the host is banned. Add a jail file to protect SSH: /etc/fail2ban/jail.d/sshd.local. To the above file, add the following lines of code.

[sshd]
enabled = true
port = $ENABLED_PORT
#action = firewallcmd-ipset
logpath = %(sshd_log)s
maxretry = 3
bantime = 3600"
