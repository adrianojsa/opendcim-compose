# OpenDCIM com Docker
Este projeto usa como base o trabalho do usuário [Luca lucamaro](https://github.com/lucamaro/opendcim-container).

Aqui você encontra o serviço OpenDCIM na versão 21.01 em container com Debian 11 e PHP 7.4

[OpenDCIM](https://www.opendcim.org) é:

> Um software de código aberto para o gerenciamento de infraestrtura de datacenter. 
> Inicialmente desenvolvido internamente na Vanderbilt University Information 
> Technology Services por Scott Milliken.

Buscando organizar nosso projeto e nome de container, renomei o diretório do projeto para opendcim21 logo após descompactar ou baixar com o git.

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

### Uso de TLS

Vamos criar os diretórios no host para armazenar os arquivos de imagens e os certificados que podem ser gerados com os comandos:

    mkdir -p certs data
    openssl req -x509 -newkey rsa:4096 -keyout certs/opendcim-ssl-cert.key -out certs/opendcim-ssl-cert.pem -days 365 -nodes -subj "/C=BR/ST=Estado/L=Cidade/O=Instituição/OU=Departamento/CN=dcim.example.com"

Para receber apenas conexões HTTPS, descomente as linha 2-4 do arquivo 000-default.conf deixando como abaixo:

        RewriteEngine On
        RewriteCond %{HTTPS} !=on
        RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R=301,L]

### Iniciar nosso serviço OpenDCIM

Para realizar o Build da imagem e iniciar o serviço em segundo plano, execute o comando:
    
    docker compose up -d
    
Após completar a instalação, remova o arquivo install.php:

    docker exec -it opendcim21-webapp-1 rm /var/www/dcim/install.php
    
### Habilitar autenticação LDAP

Depois que o openDCIM estiver funcionando com permissões de administrador (ou seja, usuário dcim), vá para o menu "Editar configuração" -> guia LDAP e configure todos os parâmetros de acordo com sua configuração LDAP.

Em seguida, desative a autenticação básica e ative a autenticação LDAP:

    docker exec -it opendcim21-webapp-1 mv /var/www/dcim/.htaccess /var/www/dcim/.htaccess.no
    docker exec -it opendcim21-webapp-1 sed -i "s/Apache/LDAP/" /var/www/dcim/db.inc.php

Agora você deve conseguir fazer login com credenciais de usuários LDAP.

# Restaução da Instalação

## Restauração de imagens

As imagens podem ser encontradas nos diretórios `/data/images` `/data/pictures` e `/data/drawings` 

## Restauração do Banco de Dados

    zcat dcim.sql.gz | docker exec -i opendcim21-db-1 mysql -u root -psenharootmysql dcim

    docker exec -it opendcim21-db-1 mysql -u root -psenhadorootmysql  dcim
    
Outra opção é gerenciar o banco de dados com a aplicação ADMINER. Com ele podemos realizar backup e restauração do banco de dados, alterar tabelas e consultas no banco de dados do OpenDCIM.

    docker-compose -f docker-compose-db.yml up -d
