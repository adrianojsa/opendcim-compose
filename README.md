# opendcim21-docker-compose
Serviço OpenDCIM 21.01 em container Docker sob Debian 11 e PHP 7.4

[OpenDCIM](https://www.opendcim.org) é:

> Um software de código aberto para o gerenciamento de infraestrtura de datacenter. 
> Inicialmente desenvolvido internamente na Vanderbilt University Information 
> Technology Services por Scott Milliken.

## PROCEDIMENTOS

Primeiro customize o arquivo `.env`.

| Variável          | Valor                                | Nota |
|-------------------|--------------------------------------|------|
|DCIM_HTTP_PORT     |80                                    |Porta HTTP que o OPenDCIM responderá|
|DCIM_HTTPS_PORT    |443                                   |Porta HTTPS que o OPenDCIM responderá|
|ADMINER_PORT       |8080                                  |Porta que responderá a aplicação Adminer|
|MYSQL_ROOT_PASSWORD|senhaRootBD                           |Senha de Root do Mysql|
|MYSQL_DATABASE     |dcim                                  |Nome do banco do OpenDCIM|
|MYSQL_USER         |dcim                                  |Usuário do OpenDCIM para conexão com o BD|
|MYSQL_PASSWORD     |senhaBDdcim                           |Senha do usuário dcim no BD|
|DCIM_PASSWD   |webdcim    |Senha padrão para logar no navegador. Usuários padrão é dcim|
|DCIM_PASSWD_FILE   |/secrets/opendcim_password    |Usar com swarm secrets|
|SSL_CERT_FILE      |/certs/ssl-cert.pem|se o certificado e a chave estiverem definidos, o SSL será ativado|
|SSL_KEY_FILE       |/certs/opendcim-ssl-cert.key|Caminho da chave do certificado do SSL|

## Uso de TLS

Vamos criar o diretório no host para armazenar os certificados que podem ser gerados com os comandos:

    mkdir -p certs
    openssl req -x509 -newkey rsa:4096 -keyout certs/opendcim-ssl-cert.key -out certs/opendcim-ssl-cert.pem -days 365 -nodes -subj "/C=BR/ST=Estado/L=Cidade/O=Instituição/OU=Departamento/CN=dcim.example.com"
