##
## SSL settings
##

# SSL/TLS support: yes, no, required. <doc/wiki/SSL.txt>
#ssl = yes
<% if($variables->{ssl}){ %>
ssl = <%= $variables->{ssl} %>
<% } %>

# PEM encoded X.509 SSL/TLS certificate and private key. They're opened before
# dropping root privileges, so keep the key file unreadable by anyone but
# root. Included doc/mkcert.sh can be used to easily generate self-signed
# certificate, just make sure to update the domains in dovecot-openssl.cnf
<% if($variables->{ssl} eq "yes"){ %>
ssl_cert = <<%= $variables->{ssl_cert} %>
ssl_key = <<%= $variables->{ssl_key} %>
<% } %>

# If key file is password protected, give the password here. Alternatively
# give it when starting dovecot with -p parameter. Since this file is often
# world-readable, you may want to place this setting instead to a different
# root owned 0600 file by using ssl_key_password = <path.
#ssl_key_password =

# PEM encoded trusted certificate authority. Set this only if you intend to use
# ssl_verify_client_cert=yes. The file should contain the CA certificate(s)
# followed by the matching CRL(s). (e.g. ssl_ca = </etc/pki/dovecot/certs/ca.pem)
#ssl_ca =

# Request client to send a certificate. If you also want to require it, set
# auth_ssl_require_client_cert=yes in auth section.
#ssl_verify_client_cert = no

# Which field from certificate to use for username. commonName and
# x500UniqueIdentifier are the usual choices. You'll also need to set
# auth_ssl_username_from_cert=yes.
#ssl_cert_username_field = commonName

# How often to regenerate the SSL parameters file. Generation is quite CPU
# intensive operation. The value is in hours, 0 disables regeneration
# entirely.
#ssl_parameters_regenerate = 168

# SSL ciphers to use
#ssl_cipher_list = ALL:!LOW:!SSLv2:!EXP:!aNULL
<% if($variables->{ssl_cipher_list}){ %>
ssl_cipher_list = <%= $variables->{ssl_cipher_list} %>
<% } %>
