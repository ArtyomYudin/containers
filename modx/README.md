<!--- app-name: MODX -->

# Package for LAMP stack modx appication

* Debian bookworm based on bitnami minideb package
* nginx 1.22.1
* MariaDB 11.4.5 bitnami package
* php-fpm 8.4.4 bitnami package
* modx 3.1.1
* listen ports 8080/tcp, 8443/tcp
* SITES="test.com" - set site name
* ENDPOINT="backend" - set backend name in proxy mode or php-fpm container name
* TZ="Europe/Moscow" set timezone
* NGINX_SKIP_SAMPLE_CERTS="false" - selfsigneg ssl cert (values false or true)
* PROXY="false" - proxy or fastcgi mode (values false or true)
