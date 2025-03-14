#!/bin/bash

set -e
[ "${DEBUG:-false}" == 'true' ] && set -x

# Load libraries
. /opt/keeper/scripts/liblog.sh

info "** MODX CLI install preparing... **";

install_config=$(cat "$HTML_ROOT/setup/config.dist.new.xml")

install_config=$(echo $install_config | sed "s/<database_server>localhost/<database_server>$MODX_DB_SERVER/g")
info "  Param: database_server";

install_config=$(echo $install_config | sed "s/<database>modx_modx/<database>$MARIADB_DATABASE/g")
info "  Param: database";

install_config=$(echo $install_config | sed "s/<database_user>db_username/<database_user>$MARIADB_USER/g")
info "  Param: database_user";

install_config=$(echo $install_config | sed "s/<database_password>db_password/<database_password>$MARIADB_PASSWORD/g")
info "  Param: database_password";

install_config=$(echo $install_config | sed "s/<database_connection_charset>utf8/<database_connection_charset>$MODX_DB_CONNECTION_CHARSET/g")
info "  Param: database_connection_charset";

install_config=$(echo $install_config | sed "s/<database_charset>utf8/<database_charset>$MODX_DB_CHARSET/g")
info "  Param: database_charset";

install_config=$(echo $install_config | sed "s/<database_collation>utf8_general_ci/<database_collation>$MODX_DB_CHARSET_COLLATION/g")
info "  Param: database_collation";

install_config=$(echo $install_config | sed "s/<table_prefix>modx_/<table_prefix>$MODX_TABLE_PREFIX/g")
info "  Param: table_prefix";

install_config=$(echo $install_config | sed "s/<https_port>443/<https_port>$MODX_HTTPS_PORT/g")
info "  Param: https_port";

install_config=$(echo $install_config | sed "s/<http_host>localhost/<http_host>$MODX_HTTP_HOST/g")
info "  Param: http_host";

install_config=$(echo $install_config | sed "s/<inplace>0/<inplace>1/g")
info "  Param: inplace";

install_config=$(echo $install_config | sed "s/<unpacked>0/<unpacked>1/g")
info "  Param: unpacked";

install_config=$(echo $install_config | sed "s/<language>en/<language>$MODX_LANGUAGE/g")
info "  Param: language";

install_config=$(echo $install_config | sed "s/<cmsadmin>username/<cmsadmin>$MODX_CMS_ADMIN/g")
info "  Param: cmsadmin";

install_config=$(echo $install_config | sed "s/<cmspassword>password/<cmspassword>$MODX_CMS_PASS/g")
info "  Param: cmspassword";

install_config=$(echo $install_config | sed "s/<cmsadminemail>email@address.com/<cmsadminemail>$MODX_CMS_EMAIL/g")
info "  Param: cmsadminemail";

install_config=$(echo $install_config | sed "s/<remove_setup_directory>1/<remove_setup_directory>$MODX_REMOVE_SETUP_DIRECTORY/g")
info "  Param: remove_setup_directory";

MODX_CONTEXT_CONNECTORS_PATH=$(echo $MODX_CONTEXT_CONNECTORS_PATH | sed "s/\//\\\\\//g")
install_config=$(echo $install_config | sed "s/<context_connectors_path>\/www\/modx\/connectors\//<context_connectors_path>$MODX_CONTEXT_CONNECTORS_PATH/g")
info "  Param: context_connectors_path";

MODX_CONTEXT_CONNECTORS_URL=$(echo $MODX_CONTEXT_CONNECTORS_URL | sed "s/\//\\\\\//g")
install_config=$(echo $install_config | sed "s/<context_connectors_url>\/modx\/connectors\//<context_connectors_url>$MODX_CONTEXT_CONNECTORS_URL/g")
info "  Param: context_connectors_url";

MODX_CONTEXT_MANAGER_PATH=$(echo $MODX_CONTEXT_MANAGER_PATH | sed "s/\//\\\\\//g")
install_config=$(echo $install_config | sed "s/<context_mgr_path>\/www\/modx\/manager\//<context_mgr_path>$MODX_CONTEXT_MANAGER_PATH/g")
info "  Param: context_mgr_path";

MODX_CONTEXT_MANAGER_URL=$(echo $MODX_CONTEXT_MANAGER_URL | sed "s/\//\\\\\//g")
install_config=$(echo $install_config | sed "s/<context_mgr_url>\/modx\/manager\//<context_mgr_url>$MODX_CONTEXT_MANAGER_URL/g")
info "  Param: context_mgr_url";

MODX_CONTEXT_WEB_PATH=$(echo $MODX_CONTEXT_WEB_PATH | sed "s/\//\\\\\//g")
install_config=$(echo $install_config | sed "s/<context_web_path>\/www\/modx\//<context_web_path>$MODX_CONTEXT_WEB_PATH/g")
info "  Param: context_web_path";

MODX_CONTEXT_WEB_URL=$(echo $MODX_CONTEXT_WEB_URL | sed "s/\//\\\\\//g")
install_config=$(echo $install_config | sed "s/<context_web_url>\/modx\//<context_web_url>$MODX_CONTEXT_WEB_URL/g")
info "  Param: context_web_url";

echo $install_config > $HTML_ROOT/setup/config.xml

info "** MODX CLI installation... **";
php $HTML_ROOT/setup/index.php --installmode=new